import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class PdfToImageDesktopLayout extends StatelessWidget {
  const PdfToImageDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile = viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsPdfToImage,
      description: l10n.toolsPdfToImageIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsPdfToImageSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageFormatSectionTitle,
              child: _FormatSelector(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageColorSectionTitle,
              child: _ColorModeSelector(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImageResolutionSectionTitle,
              child: _ResolutionEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsPdfToImagePagesSectionTitle,
              child: _PageScopeEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutputFilePicker(
              fileName: '',
              directoryPath: viewModel.outputDirectory,
              showFileName: false,
              onFileNameChanged: (_) {},
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: AppSpacing.xl),
            ToolActionBar(
              isSubmitting: viewModel.isSubmitting,
              submittingText: l10n.toolsPdfToImageSubmitting,
              canAction: viewModel.canConvert,
              icon: Icons.image_outlined,
              label: l10n.toolsPdfToImageButton,
              hintText: l10n.toolsPdfToImageButtonDisabledHint,
              onAction: viewModel.onConvert,
            ),
          ],
        ],
      ),
    );
  }
}

class _HelperText extends StatelessWidget {
  const _HelperText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _FormatSelector extends StatelessWidget {
  const _FormatSelector({required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PdfImageFormat>(
          showSelectedIcon: true,
          segments: [
            for (final format in PdfImageFormat.values)
              ButtonSegment(
                value: format,
                icon: Icon(_iconFor(format), size: 18),
                label: Text(_labelFor(context, format)),
              ),
          ],
          selected: {viewModel.format},
          onSelectionChanged: (selection) {
            viewModel.onFormatChanged(selection.first);
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(context.l10n.toolsPdfToImageFormatHelper),
      ],
    );
  }

  String _labelFor(BuildContext context, PdfImageFormat format) {
    final l10n = context.l10n;

    return switch (format) {
      PdfImageFormat.png => l10n.toolsPdfToImageFormatPng,
      PdfImageFormat.jpeg => l10n.toolsPdfToImageFormatJpeg,
      PdfImageFormat.webp => l10n.toolsPdfToImageFormatWebp,
    };
  }

  IconData _iconFor(PdfImageFormat format) {
    return switch (format) {
      PdfImageFormat.png => Icons.image_outlined,
      PdfImageFormat.jpeg => Icons.photo_outlined,
      PdfImageFormat.webp => Icons.data_object,
    };
  }
}

class _ColorModeSelector extends StatelessWidget {
  const _ColorModeSelector({required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SegmentedButton<PdfImageColorMode>(
      showSelectedIcon: true,
      segments: [
        ButtonSegment(
          value: PdfImageColorMode.color,
          icon: const Icon(Icons.palette_outlined, size: 18),
          label: Text(l10n.toolsPdfToImageColorModeColor),
        ),
        ButtonSegment(
          value: PdfImageColorMode.grayscale,
          icon: const Icon(Icons.gradient_outlined, size: 18),
          label: Text(l10n.toolsPdfToImageColorModeGreyscale),
        ),
      ],
      selected: {viewModel.colorMode},
      onSelectionChanged: (selection) {
        viewModel.onColorModeChanged(selection.first);
      },
    );
  }
}

class _ResolutionEditor extends StatelessWidget {
  const _ResolutionEditor({required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsPdfToImageDpiLabel),
            const SizedBox(width: AppSpacing.md),
            DropdownButton<int>(
              key: const ValueKey('pdf-to-image-dpi'),
              value: viewModel.dpi,
              onChanged: (value) {
                if (value != null) {
                  viewModel.onDpiChanged(value);
                }
              },
              items: [
                for (final dpi in PdfToImageToolInput.supportedDpi)
                  DropdownMenuItem(
                    value: dpi,
                    child: Text('$dpi DPI'),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsPdfToImageDpiHelper),
        const SizedBox(height: AppSpacing.lg),
        _QualityEditor(viewModel: viewModel),
      ],
    );
  }
}

class _QualityEditor extends StatelessWidget {
  const _QualityEditor({required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    // PNG is lossless: the setting has no effect, so it stays disabled.
    if (!viewModel.supportsQuality) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.toolsPdfToImageQualityLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Opacity(
                  opacity: 0.5,
                  child: Slider(
                    key: const ValueKey('pdf-to-image-quality'),
                    value: viewModel.quality.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${viewModel.quality}',
                    onChanged: null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _HelperText(l10n.toolsPdfToImageQualityHelper),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.toolsPdfToImageQualityLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Slider(
                key: const ValueKey('pdf-to-image-quality'),
                value: viewModel.quality.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: '${viewModel.quality}',
                onChanged: (value) =>
                    viewModel.onQualityChanged(value.round()),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${viewModel.quality}',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsPdfToImageQualityHelper),
      ],
    );
  }
}

class _PageScopeEditor extends StatelessWidget {
  const _PageScopeEditor({required this.viewModel});

  final PdfToImageViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PdfToImagePageScope>(
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: PdfToImagePageScope.allPages,
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: Text(l10n.toolsPdfToImageScopeAll),
            ),
            ButtonSegment(
              value: PdfToImagePageScope.selectedPages,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.toolsPdfToImageScopeSelected),
            ),
          ],
          selected: {viewModel.scope},
          onSelectionChanged: (selection) {
            viewModel.onScopeChanged(selection.first);
          },
        ),
        if (viewModel.scope.requiresSelection) ...[
          const SizedBox(height: AppSpacing.lg),
          PageSelectionField(
            value: viewModel.selection,
            fieldKey: const ValueKey('pdf-to-image-page-selection'),
            width: 260,
            hintText: l10n.toolsPdfToImageSelectionHint,
            onChanged: viewModel.onSelectionChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HelperText(l10n.toolsPdfToImageSelectionHelper),
        ],
      ],
    );
  }
}