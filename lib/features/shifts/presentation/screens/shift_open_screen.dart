import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/presentation/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/neo_brutal_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';

/// Screen for opening a new cashier shift
class ShiftOpenScreen extends ConsumerStatefulWidget {
  const ShiftOpenScreen({super.key});

  @override
  ConsumerState<ShiftOpenScreen> createState() => _ShiftOpenScreenState();
}

class _ShiftOpenScreenState extends ConsumerState<ShiftOpenScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _openingBalanceController = TextEditingController();

  @override
  void dispose() {
    _userNameController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _handleOpenShift() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = ref.read(shiftControllerProvider);

    final success = await controller.openShift(
      userName: _userNameController.text.trim(),
      openingBalance: double.parse(_openingBalanceController.text),
    );

    if (mounted && success) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(shiftControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Buka Shift'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white, // Icon on primary color background
        elevation: 0,
      ),
      body: SafeArea(
        child: () {
          if (controller.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    controller.error?.userMessage ?? 'Terjadi kesalahan',
                  ),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
              controller.clearError();
            });
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header illustration
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.storefront,
                          size: 50,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Mulai Shift Kerja',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NeoBrutalTheme.getTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Masukkan nama kasir dan modal awal untuk memulai shift',
                        style: TextStyle(
                          fontSize: 14,
                          color: NeoBrutalTheme.getSecondaryTextColor(context),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // User name field
                      ModernCard(
                        child: TextFormField(
                          controller: _userNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Kasir',
                            hintText: 'Masukkan nama kasir',
                            prefixIcon: Icon(Icons.person),
                            border: InputBorder.none,
                          ),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama kasir wajib diisi';
                            }
                            if (value.trim().length < 2) {
                              return 'Nama minimal 2 karakter';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Opening balance field
                      ModernCard(
                        child: TextFormField(
                          controller: _openingBalanceController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Modal Awal',
                            hintText: '0',
                            prefixIcon: Icon(Icons.money),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}'),
                            ),
                          ],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleOpenShift(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Modal awal wajib diisi';
                            }
                            final balance = double.tryParse(value);
                            if (balance == null || balance < 0) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Open button
                      ModernButton(
                        text: 'Buka Shift',
                        icon: Icons.play_arrow,
                        onPressed: controller.isLoading
                            ? null
                            : _handleOpenShift,
                        isLoading: controller.isLoading,
                        backgroundColor: AppTheme.primaryColor,
                      ),

                      const SizedBox(height: 16),

                      // Cancel button
                      ModernSecondaryButton(
                        text: 'Batal',
                        icon: Icons.close,
                        onPressed: controller.isLoading
                            ? null
                            : () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }(),
      ),
    );
  }
}
