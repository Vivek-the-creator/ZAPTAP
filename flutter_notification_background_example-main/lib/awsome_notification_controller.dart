import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'scheduled_notification',
          channelName: 'Scheduled Notifications',
          channelDescription: 'Channel for scheduled notifications',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          playSound: true,
          soundSource: 'resource://raw/res_notification',
          importance: NotificationImportance.High,
          channelShowBadge: true,
          vibrationPattern: Int64List(2),
          ledOnMs: 1000,
          ledOffMs: 500,
          enableLights: true,
          enableVibration: true,
        ),
      ],
      debug: true,
    );

    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  static ReceivePort? receivePort;

  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen((silentData) => onActionReceivedImplementationMethod(silentData));

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyPressed}"');

      await AwesomeNotifications().createNotification(
        schedule: NotificationInterval(
          interval: Duration(minutes: 5), // ✅ FIXED HERE
          repeats: false,
        ),
        content: NotificationContent(
          id: Random().nextInt(100),
          title: 'titlttttt',
          body: 'This is bodyyyyy',
          channelKey: 'scheduled_notification',
          displayOnBackground: true,
          displayOnForeground: true,
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
          customSound: 'resource://raw/res_notification',
        ),
        actionButtons: [
          NotificationActionButton(
              key: '30MIN',
              label: 'Remind in 30 min',
              actionType: ActionType.SilentAction),
          NotificationActionButton(
            key: '1HOUR',
            label: 'Remind in 1 hour',
          ),
        ],
      );
    } else {
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
        IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    // You can add custom logic here to respond to button actions.
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  static Future<void> createNewNotification({
    int? id,
    String? title,
    String? body,
    String? payload,
    String? period,
    int? day,
    int? month,
    int? year,
    int? hour,
    int? minute,
    int? second,
    Color? color,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: Random().nextInt(100),
        title: title,
        body: body,
        channelKey: 'scheduled_notification',
        displayOnBackground: true,
        displayOnForeground: true,
        notificationLayout: NotificationLayout.BigText,
        wakeUpScreen: true,
        customSound: 'resource://raw/res_notification',
      ),
      actionButtons: [
        NotificationActionButton(
          key: '30MIN',
          label: 'Remind in 30 min',
          actionType: ActionType.SilentAction,
        ),
        NotificationActionButton(
          key: '1HOUR',
          label: 'Remind in 1 hour',
          actionType: ActionType.SilentAction,
        ),
      ],
    );
  }
}
