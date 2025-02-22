import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  const ShimmerLoading({
    Key? key,
    required this.child,
    required this.isLoading,
  }) : super(key: key);

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Container(
        color: Colors.grey.shade300,
        child: widget.child,
      ),
    );
  }
}
