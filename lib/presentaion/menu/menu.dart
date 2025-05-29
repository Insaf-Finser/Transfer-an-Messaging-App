import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  static const List<_MenuItem> _menuItems = [
    _MenuItem(icon: Icons.chat, label: '', route: '/chats'),
    _MenuItem(icon: Icons.group, label: '', route: '/groups'),
    _MenuItem(icon:Icons.add , label: '', route: '/new_chat'),
    _MenuItem(icon: Icons.settings, label: '', route: '/settings'),
    _MenuItem(icon: Icons.person, label: '', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: Center(
        child: Text(
          'Select a menu item using the navigation bar below.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _menuItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
        onTap: (index) {
          Navigator.pushNamed(context, _menuItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String route;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}