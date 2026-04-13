import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

/// Industrial Brutalist Login Screen - Bold, Confident, Unforgettable
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authController = context.read<AuthController>();
    final success = await authController.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Login gagal'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoBrutalTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Industrial background pattern
            _buildIndustrialBackground(),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: NeoBrutalTheme.spaceXL,
                  vertical: NeoBrutalTheme.spaceXL,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Dramatic header section
                        _buildBrutalHeader(context),
                        SizedBox(height: NeoBrutalTheme.spaceXL),

                        // Login form card
                        _buildLoginFormCard(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Industrial background with noise texture and geometric patterns
  Widget _buildIndustrialBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              NeoBrutalTheme.background.withValues(alpha: 0.95),
              NeoBrutalTheme.background.withValues(alpha: 1.0),
            ],
          ),
        ),
        child: Opacity(
          opacity: 0.03,
          child: CustomPaint(
            painter: _IndustrialPatternPainter(),
          ),
        ),
      ),
    );
  }

  /// Dramatic brutalist header with asymmetric layout
  Widget _buildBrutalHeader(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Dramatic logo icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: NeoBrutalTheme.primary,
                borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
                border: Border.all(
                  color: Colors.black,
                  width: 5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: Offset(8, 8),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: NeoBrutalTheme.primary.withValues(alpha: 0.5),
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (_pulseAnimation.value * 0.1),
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: NeoBrutalTheme.spaceMD),

            // App title with bold typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMPLE',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Colors.black,
                      height: 0.9,
                    ),
                  ),
                  Text(
                    'POS',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 12,
                      color: NeoBrutalTheme.primary,
                      height: 0.85,
                    ),
                  ),
                  SizedBox(height: NeoBrutalTheme.spaceXS),
                  Text(
                    'SISTEM KASIR INDUSTRI',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(
      begin: -50,
      duration: 800.ms,
      curve: Curves.easeOut,
    );
  }

  /// Brutalist login form card with dramatic shadows
  Widget _buildLoginFormCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusLarge),
        border: Border.all(
          color: Colors.black,
          width: 5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: Offset(12, 12),
            blurRadius: 0,
          ),
          BoxShadow(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.3),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Form title
          Text(
            'LOGIN KASIR',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: Colors.black,
            ),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),

          // Username field with brutal styling
          _buildBrutalTextField(
            context,
            controller: _usernameController,
            labelText: 'USERNAME',
            icon: Icons.person_outline_rounded,
            hintText: 'admin',
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username wajib diisi';
              }
              return null;
            },
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          SizedBox(height: NeoBrutalTheme.spaceMD),

          // Password field with brutal styling
          _buildBrutalPasswordField(
            context,
            controller: _passwordController,
            labelText: 'PASSWORD',
            hintText: '•••••••••',
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password wajib diisi';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          SizedBox(height: NeoBrutalTheme.spaceLG),

          // Brutal login button
          Consumer<AuthController>(
            builder: (context, auth, child) {
              final isAuthLoading = auth.isLoading;
              return BrutalLoginButton(
                onPressed: (_isLoading || isAuthLoading) ? null : _handleLogin,
                isLoading: _isLoading || isAuthLoading,
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(
      begin: const Offset(0.95, 0.95),
      duration: 400.ms,
      curve: Curves.easeOut,
    );
  }

  /// Brutalist text field with bold styling
  Widget _buildBrutalTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required String hintText,
    required TextInputAction textInputAction,
    required String? Function(String?)? validator,
    required Function(String?)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: NeoBrutalTheme.primary,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textTertiary,
          letterSpacing: 1,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: NeoBrutalTheme.primary,
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary,
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.errorColor,
            width: 3,
          ),
        ),
      ),
    );
  }

  /// Brutalist password field with visibility toggle
  Widget _buildBrutalPasswordField(
    BuildContext context, {
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required TextInputAction textInputAction,
    required String? Function(String?)? validator,
    required Function(String?)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
          color: NeoBrutalTheme.primary,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppTheme.textTertiary,
          letterSpacing: 1,
        ),
        prefixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.lock_outline_rounded,
            color: NeoBrutalTheme.primary,
            size: 22,
          ),
        ),
        suffixIcon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusSmall),
          ),
          child: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: NeoBrutalTheme.primary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.getBorderColor(context),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: NeoBrutalTheme.primary,
            width: 3,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppTheme.errorColor,
            width: 3,
          ),
        ),
      ),
    );
  }
}

/// Brutalist login button with dramatic shadows
class BrutalLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const BrutalLoginButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLoading
              ? [
                  Colors.grey.shade400,
                  Colors.grey.shade300,
                ]
              : [
                  NeoBrutalTheme.primary,
                  NeoBrutalTheme.primary.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
        border: Border.all(
          color: Colors.black,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            offset: Offset(6, 6),
            blurRadius: 0,
          ),
          BoxShadow(
            color: NeoBrutalTheme.primary.withValues(alpha: 0.5),
            offset: Offset(3, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(NeoBrutalTheme.radiusMedium),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    'MASUK SEKARANG',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for industrial background pattern
class _IndustrialPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03);

    // Draw geometric pattern - diagonal lines
    final lineSpacing = 40.0;
    for (double i = -size.height; i < size.width; i += lineSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Draw small circles at intersections
    final circlePaint = Paint()
      ..color = NeoBrutalTheme.secondary.withValues(alpha: 0.05);
    for (double x = 0; x < size.width; x += 80) {
      for (double y = 0; y < size.height; y += 80) {
        canvas.drawCircle(Offset(x, y), 3, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_IndustrialPatternPainter oldDelegate) => false;
}
