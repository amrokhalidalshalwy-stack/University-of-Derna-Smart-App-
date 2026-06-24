import 'package:flutter_project/features/notifications/presentation/pages/notifications_page.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar(
  BuildContext context,
  String title, {
  required bool automaticallyImplyLeading,
}) {
  final theme = Theme.of(context);

  return AppBar(
    backgroundColor: theme.primaryColor, // App color based on theme
    automaticallyImplyLeading: automaticallyImplyLeading,
    elevation: 2,
    toolbarHeight: 80,
    centerTitle: true,
    title: Text(
      title,
      style: TextStyle(
        color:
            theme.appBarTheme.foregroundColor ??
            Colors.white, // Text color based on theme or white default
        fontSize: 23,
        fontWeight: FontWeight.w500,
        fontFamily: "Cairo",
      ),
    ),
    iconTheme: IconThemeData(
      color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.notifications_none,
          size: 26,
          color: theme.appBarTheme.iconTheme?.color ?? Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
      ),
      const SizedBox(width: 8),
    ],
  );
}
