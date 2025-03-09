import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: "AIzaSyDvwpHUI05hbk-IRBbJLAR0VqMxAqZDdQY", // From "api_key" -> "current_key"
      authDomain: "currensee-6067f.firebaseapp.com", // Firebase provides this for web
      projectId: "currensee-6067f", // From "project_info" -> "project_id"
      storageBucket: "currensee-6067f.firebasestorage.app", // From "project_info" -> "storage_bucket"
      messagingSenderId: "104481714202", // You might need to get this from Firebase Console
      appId: "1:104481714202:android:24ea970a0f6baf5ab021a3", // From "mobilesdk_app_id"
      measurementId: "", // Optional: Only for Web (Get from Firebase Analytics)
    );
  }
}
