import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_helper.dart';
import 'shimmer_loading.dart';
import 'modern_button.dart';
import 'package:simple_pos/l10n/app_localizations.dart';

/// Product image picker widget with support for camera and gallery
///
/// Features:
/// - Pick image from camera or gallery
/// - Display preview of selected image
/// - Remove image option
/// - Shimmer loading while processing
class ProductImagePicker extends StatefulWidget {
  final String? currentImagePath;
  final ValueChanged<String?> onImageChanged;
  final double size;
  final bool enabled;

  const ProductImagePicker({
    super.key,
    this.currentImagePath,
    required this.onImageChanged,
    this.size = 100,
    this.enabled = true,
  });

  @override
  State<ProductImagePicker> createState() => _ProductImagePickerState();
}

class _ProductImagePickerState extends State<ProductImagePicker> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.enabled
              ? (!_isLoading ? _showImageSourceDialog : null)
              : null,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.enabled
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : AppTheme.getBorderColor(context),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildContent(),
          ),
        ),
        if (widget.enabled && widget.currentImagePath != null) ...[
          const SizedBox(height: 8),
          ModernSecondaryButton(
            text: AppLocalizations.of(context)!.image_picker_delete,
            icon: Icons.delete_outline,
            onPressed: _removeImage,
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: ShimmerLoading(child: ShimmerCircle(size: 40)),
      );
    }

    if (widget.currentImagePath != null) {
      // Check if it's a network URL or local file
      if (widget.currentImagePath!.startsWith('http')) {
        // Network image
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            widget.currentImagePath!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackIcon();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
          ),
        );
      } else {
        // Local file
        final file = File(widget.currentImagePath!);
        if (file.existsSync()) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              file,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
            ),
          );
        }
      }
    }

    // Fallback with icon
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.image_outlined,
          size: widget.size * 0.4,
          color: AppTheme.textTertiary,
        ),
        if (widget.enabled)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    HapticHelper.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(
        onCameraSelected: _pickFromCamera,
        onGallerySelected: _pickFromGallery,
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    Navigator.of(context).pop();
    _setLoading(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null && mounted) {
        widget.onImageChanged(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.image_picker_failed_camera(e),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _pickFromGallery() async {
    Navigator.of(context).pop();
    _setLoading(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null && mounted) {
        widget.onImageChanged(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.image_picker_failed_gallery(e),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void _removeImage() {
    HapticHelper.mediumImpact();
    widget.onImageChanged(null);
  }

  void _setLoading(bool value) {
    if (mounted) {
      setState(() => _isLoading = value);
    }
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final VoidCallback onCameraSelected;
  final VoidCallback onGallerySelected;

  const _ImageSourceBottomSheet({
    required this.onCameraSelected,
    required this.onGallerySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.image_picker_title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImageSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: AppLocalizations.of(context)!.image_picker_camera,
                  onTap: () {
                    HapticHelper.lightImpact();
                    onCameraSelected();
                  },
                ),
                _ImageSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: AppLocalizations.of(context)!.image_picker_gallery,
                  onTap: () {
                    HapticHelper.lightImpact();
                    onGallerySelected();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimaryColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact version of product image picker for use in forms
class CompactProductImagePicker extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String?> onChanged;
  final double size;

  const CompactProductImagePicker({
    super.key,
    required this.imagePath,
    required this.onChanged,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ProductImagePicker(
      currentImagePath: imagePath,
      onImageChanged: onChanged,
      size: size,
    );
  }
}

/// Product image display widget (read-only)
class ProductImageDisplay extends StatelessWidget {
  final String? imagePath;
  final double size;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ProductImageDisplay({
    super.key,
    required this.imagePath,
    this.size = 60,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: effectiveBorderRadius,
          border: Border.all(color: AppTheme.getBorderColor(context), width: 1),
        ),
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return Icon(
        Icons.image_outlined,
        size: size * 0.4,
        color: AppTheme.textTertiary,
      );
    }

    if (imagePath!.startsWith('http')) {
      return Image.network(
        imagePath!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.broken_image_outlined,
            size: size * 0.4,
            color: AppTheme.textTertiary,
          );
        },
      );
    }

    final file = File(imagePath!);
    if (file.existsSync()) {
      return Image.file(file, width: size, height: size, fit: BoxFit.cover);
    }

    return Icon(
      Icons.image_outlined,
      size: size * 0.4,
      color: AppTheme.textTertiary,
    );
  }
}
