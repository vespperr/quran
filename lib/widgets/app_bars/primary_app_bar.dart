import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Function()? onPressed;
  final double? bottomHeight;
  final double? elevation;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.onPressed,
    this.bottomHeight,
    this.elevation,
  })  : preferredSize = const Size.fromHeight(75.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      centerTitle: true,
      backgroundColor: context.theme.appBarTheme.backgroundColor,
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(
          title,
          style: context.theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      leading: leading,
      actions: actions,
      automaticallyImplyLeading: false,
    );
  }
}
