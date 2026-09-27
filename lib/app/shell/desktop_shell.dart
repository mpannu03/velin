import 'package:flutter/material.dart';

import 'package:velin/shared/widgets/widgets.dart';

import 'widgets/widgets.dart';

class DesktopShell extends StatelessWidget {
  const DesktopShell({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Velin',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              VelinMenuButton(
                label: 'File',
                onPressed: () {},
              ),
              VelinMenuButton(
                label: 'Edit',
                onPressed: () {},
              ),
              VelinMenuButton(
                label: 'View',
                onPressed: () {},
              ),
              const Spacer(),
              const VelinWindowControls(),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(child: child),
      ],
    );
  }
}