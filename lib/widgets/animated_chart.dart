import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class AnimatedChart extends StatefulWidget {
  final List<FlSpot> data;
  final String title;
  final bool showLabels;
  final Color lineColor;
  final Color fillColor;
  final double minY;
  final double maxY;
  
  const AnimatedChart({
    Key? key,
    required this.data,
    this.title = '',
    this.showLabels = true,
    this.lineColor = AppTheme.primaryColor,
    this.fillColor = AppTheme.accentColor,
    this.minY = 0,
    this.maxY = 100,
  }) : super(key: key);

  @override
  _AnimatedChartState createState() => _AnimatedChartState();
}

class _AnimatedChartState extends State<AnimatedChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<FlSpot> _currentData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _currentData = List.from(oldWidget.data);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final animatedData = List.generate(
          widget.data.length,
          (index) {
            final spot = widget.data[index];
            final oldSpot = _currentData.length > index
                ? _currentData[index]
                : FlSpot(spot.x, widget.minY);
                
            return FlSpot(
              spot.x,
              lerpDouble(oldSpot.y, spot.y, _animation.value)!,
            );
          },
        );

        return Column(
          children: [
            if (widget.title.isNotEmpty) ...[
              Text(
                widget.title,
                style: AppTheme.headlineSmall,
              ),
              SizedBox(height: AppTheme.spacing * 2),
            ],
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: widget.showLabels,
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTextStyles: (context, value) => TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      margin: 8,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (context, value) => TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      reservedSize: 28,
                      margin: 12,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: widget.data.length.toDouble() - 1,
                  minY: widget.minY,
                  maxY: widget.maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: animatedData,
                      isCurved: true,
                      colors: [widget.lineColor],
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        colors: [
                          widget.fillColor.withOpacity(0.3),
                          widget.fillColor.withOpacity(0.0),
                        ],
                        gradientFrom: Offset(0, 0),
                        gradientTo: Offset(0, 1),
                      ),
                    ),
                  ],
                ),
                swapAnimationDuration: Duration(milliseconds: 250),
              ),
            ),
          ],
        );
      },
    );
  }
  
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
