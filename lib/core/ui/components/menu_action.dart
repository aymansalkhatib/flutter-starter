import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/generated/locale_keys.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../extensions/index.dart';

class MenuAction {
  const MenuAction({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String title;

  /// Any widget: SVG, Image.asset, Icon, etc.
  final Widget icon;

  final Color? iconColor;
  final VoidCallback onTap;
}

/// A three-dot popup menu button driven by a list of [MenuAction]s.
class MenuActionWidget extends StatelessWidget {
  const MenuActionWidget({
    super.key,
    required this.actions,
    this.onMenuOpened,
  });

  final List<MenuAction> actions;
  final VoidCallback? onMenuOpened;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Skeleton.replace(
      replacement: const Skeleton.leaf(child: CircleAvatar(radius: 9)),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: PopupMenuButton<int>(
          offset: const Offset(-20, 10),
          color: colors.surface,
          tooltip: LocaleKeys.moreOptions.tr(context),
          onOpened: () {
            context.unfocus();
            onMenuOpened?.call();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colors.hintTextColor.withValues(alpha: 0.1),
            ),
          ),
          itemBuilder: (context) => [
            for (int i = 0; i < actions.length; i++)
              _buildItem(context, actions[i], i),
          ],
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: Icon(
              CupertinoIcons.ellipsis_vertical,
              color: colors.primary,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<int> _buildItem(
    BuildContext context,
    MenuAction action,
    int index,
  ) {
    final colors = context.colors;

    return PopupMenuItem<int>(
      value: index,
      onTap: action.onTap,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                color: action.iconColor ?? colors.primary,
                size: 18,
              ),
              child: action.icon,
            ),
            const SizedBox(width: 12),
            Text(
              action.title,
              style: context.styles.semiBold14.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
