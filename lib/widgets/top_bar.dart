import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final bool showLogo;
  final bool showBell;
  final VoidCallback? onPlus;
  final VoidCallback? onSwitchRole;

  const TopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.showLogo = false,
    this.showBell = false,
    this.onPlus,
    this.onSwitchRole,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          if (showBack)
            _iconButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.of(context).maybePop(),
            )
          else if (showLogo)
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('B',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17)),
            ),
          if (showBack || showLogo) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16.5,
                      color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (showBell)
            Stack(
              clipBehavior: Clip.none,
              children: [
                _iconButton(icon: Icons.notifications_none, onTap: () {}),
                Positioned(
                  top: 8,
                  right: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        color: Color(0xFFE8890C), shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          if (onPlus != null) _iconButton(icon: Icons.add, onTap: onPlus, filled: true),
          if (onSwitchRole != null)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _iconButton(icon: Icons.swap_horiz, onTap: onSwitchRole),
            ),
        ],
      ),
    );
  }

  Widget _iconButton({required IconData icon, VoidCallback? onTap, bool filled = false}) {
    return Material(
      color: filled ? AppColors.primary : const Color(0xFFF1F4F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: filled ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );
  }
}
