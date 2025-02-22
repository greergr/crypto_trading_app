import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedNumber extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final TextStyle? style;
  final bool isPositive;
  
  const AnimatedNumber({
    Key? key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 2,
    this.style,
    this.isPositive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final displayValue = value.abs().toStringAsFixed(decimals);
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: AppTheme.animationDuration,
      curve: AppTheme.animationCurve,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.abs().toStringAsFixed(decimals)}$suffix',
          style: (style ?? AppTheme.headlineMedium).copyWith(
            color: color,
          ),
        );
      },
    );
  }
}
