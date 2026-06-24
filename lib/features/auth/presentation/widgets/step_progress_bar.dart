import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          final leftStep = i ~/ 2;
          final isCompleted = leftStep < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 3,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF001835)
                    : const Color(0xFFC4C6CF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        } else {
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentStep;
          final isCurrent = stepIndex == currentStep;
          return SizedBox(
            width: 56,
            child: _StepCircle(
              index: stepIndex,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              label: labels[stepIndex],
            ),
          );
        }
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isCompleted;
  final bool isCurrent;
  final String label;

  const _StepCircle({
    required this.index,
    required this.isCompleted,
    required this.isCurrent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Widget child;

    if (isCompleted) {
      bgColor = const Color(0xFF001835);
      borderColor = const Color(0xFF001835);
      child = const Icon(Icons.check_rounded, color: Colors.white, size: 16);
    } else if (isCurrent) {
      bgColor = Colors.white;
      borderColor = const Color(0xFF001835);
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF001835),
          fontFamily: 'Cairo',
        ),
      );
    } else {
      bgColor = const Color(0xFFF7F9FB);
      borderColor = const Color(0xFFC4C6CF);
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF74777F),
          fontFamily: 'Cairo',
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutBack,
          width: isCurrent ? 36 : 30,
          height: isCurrent ? 36 : 30,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFF001835).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Cairo',
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent
                ? const Color(0xFF001835)
                : isCompleted
                    ? const Color(0xFF001835)
                    : const Color(0xFF74777F),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
