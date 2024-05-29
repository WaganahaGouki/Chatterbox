import 'package:permission_handler/permission_handler.dart';

Future<void> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    await Permission.microphone.request();
  } else if (status.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this app. The only way to change the permission's status now is to let the user manually enable it in the system settings.
    await openAppSettings();
  }
}