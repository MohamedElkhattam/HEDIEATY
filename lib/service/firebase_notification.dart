import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> handlerBackgroundMessage(RemoteMessage message) async {
  // ignore: avoid_print
  print('Handling a background message ${message.messageId}');
}

class FirebaseNotification {
  Future<void> initNotification() async {
    await Permission.notification.request();
    FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
    await getFcmToken();
  }

  Future<String> getFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken ?? '';
  }
}
