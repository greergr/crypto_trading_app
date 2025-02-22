import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final double height;
  final VoidCallback? onTap;
  
  const GradientCard({
    Key? key,
    required this.child,
    this.colors = const [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
    ],
    this.height = 200,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.borderRadius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.borderRadius,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppTheme.borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
