import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double width;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () {
                  HapticFeedback.lightImpact();
                  onPressed?.call();
                },
        child:
            isLoading
                ? Shimmer.fromColors(
                  baseColor: Colors.white24,
                  highlightColor: Colors.white54,
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
                : Text(text),
      ),
    );
  }
}
