import 'package:flutter/material.dart';

/// Premium micro-animation helpers used throughout Mera screens.
///
/// Usage:
///   MeraAnimatedEntry(delay: 0, child: myWidget)
class MeraAnimatedEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideFromY;
  final double beginOpacity;

  const MeraAnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 460),
    this.slideFromY = 24.0,
    this.beginOpacity = 0.0,
  });

  @override
  State<MeraAnimatedEntry> createState() => _MeraAnimatedEntryState();
}

class _MeraAnimatedEntryState extends State<MeraAnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);

    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );

    _opacity = Tween<double>(
      begin: widget.beginOpacity,
      end: 1.0,
    ).animate(curve);

    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideFromY / 100),
      end: Offset.zero,
    ).animate(curve);

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Staggered list that animates children in one-by-one.
class MeraStaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration baseDelay;
  final Duration stepDelay;

  const MeraStaggeredList({
    super.key,
    required this.children,
    this.baseDelay = const Duration(milliseconds: 60),
    this.stepDelay = const Duration(milliseconds: 80),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++)
          MeraAnimatedEntry(
            delay: baseDelay + stepDelay * i,
            child: children[i],
          ),
      ],
    );
  }
}

/// Pulsating glow animation for primary CTA buttons.
class MeraBreathingGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double spread;
  final double blur;

  const MeraBreathingGlow({
    super.key,
    required this.child,
    required this.color,
    this.spread = 4,
    this.blur = 18,
  });

  @override
  State<MeraBreathingGlow> createState() => _MeraBreathingGlowState();
}

class _MeraBreathingGlowState extends State<MeraBreathingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: _anim.value),
              blurRadius: widget.blur,
              spreadRadius: widget.spread,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
