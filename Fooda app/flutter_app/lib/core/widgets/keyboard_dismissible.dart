import 'package:flutter/material.dart';

/// 包裝器組件，使任何子組件都能通過點擊空白區域收起鍵盤
class KeyboardDismissible extends StatelessWidget {
  final Widget child;
  
  const KeyboardDismissible({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 收起鍵盤
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}