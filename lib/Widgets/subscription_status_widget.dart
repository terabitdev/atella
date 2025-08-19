import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/subscription_manager_service.dart';

/// Widget to display current subscription status - useful for debugging and user info
class SubscriptionStatusWidget extends StatelessWidget {
  final bool showDetailedInfo;
  
  const SubscriptionStatusWidget({
    Key? key,
    this.showDetailedInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: SubscriptionManagerService().getSubscriptionStatus(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading subscription...'),
              ],
            ),
          );
        }

        final status = snapshot.data!;
        final plan = status['plan'] as String;
        final displayName = status['displayName'] as String;
        final remainingTechpacks = status['remainingTechpacks'] as int;
        final maxTechpacks = status['maxTechpacks'] as int;
        final isActive = status['isActive'] as bool;

        Color statusColor = _getStatusColor(plan, isActive);
        IconData statusIcon = _getStatusIcon(plan);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      fontSize: 16,
                    ),
                  ),
                  if (!isActive && plan != 'FREE')
                    Container(
                      margin: EdgeInsets.only(left: 8),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Inactive',
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (showDetailedInfo && plan == 'STARTER')
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Techpacks: $remainingTechpacks/$maxTechpacks remaining',
                    style: TextStyle(
                      fontSize: 14,
                      color: remainingTechpacks > 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ),
              if (showDetailedInfo && plan == 'PRO')
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Unlimited techpacks',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              if (showDetailedInfo && plan == 'FREE')
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No techpack access',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String plan, bool isActive) {
    if (!isActive && plan != 'FREE') return Colors.red;
    
    switch (plan) {
      case 'FREE':
        return Colors.grey;
      case 'STARTER':
        return Colors.blue;
      case 'PRO':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String plan) {
    switch (plan) {
      case 'FREE':
        return Icons.free_breakfast_outlined;
      case 'STARTER':
        return Icons.rocket_launch_outlined;
      case 'PRO':
        return Icons.star_outline;
      default:
        return Icons.help_outline;
    }
  }
}