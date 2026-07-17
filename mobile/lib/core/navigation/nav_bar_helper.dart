import 'package:flutter/material.dart';

class NavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class NavBarHelper {
  NavBarHelper._();

  static const List<NavBarItem> items = [
    NavBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Ana Sayfa',
    ),
    NavBarItem(icon: Icons.search, activeIcon: Icons.search, label: 'Arama'),
    NavBarItem(
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner,
      label: 'Puanlama',
    ),
    NavBarItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Ayarlar',
    ),
  ];
}
