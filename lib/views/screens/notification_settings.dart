import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/services/notification_service.dart';

class NotificationSettingsScreen extends StatelessWidget {
  NotificationSettingsScreen({super.key});

  final NotificationService notificationService = Get.find<NotificationService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive order updates, promotions, etc.'),
            value: notificationService.areNotificationsEnabled(),
            onChanged: (value) {
              notificationService.toggleNotifications(value);
              Get.snackbar(
                'Settings Updated',
                value ? 'Notifications enabled' : 'Notifications disabled',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Order Updates'),
            subtitle: const Text('Order confirmations, status changes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to more specific settings
            },
          ),
          ListTile(
            title: const Text('Promotions & Offers'),
            subtitle: const Text('Discounts, special offers, etc.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to more specific settings
            },
          ),
          ListTile(
            title: const Text('Sound'),
            subtitle: const Text('Notification sound settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to sound settings
            },
          ),
        ],
      ),
    );
  }
}