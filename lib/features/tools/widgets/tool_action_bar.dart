import 'package:material_ui/material_ui.dart';
import 'package:velin/app/theme/theme.dart';
import 'package:velin/features/tools/bloc/tool_task_runner.dart';
import 'package:velin/shared/extensions/extensions.dart';

class ToolActionBar extends StatelessWidget {
  const ToolActionBar({
    super.key,
    required this.isSubmitting,
    required this.submittingText,
    required this.canAction,
    required this.icon,
    required this.label,
    required this.hintText,
    required this.onAction,
    this.task,
  });

  final bool isSubmitting;
  final String submittingText;
  final IconData icon;
  final String label;
  final String hintText;

  final bool canAction;
  final VoidCallback onAction;

  /// The running task, for progress and cancellation. Without it the bar
  /// shows an indeterminate spinner while [isSubmitting].
  final ToolTaskHandle? task;

  @override
  Widget build(BuildContext context) {
    if (isSubmitting) {
      final task = this.task;

      if (task == null) {
        return Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(submittingText),
          ),
        );
      }

      return ValueListenableBuilder<ToolTaskStatus>(
        valueListenable: task.status,
        builder: (context, status, _) => _TaskProgressBar(
          status: status,
          runningText: submittingText,
          onCancel: task.cancel,
        ),
      );
    }

    final button = canAction
        ? FilledButton.icon(
            onPressed: onAction,
            icon: Icon(icon, size: 18),
            label: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onAction,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );

    return Align(
      alignment: Alignment.centerRight,
      child: Tooltip(message: canAction ? '' : hintText, child: button),
    );
  }
}

class _TaskProgressBar extends StatelessWidget {
  const _TaskProgressBar({
    required this.status,
    required this.runningText,
    required this.onCancel,
  });

  final ToolTaskStatus status;
  final String runningText;
  final VoidCallback onCancel;

  static const _width = 320.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final progress = status.progress;

    final text = switch (status.phase) {
      ToolTaskPhase.queued => l10n.toolsTaskQueued,
      ToolTaskPhase.cancelling => l10n.toolsTaskCancelling,
      ToolTaskPhase.running when progress != null =>
        '$runningText · ${l10n.toolsTaskProgress((progress * 100).round())}',
      ToolTaskPhase.running || ToolTaskPhase.idle => runningText,
    };

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  child: LinearProgressIndicator(
                    // Indeterminate until the engine reports progress.
                    value: status.phase == ToolTaskPhase.running
                        ? progress
                        : null,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          OutlinedButton(
            onPressed: status.canCancel ? onCancel : null,
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
  }
}
