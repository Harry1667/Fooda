import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? maxWidth;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 600,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 計算適合的內邊距
    final horizontalPadding = screenWidth * 0.05; // 5% 的水平邊距
    final verticalPadding = screenHeight * 0.02;  // 2% 的垂直邊距
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: horizontalPadding.clamp(16.0, 32.0),
        vertical: verticalPadding.clamp(16.0, 24.0),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? screenWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}

class AnimatedScaleWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double scale;
  
  const AnimatedScaleWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutBack,
    this.scale = 1.0,
  });

  @override
  State<AnimatedScaleWidget> createState() => _AnimatedScaleWidgetState();
}

class _AnimatedScaleWidgetState extends State<AnimatedScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: widget.scale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Offset begin;
  final Offset end;
  
  const SlideInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.begin = const Offset(0, 1),
    this.end = Offset.zero,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.begin,
      end: widget.end,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}