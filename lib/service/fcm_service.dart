import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:hedieaty/models/model/gift.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:http/http.dart' as http;

class FcmService {
  Future<String> getAccessToken() async {
    // Your client ID and client secret obtained from Google Cloud Console
    final serviceAccountJson = { 
      // service account JSON
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );
    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<void> sendFCMMessage(UserModel user, Gift gift) async {
    final String serverKey = await getAccessToken(); // Your FCM server key
    const String fcmEndpoint =
        'https://fcm.googleapis.com/v1/projects/hedieaty-8d947/messages:send';
    final currentFCMToken = user.fcmToken;
    final Map<String, dynamic> message = {
      'message': {
        'token':
            currentFCMToken, // Token of the device you want to send the message to
        'notification': {
          'body': 'The Gift "${gift.name}" is now ${gift.status.name} FCM.',
          'title': 'Gift ${gift.name} is updated'
        },
        'data': {
          'current_user_fcm_token': currentFCMToken,
        },
      }
    };

    await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );
  }
}
