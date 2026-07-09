import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/core/widgets/loaders/truck_loader.dart';

/// Wraps [child] with a brief truck loading animation before fading in.
/// Use this for page transitions to give visual feedback during navigation.
class TruckTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration loadingDuration;

  const TruckTransitionWrapper({
    super.key,
    required this.child,
    this.loadingDuration = const Duration(milliseconds: 800),
  });

  @override
  State<TruckTransitionWrapper> createState() => _TruckTransitionWrapperState();
}

class _TruckTransitionWrapperState extends State<TruckTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    // Show loader for [loadingDuration], then fade in the actual page
    Future.delayed(widget.loadingDuration, () {
      if (!mounted) return;
      setState(() => _showLoading = false);
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showLoading) return const TruckLoadingOverlay();
    return FadeTransition(
      opacity: _fadeAnim,
      child: widget.child,
    );
  }
}
