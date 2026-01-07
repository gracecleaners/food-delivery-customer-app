import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed('/notification-settings');
            },
          ),
        ],
      ),
      body: StreamBuilder<RemoteMessage>(
        stream: notificationService.notificationStream,
        builder: (context, snapshot) {
          // You can display notifications here
          return ListView(
            children: [
              // Notification list items
            ],
          );
        },
      ),
    );
  }
}