import 'package:flutter/material.dart';
import 'package:ntv_flutter_wallet/core/theme/app_colors.dart';

class GlowingImage extends StatefulWidget {
  final double size;
  final String imagePath;
  final VoidCallback? onTap;

  const GlowingImage({
    super.key,
    this.size = 100,
    required this.imagePath,
    this.onTap,
  });

  @override
  State<GlowingImage> createState() => _GlowingImageState();
}

class _GlowingImageState extends State<GlowingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 1.0, end: 2.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCirc),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [
                        const Color.fromARGB(255, 236, 96, 180).withAlpha(128),
                        const Color.fromARGB(255, 29, 82, 205).withAlpha(128),
                        AppColors.success.withAlpha(128),
                      ]
                    : [
                        AppColors.primaryBlue.withAlpha(128),
                        AppColors.success.withAlpha(128),
                        AppColors.primaryBlue.withAlpha(128),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 47, 5, 61).withAlpha(77)
                      : AppColors.primaryBlue.withAlpha(77),
                  blurRadius: 30 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: CircleAvatar(
                radius: widget.size / 2,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.purpleSwagLight.withAlpha(50)
                    : AppColors.primaryBlue.withAlpha(50),
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}