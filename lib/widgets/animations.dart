import 'package:flutter/material.dart';

/// Whether the platform requested reduced motion (accessibility).
bool _reduced(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

/// Fade + slide-up entrance. Plays once on first build.
/// Use [delay] to stagger a list/column of items.
/// Respects the OS "reduce motion" setting (renders final state instantly).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 18,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    if (_reduced(context)) {
      _c.value = 1.0;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - v)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Helper: build a vertical list of children, each wrapped in [FadeSlideIn]
/// with an incremental stagger delay (per UX motion guidance, 30-60ms each).
List<Widget> staggered(
  List<Widget> children, {
  Duration step = const Duration(milliseconds: 70),
  Duration start = Duration.zero,
}) {
  return List.generate(children.length, (i) {
    return FadeSlideIn(
      delay: start + step * i,
      child: children[i],
    );
  });
}

/// Subtle scale-down feedback on press for cards / tappable surfaces.
/// Keeps layout bounds stable (transform only). Respects reduced motion.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final pressed = _down && !_reduced(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: widget.onTap == null ? null : (_) => _set(true),
      onTapUp: widget.onTap == null ? null : (_) => _set(false),
      onTapCancel: widget.onTap == null ? null : () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Animated count-up for dashboard stat numbers.
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 750),
  });

  @override
  Widget build(BuildContext context) {
    if (_reduced(context)) {
      return Text('$value', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// Page route with a fade + gentle slide-up transition (forward navigation).
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeThroughRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 360),
          reverseTransitionDuration: const Duration(milliseconds: 240),
          pageBuilder: (_, _, _) => page,
          transitionsBuilder: (context, animation, _, child) {
            if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
              return child;
            }
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeIn,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
        );
}
