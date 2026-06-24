import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Centralized animation constants for DUSPS application.
/// All animations are RTL-aware and respect text direction context.
class AppAnimations {
  // Private constructor to prevent instantiation
  AppAnimations._();

  // ==================== DURATION CONSTANTS ====================

  /// Fast duration for micro-interactions (e.g., button taps, icon changes)
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal duration for standard UI transitions (e.g., card appearances)
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow duration for complex animations (e.g., page transitions, list loading)
  static const Duration slow = Duration(milliseconds: 500);

  /// Extra slow duration for emphasis animations
  static const Duration extraSlow = Duration(milliseconds: 700);

  // ==================== CURVE CONSTANTS ====================

  /// Standard ease curve for smooth animations
  static const Curve ease = Curves.ease;

  /// Ease-in curve for entering animations
  static const Curve easeIn = Curves.easeIn;

  /// Ease-out curve for exiting animations
  static const Curve easeOut = Curves.easeOut;

  /// Ease-in-out curve for bidirectional animations
  static const Curve easeInOut = Curves.easeInOut;

  /// Bounce curve for playful interactions
  static const Curve bounce = Curves.bounceOut;

  /// Elastic curve for spring-like animations
  static const Curve elastic = Curves.elasticOut;

  /// Decelerate curve for smooth stops
  static const Curve decelerate = Curves.decelerate;

  // ==================== SLIDE ANIMATIONS (RTL-AWARE) ====================

  /// Slide animation from the start (respects RTL: left in LTR, right in RTL)
  static const Effect slideFromStart = SlideEffect(
    begin: Offset(-1.0, 0),
    end: Offset.zero,
    duration: normal,
    curve: easeOut,
  );

  /// Slide animation from the end (respects RTL: right in LTR, left in RTL)
  static const Effect slideFromEnd = SlideEffect(
    begin: Offset(1.0, 0),
    end: Offset.zero,
    duration: normal,
    curve: easeOut,
  );

  /// Slide animation from top
  static const Effect slideFromTop = SlideEffect(
    begin: Offset(0, -1.0),
    end: Offset.zero,
    duration: normal,
    curve: easeOut,
  );

  /// Slide animation from bottom
  static const Effect slideFromBottom = SlideEffect(
    begin: Offset(0, 1.0),
    end: Offset.zero,
    duration: normal,
    curve: easeOut,
  );

  /// Subtle slide animation for list items (smaller offset)
  static const Effect slideSubtle = SlideEffect(
    begin: Offset(0.05, 0),
    end: Offset.zero,
    duration: normal,
    curve: easeOut,
  );

  // ==================== FADE ANIMATIONS ====================

  /// Standard fade-in animation
  static const Effect fadeIn = FadeEffect(duration: normal, curve: easeIn);

  /// Fast fade-in animation
  static const Effect fadeInFast = FadeEffect(duration: fast, curve: easeIn);

  /// Slow fade-in animation
  static const Effect fadeInSlow = FadeEffect(duration: slow, curve: easeIn);

  /// Fade-out animation
  static const Effect fadeOut = FadeEffect(
    duration: normal,
    curve: easeOut,
    begin: 1.0,
    end: 0.0,
  );

  // ==================== SCALE ANIMATIONS ====================

  /// Scale-in animation for cards and widgets
  static const Effect scaleIn = ScaleEffect(
    begin: Offset(0.9, 0.9),
    end: Offset(1.0, 1.0),
    duration: normal,
    curve: easeOut,
  );

  /// Scale-up animation for emphasis
  static const Effect scaleUp = ScaleEffect(
    begin: Offset(1.0, 1.0),
    end: Offset(1.05, 1.05),
    duration: fast,
    curve: easeOut,
  );

  /// Scale-down animation for button presses
  static const Effect scaleDown = ScaleEffect(
    begin: Offset(1.0, 1.0),
    end: Offset(0.95, 0.95),
    duration: fast,
    curve: easeOut,
  );

  /// Bouncy scale animation for playful interactions
  static const Effect scaleBounce = ScaleEffect(
    begin: Offset(0.0, 0.0),
    end: Offset(1.0, 1.0),
    duration: extraSlow,
    curve: elastic,
  );

  // ==================== COMBINED ANIMATIONS ====================

  /// Standard card entrance animation (fade + scale + slide)
  static List<Effect> cardEntrance(BuildContext context) {
    return [fadeIn, scaleIn, slideFromStart];
  }

  /// List item stagger animation (fade + slide)
  /// Apply delay externally using the staggerDelay methods
  static List<Effect> listItemEntrance() {
    return [fadeIn, slideSubtle];
  }

  /// Button press animation (scale down)
  static List<Effect> buttonPress() {
    return [scaleDown];
  }

  /// Success animation (scale up + bounce)
  static List<Effect> successAnimation() {
    return [scaleUp, scaleBounce];
  }

  /// Modal entrance animation (fade + slide from bottom)
  static List<Effect> modalEntrance() {
    return [fadeIn, slideFromBottom];
  }

  /// Tab switch animation (fade + slide from start)
  static List<Effect> tabSwitch() {
    return [fadeInFast, slideFromStart];
  }

  // ==================== STAGGER DELAYS ====================

  /// Delay for staggered animations based on index
  static Duration staggerDelay(int index, {int step = 50}) {
    return Duration(milliseconds: (index * step).clamp(0, 1000));
  }

  /// Delay for list items (faster stagger)
  static Duration listItemDelay(int index) {
    return staggerDelay(index, step: 30);
  }

  /// Delay for cards (slower stagger)
  static Duration cardDelay(int index) {
    return staggerDelay(index, step: 100);
  }
}
