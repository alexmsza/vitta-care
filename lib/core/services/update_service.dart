import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitta/core/theme/app_colors.dart';
import 'package:vitta/core/config/api_config.dart';

class UpdateService {
  static const String _versionEndpoint = ApiConfig.versionEndpoint;

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest version from API
      // Note: In a real scenario, you probably want to use a real HTTP client with timeout
      final response = await http.get(Uri.parse(_versionEndpoint)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('Error', 408),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['latest_version'] as String;
        final downloadUrl = data['download_url'] as String;
        final forceUpdate = data['force_update'] as bool? ?? false;

        // 3. Compare versions (Simple string comparison for MVP)
        // Ideally use a semantic version parser
        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          if (context.mounted) {
            _showUpdateDialog(context, latestVersion, downloadUrl, forceUpdate);
          }
        }
      }
    } catch (e) {
      // Fail silently for network errors on update check
      debugPrint('Update check failed: $e');
    }
  }

  bool _isUpdateAvailable(String current, String latest) {
    // Very basic comparison.
    // For production, split by '.' and compare integers (major, minor, patch)
    return current != latest;
  }

  void _showUpdateDialog(
      BuildContext context, String version, String url, bool force) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (context) => AlertDialog(
        title: const Text('Nova Versão Disponível'),
        content: Text(
            'A versão $version do Vitta está disponível. Atualize para ter as últimas novidades.'),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Depois', style: TextStyle(color: Colors.grey)),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              _launchURL(url);
              if (!force) Navigator.pop(context);
            },
            child: const Text('Atualizar Agora',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
