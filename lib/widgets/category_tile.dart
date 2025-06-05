import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CategoryTile({super.key, required this.title, required this.onTap});

  String get _assetName {
    String fileName = title.toLowerCase();

    fileName = fileName.replaceAll(RegExp(r'\s*/\s*'), '-');

    fileName = fileName.replaceAll(RegExp(r'\s+'), '-');

    return 'assets/images/categories/$fileName.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _assetName,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.black.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 8,
              bottom: 8,
              right: 8,
              child: Text(
                _displayTitle(title),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _displayTitle(String raw) {
    if (raw.contains('/')) {
      final parts = raw.split('/');
      return parts
          .map(
            (part) =>
                part.trim().substring(0, 1).toUpperCase() +
                part.trim().substring(1).toLowerCase(),
          )
          .join(' / ');
    }
    final trimmed = raw.trim();
    return trimmed.substring(0, 1).toUpperCase() +
        trimmed.substring(1).toLowerCase();
  }
}
