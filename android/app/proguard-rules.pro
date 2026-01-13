# Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.firebase.messaging.FirebaseMessagingService <methods>;
}

# WebView
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
    public void *(android.webkit.WebView, java.lang.String);
}
