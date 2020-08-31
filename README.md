# react-native-pjsip-builder

Easily build PJSIP with: OpenSSL, OpenH264, Opus and G.729 for Android and iOS, by using Docker and xCode.

## Versions

| Library     | Android Version | iOS Version |
| ----------- | --------------- | ----------- |
| Android API | 26              | N/A         |
| Android NDK | r21d            | N/A         |
| PJSIP       | 2.10            | 2.10        |
| OPENSSL     | 1.1.1g          | 1.1.1d      |
| OPENH264    | 2.1.0           | 2.0.0       |
| OPUS        | 1.3.1           | 1.3.1       |

## Build for Android

```
git clone git@github.com:tariq86/react-native-pjsip-builder.git
cd react-native-pjsip-builder
```

Before starting the build, you will need to copy you Android SDK licenses file from your local SDK installation to `./android/android-sdk-licenses`. See [this page](https://developer.android.com/studio/intro/update.html#download-with-gradle) for mor info.

Once you've got that file in place, run `./build_android` to start the process.

## Build for iOS

The iOS build is provided by https://github.com/VoIPGRID/Vialer-pjsip-iOS

```
./build_ios.sh
```
