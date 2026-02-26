import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoRotationAnimation;

  late AnimationController _textController;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;

  late AnimationController _particleController;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Logo Animation Setup - Enhanced
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Text Animation Setup
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _textSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );

    // Particle Animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Start Animations
    _logoController.forward().then((_) {
      _textController.forward();
    });

    // Navigate to Home after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A237E), // Deep Indigo
              const Color(0xFF283593), // Indigo
              const Color(0xFF3949AB), // Medium Indigo
              const Color(0xFF5C6BC0), // Light Indigo
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated Gradient Overlay
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.5 + (_particleAnimation.value - 0.5) * 0.2,
                        0.5 + (_particleAnimation.value - 0.5) * 0.2,
                      ),
                      radius: 0.8 + _particleAnimation.value * 0.3,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),

            // Floating Particles
            ...List.generate(15, (index) {
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Positioned(
                    left: (index * 30.0) % MediaQuery.of(context).size.width,
                    top: (index * 40.0 + _particleController.value * 100) % MediaQuery.of(context).size.height,
                    child: Opacity(
                      opacity: 0.1 + (index % 3) * 0.1,
                      child: Container(
                        width: 2 + (index % 4) * 2.0,
                        height: 2 + (index % 4) * 2.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Background Decorations - Enhanced
            Positioned(
              top: -100,
              right: -100,
              child: AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _particleAnimation.value * 2,
                    child: _buildGlassmorphicCircle(350, Colors.white.withOpacity(0.03)),
                  );
                },
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: AnimatedBuilder(
                animation: _particleAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_particleAnimation.value * 1.5,
                    child: _buildGlassmorphicCircle(250, Colors.white.withOpacity(0.03)),
                  );
                },
              ),
            ),
            
            // Main Content with Glassmorphism effect
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Enhanced Animation
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoFadeAnimation.value,
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Transform.rotate(
                            angle: _logoRotationAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.blue.shade50,
                                    Colors.indigo.shade50,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: Colors.blue.shade400.withOpacity(0.6),
                                    blurRadius: 70,
                                    spreadRadius: 10,
                                  ),
                                  BoxShadow(
                                    color: Colors.indigo.shade500.withOpacity(0.4),
                                    blurRadius: 100,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Inner glow
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          blurRadius: 30,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Main icon
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 90,
                                    color: Colors.indigo.shade700,
                                  ),
                                  // Small decorative stars
                                  Positioned(
                                    top: 15,
                                    right: 15,
                                    child: Icon(
                                      Icons.star,
                                      size: 20,
                                      color: Colors.amber.shade400,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 20,
                                    left: 20,
                                    child: Icon(
                                      Icons.star_half,
                                      size: 16,
                                      color: Colors.amber.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  
                  // App Name with Enhanced Animation and Styling
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [Colors.white, Colors.blue.shade200],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      "AI Schedule",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2.5,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black38,
                                            offset: Offset(0, 6),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      "GENERATOR",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 10.0,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Tagline with fade in
                              AnimatedBuilder(
                                animation: _textController,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _textFadeAnimation.value * 0.7,
                                    child: Text(
                                      "Optimize Your Time with AI",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Enhanced Bottom Indicator with Animation
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _particleController,
                      builder: (context, child) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 40,
                              height: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Loading Amazing Schedule...",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Right Decoration
            Positioned(
              top: 40,
              right: 30,
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + _particleAnimation.value * 0.2,
                    child: Icon(
                      Icons.calendar_month,
                      color: Colors.white.withOpacity(0.2),
                      size: 40,
                    ),
                  );
                },
              ),
            ),

            // Bottom Left Decoration
            Positioned(
              bottom: 40,
              left: 30,
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + (1 - _particleAnimation.value) * 0.2,
                    child: Icon(
                      Icons.schedule,
                      color: Colors.white.withOpacity(0.2),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}