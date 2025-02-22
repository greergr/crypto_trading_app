import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ParticleBackground extends StatefulWidget {
  final int numberOfParticles;
  final Color particleColor;
  
  const ParticleBackground({
    Key? key,
    this.numberOfParticles = 50,
    this.particleColor = AppTheme.primaryColor,
  }) : super(key: key);

  @override
  _ParticleBackgroundState createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    particles = List.generate(
      widget.numberOfParticles,
      (index) => Particle.random(),
    );

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..addListener(() {
        for (var particle in particles) {
          particle.update();
        }
        setState(() {});
      });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ParticlePainter(
        particles: particles,
        color: widget.particleColor,
      ),
      child: Container(),
    );
  }
}

class Particle {
  double x;
  double y;
  double speed;
  double theta;
  double radius;

  Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.theta,
    required this.radius,
  });

  factory Particle.random() {
    final random = Random();
    return Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      speed: random.nextDouble() * 0.0002 + 0.0001,
      theta: random.nextDouble() * 2 * pi,
      radius: random.nextDouble() * 2 + 1,
    );
  }

  void update() {
    x += cos(theta) * speed;
    y += sin(theta) * speed;

    if (x < 0) {
      x = 1;
    } else if (x > 1) {
      x = 0;
    }

    if (y < 0) {
      y = 1;
    } else if (y > 1) {
      y = 0;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;

  ParticlePainter({
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.radius,
        paint,
      );

      // رسم الخطوط بين الجزيئات القريبة
      for (var other in particles) {
        final dx = (particle.x - other.x) * size.width;
        final dy = (particle.y - other.y) * size.height;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < 100) {
          canvas.drawLine(
            Offset(particle.x * size.width, particle.y * size.height),
            Offset(other.x * size.width, other.y * size.height),
            Paint()
              ..color = color.withOpacity(0.2 * (1 - distance / 100))
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
