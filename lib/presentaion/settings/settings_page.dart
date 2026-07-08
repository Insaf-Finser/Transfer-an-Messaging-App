import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('End-to-end encryption'),
            subtitle: Text('Messages are encrypted on your device'),
            trailing: Icon(Icons.check_circle, color: Colors.green),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            subtitle: Text('Coming soon'),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined),
            title: Text('Privacy'),
            subtitle: Text('Coming soon'),
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About Transfer'),
            subtitle: Text('Secure messaging v1.0.0'),
          ),
        ],
      ),
    );
  }
}
