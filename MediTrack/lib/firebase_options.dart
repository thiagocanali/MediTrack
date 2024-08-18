import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCjlibsQIy3vi2sJmC6kmFygfyjVVXbeUM",
    authDomain: "meditrack-4456e.firebaseapp.com",
    projectId: "meditrack-4456e",
    storageBucket: "meditrack-4456e.appspot.com",
    messagingSenderId: "104432061302",
    appId: "1:104432061302:web:2d7d56b5803cfb6070c857",
    measurementId: "G-VXPQ7RMX73",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCjlibsQIy3vi2sJmC6kmFygfyjVVXbeUM",
    appId: "1:104432061302:web:2d7d56b5803cfb6070c857",
    messagingSenderId: "104432061302",
    projectId: "meditrack-4456e",
    storageBucket: "meditrack-4456e.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCjlibsQIy3vi2sJmC6kmFygfyjVVXbeUM",
    appId: "app-1-104432061302-ios-1f7989c0a613d3dc70c857",
    messagingSenderId: "104432061302",
    projectId: "meditrack-4456e",
    storageBucket: "meditrack-4456e.appspot.com",
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "AIzaSyCjlibsQIy3vi2sJmC6kmFygfyjVVXbeUM",
    appId: "app-1-104432061302-ios-1f7989c0a613d3dc70c857",
    messagingSenderId: "104432061302",
    projectId: "meditrack-4456e",
    storageBucket: "meditrack-4456e.appspot.com",
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  );
}
