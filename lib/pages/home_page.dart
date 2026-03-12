import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gleisguru/models/api.dart';
import 'package:gleisguru/services/api_service.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  ApiData? _data;
  Timer? _timer;
  bool _connectionLost = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final result = await _apiService.getData();
      if (!mounted) return;

      setState(() {
        _data = result;
        _connectionLost = false;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connectionLost = true;
        _loading = false;
      });
    }
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );

    if (changed == true) {
      await _loadData();
    }
  }

  Future<void> _resetValue(String key) async {
    try {
      await _apiService.resetValue(key);
      await _loadData();
    } catch (_) {
      if (!mounted) return;
      _showError('Reset fehlgeschlagen');
    }
  }

  Future<void> _resetAll() async {
    try {
      await _apiService.resetAll();
      await _loadData();
    } catch (_) {
      if (!mounted) return;
      _showError('Reset All fehlgeschlagen');
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _formatValue(double? value, int decimals) {
    if (value == null) return '-----';
    return value.toStringAsFixed(decimals);
  }

  String _formatDistanceValue(double? meters) {
    if (meters == null) return '-----';
    if (meters >= 1000) {
      return (meters / 1000).toStringAsFixed(2);
    }
    return meters.toStringAsFixed(2);
  }

  String _distanceUnit(double? meters) {
    if (meters == null) return 'm';
    return meters >= 1000 ? 'km' : 'm';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distanceUnit = _distanceUnit(_data?.distance);

    final items = [
      _DataItem('Modellgeschwindigkeit [cm/s]', _formatValue(_data?.vMod, 1)),
      _DataItem('Realgeschwindigkeit [km/h]', _formatValue(_data?.vReal, 1)),
      _DataItem('Maximalgeschwindigkeit [km/h]', _formatValue(_data?.vMax, 1),
          resetKey: 'v_max'),
      _DataItem('Durchschnitt [km/h]', _formatValue(_data?.vAverage, 1),
          resetKey: 'v_average'),
      _DataItem('Strecke [$distanceUnit]', _formatDistanceValue(_data?.distance),
          resetKey: 'distance'),
      _DataItem('Steigung [%]', _formatValue(_data?.slopePct, 0)),
      _DataItem('Neigung [°]', _formatValue(_data?.inclinationDeg, 0)),
      _DataItem('Temperatur [°C]', _formatValue(_data?.temperatureC, 1)),
      _DataItem('Luftdruck [hPa]', _formatValue(_data?.pressureHpa, 1)),
      _DataItem('Feuchte [%]', _formatValue(_data?.humidityPct, 1)),
      _DataItem('Schienenspannung [V]', _formatValue(_data?.voltage, 2)),
      _DataItem('Akkustand [%]', _formatValue(_data?.batteryPercent, 0)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gleis-Guru'),
        actions: [
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadData,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length + 1,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 165,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                if (index == items.length) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _resetAll,
                              child: const Text('Reset All'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _loadData,
                              child: const Text('Aktualisieren'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final item = items[index];
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Text(
                          item.value,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const Spacer(),
                        if (item.resetKey != null)
                          OutlinedButton(
                            onPressed: () => _resetValue(item.resetKey!),
                            child: const Text('Reset'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (_connectionLost)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Card(
                margin: const EdgeInsets.all(24),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Verbindung verloren',
                    style: TextStyle(fontSize: 22, color: Colors.red),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DataItem {
  final String title;
  final String value;
  final String? resetKey;

  _DataItem(this.title, this.value, {this.resetKey});
}