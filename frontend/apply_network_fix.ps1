# Fix: Android blocking cleartext HTTP traffic to the dev backend
# Adds INTERNET permission + network_security_config allowing http:// to 192.168.1.18

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\android\app\src\main\AndroidManifest.xml"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <application
        android:label="AI Mentor"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:networkSecurityConfig="@xml/network_security_config">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"

$path = "C:\Users\ABC\Desktop\AI_Mentor\frontend\android\app\src\main\res\xml\network_security_config.xml"
New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
$content = @'
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allows plain http:// (cleartext) traffic to the local dev backend only.
         Android blocks cleartext traffic by default for targetSdk 28+, which was
         silently breaking every login/register/API call in debug builds. -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="false">192.168.1.18</domain>
        <domain includeSubdomains="false">10.0.2.2</domain>
        <domain includeSubdomains="false">localhost</domain>
    </domain-config>
</network-security-config>
'@
[System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Written: $path"
