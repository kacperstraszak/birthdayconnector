import 'package:birthday_connector/widgets/stat_row.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LifeStatisticsCard extends StatefulWidget {
  final DateTime birthDate;
  final bool showDatePicker;

  const LifeStatisticsCard({
    super.key,
    required this.birthDate,
    this.showDatePicker = false,
  });

  @override
  State<LifeStatisticsCard> createState() => _LifeStatisticsCardState();
}

class _LifeStatisticsCardState extends State<LifeStatisticsCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Duration get _age => DateTime.now().difference(widget.birthDate);

  int get _secondsLived => _age.inSeconds;
  int get _minutesLived => _age.inMinutes;
  int get _hoursLived => _age.inHours;
  int get _daysLived => _age.inDays;
  int get _weeksLived => (_age.inDays / 7).floor();
  int get _monthsLived => ((DateTime.now().year - widget.birthDate.year) * 12 +
          DateTime.now().month -
          widget.birthDate.month)
      .toInt();
  int get _yearsLived => (_age.inDays / 365.25).floor();

  int get _heartbeats => (_secondsLived * 1.2).toInt(); // ~72 bpm average
  int get _breathsTaken => (_secondsLived * 0.25).toInt(); // ~15 breaths/min
  double get _distanceWalked =>
      (_daysLived * 7500 * 0.7) / 1000; // ~7500 steps/day * 0.7m/step

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timeline,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Life Statistics',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                StatRow(
                  icon: Icons.access_time,
                  label: 'Seconds lived',
                  value: _formatNumber(_secondsLived),
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.schedule,
                  label: 'Minutes lived',
                  value: _formatNumber(_minutesLived),
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Days lived',
                  value: _formatNumber(_daysLived),
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.cake_outlined,
                  label: 'Years lived',
                  value: _yearsLived.toString(),
                  color: Colors.purple,
                ),
                const Divider(height: 32),
                Text(
                  'Fun Facts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.favorite_outline,
                  label: 'Heartbeats',
                  value: '~${_formatNumber(_heartbeats)}',
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.air,
                  label: 'Breaths taken',
                  value: '~${_formatNumber(_breathsTaken)}',
                  color: Colors.cyan,
                ),
                const SizedBox(height: 16),
                StatRow(
                  icon: Icons.directions_walk,
                  label: 'Distance walked',
                  value: '~${_formatNumber(_distanceWalked.toInt())} km',
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
