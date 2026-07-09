import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class ChatHeaderSkeleton extends StatefulWidget {
  const ChatHeaderSkeleton({super.key});

  @override
  State<ChatHeaderSkeleton> createState() => _ChatHeaderSkeletonState();
}

class _ChatHeaderSkeletonState extends State<ChatHeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (_, __) {
        final color = AppColors.divider.withValues(alpha: _animation.value);
        return Row(
          children: [
            _SkeletonBlock(
              width: 40,
              height: 40,
              color: color,
              shape: BoxShape.circle,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SkeletonBlock(width: 118, height: 14, color: color),
                  const SizedBox(height: 6),
                  _SkeletonBlock(width: 74, height: 9, color: color),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChatMessagesSkeleton extends StatefulWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  State<ChatMessagesSkeleton> createState() => _ChatMessagesSkeletonState();
}

class _ChatMessagesSkeletonState extends State<ChatMessagesSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
      builder: (_, __) {
        final color = AppColors.divider.withValues(alpha: _animation.value);
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            const SizedBox(height: 20),
            _OutgoingSkeletonBubble(color: color, widthFactor: 0.72),
            _OutgoingSkeletonBubble(color: color, widthFactor: 0.54),
            _IncomingSkeletonBubble(color: color, widthFactor: 0.70),
            _IncomingSkeletonBubble(color: color, widthFactor: 0.58),
            _OutgoingSkeletonBubble(color: color, widthFactor: 0.76),
            _IncomingSkeletonBubble(color: color, widthFactor: 0.64),
          ],
        );
      },
    );
  }
}

class _OutgoingSkeletonBubble extends StatelessWidget {
  final Color color;
  final double widthFactor;

  const _OutgoingSkeletonBubble({
    required this.color,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: _SkeletonBubble(color: color),
      ),
    );
  }
}

class _IncomingSkeletonBubble extends StatelessWidget {
  final Color color;
  final double widthFactor;

  const _IncomingSkeletonBubble({
    required this.color,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SkeletonBlock(
            width: 32,
            height: 32,
            color: color,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: _SkeletonBubble(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBubble extends StatelessWidget {
  final Color color;

  const _SkeletonBubble({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final BoxShape shape;

  const _SkeletonBlock({
    required this.width,
    required this.height,
    required this.color,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(6) : null,
      ),
    );
  }
}
