import 'package:flutter/widgets.dart';

/// Fades [child] in while it slides up and grows slightly, once, after
/// [delay]. Shows [child] at rest when [animate] is false or the system
/// disables animations.
class AppearAnimation extends StatefulWidget {
  const AppearAnimation({
    required this.child,
    this.animate = true,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final bool animate;
  final Duration delay;

  static const Duration duration = Duration(milliseconds: 450);

  /// Start offset as a fraction of the child's height.
  static const double slideFraction = 0.12;
  static const double startScale = 0.94;

  @override
  State<AppearAnimation> createState() => _AppearAnimationState();
}

class _AppearAnimationState extends State<AppearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + AppearAnimation.duration;
    _controller = AnimationController(vsync: this, duration: total);
    // The delay is the start of the interval, so no timer is needed.
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        widget.delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _slide = Tween(
      begin: const Offset(0, AppearAnimation.slideFraction),
      end: Offset.zero,
    ).animate(_progress);
    _scale = Tween(
      begin: AppearAnimation.startScale,
      end: 1.0,
    ).animate(_progress);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (widget.animate && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _progress,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}
