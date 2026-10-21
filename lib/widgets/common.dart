import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cleardata_app/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const GlassCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorder),
        ),
        child: child,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kSurface, const Color(0xFF153D18).withValues(alpha: 0.4)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kPrimary, size: 18),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(
            color: kText, fontSize: 22, fontWeight: FontWeight.w800,
            fontFamily: 'SpaceGrotesk',
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: kTextMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class GazChip extends StatelessWidget {
  final String sigle;
  final bool selected;
  final VoidCallback onTap;

  const GazChip({super.key, required this.sigle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = kGazColors[sigle] ?? kPrimary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? color : kBorder),
        ),
        child: Text(
          sigle,
          style: TextStyle(
            color: selected ? Colors.black : kTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const ShimmerLoading({super.key, this.height = 60, this.width, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: kSurface,
      highlightColor: const Color(0xFF1A3D1E),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 1, color: kPrimary.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(
          color: kText, fontSize: 20, fontWeight: FontWeight.w700,
        )),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: kPrimary.withValues(alpha: 0.1))),
      ],
    );
  }
}
