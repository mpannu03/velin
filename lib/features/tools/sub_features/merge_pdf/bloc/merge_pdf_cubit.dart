import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:velin/core/file/file_picker.dart';
import 'package:velin/core/result/result.dart';
import 'package:velin/core/task/task.dart';
import 'package:velin/engine/engine.dart';

import 'merge_pdf_input.dart';
import 'merge_pdf_state.dart';

class MergePdfCubit extends Cubit<MergePdfState> {
  MergePdfCubit({
    required this._filePicker, 
    required this._mergePdfEngine,
    required this._taskManager,
  }) : super(const MergePdfInitial());

  final DocumentFilePicker _filePicker;
  final MergePdfEngine _mergePdfEngine;
  final TaskManager _taskManager;

  void started() {
    emit(const MergePdfReady());
  }

  Future<void> pickFiles() async {
    final result = await _filePicker.pickFiles(
      allowedExtensions: ['pdf'],
    );

    switch (result) {
      case Success(data: final filePaths):
        final current = _readyState;

        emit(
          current.copyWith(
            inputs: [
              ...current.inputs,
              for (final filePath in filePaths)
                MergePdfToolInput(filePath: filePath),
            ],
          ),
        );

      case Failure(error: final error):
        emit(MergePdfError(error));
    }
  }

  void removeFile(int index) {
    final current = _readyState;
    final inputs = [...current.inputs]..removeAt(index);

    emit(
      current.copyWith(
        inputs: inputs,
      ),
    );
  }

  void reorderFiles(int oldIndex, int newIndex) {
    final current = _readyState;
    final inputs = [...current.inputs];

    if (newIndex > oldIndex) {
      newIndex--;
    }

    final input = inputs.removeAt(oldIndex);
    inputs.insert(newIndex, input);

    emit(
      current.copyWith(
        inputs: inputs,
      ),
    );
  }

  void updatePageSelection(
    int index,
    String value,
  ) {
    final current = _readyState;
    final inputs = [...current.inputs];

    inputs[index] = inputs[index].copyWith(
      pageSelection: value,
    );

    emit(
      current.copyWith(
        inputs: inputs,
      ),
    );
  }

  void updateOutputFileName(String value) {
    emit(
      _readyState.copyWith(
        outputFileName: value,
      ),
    );
  }

  Future<void> pickOutputDirectory() async {
    final result = await _filePicker.pickDirectory();

    switch (result) {
      case Success(data: final directoryPath):
        emit(
          _readyState.copyWith(
            outputDirectory: directoryPath,
          ),
        );

      case Failure(error: final error):
        emit(MergePdfError(error));
    }
  }

  void merge() {
    final current = _readyState;

    if (current.inputs.isEmpty) {
      return;
    }

    final outputDirectory = current.outputDirectory;

    if (outputDirectory == null || outputDirectory.isEmpty) {
      return;
    }

    final outputFile = File(
      '$outputDirectory${Platform.pathSeparator}${current.outputFileName}',
    );

    _taskManager.submit(
      id: 'merge-pdf-${DateTime.now().microsecondsSinceEpoch}',
      title: 'Merge PDF',
      operation: () async {
        await _mergePdfEngine.merge(
          inputs: [
            for (final input in current.inputs) input.toPdfInput(),
          ],
          outputFile: outputFile,
        );
      },
    );

    emit(const MergePdfReady());
  }


  MergePdfReady get _readyState {
    final current = state;

    if (current is MergePdfReady) {
      return current;
    }

    throw StateError(
      'MergePdfCubit has not been started.',
    );
  }
}