import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/utils/hive_keys.dart';

/// Full-screen splash overlay showing two mantras, fading out once
/// the app content has finished its first render.
///
/// Reads language and theme directly from the already-open Hive box so
/// the correct text and colours appear before any Riverpod provider fires.
class SplashOverlay extends StatefulWidget {
  final Widget child;

  const SplashOverlay({super.key, required this.child});

  @override
  State<SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<SplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  bool _visible = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fades the splash FROM fully opaque TO transparent
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Wait for the first frame to render, then show mantras briefly,
    // then fade out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1600), () {
        if (!mounted) return;
        _controller.forward().then((_) {
          if (mounted) setState(() => _visible = false);
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;

    // Read persisted settings from Hive — box is already open by main()
    final Box box = Hive.box(HiveKeys.settingsBox);
    final bool isTelugu =
        (box.get(HiveKeys.language, defaultValue: 'te') as String) == 'te';
    final String storedTheme =
        box.get(HiveKeys.themeMode, defaultValue: 'system') as String;

    // Determine dark/light
    final Brightness platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final bool useDark = storedTheme == 'dark' ||
        (storedTheme == 'system' && platformBrightness == Brightness.dark);

    final Color bgColor =
        useDark ? const Color(0xFF121212) : const Color(0xFFFFFDF7);
    final Color textColor =
        useDark ? const Color(0xFFE8D5B7) : const Color(0xFF6B2E1F);
    final Color subtleColor =
        useDark ? const Color(0xFF8B7355) : const Color(0xFFB07045);

    final String mantra1 = isTelugu
        ? 'ఓం నమో భగవతే రుద్రాయ'
        : 'Om Namo Bhagavate Rudraya';
    final String mantra2 = isTelugu
        ? 'ఓం నమో భగవతే వాసుదేవాయ'
        : 'Om Namo Bhagavate Vasudevaya';

    // Font size: Telugu script renders slightly larger visually
    final double fontSize = isTelugu ? 21.0 : 19.0;

    return Stack(
      children: [
        // The real app renders underneath — content is ready when splash fades
        widget.child,

        // Splash overlay
        FadeTransition(
          opacity: _opacity,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: bgColor,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        mantra1,
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.6,
                          height: 1.5,
                          decoration: TextDecoration.none,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        mantra2,
                        style: TextStyle(
                          color: subtleColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.6,
                          height: 1.5,
                          decoration: TextDecoration.none,
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
      ],
    );
  }
}
