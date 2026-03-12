import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gleisguru/models/api.dart';
import 'package:gleisguru/services/api_service.dart';

import 'home_page_layout.dart';
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

  final List<double> _speedHistory = [];
  final List<double> _temperatureHistory = [];
  final List<double> _batteryHistory = [];
  final List<double> _voltageHistory = [];

  static const int _maxHistoryPoints = 30;

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

        _addHistoryValue(_speedHistory, result.vReal);
        _addHistoryValue(_temperatureHistory, result.temperatureC);
        _addHistoryValue(_batteryHistory, result.batteryPercent);
        _addHistoryValue(_voltageHistory, result.voltage);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _connectionLost = true;
        _loading = false;
      });
    }
  }

  void _addHistoryValue(List<double> history, double? value) {
    if (value == null) return;
    history.add(value);
    if (history.length > _maxHistoryPoints) {
      history.removeAt(0);
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
      DataItem('Modellgeschwindigkeit', '${_formatValue(_data?.vMod, 1)} cm/s'),
      DataItem('Realgeschwindigkeit', '${_formatValue(_data?.vReal, 1)} km/h'),
      DataItem(
        'Maximalgeschwindigkeit',
        '${_formatValue(_data?.vMax, 1)} km/h',
        resetKey: 'v_max',
      ),
      DataItem(
        'Durchschnitt',
        '${_formatValue(_data?.vAverage, 1)} km/h',
        resetKey: 'v_average',
      ),
      DataItem(
        'Strecke',
        '${_formatDistanceValue(_data?.distance)} $distanceUnit',
        resetKey: 'distance',
      ),
      DataItem('Steigung', '${_formatValue(_data?.slopePct, 0)} %'),
      DataItem('Neigung', '${_formatValue(_data?.inclinationDeg, 0)} °'),
      DataItem('Temperatur', '${_formatValue(_data?.temperatureC, 1)} °C'),
      DataItem('Luftdruck', '${_formatValue(_data?.pressureHpa, 1)} hPa'),
      DataItem('Feuchte', '${_formatValue(_data?.humidityPct, 1)} %'),
      DataItem('Schienenspannung', '${_formatValue(_data?.voltage, 2)} V'),
      DataItem('Akkustand', '${_formatValue(_data?.batteryPercent, 0)} %'),
    ];

    return HomePageLayout(
      items: items,
      data: _data,
      loading: _loading,
      connectionLost: _connectionLost,
      speedHistory: _speedHistory,
      temperatureHistory: _temperatureHistory,
      batteryHistory: _batteryHistory,
      voltageHistory: _voltageHistory,
      onRefresh: _loadData,
      onOpenSettings: _openSettings,
      onResetAll: _resetAll,
      onResetValue: _resetValue,
    );
  }
}