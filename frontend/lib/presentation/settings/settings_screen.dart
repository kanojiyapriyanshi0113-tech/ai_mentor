import "package:flutter/material.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text("Notifications", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Push Notifications"),
              subtitle: const Text("Get notified about live classes and updates"),
              value: _pushNotifications,
              onChanged: (v) => setState(() => _pushNotifications = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Email Updates"),
              subtitle: const Text("Receive weekly progress summaries"),
              value: _emailUpdates,
              onChanged: (v) => setState(() => _emailUpdates = v),
            ),
            const SizedBox(height: 16),
            Text("Appearance", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Dark Mode"),
              subtitle: const Text("Coming soon"),
              value: _darkMode,
              onChanged: null,
            ),
            const SizedBox(height: 16),
            Text("About", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("App Version"),
              trailing: Text("1.0.0", style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}
