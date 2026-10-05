import 'package:material_ui/material_ui.dart';
import 'package:velin/features/tools/tools.dart';
import 'package:velin/shared/extensions/extensions.dart';

class DirectionSelector extends StatelessWidget {
  const DirectionSelector({
    super.key,
    required this.direction,
    required this.onDirectionChanged,
  });

  final RotatePdfDirection direction;
  final ValueChanged<RotatePdfDirection> onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RotatePdfDirection>(
      showSelectedIcon: true,
      segments: [
        for (final direction in RotatePdfDirection.values)
          ButtonSegment(
            value: direction,
            icon: Icon(_iconFor(direction), size: 18),
            label: Text(_labelFor(context, direction)),
          ),
      ],
      selected: {direction},
      onSelectionChanged: (selection) {
        onDirectionChanged(selection.first);
      },
    );
  }

  String _labelFor(BuildContext context, RotatePdfDirection direction) {
    final l10n = context.l10n;

    return switch (direction) {
      RotatePdfDirection.clockwise90 => l10n.toolsRotateDirection90,
      RotatePdfDirection.upsideDown => l10n.toolsRotateDirection180,
      RotatePdfDirection.counterClockwise90 => l10n.toolsRotateDirection270,
    };
  }

  IconData _iconFor(RotatePdfDirection direction) {
    return switch (direction) {
      RotatePdfDirection.clockwise90 => Icons.rotate_90_degrees_cw,
      RotatePdfDirection.upsideDown => Icons.flip,
      RotatePdfDirection.counterClockwise90 => Icons.rotate_90_degrees_ccw,
    };
  }
}