import 'dart:convert';
import 'dart:io';

import 'package:handyman_provider_flutter/models/firebase_details_model.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/user_data.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? image, required UserData receiverUser, required UserData senderUserData}) async {
    await getFirebaseTokenAndId().then((value) async {
      if (value.data != null && value.data!.firebaseToken.validate().isNotEmpty && value.data!.projectId.validate().isNotEmpty) {
        Map<String, dynamic> data = {
          "created_at": senderUserData.createdAt,
          "email": senderUserData.email,
          "first_name": senderUserData.firstName,
          "id": senderUserData.id.toString(),
          "last_name": senderUserData.lastName,
          "updated_at": senderUserData.updatedAt,
          "profile_image": senderUserData.profileImage,
          "uid": senderUserData.uid,
        };

        data.putIfAbsent("is_chat", () => '1');
        if (image != null && image.isNotEmpty) data.putIfAbsent("image_url", () => image.validate());

        Map req = {
          "message": {
            "topic": "user_${receiverUser.id.validate()}",
            "notification": {
              "body": content,
              "title": "$title ${languages.sentYouAMessage}",
              "image": image.validate(),
            },
            "data": data,
          }
        };

        log('FCM Request - Project ID: ${value.data!.projectId}');
        log('FCM Request - Topic: user_${receiverUser.id.validate()}');
        var header = {
          HttpHeaders.authorizationHeader: 'Bearer ${value.data!.firebaseToken}',
          HttpHeaders.contentTypeHeader: 'application/json',
        };

        Response res = await post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/${value.data!.projectId}/messages:send'),
          body: jsonEncode(req),
          headers: header,
        );

        log('FCM Response Status: ${res.statusCode}');
        log('FCM Response Body: ${res.body}');

        if (res.statusCode.isSuccessful()) {
          log('Push notification sent successfully');
        } else {
          // Check for specific error codes
          final responseBody = res.body;
          if (res.statusCode == 401 || res.statusCode == 403) {
            log('FCM Authentication Error: Token may be expired or invalid. Status: ${res.statusCode}');
            log('Response: $responseBody');
            throw 'Firebase credentials expired or invalid. Please contact support to update Firebase credentials.';
          } else if (res.statusCode == 404) {
            log('FCM Project Not Found: Project ID may be incorrect. Status: ${res.statusCode}');
            throw 'Firebase project not found. Please check Firebase configuration.';
          } else {
            log('FCM Error: ${res.statusCode} - $responseBody');
            throw errorSomethingWentWrong;
          }
        }
      } else {
        log('Firebase credentials missing or invalid');
        log('Status: ${value.status}, Message: ${value.message}');
        log('Has Data: ${value.data != null}');
        if (value.data != null) {
          log('Has Token: ${value.data!.firebaseToken.validate().isNotEmpty}');
          log('Has Project ID: ${value.data!.projectId.validate().isNotEmpty}');
        }
        throw 'Firebase credentials not available. Please contact support.';
      }
    }).catchError((e) {
      log('Error getting Firebase credentials: $e');
      throw e;
    });
  }

  Future<FirebaseDetailsModel> getFirebaseTokenAndId({Map? request}) async {
    return FirebaseDetailsModel.fromJson(await handleResponse(await buildHttpResponse('firebase-detail', request: request, method: HttpMethodType.GET)));
  }
}
