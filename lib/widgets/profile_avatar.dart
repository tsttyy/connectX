import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final bool isOnline;
  final bool isEditable;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    Key? key,
    required this.imageUrl,
    required this.name,
    this.radius = 32,
    this.isOnline = false,
    this.isEditable = false,
    this.onEditTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Stack(
      children: [
        // Main Avatar Circle
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: isDark ? AppColors.darkSurface : Colors.grey[200],
            child: ClipOval(
              child: Image.network(
                imageUrl,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to initials if network loading fails
                  return Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: radius * 0.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: radius,
                      height: radius,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Glowing Online Status Dot Indicator
        if (isOnline && !isEditable)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: radius * 0.3,
              height: radius * 0.3,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkBackground : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.online.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
          ),

        // Camera Edit Overlay Badge Icon
        if (isEditable)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          )
      ],
    );
  }
}
