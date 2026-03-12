import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gleisguru/models/api.dart';

class DataItem {
  final String title;
  final String value;
  final String? resetKey;

  DataItem(this.title, this.value, {this.resetKey});
}

class HomePageLayout extends StatelessWidget {
  final List<DataItem> items;
  final ApiData? data;
  final bool loading;
  final bool connectionLost;

  final List<double> speedHistory;
  final List<double> temperatureHistory;
  final List<double> batteryHistory;
  final List<double> voltageHistory;

  final Future<void> Function() onRefresh;
  final Future<void> Function() onOpenSettings;
  final Future<void> Function() onResetAll;
  final Future<void> Function(String key) onResetValue;

  const HomePageLayout({
    super.key,
    required this.items,
    required this.data,
    required this.loading,
    required this.connectionLost,
    required this.speedHistory,
    required this.temperatureHistory,
    required this.batteryHistory,
    required this.voltageHistory,
    required this.onRefresh,
    required this.onOpenSettings,
    required this.onResetAll,
    required this.onResetValue,
  });

  bool _isCompact(double width) => width < 600;
  bool _isDesktop(double width) => width >= 1000;

  int _crossAxisCount(double width) {
    if (width >= 1400) return 4;
    if (width >= 1000) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = _isCompact(width);
    final desktop = _isDesktop(width);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gleis-Guru',
          style: TextStyle(fontSize: compact ? 18 : 20),
        ),
        toolbarHeight: compact ? 48 : 56,
        actions: [
          IconButton(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: onRefresh,
            child: desktop
                ? _buildDesktopLayout(context, width)
                : compact
                    ? _buildMobileLayout(context)
                    : _buildTabletLayout(context, width),
          ),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (connectionLost)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Verbindung verloren',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 18 : 22,
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      children: [
        _buildTopSummaryCard(context, true),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildStatCard(context, item, true),
          ),
        ),
        _buildActionsCard(context, true),
        const SizedBox(height: 8),
        _buildChartCard(
          context,
          title: 'Geschwindigkeit',
          unit: 'km/h',
          values: speedHistory,
          compact: true,
        ),
        const SizedBox(height: 8),
        _buildChartCard(
          context,
          title: 'Temperatur',
          unit: '°C',
          values: temperatureHistory,
          compact: true,
        ),
        const SizedBox(height: 8),
        _buildChartCard(
          context,
          title: 'Akkustand',
          unit: '%',
          values: batteryHistory,
          compact: true,
        ),
        const SizedBox(height: 8),
        _buildChartCard(
          context,
          title: 'Schienenspannung',
          unit: 'V',
          values: voltageHistory,
          compact: true,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, double width) {
    final columns = _crossAxisCount(width);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: SizedBox.shrink(),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildTopSummaryCard(context, false),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return _buildStatCard(context, item, false);
              },
              childCount: items.length,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 160,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildActionsCard(context, false),
              const SizedBox(height: 12),
              _buildChartCard(
                context,
                title: 'Geschwindigkeit',
                unit: 'km/h',
                values: speedHistory,
                compact: false,
              ),
              const SizedBox(height: 12),
              _buildChartCard(
                context,
                title: 'Temperatur',
                unit: '°C',
                values: temperatureHistory,
                compact: false,
              ),
              const SizedBox(height: 12),
              _buildChartCard(
                context,
                title: 'Akkustand',
                unit: '%',
                values: batteryHistory,
                compact: false,
              ),
              const SizedBox(height: 12),
              _buildChartCard(
                context,
                title: 'Schienenspannung',
                unit: 'V',
                values: voltageHistory,
                compact: false,
              ),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double width) {
    final twoColumns = width > 1280;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1500),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 320,
                child: Column(
                  children: [
                    _buildTopSummaryCard(context, false),
                    const SizedBox(height: 16),
                    _buildActionsCard(context, false),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 150,
                      ),
                      itemBuilder: (context, index) {
                        return _buildStatCard(context, items[index], false);
                      },
                    ),
                    const SizedBox(height: 20),
                    if (twoColumns) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildChartCard(
                              context,
                              title: 'Geschwindigkeit',
                              unit: 'km/h',
                              values: speedHistory,
                              compact: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChartCard(
                              context,
                              title: 'Temperatur',
                              unit: '°C',
                              values: temperatureHistory,
                              compact: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildChartCard(
                              context,
                              title: 'Akkustand',
                              unit: '%',
                              values: batteryHistory,
                              compact: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildChartCard(
                              context,
                              title: 'Schienenspannung',
                              unit: 'V',
                              values: voltageHistory,
                              compact: false,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildChartCard(
                        context,
                        title: 'Geschwindigkeit',
                        unit: 'km/h',
                        values: speedHistory,
                        compact: false,
                      ),
                      const SizedBox(height: 12),
                      _buildChartCard(
                        context,
                        title: 'Temperatur',
                        unit: '°C',
                        values: temperatureHistory,
                        compact: false,
                      ),
                      const SizedBox(height: 12),
                      _buildChartCard(
                        context,
                        title: 'Akkustand',
                        unit: '%',
                        values: batteryHistory,
                        compact: false,
                      ),
                      const SizedBox(height: 12),
                      _buildChartCard(
                        context,
                        title: 'Schienenspannung',
                        unit: 'V',
                        values: voltageHistory,
                        compact: false,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSummaryCard(BuildContext context, bool compact) {
    final real = data?.vReal?.toStringAsFixed(1) ?? '-----';
    final temp = data?.temperatureC?.toStringAsFixed(1) ?? '-----';
    final battery = data?.batteryPercent?.toStringAsFixed(0) ?? '-----';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          children: [
            Expanded(child: _summaryValue('Real', '$real km/h', compact)),
            SizedBox(width: compact ? 8 : 12),
            Expanded(child: _summaryValue('Temp', '$temp °C', compact)),
            SizedBox(width: compact ? 8 : 12),
            Expanded(child: _summaryValue('Akku', '$battery %', compact)),
          ],
        ),
      ),
    );
  }

  Widget _summaryValue(String label, String value, bool compact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 11 : 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 15 : 18,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, DataItem item, bool compact) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1.5,
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
            SizedBox(height: compact ? 14 : 18),
            Text(
              item.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 24 : 28,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            if (item.resetKey != null) ...[
              SizedBox(height: compact ? 14 : 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => onResetValue(item.resetKey!),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(compact ? 88 : 84, compact ? 38 : 38),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Reset'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, bool compact) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onResetAll,
                style: FilledButton.styleFrom(
                  minimumSize: Size.fromHeight(compact ? 40 : 46),
                ),
                child: const Text('Alles zurücksetzen'),
              ),
            ),
            SizedBox(height: compact ? 8 : 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRefresh,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size.fromHeight(compact ? 40 : 46),
                ),
                child: const Text('Jetzt aktualisieren'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required String unit,
    required List<double> values,
    required bool compact,
  }) {
    final hasData = values.length >= 2;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          compact ? 12 : 16,
          compact ? 10 : 14,
          compact ? 12 : 16,
          compact ? 12 : 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Letzte ${values.length} Werte · $unit',
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: compact ? 150 : 200,
              child: hasData
                  ? LineChart(_buildLineChartData(values, compact))
                  : Center(
                      child: Text(
                        'Noch nicht genug Daten',
                        style: TextStyle(fontSize: compact ? 12 : 14),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<double> values, bool compact) {
    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = maxValue - minValue;
    final padding = range == 0 ? max(1, maxValue.abs() * 0.1) : range * 0.15;

    final chartMinY = minValue - padding;
    final chartMaxY = maxValue + padding;
    final chartRange = chartMaxY - chartMinY;

    double yInterval;
    if (chartRange <= 1) {
      yInterval = 0.2;
    } else if (chartRange <= 2) {
      yInterval = 0.5;
    } else if (chartRange <= 5) {
      yInterval = 1;
    } else if (chartRange <= 10) {
      yInterval = 2;
    } else if (chartRange <= 20) {
      yInterval = 5;
    } else if (chartRange <= 50) {
      yInterval = 10;
    } else {
      yInterval = 20;
    }

    String formatYAxis(double value) {
      if (chartRange < 2) {
        return value.toStringAsFixed(1);
      }
      return value.toStringAsFixed(0);
    }

    return LineChartData(
      minX: 0,
      maxX: (values.length - 1).toDouble(),
      minY: chartMinY,
      maxY: chartMaxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: !compact,
        horizontalInterval: yInterval,
      ),
      borderData: FlBorderData(show: true),
      lineTouchData: LineTouchData(enabled: true),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: compact ? 38 : 48,
            interval: yInterval,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  formatYAxis(value),
                  style: TextStyle(fontSize: compact ? 9 : 10),
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: compact ? 20 : 24,
            interval: values.length > (compact ? 5 : 6)
                ? (values.length / (compact ? 5 : 6)).ceilToDouble()
                : 1,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: compact ? 9 : 10),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            values.length,
            (index) => FlSpot(index.toDouble(), values[index]),
          ),
          isCurved: true,
          barWidth: compact ? 2.5 : 3,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true),
        ),
      ],
    );
  }
}