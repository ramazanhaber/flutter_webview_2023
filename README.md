![aaa](https://user-images.githubusercontent.com/21096087/230883107-f2ec893c-492c-4ee5-9456-9605f1eed341.png)


kur : 

flutter pub add webview_flutter

flutter pub add webview_flutter_android

flutter pub add webview_flutter_wkwebview

flutter pub add url_launcher


package="com.ramzey.egitimwebview5">
<uses-permission android:name="android.permission.INTERNET" />
<application
    android:usesCleartextTraffic="true"
<!-- Provide required visibility configuration for API level 30 and above -->
    <queries>
        <!-- If your app checks for SMS support -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="sms" />
        </intent>
        <!-- If your app checks for call support -->
        <intent>
            <action android:name="android.intent.action.VIEW" />
            <data android:scheme="tel" />
        </intent>
    </queries>
</manifest>


1.1 ADIM -> info.plist e şunları ekle

<key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key><true/>
</dict>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>sms</string>
  <string>tel</string>
</array>



2. ADIM ->  ctrl+shift+f ile ara(in project) neyi "minsdkversion" u ve aşağdaki gibi yap o sayfadakiler
compileSdkVersion 33

minSdkVersion 19
targetSdkVersion 33

