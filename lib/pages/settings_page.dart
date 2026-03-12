import 'package:flutter/material.dart';
import 'package:gleisguru/services/settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final ip = await SettingsService.getIp();
    final port = await SettingsService.getPort();

    _ipController.text = ip;
    _portController.text = port;
  }

  Future<void> _save() async {
    final ip = _ipController.text.trim();
    final port = _portController.text.trim();

    if (ip.isEmpty || port.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("IP und Port eingeben")),
      );
      return;
    }

    setState(() => _saving = true);

    await SettingsService.saveIp(ip);
    await SettingsService.savePort(port);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Einstellungen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: "IP Adresse",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: "Port",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text("Speichern"),
              ),
            )
          ],
        ),
      ),
    );
  }
}