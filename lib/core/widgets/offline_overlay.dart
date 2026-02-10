import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:noor_energy/core/constants/app_colors.dart';
import 'package:noor_energy/l10n/app_localizations.dart';

/// Shows a full-screen overlay when the device is offline, blocking interaction
/// and displaying a friendly message asking the user to connect to the internet.
class OfflineOverlay extends StatefulWidget {
  const OfflineOverlay({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<OfflineOverlay> createState() => _OfflineOverlayState();
}

class _OfflineOverlayState extends State<OfflineOverlay> {
  final Connectivity _connectivity = Connectivity();
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final result = await _connectivity.checkConnectivity();
    _updateOffline(result);
  }

  void _onConnectivityChanged(List<ConnectivityResult> result) {
    _updateOffline(result);
  }

  void _updateOffline(List<ConnectivityResult> result) {
    final offline = result.isEmpty ||
        result.every((r) => r == ConnectivityResult.none);
    if (mounted && _isOffline != offline) {
      setState(() => _isOffline = offline);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline) _buildOverlay(context),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final title = loc?.offlineTitle ?? 'No connection';
    final message = loc?.offlineMessage ?? 'Please connect to the internet to use the app.';

    return Positioned.fill(
      child: Material(
        color: Colors.black54,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 72,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
