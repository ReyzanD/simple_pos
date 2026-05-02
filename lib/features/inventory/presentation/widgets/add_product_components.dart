import 'package:flutter/material.dart';
import '../../../../core/theme/neo_brutal_theme.dart';

class AddProductHeader extends StatelessWidget {
  const AddProductHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: BoxDecoration(
        color: NeoBrutalTheme.blockBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: const Border(bottom: BorderSide(color: Colors.black, width: 5)),
      ),
      child: Row(
        children: [
          _IconBox(
            icon: Icons.inventory_2_outlined,
            color: NeoBrutalTheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TAMBAH PRODUK',
                  style: NeoBrutalTheme.headlineLarge.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'INVENTORY MANAGEMENT',
                  style: NeoBrutalTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class AddProductActions extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const AddProductActions({
    super.key,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(NeoBrutalTheme.spaceLG),
      decoration: const BoxDecoration(
        color: NeoBrutalTheme.background,
        border: Border(top: BorderSide(color: Colors.black, width: 5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BrutalBtn(
              text: 'BATAL',
              color: Colors.white,
              onTap: onCancel,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _BrutalBtn(
              text: 'SIMPAN',
              color: NeoBrutalTheme.primary,
              onTap: onSave,
              isLoading: isSubmitting,
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Internal Small Helpers ---

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBox({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: NeoBrutalTheme.chunkyShadow,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _BrutalBtn extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  final Color textColor;

  const _BrutalBtn({
    required this.text,
    required this.color,
    required this.onTap,
    this.isLoading = false,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 4),
          boxShadow: NeoBrutalTheme.chunkyShadow,
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
        ),
      ),
    );
  }
}
