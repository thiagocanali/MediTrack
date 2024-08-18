import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EditMedicationScreen extends StatefulWidget {
  final String documentId;
  final String currentName;
  final Timestamp? currentReminderTime;

  const EditMedicationScreen({
    Key? key,
    required this.documentId,
    required this.currentName,
    this.currentReminderTime,
  }) : super(key: key);

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final TextEditingController _medicationController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _medicationController.text = widget.currentName;
    if (widget.currentReminderTime != null) {
      final dateTime = widget.currentReminderTime!.toDate();
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
    }
  }

  void _updateMedication() async {
    final newName = _medicationController.text;
    final newTime = _selectedTime;
    if (newName.isNotEmpty) {
      final now = DateTime.now();
      final reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        newTime.hour,
        newTime.minute,
      );

      await FirebaseFirestore.instance
          .collection('medications')
          .doc(widget.documentId)
          .update({
        'name': newName,
        'reminderTime': Timestamp.fromDate(reminderDateTime),
      });

      // Cancel any existing notifications and schedule a new one
      _scheduleNotification(reminderDateTime);

      Navigator.pop(context);
    }
  }

  void _deleteMedication() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this medication?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('medications')
          .doc(widget.documentId)
          .delete();

      // Cancel any existing notifications
      _cancelNotification();

      Navigator.pop(context);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleNotification(DateTime dateTime) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medication_channel',
      'Medication Notifications',
      channelDescription: 'Channel for medication notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Medication Reminder',
      'Time to take your medication!',
      tz.TZDateTime.from(dateTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _cancelNotification() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.cancelAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _medicationController,
              decoration: InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text('Reminder Time: ${_selectedTime.format(context)}'),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: _selectTime,
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateMedication,
              child: Text('Update Medication'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _deleteMedication,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Substitua primary por backgroundColor
              ),
              child: Text('Delete Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
