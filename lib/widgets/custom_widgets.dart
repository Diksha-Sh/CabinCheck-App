import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.provider.dart';
import '../utils/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final LinearGradient gradient;

  const StatusBadge({super.key, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const ModernCard({super.key, required this.child, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.darkSurface : AppColors.surface),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100, 
          width: 1
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final LinearGradient? gradient;

  const GradientButton({
    super.key, 
    required this.label, 
    required this.onPressed, 
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient ?? AppColors.primaryGradient).colors.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassCard({
    super.key, 
    required this.child, 
    this.blur = 10, 
    this.opacity = 0.1, 
    this.color
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = color ?? (isDark ? AppColors.darkSurface : Colors.white);

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: (isDark ? Colors.white : Colors.white).withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            baseColor.withOpacity(opacity),
            BlendMode.srcOver,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color glowColor;
  final IconData? icon;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.glowColor = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(onPressed == null ? 0.1 : 0.4),
            blurRadius: 15,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey.shade300 : glowColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
class PulseIndicator extends StatefulWidget {
  final Color color;
  const PulseIndicator({super.key, this.color = Colors.green});

  @override
  _PulseIndicatorState createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<PulseIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(1 - _controller.value),
                blurRadius: 8 * _controller.value,
                spreadRadius: 4 * _controller.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
class ConfidenceMeter extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;

  const ConfidenceMeter({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Prediction Confidence", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
            Text("${(value * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 4),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String time;
  final String status;
  final Color color;
  final bool isLast;

  const TimelineItem({
    super.key, 
    required this.time, 
    required this.status, 
    required this.color, 
    this.isLast = false
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.2), width: 4),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(time, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SOSAlert extends StatelessWidget {
  final String message;
  const SOSAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          const PulseIndicator(color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("EMERGENCY SAFETY PROTOCOL", 
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IconButton(
      icon: Icon(
        state.themeMode == ThemeMode.system 
          ? Icons.brightness_auto_outlined 
          : (isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        color: AppColors.primary,
        size: 26,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.4),
          builder: (context) => Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                const Text("Appearance", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _ThemeOption(mode: ThemeMode.light, label: "Always Bright", icon: Icons.light_mode_rounded),
                _ThemeOption(mode: ThemeMode.dark, label: "Always Dark", icon: Icons.dark_mode_rounded),
                _ThemeOption(mode: ThemeMode.system, label: "System Adaptive", icon: Icons.brightness_auto_rounded),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode mode;
  final String label;
  final IconData icon;

  const _ThemeOption({required this.mode, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isSelected = state.themeMode == mode;

    return InkWell(
      onTap: () {
        state.setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500))),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
