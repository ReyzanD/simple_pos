import 'package:flutter/material.dart';
import '../animations/animation_constants.dart';
import '../theme/app_theme.dart';

/// Animated empty state widget with floating icon animation
class AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.iconColor,
    this.iconSize,
  });

  // Preset factory methods for common empty states

  factory AnimatedEmptyState.noProducts({VoidCallback? onAction}) =>
      AnimatedEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'Belum Ada Produk',
        subtitle: 'Mulai tambahkan produk ke inventaris Anda',
        actionText: 'Tambah Produk',
        onAction: onAction,
      );

  factory AnimatedEmptyState.noTransactions({VoidCallback? onAction}) =>
      AnimatedEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Transaksi',
        subtitle: 'Transaksi penjualan Anda akan muncul di sini',
        actionText: 'Mulai Transaksi',
        onAction: onAction,
      );

  factory AnimatedEmptyState.noExpenses({VoidCallback? onAction}) =>
      AnimatedEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum Ada Pengeluaran',
        subtitle: 'Catat pengeluaran operasional toko',
        actionText: 'Tambah Pengeluaran',
        onAction: onAction,
      );

  factory AnimatedEmptyState.noSuppliers({VoidCallback? onAction}) =>
      AnimatedEmptyState(
        icon: Icons.local_shipping_outlined,
        title: 'Belum Ada Pemasok',
        subtitle: 'Tambahkan pemasok untuk inventori Anda',
        actionText: 'Tambah Pemasok',
        onAction: onAction,
      );

  factory AnimatedEmptyState.noCategories({VoidCallback? onAction}) =>
      AnimatedEmptyState(
        icon: Icons.category_outlined,
        title: 'Belum Ada Kategori',
        subtitle: 'Kategori membantu mengelola produk',
        actionText: 'Tambah Kategori',
        onAction: onAction,
      );

  factory AnimatedEmptyState.searchNoResults({String? query}) =>
      AnimatedEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Tidak Ditemukan',
        subtitle:
            query != null ? 'Tidak ada hasil untuk "$query"' : 'Coba kata kunci lain',
      );

  factory AnimatedEmptyState.noNetwork({VoidCallback? onRetry}) =>
      AnimatedEmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Tidak Ada Koneksi',
        subtitle: 'Periksa koneksi internet Anda',
        actionText: 'Coba Lagi',
        onAction: onRetry,
      );

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Float animation - continuous gentle up and down
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Fade in animation on appearance
    _fadeController = AnimationController(
      vsync: this,
      duration: AnimationDurations.normal,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AnimationCurves.decelerate,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppTheme.textTertiary;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Floating icon
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: child,
                  );
                },
                child: _AnimatedIconContainer(
                  icon: widget.icon,
                  iconColor: iconColor,
                  size: widget.iconSize ?? 80,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.actionText != null && widget.onAction != null) ...[
                const SizedBox(height: 24),
                _PulseActionButton(
                  text: widget.actionText!,
                  onPressed: widget.onAction!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated icon container with subtle glow effect
class _AnimatedIconContainer extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final double size;

  const _AnimatedIconContainer({
    required this.icon,
    required this.iconColor,
    required this.size,
  });

  @override
  State<_AnimatedIconContainer> createState() => _AnimatedIconContainerState();
}

class _AnimatedIconContainerState extends State<_AnimatedIconContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 0.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: widget.size * 1.5,
            height: widget.size * 1.5,
            decoration: BoxDecoration(
              color: widget.iconColor.withValues(alpha: _glowAnimation.value),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: widget.iconColor,
            ),
          ),
        );
      },
    );
  }
}

/// Pulse action button for the empty state
class _PulseActionButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const _PulseActionButton({
    required this.text,
    required this.onPressed,
  });

  @override
  State<_PulseActionButton> createState() => _PulseActionButtonState();
}

class _PulseActionButtonState extends State<_PulseActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 4.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: () {
              _pulseController.stop();
              widget.onPressed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: _shadowAnimation.value,
              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simplified animated empty state with just an illustration area
class EmptyStateIllustration extends StatefulWidget {
  final IconData icon;
  final String? label;
  final Color? color;
  final double size;

  const EmptyStateIllustration({
    super.key,
    required this.icon,
    this.label,
    this.color,
    this.size = 100,
  });

  @override
  State<EmptyStateIllustration> createState() => _EmptyStateIllustrationState();
}

class _EmptyStateIllustrationState extends State<EmptyStateIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.textTertiary;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.size * 1.4,
                height: widget.size * 1.4,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: widget.size,
                  color: color,
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
