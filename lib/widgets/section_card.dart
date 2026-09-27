import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

class SectionCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Entrance stagger delay. Each card fades + slides in once on first build.
  final Duration entranceDelay;

  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.entranceDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      delay: entranceDelay,
      child: Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D1B3E),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: C.royal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: C.royal, size: 20),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: const TextStyle(
                          color: C.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: C.muted,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text.toUpperCase(),
        style: const TextStyle(
          color: C.muted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: C.danger),
                ),
              ]
            : const [],
      ),
    );
  }
}
