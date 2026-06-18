import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cobox_sv_mobile/core/utils/extensions.dart';

class EvidenceGrid extends StatelessWidget {
  final List<String> imageUrls;
  final bool isLoading;
  final VoidCallback? onAddPhoto;

  const EvidenceGrid({
    super.key,
    this.imageUrls = const [],
    this.isLoading = false,
    this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;

    if (imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'Sin evidencia fotográfica',
              style: context.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (onAddPhoto != null) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: onAddPhoto,
                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                label: const Text('Agregar foto'),
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length + (onAddPhoto != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= imageUrls.length) {
          return _AddPhotoButton(onTap: onAddPhoto!, cs: cs);
        }

        return _EvidenceImage(url: imageUrls[index], cs: cs);
      },
    );
  }
}

class _EvidenceImage extends StatelessWidget {
  final String url;
  final ColorScheme cs;

  const _EvidenceImage({required this.url, required this.cs});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: () => _showImagePreview(context, url),
        child: url.startsWith('http')
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(cs: cs),
              )
            : Image.file(
                File(url),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PlaceholderImage(cs: cs),
              ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: url.startsWith('http')
              ? Image.network(url, fit: BoxFit.contain)
              : Image.file(File(url), fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final ColorScheme cs;

  const _PlaceholderImage({required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: cs.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}

class _AddPhotoButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme cs;

  const _AddPhotoButton({required this.onTap, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                color: cs.onSurfaceVariant,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                'Agregar',
                style: context.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
