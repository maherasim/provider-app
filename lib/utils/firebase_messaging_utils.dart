import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/bid_list_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../provider/services/service_detail_screen.dart';
import '../screens/booking_detail_screen.dart';
import '../screens/chat/frobster_chat_thread_screen.dart';
import 'constant.dart';
import '../networks/push_api.dart';

Future<void> initFirebaseMessaging() async {
  await FirebaseMessaging.instance
      .requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  )
      .then((value) async {
    if (value.authorizationStatus == AuthorizationStatus.authorized) {
      await registerNotificationListeners().catchError((e) {
        log('------Notification Listener REGISTRATION ERROR-----------');
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true).catchError((e) {
        log('------setForegroundNotificationPresentationOptions ERROR-----------');
      });

      // Register push token with backend
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');
          await PushApi.register(token: token, platform: platform);
        }
        // Re-register on refresh
        FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
          final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web');
          await PushApi.register(token: t, platform: platform);
        });
      } catch (e) {
        log('Push register error: $e');
      }
    }
  });
}

Future<void> registerNotificationListeners() async {
  FirebaseMessaging.instance.setAutoInitEnabled(true).then((value) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('=== FOREGROUND MESSAGE RECEIVED ===');
      log('Message ID: ${message.messageId}');
      log('Notification Title: ${message.notification?.title}');
      log('Notification Body: ${message.notification?.body}');
      log('Notification Data: ${message.data}');
      log('Message Type: ${message.data['type']}');
      log('Is Chat: ${message.data['is_chat']}');
      log('Has Conversation ID: ${message.data.containsKey('conversation_id')}');
      
      // Check if this is a chat message - be more flexible with detection
      final isChatMessage = message.data['is_chat'] == '1' || 
                           message.data['is_chat'] == 1 ||
                           message.data.containsKey('conversation_id') ||
                           message.data.containsKey('conversationId') ||
                           (message.notification?.title?.contains('message') ?? false) ||
                           (message.notification?.title?.contains('Message') ?? false);
      
      log('Detected as Chat Message: $isChatMessage');
      
      if (message.notification != null && message.notification!.title.validate().isNotEmpty && message.notification!.body.validate().isNotEmpty) {
        // Show notification with sound and vibration for chat messages
        await showNotification(
          currentTimeStamp(), 
          message.notification!.title.validate(), 
          parseHtmlString(message.notification!.body.validate()), 
          message,
          isChatMessage: isChatMessage,
        );
      } else {
        // Data-only push - build a basic notification
        final data = message.data;
        String title = 'New message';
        String body = 'You have a new message';
        
        if (isChatMessage) {
          // For chat messages, try to get sender name from data (Laravel format)
          // Laravel sends: sender_name, or first_name/last_name
          final senderName = data['sender_name']?.toString() ?? '';
          final firstName = data['first_name']?.toString() ?? '';
          final lastName = data['last_name']?.toString() ?? '';
          
          if (senderName.isNotEmpty) {
            title = senderName;
          } else if (firstName.isNotEmpty || lastName.isNotEmpty) {
            title = '$firstName $lastName'.trim();
          }
          
          // Get message body from Laravel format: 'message' field
          body = data['message']?.toString().validate().isNotEmpty == true
              ? data['message'].toString()
              : (data['preview']?.toString().validate().isNotEmpty == true 
                  ? data['preview'].toString() 
                  : (message.notification?.body ?? 'You have a new message'));
        } else {
          title = data['title']?.toString().validate().isNotEmpty == true ? data['title'].toString() : 'New message';
          body = data['preview']?.toString().validate().isNotEmpty == true ? data['preview'].toString() : 'You have a new message';
        }
        
        log('Data-only notification - Title: $title, Body: $body');
        await showNotification(currentTimeStamp(), title, body, message, isChatMessage: isChatMessage);
      }
      
      // Foreground notification handling - Update counts for both chat and booking status updates
      try {
        final data = message.data;
        final isChat = data['type'] == 'chat' || 
                      data['is_chat'] == '1' || 
                      data['is_chat'] == 1 ||
                      data.containsKey('conversation_id') ||
                      data.containsKey('conversationId') ||
                      data.containsKey('sender_id') || // Laravel format
                      data.containsKey('sender_name') || // Laravel format
                      isChatMessage;
        
        if (isChat) {
          log('Processing chat notification - emitting LIVESTREAM_UPDATE_CHAT_UNREAD');
          // Emit immediately to update chat badge
          LiveStream().emit(LIVESTREAM_UPDATE_CHAT_UNREAD);
          
          // Also increment top bell badge like WhatsApp (in-app counter)
          try {
            final current = appStore.notificationCount;
            final next = (current > 0) ? current + 1 : 1;
            await appStore.setNotificationCount(next);
            log('Updated notification count to: $next');
          } catch (e) {
            log('increment notificationCount error: $e');
          }
        } else {
          // Handle booking status updates and other non-chat notifications
          log('Processing booking/status notification - updating notification count');
          try {
            final current = appStore.notificationCount;
            final next = (current > 0) ? current + 1 : 1;
            await appStore.setNotificationCount(next);
            log('Updated notification count for booking status: $next');
            
            // Emit event to refresh notification list
            LiveStream().emit(LIVESTREAM_UPDATE_NOTIFICATIONS);
          } catch (e) {
            log('increment notificationCount for booking error: $e');
          }
        }
      } catch (e) {
        log('onMessage notification parse error: $e');
      }
      
      log('=== END FOREGROUND MESSAGE PROCESSING ===');
    }, onError: (e) {
      log("setAutoInitEnabled error $e");
    });

    // replacement for onResume: When the app is in the background and opened directly from the push notification.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationClick(message);
    }, onError: (e) {
      log("onMessageOpenedApp Error $e");
    });

    // workaround for onLaunch: When the app is completely closed (not in the background) and opened directly from the push notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        handleNotificationClick(message);
      }
    }, onError: (e) {
      log("getInitialMessage error : $e");
    });
  }).onError((error, stackTrace) {
    log("onGetInitialMessage error: $error");
  });
}

Future<bool> subscribeToFirebaseTopic() async {
  bool result = appStore.isSubscribedForPushNotification;
  if (appStore.isLoggedIn) {
    log('=== SUBSCRIBING TO FIREBASE TOPICS ===');
    log('User ID: ${appStore.userId}');
    log('User Type: ${appStore.userType}');
    
    await initFirebaseMessaging();

    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken == null) {
        await 3.seconds.delay;
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      }
      log('APNS Token: $apnsToken');
    }

    // Get FCM token
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      log('FCM Token: $fcmToken');
    } catch (e) {
      log('Error getting FCM token: $e');
    }

    // Subscribe to user-specific topic
    try {
      await FirebaseMessaging.instance.subscribeToTopic('user_${appStore.userId}').then((value) {
        result = true;
        log("✓ Successfully subscribed to topic: user_${appStore.userId}");
      }).catchError((e) {
        log("✗ Error subscribing to user topic: $e");
      });
    } catch (e) {
      log("✗ Exception subscribing to user topic: $e");
    }
    
    // Subscribe to app-specific topic
    final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topicTag).then((value) {
        result = true;
        log("✓ Successfully subscribed to topic: $topicTag");
      }).catchError((e) {
        log("✗ Error subscribing to app topic: $e");
      });
    } catch (e) {
      log("✗ Exception subscribing to app topic: $e");
    }

    await appStore.setPushNotificationSubscriptionStatus(result);
    log('Subscription status saved: $result');
    log('=== END SUBSCRIPTION ===');
  } else {
    log('User not logged in, skipping subscription');
  }
  return result;
}

Future<bool> unsubscribeFirebaseTopic(int userId) async {
  bool result = appStore.isSubscribedForPushNotification;
  await FirebaseMessaging.instance.unsubscribeFromTopic('user_$userId').then((_) {
    result = false;
    log("topic-----unsubscribed----> user_$userId");
  });
  final topicTag = isUserTypeHandyman ? HANDYMAN_APP_TAG : PROVIDER_APP_TAG;
  await FirebaseMessaging.instance.unsubscribeFromTopic(topicTag).then((_) {
    result = false;
    log('topic-----unsubscribed---->------> $topicTag');
  });

  await appStore.setPushNotificationSubscriptionStatus(result);
  return result;
}

void handleNotificationClick(RemoteMessage message) {
  log('=== NOTIFICATION CLICKED ===');
  log('Notification data: ${message.data}');
  
  // Try multiple ways to detect chat notification (Laravel format)
  final conversationId = message.data['conversation_id'] ?? 
                        message.data['conversationId'] ?? 
                        message.data['conversation_id'];
  final isChat = message.data['type'] == 'chat' || 
                message.data['is_chat'] == '1' || 
                message.data['is_chat'] == 1 ||
                message.data.containsKey('sender_id') || // Laravel sends sender_id
                message.data.containsKey('sender_name') || // Laravel sends sender_name
                conversationId != null;
  
  log('Is Chat: $isChat, Conversation ID: $conversationId');
  
  if (isChat && conversationId != null) {
    final cidRaw = conversationId.toString();
    final cid = int.tryParse(cidRaw);
    log('Parsed Conversation ID: $cid');
    if (cid != null && cid > 0) {
      log('Navigating to chat thread: $cid');
      // Get sender info for better navigation (Laravel format)
      final senderName = message.data['sender_name']?.toString() ?? 'User';
      final senderAvatar = message.data['sender_avatar_url']?.toString();
      navigatorKey.currentState!.push(MaterialPageRoute(
        builder: (context) => FrobsterChatThreadScreen(
          conversationId: cid,
          title: senderName,
          otherDisplayName: senderName,
          otherAvatarUrl: senderAvatar,
        )
      ));
      return;
    }
  } else if (message.data.containsKey('additional_data')) {
    Map<String, dynamic> additionalData = jsonDecode(message.data["additional_data"]) ?? {};
    if (additionalData.containsKey('id') && additionalData['id'] != null) {
      if (additionalData.containsKey('check_booking_type') && additionalData['check_booking_type'] == 'booking') {
        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BookingDetailScreen(bookingId: additionalData['id'].toInt())));
      }

      if (additionalData.containsKey('notification-type') && additionalData['notification-type'] == 'user_accept_bid') {
        navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => BidListScreen()));
      }
    }

    if (additionalData.containsKey('service_id') && additionalData["service_id"] != null) {
      navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ServiceDetailScreen(serviceId: additionalData["service_id"].toInt())));
    }
  }
}

Future<void> showNotification(int id, String title, String message, RemoteMessage remoteMessage, {bool isChatMessage = false}) async {
  log('showNotification called - id: $id, title: $title, isChatMessage: $isChatMessage');
  if (remoteMessage.notification != null) {
    log('Notification : ${remoteMessage.notification!.toMap()}');
  }
  if (remoteMessage.data.isNotEmpty) {
    log('Message Data : ${remoteMessage.data}');
    log("Provider Message Image Url : ${remoteMessage.data["image_url"]} ");
  }
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Create separate channel for chat messages (like WhatsApp)
  final channelId = isChatMessage ? 'chat_messages' : 'notification';
  final channelName = isChatMessage ? 'Chat Messages' : 'Notification';
  final channelDescription = isChatMessage ? 'Notifications for chat messages' : 'General notifications';
  
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDescription,
    importance: Importance.high,
    enableLights: true,
    enableVibration: true,
    playSound: true,
    showBadge: true,
    sound: isChatMessage ? RawResourceAndroidNotificationSound('notification') : null,
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_stat_ic_notification');
  var iOS = const DarwinInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: false,
  );
  var macOS = iOS;
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: iOS, macOS: macOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (details) {
      handleNotificationClick(remoteMessage);
    },
  );

  // region image logic
  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // Helper function to copy asset to file path for notification icon
  Future<String> _copyAssetToFile(String assetPath, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final ByteData data = await rootBundle.load(assetPath);
    final File file = File(filePath);
    await file.writeAsBytes(data.buffer.asUint8List());
    return filePath;
  }

  BigPictureStyleInformation? bigPictureStyleInformation = remoteMessage.data.containsKey("image_url")
      ? BigPictureStyleInformation(
          FilePathAndroidBitmap(await _downloadAndSaveFile(remoteMessage.data["image_url"], 'bigPicture')),
          largeIcon: FilePathAndroidBitmap(await _downloadAndSaveFile(remoteMessage.data["image_url"], 'largeIcon')),
        )
      : null;
  // endregion

  // For chat messages, use messaging style like WhatsApp
  StyleInformation? styleInformation;
  if (isChatMessage && !remoteMessage.data.containsKey("image_url")) {
    // Use BigTextStyle for chat messages to show full message preview
    styleInformation = BigTextStyleInformation(
      message,
      contentTitle: title,
      summaryText: isChatMessage ? 'New message' : null,
    );
  } else if (remoteMessage.data.containsKey("image_url")) {
    styleInformation = bigPictureStyleInformation;
  }

  // Download profile image for chat messages if available (Laravel sends sender_avatar_url)
  String? profileImagePath;
  if (isChatMessage && !remoteMessage.data.containsKey("image_url")) {
    final avatarUrl = remoteMessage.data["sender_avatar_url"]?.toString() ?? 
                     remoteMessage.data["profile_image"]?.toString() ?? '';
    if (avatarUrl.isNotEmpty) {
      try {
        profileImagePath = await _downloadAndSaveFile(avatarUrl, 'profileIcon');
        log('Downloaded profile image: $profileImagePath');
      } catch (e) {
        log('Error downloading profile image: $e');
      }
    }
  }

  // Get default Frobster logo for notifications
  String? defaultLogoPath;
  try {
    defaultLogoPath = await _copyAssetToFile('assets/provider 36x36.png', 'frobster_logo_notification.png');
    log('Loaded Frobster logo for notification: $defaultLogoPath');
  } catch (e) {
    log('Error loading Frobster logo: $e');
  }

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.high,
    visibility: NotificationVisibility.public,
    autoCancel: true,
    playSound: true, // Always play sound for notifications
    enableVibration: true,
    priority: Priority.high,
    icon: '@drawable/ic_stat_ic_notification',
    largeIcon: remoteMessage.data.containsKey("image_url") 
        ? FilePathAndroidBitmap(await _downloadAndSaveFile(remoteMessage.data["image_url"], 'largeIcon'))
        : (profileImagePath != null
            ? FilePathAndroidBitmap(profileImagePath)
            : (defaultLogoPath != null
                ? FilePathAndroidBitmap(defaultLogoPath)
                : null)),
    styleInformation: styleInformation,
    ticker: isChatMessage ? message : null,
    category: isChatMessage ? AndroidNotificationCategory.message : AndroidNotificationCategory.status,
    // Ensure sound plays for chat messages
    sound: isChatMessage ? const RawResourceAndroidNotificationSound('notification') : null,
  );

  var darwinPlatformChannelSpecifics = const DarwinNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: darwinPlatformChannelSpecifics,
    macOS: darwinPlatformChannelSpecifics,
  );

  flutterLocalNotificationsPlugin.show(id, title, message, platformChannelSpecifics);
}
