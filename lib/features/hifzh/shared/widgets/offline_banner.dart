/// Offline banner widget for HifdhTracker.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_project/features/hifzh/core/services/connectivity_service.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';

/// A slim animated banner that slides down from the top when offline.
///
/// Place this at the top of [HifzhShellPage]'s body so it appears on
/// all tabs. It auto-dismisses when connectivity is restored.
class HifzhOfflineBanner extends StatefulWidget {
  /// Creates a [HifzhOfflineBanner].
  const HifzhOfflineBanner({
    super.key,
    required this.service,
    required this.child,
  });

  /// The connectivity service to listen to.
  final HifzhConnectivityService service;

  /// The child widget rendered below the banner.
  final Widget child;

  @override
  State<HifzhOfflineBanner> createState() => _HifzhOfflineBannerState();
}

class _HifzhOfflineBannerState extends State<HifzhOfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _sub = widget.service.isConnected.listen((online) {
      if (!mounted) return;
      setState(() => _isOffline = !online);
      if (_isOffline) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Offline banner ──────────────────────────────────────────────
        SlideTransition(
          position: _slide,
          child:
              _isOffline
                  ? Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.tertiary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            HifzhStrings.offlineBanner,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
        // ── Content ─────────────────────────────────────────────────────
        Expanded(child: widget.child),
      ],
    );
  }
}
