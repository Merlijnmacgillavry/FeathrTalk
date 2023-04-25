import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final String message = notificationProvider.message;
        if (message.isNotEmpty) {
          // Show a SnackBar with the alert message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: Duration(seconds: 2),
              ),
            );
          });
        }
        return SizedBox.shrink();
      },
    );
  }
}
