import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _ipKey = 'api_ip';
  static const _portKey = 'api_port';

  static Future<String> getIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ipKey) ?? '192.168.4.1';
  }

  static Future<String> getPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_portKey) ?? '5000';
  }

  static Future<void> saveIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
  }

  static Future<void> savePort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_portKey, port);
  }

  static Future<String> getBaseUrl() async {
    final ip = await getIp();
    final port = await getPort();

    return 'http://$ip:$port/api';
  }
}