import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../session/session_manager.dart';
import 'local_notification_services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {

    SessionManager.removeExpiredNotifications();

    var list = await SessionManager.getNotificationList();

    notifications = list
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    setState(() {});
  }

  Future<void> addNotification(int second) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final DateTime scheduledTime =  DateTime.now().add(Duration(seconds: second));

    await NotificationService.showScheduleNotification("this is test notification scheduled", "$scheduledTime", time: scheduledTime);
    loadNotifications();
  }

  Future<void> cancelNotification(int id) async {
    await NotificationService.flutterLocalNotificationsPlugin.cancel( id: id);
    SessionManager.clearAllNotificationById(id.toString());
    loadNotifications();
  }

  Future<void> cancelAll() async {
    SessionManager.clearAllNotificationList();
    await NotificationService.flutterLocalNotificationsPlugin.cancelAll();

    loadNotifications();
  }



  String formatTime(String scheduledTime) {
    if (scheduledTime.isEmpty) return "";

    return scheduledTime.split('T')[1].split('.').first;
  }

  String formateDate(String scheduledTime){
    if (scheduledTime.isEmpty) {
      return "";
    }

    final dateTime = DateTime.parse(scheduledTime);

    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString()}/${dateTime.year.toString()}";
  }

  Future<void> pickTimeAndSchedule(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    final now = DateTime.now();

    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // // If selected time already passed today, schedule for tomorrow
    // if (scheduledDate.isBefore(now)) {
    //   scheduledDate = scheduledDate.add(const Duration(days: 1));
    // }
    // addNotification(60);
    // for (int i = 0; i < 20; i++) {
    //   final DateTime scheduledTime2 =  DateTime.now().add(Duration(seconds: i*120));
    //
    //   print("Loop: $i");
    //   await NotificationService.showScheduleNotification("this is test notification scheduled", "$scheduledTime2", time: scheduledTime2);
    //
    // }

    await NotificationService.showScheduleNotification("this is test notification scheduled", "$scheduledDate", time: scheduledDate);
    loadNotifications();
  }

  Future<String> getImagePath() async {
    final byteData = await rootBundle.load('assets/images/img_flag.png');

    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/logo.png');

    await file.writeAsBytes(
      byteData.buffer.asUint8List(),
    );

    return file.path;
  }

  void sendImageNotification() async{

    var path = await getImagePath();
    print("this is good");
    print(path);

    NotificationService.showNotificationBigSizeImage("New Msg", "show more", path);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text("Notifications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: cancelAll,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadNotifications,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){

          // sendImageNotification();
          NotificationService.showNotificationBigSize("this is good", "test apk");
          // pickTimeAndSchedule(context);
        },
        icon: const Icon(Icons.add_alarm),
        label: const Text("Schedule"),
      ),
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          "No Scheduled Notifications",
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.notifications),
              ),
              title: Text(
                item['title'] ?? '',
              ),
              subtitle: ListTile(
                title: Text("Id:  "+item['id'] ),
                subtitle: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTime(item['scheduledTime']?? ''),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      formateDate(item['scheduledTime']?? ''),
                    ),
                  ],
                ),
              ),
              // subtitle: Text(
              //   item['scheduledTime'] ?? '',
              // ),
              trailing: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    int id = int.tryParse(item['id'])?? 0;
                    cancelNotification(id);
                  }

              ),
            ),
          );
        },
      ),
    );
  }
}