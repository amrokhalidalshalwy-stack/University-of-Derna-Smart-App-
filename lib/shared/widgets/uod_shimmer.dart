import 'package:flutter/material.dart';

class UodShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? child; // إضافة الـ child لدعم الصفحات القديمة

  const UodShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.child,
  });

  // تحديث الـ round ليقبل المعلمات الاختيارية والـ child لتفادي أخطاء البروفايل
  const UodShimmer.round({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 60, // قيمة افتراضية في حال لم يتم تمريرها
      height: height ?? 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape:
            borderRadius == null && child != null
                ? BoxShape.circle
                : BoxShape.rectangle,
        borderRadius:
            borderRadius ?? (child != null ? null : BorderRadius.circular(8)),
      ),
      child: child,
    );
  }
}

class UodScreenLoading extends StatelessWidget {
  const UodScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}