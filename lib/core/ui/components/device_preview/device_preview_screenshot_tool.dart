import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_settings.dart';
import '../../../functions/download_path.dart';
import '../../../functions/storage_permission.dart';
import '../../snackbar/overlay_snackbar.dart';
import '../../snackbar/scaffold_snackbar.dart';

class DevicePreviewScreenshotTool extends StatefulWidget {
  const DevicePreviewScreenshotTool({super.key});

  @override
  State<DevicePreviewScreenshotTool> createState() =>
      _DevicePreviewScreenshotToolState();
}

class _DevicePreviewScreenshotToolState
    extends State<DevicePreviewScreenshotTool> {
  Future<void> _takeScreenshot() async {
    try {
      final hasPermission = await StoragePermission.request();
      if (!hasPermission) {
        if (mounted) {
          showSnackbar('Storage permission denied');
        }
        return;
      }

      final downloadPath = await DownloadPath.get();
      if (downloadPath == null) {
        if (mounted) {
          showSnackbar('Could not determine download path');
        }
        return;
      }

      final dirPath = '$downloadPath/${AppSettings.appName}/screenshots';
      await Directory(dirPath).create(recursive: true);

      if (!mounted) {
        return;
      }
      final screenshot = await DevicePreview.screenshot(context);

      if (!mounted) {
        return;
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await File('$dirPath/$timestamp.png').writeAsBytes(screenshot.bytes);

      if (mounted) {
        showSnackbar(
          'Screenshot saved successfully',
          type: OverlaySnackbarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
          'Failed to save screenshot: $e',
          type: OverlaySnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolPanelSection(
      title: 'Screenshots',
      children: [
        ListTile(
          title: const Text('Take Screenshot'),
          subtitle: const Text(
            'Path: Download/${AppSettings.appName}/screenshots',
          ),
          trailing: const Icon(Icons.camera_alt),
          onTap: _takeScreenshot,
        ),
      ],
    );
  }
}
