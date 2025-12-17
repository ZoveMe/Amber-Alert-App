import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert.dart';
import '../models/mk_regions.dart';


class AlertsScreen extends StatelessWidget {
  final List<Alert> alerts;

  const AlertsScreen({super.key, required this.alerts});

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE74C3C);
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Center(child: Text('No active alerts.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        final color = _priorityColor(alert.priority);
        final time = DateFormat.yMMMd().add_Hm().format(alert.createdAt.toLocal());
        final priorityLabel =
            alert.priority[0].toUpperCase() + alert.priority.substring(1);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(
                alert.priority.toLowerCase() == 'high'
                    ? Icons.warning
                    : Icons.person_search,
                color: color,
              ),
            ),
            title: Text(
              alert.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${alert.name} · ${MkRegions.toDisplay(alert.region ?? '')}',
            ),

            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color),
              ),
              child: Text(
                priorityLabel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
