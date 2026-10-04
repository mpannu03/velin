import 'package:material_ui/material_ui.dart';

import 'package:velin/app/theme/theme.dart';
import 'package:velin/engine/engine.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class AddWatermarkDesktopLayout extends StatelessWidget {
  const AddWatermarkDesktopLayout({
    super.key,
    required this.viewModel,
  });

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasInputFile = viewModel.inputFilePath != null &&
        viewModel.inputFilePath!.trim().isNotEmpty;

    return ToolScaffold(
      title: l10n.toolsWatermark,
      description: l10n.toolsWatermarkIntro,
      onBack: viewModel.onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSectionCard(
            title: l10n.toolsWatermarkSourceSectionTitle,
            child: SingleFilePicker(
              filePath: viewModel.inputFilePath,
              emptyStateDescription: l10n.toolsWatermarkSourceDescription,
              onPickFile: viewModel.onPickFile,
            ),
          ),
          if (hasInputFile) ...[
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkTypeSectionTitle,
              child: _WatermarkContentEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkStyleSectionTitle,
              child: _StyleEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            ToolSectionCard(
              title: l10n.toolsWatermarkPagesSectionTitle,
              child: _PageScopeEditor(viewModel: viewModel),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutputFilePicker(
              fileName: viewModel.outputFileName,
              directoryPath: viewModel.outputDirectory,
              onFileNameChanged: viewModel.onOutputFileNameChanged,
              onChooseFolder: viewModel.onChooseOutputFolder,
            ),
            const SizedBox(height: AppSpacing.xl),
            ToolActionBar(
              isSubmitting: viewModel.isSubmitting,
              submittingText: l10n.toolsWatermarkSubmitting,
              canAction: viewModel.canApplyWatermark,
              icon: Icons.water_outlined,
              label: l10n.toolsWatermarkButton,
              hintText: l10n.toolsWatermarkButtonDisabledHint,
              onAction: viewModel.onApplyWatermark,
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

/// A labelled slider with a live readout on the right, matching the quality
/// slider used by the other PDF tools.
class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.sliderKey,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;

  /// Text shown at the end of the slider row.
  final String displayValue;

  final Key sliderKey;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label),
        ),
        Expanded(
          child: Slider(
            key: sliderKey,
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: displayValue,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 56,
          child: Text(
            displayValue,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _WatermarkContentEditor extends StatelessWidget {
  const _WatermarkContentEditor({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WatermarkType>(
          key: const ValueKey('add-watermark-type'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkType.text,
              icon: const Icon(Icons.text_fields, size: 18),
              label: Text(l10n.toolsWatermarkTypeText),
            ),
            ButtonSegment(
              value: WatermarkType.image,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(l10n.toolsWatermarkTypeImage),
            ),
          ],
          selected: {viewModel.type},
          onSelectionChanged: (selection) =>
              viewModel.onTypeChanged(selection.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (viewModel.type == WatermarkType.text)
          _TextWatermarkEditor(viewModel: viewModel)
        else
          _ImageWatermarkEditor(viewModel: viewModel),
      ],
    );
  }
}

class _TextWatermarkEditor extends StatelessWidget {
  const _TextWatermarkEditor({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey('add-watermark-text'),
          controller: TextEditingController(text: viewModel.text),
          onChanged: viewModel.onTextChanged,
          decoration: InputDecoration(
            labelText: l10n.toolsWatermarkTextLabel,
            hintText: l10n.toolsWatermarkTextHint,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Text(l10n.toolsWatermarkFontLabel),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _FontDropdown(viewModel: viewModel),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _LabeledSlider(
          label: l10n.toolsWatermarkFontSizeLabel,
          value: viewModel.fontSize,
          min: AddWatermarkToolInput.minFontSize.toDouble(),
          max: AddWatermarkToolInput.maxFontSize.toDouble(),
          divisions:
              AddWatermarkToolInput.maxFontSize -
              AddWatermarkToolInput.minFontSize,
          displayValue: viewModel.fontSize.round().toString(),
          sliderKey: const ValueKey('add-watermark-font-size'),
          onChanged: viewModel.onFontSizeChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        _ColorPicker(viewModel: viewModel),
      ],
    );
  }
}

class _FontDropdown extends StatelessWidget {
  const _FontDropdown({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DropdownButtonFormField<String?>(
      key: const ValueKey('add-watermark-font'),
      initialValue: viewModel.fontName,
      isDense: true,
      decoration: InputDecoration(
        labelText: l10n.toolsWatermarkFontLabel,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final font in AddWatermarkToolInput.supportedFonts)
          DropdownMenuItem<String?>(
            value: font,
            child: Text(font ?? l10n.toolsWatermarkFontDefault),
          ),
      ],
      onChanged: viewModel.onFontNameChanged,
    );
  }
}

/// One-tap swatches plus a free-form `#RRGGBB` field.
class _ColorPicker extends StatefulWidget {
  const _ColorPicker({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.colorHex);
  }

  @override
  void didUpdateWidget(_ColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // The state is the source of truth: a rejected hex is not echoed back
    // into the field, so only push when the two actually diverge.
    if (widget.viewModel.colorHex != _controller.text) {
      _controller.text = widget.viewModel.colorHex;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _commit(String value) {
    widget.viewModel.onColorHexChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentHex = widget.viewModel.colorHex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.toolsWatermarkColorLabel),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final hex in AddWatermarkToolInput.commonColors)
              _ColorSwatch(
                hex: hex,
                isSelected:
                    hex.toUpperCase() == normalizeHexColor(currentHex),
                onTap: () => _commit(hex),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _colorFromHex(currentHex),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                Icons.colorize,
                size: 18,
                color: _contrastColorFor(currentHex),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: TextField(
                key: const ValueKey('add-watermark-color-hex'),
                controller: _controller,
                onSubmitted: _commit,
                onTapOutside: (_) => _commit(_controller.text),
                decoration: InputDecoration(
                  labelText: l10n.toolsWatermarkColorLabel,
                  hintText: l10n.toolsWatermarkColorHint,
                  prefixText: '#',
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.hex,
    required this.isSelected,
    required this.onTap,
  });

  final String hex;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: hex,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _colorFromHex(hex),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected ? colors.primary : colors.outlineVariant,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: _contrastColorFor(hex),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Parses `#RRGGBB`, falling back to the theme surface when the value is not
/// a color the engine would accept.
Color _colorFromHex(String hex) {
  if (!AddWatermarkToolInput.colorHexPattern.hasMatch(hex.trim())) {
    return Colors.transparent;
  }

  final rgb = int.tryParse(
    hex.trim().replaceFirst('#', ''),
    radix: 16,
  );

  if (rgb == null) {
    return Colors.transparent;
  }

  return Color(0xff000000 | rgb);
}

/// Picks black or white so the checkmark and eyedropper stay readable.
Color _contrastColorFor(String hex) {
  return _colorFromHex(hex).computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}

class _ImageWatermarkEditor extends StatelessWidget {
  const _ImageWatermarkEditor({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final imageFilePath = viewModel.imageFilePath;
    final hasImage = imageFilePath != null && imageFilePath.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          _SelectedImageRow(
            filePath: imageFilePath,
            onReplace: viewModel.onPickWatermarkImage,
            onRemove: viewModel.onClearWatermarkImage,
          )
        else
          _ImageEmptyState(onPickImage: viewModel.onPickWatermarkImage),
        const SizedBox(height: AppSpacing.lg),
        _LabeledSlider(
          label: l10n.toolsWatermarkImageWidthLabel,
          value: viewModel.imageWidthPercent,
          min: AddWatermarkToolInput.minImageWidthPercent,
          max: AddWatermarkToolInput.maxImageWidthPercent,
          divisions: 19,
          displayValue: '${viewModel.imageWidthPercent.round()}%',
          sliderKey: const ValueKey('add-watermark-image-width'),
          onChanged: viewModel.onImageWidthPercentChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsWatermarkImageWidthHelper),
      ],
    );
  }
}

class _SelectedImageRow extends StatelessWidget {
  const _SelectedImageRow({
    required this.filePath,
    required this.onReplace,
    required this.onRemove,
  });

  final String filePath;
  final VoidCallback onReplace;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final fileName = filePath.split(RegExp(r'[/\\]')).last;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: ImageFileThumbnail(filePath: filePath),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onReplace,
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: Text(l10n.toolsWatermarkImageReplace),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.toolsWatermarkImageRemove),
          ),
        ],
      ),
    );
  }
}

class _ImageEmptyState extends StatelessWidget {
  const _ImageEmptyState({required this.onPickImage});

  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 26,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.toolsWatermarkImageDescription,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const ValueKey('add-watermark-pick-image'),
            onPressed: onPickImage,
            icon: const Icon(Icons.add, size: 18),
            label: Text(l10n.toolsWatermarkImageChoose),
          ),
        ],
      ),
    );
  }
}

/// Opacity, rotation, position, offsets and layer. Everything here applies to
/// both text and image watermarks.
class _StyleEditor extends StatelessWidget {
  const _StyleEditor({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LabeledSlider(
          label: l10n.toolsWatermarkOpacityLabel,
          value: viewModel.opacity,
          min: AddWatermarkToolInput.minOpacity,
          max: AddWatermarkToolInput.maxOpacity,
          divisions: 19,
          displayValue: '${(viewModel.opacity * 100).round()}%',
          sliderKey: const ValueKey('add-watermark-opacity'),
          onChanged: viewModel.onOpacityChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabeledSlider(
          label: l10n.toolsWatermarkRotationLabel,
          value: viewModel.rotation,
          min: AddWatermarkToolInput.minRotation,
          max: AddWatermarkToolInput.maxRotation,
          divisions: 72,
          displayValue: '${viewModel.rotation.round()}\u00b0',
          sliderKey: const ValueKey('add-watermark-rotation'),
          onChanged: viewModel.onRotationChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsWatermarkRotationHelper),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.toolsWatermarkPositionLabel),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final entry in _positionEntries(context))
              ChoiceChip(
                label: Text(entry.label),
                selected: viewModel.position == entry.position,
                onSelected: (_) =>
                    viewModel.onPositionChanged(entry.position),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _LabeledSlider(
          label: l10n.toolsWatermarkOffsetXLabel,
          value: viewModel.xOffset,
          min: AddWatermarkToolInput.minOffset,
          max: AddWatermarkToolInput.maxOffset,
          divisions: 60,
          displayValue: viewModel.xOffset.round().toString(),
          sliderKey: const ValueKey('add-watermark-offset-x'),
          onChanged: viewModel.onXOffsetChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _LabeledSlider(
          label: l10n.toolsWatermarkOffsetYLabel,
          value: viewModel.yOffset,
          min: AddWatermarkToolInput.minOffset,
          max: AddWatermarkToolInput.maxOffset,
          divisions: 60,
          displayValue: viewModel.yOffset.round().toString(),
          sliderKey: const ValueKey('add-watermark-offset-y'),
          onChanged: viewModel.onYOffsetChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _HelperText(l10n.toolsWatermarkOffsetHelper),
        const SizedBox(height: AppSpacing.lg),
        Text(l10n.toolsWatermarkLayerLabel),
        const SizedBox(height: AppSpacing.sm),
        SegmentedButton<WatermarkLayer>(
          key: const ValueKey('add-watermark-layer'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkLayer.foreground,
              icon: const Icon(Icons.layers_outlined, size: 18),
              label: Text(l10n.toolsWatermarkLayerForeground),
            ),
            ButtonSegment(
              value: WatermarkLayer.background,
              icon: const Icon(Icons.layers_clear_outlined, size: 18),
              label: Text(l10n.toolsWatermarkLayerBackground),
            ),
          ],
          selected: {viewModel.layer},
          onSelectionChanged: (selection) =>
              viewModel.onLayerChanged(selection.first),
        ),
      ],
    );
  }
}

/// Localized labels for every [WatermarkPosition], in enum order.
List<({WatermarkPosition position, String label})> _positionEntries(
  BuildContext context,
) {
  final l10n = context.l10n;

  return [
    (
      position: WatermarkPosition.center,
      label: l10n.toolsWatermarkPositionCenter,
    ),
    (
      position: WatermarkPosition.topLeft,
      label: l10n.toolsWatermarkPositionTopLeft,
    ),
    (
      position: WatermarkPosition.topRight,
      label: l10n.toolsWatermarkPositionTopRight,
    ),
    (
      position: WatermarkPosition.bottomLeft,
      label: l10n.toolsWatermarkPositionBottomLeft,
    ),
    (
      position: WatermarkPosition.bottomRight,
      label: l10n.toolsWatermarkPositionBottomRight,
    ),
  ];
}

class _PageScopeEditor extends StatelessWidget {
  const _PageScopeEditor({required this.viewModel});

  final AddWatermarkViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<WatermarkPageScope>(
          key: const ValueKey('add-watermark-scope'),
          showSelectedIcon: true,
          segments: [
            ButtonSegment(
              value: WatermarkPageScope.allPages,
              icon: const Icon(Icons.auto_stories_outlined, size: 18),
              label: Text(l10n.toolsWatermarkScopeAll),
            ),
            ButtonSegment(
              value: WatermarkPageScope.selectedPages,
              icon: const Icon(Icons.tune_outlined, size: 18),
              label: Text(l10n.toolsWatermarkScopeSelected),
            ),
          ],
          selected: {viewModel.scope},
          onSelectionChanged: (selection) =>
              viewModel.onScopeChanged(selection.first),
        ),
        if (viewModel.scope.requiresSelection) ...[
          const SizedBox(height: AppSpacing.lg),
          PageSelectionField(
            value: viewModel.selection,
            fieldKey: const ValueKey('add-watermark-page-selection'),
            width: 260,
            hintText: l10n.toolsWatermarkSelectionHint,
            onChanged: viewModel.onSelectionChanged,
          ),
          const SizedBox(height: AppSpacing.sm),
          _HelperText(l10n.toolsWatermarkSelectionHelper),
        ],
      ],
    );
  }
}
