import 'package:flutter/material.dart';

class AyatCardButton extends StatelessWidget {
  const AyatCardButton({super.key, required this.icon, required this.onTap});
  final Widget icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 15,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: onTap,
          icon: icon,
        ));
  }
}
