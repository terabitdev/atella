import 'package:flutter/material.dart';
import '../services/PaymentService/stripe_subscription_service.dart';

/// Debug widget to show current subscription status - remove in production
class DebugSubscriptionWidget extends StatefulWidget {
  @override
  _DebugSubscriptionWidgetState createState() => _DebugSubscriptionWidgetState();
}

class _DebugSubscriptionWidgetState extends State<DebugSubscriptionWidget> {
  final StripeSubscriptionService _subscriptionService = StripeSubscriptionService();
  Map<String, dynamic>? _status;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _subscriptionService.getSubscriptionStatus();
    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_status == null) {
      return Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('Loading subscription status...'),
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔧 DEBUG: Subscription Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text('Plan: ${_status!['plan']}', style: TextStyle(fontSize: 11)),
          Text('Active: ${_status!['isActive']}', style: TextStyle(fontSize: 11)),
          if (_status!['plan'] == 'STARTER')
            Text(
              'Techpacks: ${_status!['remainingTechpacks']}/3 remaining',
              style: TextStyle(
                fontSize: 11,
                color: _status!['remainingTechpacks'] > 0 ? Colors.green : Colors.red,
              ),
            ),
          SizedBox(height: 4),
          Row(
            children: [
              ElevatedButton(
                onPressed: _loadStatus,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text('Refresh', style: TextStyle(fontSize: 10)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await _subscriptionService.checkAndHandleMonthlyReset();
                  _loadStatus();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text('Test Reset', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}