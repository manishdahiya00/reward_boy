import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Future<Map<String, String>> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;

    String deviceId;
    String deviceType;
    String deviceName;
    String versionName = 'Unknown';
    String versionCode = 'Unknown';

    String baseUrl = "https://bf11-152-58-102-169.ngrok-free.app/api/v1/";

    if (deviceInfo is AndroidDeviceInfo) {
      deviceId = deviceInfo.model;
      deviceType = "Android";
      deviceName = deviceInfo.brand;
      versionName = deviceInfo.version.release;
      versionCode = deviceInfo.version.sdkInt.toString();
    } else if (deviceInfo is IosDeviceInfo) {
      deviceId = deviceInfo.identifierForVendor!;
      deviceType = "iOS";
      deviceName = deviceInfo.model;
      versionName = deviceInfo.systemVersion;
      versionCode = deviceInfo.utsname.version;
    } else {
      deviceId = "Unknown";
      deviceType = "Unknown";
      deviceName = "Unknown";
    }

    return {
      "deviceId": deviceId,
      "deviceType": deviceType,
      "deviceName": deviceName,
      "versionName": versionName,
      "versionCode": versionCode,
      "baseUrl": baseUrl
    };
  }

  static Future<Map<String, String>> getAppVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;

    return {
      "versionName": versionName,
      "versionCode": versionCode,
    };
  }

  static Future<void> saveUTMParams(Map<String, String> utmParams) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    utmParams.forEach((key, value) async {
      await prefs.setString(key, value);
    });
  }

  static Future<Map<String, String>> getUTMParams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String> utmParams = {
      "utmSource": prefs.getString('utmSource') ?? '',
      "utmMedium": prefs.getString('utmMedium') ?? '',
      "utmCampaign": prefs.getString('utmCampaign') ?? '',
      "utmContent": prefs.getString('utmContent') ?? '',
      "utmTerm": prefs.getString('utmTerm') ?? ''
    };
    return utmParams;
  }

  static Future<Map<String, String>> collectAllInfo() async {
    Map<String, String> deviceInfo = await getDeviceInfo();
    Map<String, String> appVersionInfo = await getAppVersionInfo();
    Map<String, String> utmParams = await getUTMParams();

    return {...deviceInfo, ...appVersionInfo, ...utmParams};
  }
}
