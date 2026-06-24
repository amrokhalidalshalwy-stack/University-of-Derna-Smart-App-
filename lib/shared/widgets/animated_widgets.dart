import 'package:flutter/material.dart';
import 'package:flutter_project/core/theme/app_animations.dart';

bool shouldAnimate(BuildContext context) {
  return MediaQuery.of(context).disableAnimations != true;
}

class StaggeredFadeInSlideY extends StatelessWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double beginOffset;

  const StaggeredFadeInSlideY({
    super.key,
    required this.child,
    required this.index,
    this.duration = AppAnimations.normal,
    this.beginOffset = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate(context)) {
      return child;
    }
    final clampedIndex = index.clamp(0, 6);
    final delay = AppAnimations.staggerDelay(clampedIndex);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration + delay,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, beginOffset * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class SlideInX extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double beginOffset;
  final bool isRTL;

  const SlideInX({
    super.key,
    required this.child,
    this.duration = AppAnimations.normal,
    this.beginOffset = 0.3,
    this.isRTL = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate(context)) {
      return child;
    }
    final direction = isRTL ? 1.0 : -1.0;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(beginOffset * direction * (1 - value), 0),
          child: child,
        );
      },
      child: child,
    );
  }
}

class FadeInScale extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeInScale({
    super.key,
    required this.child,
    this.duration = AppAnimations.normal,
  });

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.95,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown() {
    _controller.forward();
  }

  void _handleTapUp() {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldAnimate(context)) {
      return GestureDetector(
        onTap: widget.onTap,
        child: widget.child,
      );
    }
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) {
        _handleTapUp();
        widget.onTap?.call();
      },
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
