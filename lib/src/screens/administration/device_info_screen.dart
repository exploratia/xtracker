import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../util/date_time_utils.dart';
import '../../util/dialogs.dart';
import '../../util/json_utils.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/media_query_utils.dart';
import '../../util/theme_utils.dart';
import '../../widgets/administration/device_info_view.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/popupmenu/icon_popup_menu.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class DeviceInfoScreen extends StatefulWidget {
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.perm_device_info_outlined,
    routeName: '/device_info_screen',
    titleBuilder: () => LocaleKeys.deviceInfo_title.tr(),
  );

  const DeviceInfoScreen({super.key});

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static final List<String> _deviceInfoKeysBlacklist = [
    "board",
    "bootloader",
    "fingerprint",
    "host",
    "id",
    "name",
    "serialNumber",
    "supported32BitAbis",
    "supported64BitAbis",
    "supportedAbis",
    "systemFeatures",
    "version.previewSdkInt",
  ];
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  final Map<String, dynamic> _deviceScreenData = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQueryUtils.of(context).mediaQueryData;
      final size = mediaQuery.size;
      final devicePixelRatio = mediaQuery.devicePixelRatio;
      final physicalWidth = size.width * devicePixelRatio;
      final physicalHeight = size.height * devicePixelRatio;
      final padding = mediaQuery.padding;
      final textScaler = mediaQuery.textScaler;
      setState(() {
        _deviceScreenData["Logical Size (dp)"] = "${size.width.toStringAsFixed(2)} × ${size.height.toStringAsFixed(2)}";
        _deviceScreenData["Device Pixel Ratio"] = devicePixelRatio;
        _deviceScreenData["Physical Pixels"] = "${physicalWidth.toStringAsFixed(0)} × ${physicalHeight.toStringAsFixed(0)}";
        _deviceScreenData["Text scale ~"] = (textScaler.scale(1) * 1000).round() / 1000;

        _deviceScreenData["Safe Area Top"] = "${padding.top.toStringAsFixed(2)} dp";
        _deviceScreenData["Safe Area Bottom"] = "${padding.bottom.toStringAsFixed(2)} dp";
        _deviceScreenData["Safe Area Left"] = "${padding.left.toStringAsFixed(2)} dp";
        _deviceScreenData["Safe Area Right"] = "${padding.right.toStringAsFixed(2)} dp";
      });
    });
  }

  Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        deviceData = switch (defaultTargetPlatform) {
          TargetPlatform.android => _readAndroidBuildData(await deviceInfoPlugin.androidInfo),
          TargetPlatform.iOS => _readIosDeviceInfo(await deviceInfoPlugin.iosInfo),
          TargetPlatform.linux => _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo),
          TargetPlatform.windows => _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo),
          TargetPlatform.macOS => _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo),
          TargetPlatform.fuchsia => <String, dynamic>{'Error:': 'Fuchsia platform isn\'t supported'},
        };
      }
    } on PlatformException {
      deviceData = <String, dynamic>{'Error:': 'Failed to get platform version.'};
    }

    if (!mounted) return;

    // clear blacklisted
    deviceData.removeWhere((key, value) => _deviceInfoKeysBlacklist.contains(key));

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'name': build.name,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'freeDiskSize': build.freeDiskSize,
      'totalDiskSize': build.totalDiskSize,
      'systemFeatures': build.systemFeatures,
      'serialNumber': build.serialNumber,
      'isLowRamDevice': build.isLowRamDevice,
      'physicalRamSize': build.physicalRamSize,
      'availableRamSize': build.availableRamSize,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'modelName': data.modelName,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'isiOSAppOnMac': data.isiOSAppOnMac,
      'freeDiskSize': data.freeDiskSize,
      'totalDiskSize': data.totalDiskSize,
      'physicalRamSize': data.physicalRamSize,
      'availableRamSize': data.availableRamSize,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.name,
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'modelName': data.modelName,
      'kernelVersion': data.kernelVersion,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'patchVersion': data.patchVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'csdVersion': data.csdVersion,
      'servicePackMajor': data.servicePackMajor,
      'servicePackMinor': data.servicePackMinor,
      'suitMask': data.suitMask,
      'productType': data.productType,
      'reserved': data.reserved,
      'buildLab': data.buildLab,
      'buildLabEx': data.buildLabEx,
      'digitalProductId': data.digitalProductId,
      'displayVersion': data.displayVersion,
      'editionId': data.editionId,
      'installDate': data.installDate,
      'productId': data.productId,
      'productName': data.productName,
      'registeredOwner': data.registeredOwner,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  Map<String, dynamic> _buildExportableJson() {
    Map<String, dynamic> device = {};

    final keys = _deviceData.keys.toList();
    keys.sort();
    for (var key in keys) {
      var value = _deviceData[key];
      if (value is num) {
        device[key] = value;
      } else {
        device[key] = value.toString();
      }
    }

    return {"device": device, "screen": _deviceScreenData};
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: DeviceInfoScreen.navItem,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(DeviceInfoScreen.navItem.titleBuilder()),
        actions: [
          Tooltip(
            message: LocaleKeys.deviceInfo_action_exportOrShare_tooltip.tr(),
            child: IconPopupMenu(
              icon: const Icon(Icons.download_outlined),
              menuEntries: [
                _buildExportIconPopupMenuEntry(context),
                _buildShareIconPopupMenuEntry(context),
              ],
            ),
          ),
          const SizedBox(width: ThemeUtils.defaultPadding),
        ],
      ),
      bodyBuilder: (context) => DeviceInfoView(deviceData: _deviceData, screenData: _deviceScreenData),
    );
  }

  IconPopupMenuEntry _buildExportIconPopupMenuEntry(BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.download_outlined),
      () async {
        try {
          bool exported = await JsonUtils.exportJsonFile(_buildExportableJson(), 'xtracker_device_info_${DateTimeUtils.formatExportDateTime()}.json');
          if (exported) {
            SimpleLogging.i('Successfully exported device info.');
            if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_exportSuccess.tr(), context);
          }
        } catch (ex) {
          SimpleLogging.w("Failed to export device info.", error: ex);
          if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_exportFailed, context);
        }
      },
      LocaleKeys.deviceInfo_action_export_tooltip.tr(),
    );
  }

  IconPopupMenuEntry _buildShareIconPopupMenuEntry(BuildContext context) {
    return IconPopupMenuEntry(
      const Icon(Icons.share_outlined),
      () async {
        try {
          bool shared = await JsonUtils.shareJsonFile(_buildExportableJson(), 'xtracker_device_info_${DateTimeUtils.formatExportDateTime()}.json');
          if (shared) {
            SimpleLogging.i('Successfully shared device info.');
            if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_shareSuccess.tr(), context);
          }
        } catch (ex) {
          SimpleLogging.w('Failed to share series device info.', error: ex);
          if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_shareFailed, context);
        }
      },
      LocaleKeys.deviceInfo_action_share_tooltip.tr(),
    );
  }
}
