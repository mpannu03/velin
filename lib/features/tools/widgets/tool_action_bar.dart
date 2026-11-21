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
        return FilledButton.icon(
          onPressed: null,
          style: _fullWidth,
          icon: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          label: Text(submittingText),
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

    // Stays a filled button when it cannot run yet: pressing it shows why
    // (the hint) rather than silently doing nothing.
    final button = FilledButton.icon(
      onPressed: onAction,
      style: canAction ? _fullWidth : _fullWidthMuted(context),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );

    return Tooltip(message: canAction ? '' : hintText, child: button);
  }

  static final _fullWidth = FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(40),
  );

  static ButtonStyle _fullWidthMuted(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(40),
      backgroundColor: colors.surfaceContainerHighest,
      foregroundColor: colors.onSurfaceVariant,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.xs),
          child: LinearProgressIndicator(
            // Indeterminate until the engine reports progress.
            value: status.phase == ToolTaskPhase.running ? progress : null,
            minHeight: 4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: status.canCancel ? onCancel : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(40),
          ),
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}
