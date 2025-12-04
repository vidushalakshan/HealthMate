import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';

class RecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordCard({
    Key? key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final recordDate = DateTime(date.year, date.month, date.day);

      if (recordDate == today) {
        return 'Today, ${DateFormat('MMM dd').format(date)}';
      } else if (recordDate == yesterday) {
        return 'Yesterday, ${DateFormat('MMM dd').format(date)}';
      } else {
        return DateFormat('EEEE, MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  String _getHealthScore() {
    int score = 0;

    if (record.steps >= 10000) {
      score += 40;
    } else if (record.steps >= 7000) score += 30;
    else if (record.steps >= 5000) score += 20;
    else score += 10;
    
    if (record.calories >= 400 && record.calories <= 600) {
      score += 30;
    } else if (record.calories >= 300) score += 20;
    else score += 10;
    
    if (record.water >= 2000) {
      score += 30;
    } else if (record.water >= 1500) score += 20;
    else score += 10;
    
    return '$score%';
  }

  Color _getScoreColor(String score) {
    int value = int.parse(score.replaceAll('%', ''));
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final healthScore = _getHealthScore();
    final scoreColor = _getScoreColor(healthScore);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              scoreColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(record.date),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: scoreColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: scoreColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Health Score: $healthScore',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: onEdit,
                          tooltip: 'Edit Record',
                          iconSize: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: onDelete,
                          tooltip: 'Delete Record',
                          iconSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.directions_walk,
                    value: _formatNumber(record.steps),
                    label: 'Steps',
                    color: Colors.green,
                    target: 10000,
                    current: record.steps,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    icon: Icons.local_fire_department,
                    value: _formatNumber(record.calories),
                    label: 'Calories',
                    color: Colors.orange,
                    target: 500,
                    current: record.calories,
                  ),
                  _buildVerticalDivider(),
                  _buildStatItem(
                    icon: Icons.water_drop,
                    value: '${_formatNumber(record.water)} ml',
                    label: 'Water',
                    color: Colors.blue,
                    target: 2000,
                    current: record.water,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 60,
      width: 1,
      color: Colors.grey[300],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required int target,
    required int current,
  }) {
    final percentage = (current / target * 100).clamp(0, 100).toInt();
    
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        _buildProgressBar(
          'Steps',
          record.steps,
          10000,
          Colors.green,
          Icons.directions_walk,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          'Calories',
          record.calories,
          500,
          Colors.orange,
          Icons.local_fire_department,
        ),
        const SizedBox(height: 8),
        _buildProgressBar(
          'Water',
          record.water,
          2000,
          Colors.blue,
          Icons.water_drop,
        ),
      ],
    );
  }

  Widget _buildProgressBar(
    String label,
    int current,
    int target,
    Color color,
    IconData icon,
  ) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$current / $target',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.7), color],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}