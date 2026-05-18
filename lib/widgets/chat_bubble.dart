import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../constants/app_colors.dart';
import '../utils/helpers.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Bubble theme configs
    final bgBubble = isMe
        ? AppColors.primary
        : (isDark ? AppColors.darkSurface : AppColors.lightSurfaceCard);
        
    final textTheme = TextStyle(
      color: isMe 
          ? Colors.white 
          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      fontSize: 15,
      height: 1.3,
    );

    final timeTheme = TextStyle(
      color: isMe 
          ? Colors.white.withOpacity(0.7) 
          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      fontSize: 10,
    );

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: bgBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Render attachment if exists
                      if (message.type != 'text' && message.attachmentUrl != null) ...[
                        _buildAttachment(context),
                        const SizedBox(height: 6),
                      ],
                      // Render message text if not empty
                      if (message.message.isNotEmpty)
                        Text(
                          message.message,
                          style: textTheme,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Meta Data: Time + Status Ticks
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Helpers.formatMessageTime(message.timestamp),
                    style: timeTheme,
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: message.isRead 
                          ? AppColors.accent 
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ],
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context) {
    if (message.type == 'image') {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        height: 160,
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message.attachmentUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.broken_image_outlined, size: 32, color: Colors.grey),
              );
            },
          ),
        ),
      );
    } else {
      // Document file pill
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              color: isMe ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message.attachmentUrl!.split('/').last,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isMe ? Colors.white : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '2.4 MB • PDF',
                    style: TextStyle(
                      fontSize: 10,
                      color: isMe ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
