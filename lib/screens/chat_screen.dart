import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/custom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Schedule an initial jump/scroll to bottom once first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(animate: false);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120.0, // small offset buffer for typing indicator
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.sendMessage(text);
    _messageController.clear();
    
    // Smooth scroll down to sent item
    Timer(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  void _simulateAttachment(String type) {
    Navigator.pop(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    String url = '';
    String previewText = '';
    if (type == 'image') {
      url = 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&q=80';
      previewText = 'Uploaded design illustration';
    } else {
      url = 'files/Project_Briefing_ConnectX.pdf';
      previewText = 'Project_Briefing_ConnectX.pdf';
    }

    chatProvider.sendMessage(
      previewText,
      type: type,
      attachmentUrl: url,
    );

    Timer(const Duration(milliseconds: 100), () => _scrollToBottom());
  }

  void _showAttachmentOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentPill(
                    icon: Icons.image_rounded,
                    label: 'Gallery',
                    color: Colors.teal,
                    onTap: () => _simulateAttachment('image'),
                  ),
                  _buildAttachmentPill(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: Colors.blue,
                    onTap: () => _simulateAttachment('file'),
                  ),
                  _buildAttachmentPill(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location mocked in Phase 2.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);
    final user = chatProvider.getUserById(widget.userId);

    // Watch provider scroll trigger
    if (chatProvider.isScrollNeeded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
        chatProvider.resetScrollNeeded();
      });
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User details not found.')),
      );
    }

    final messages = chatProvider.getMessagesForUser(widget.userId);
    final isTyping = chatProvider.getIsTyping(widget.userId);

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(user.profileImage),
                ),
                if (user.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? AppColors.darkBackground : Colors.white, width: 1.5),
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    isTyping 
                        ? 'typing...' 
                        : (user.isOnline ? 'Online' : 'Offline'),
                    style: TextStyle(
                      fontSize: 10,
                      color: isTyping 
                          ? AppColors.primary 
                          : (user.isOnline ? AppColors.online : Colors.grey),
                      fontWeight: (isTyping || user.isOnline) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${user.name}...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              // Custom dialog detailing user profile bio
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                    title: Text(user.name, style: const TextStyle(fontFamily: 'Outfit')),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(user.profileImage),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('STATUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(user.status, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        const Text('EMAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. MESSAGES CHAT LOG
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // If is at last index and typing is active, display indicator
                if (index == messages.length) {
                  return const TypingIndicator();
                }

                final msg = messages[index];
                final isMe = msg.senderId == 'current_user';
                return ChatBubble(
                  message: msg,
                  isMe: isMe,
                );
              },
            ),
          ),

          // 2. BOTTOM MESSAGE INPUT CONTAINER
          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            child: Row(
              children: [
                // Text input box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder.withOpacity(0.4) : AppColors.lightBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        // Attachment Paperclip
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_outline_rounded,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          onPressed: _showAttachmentOptions,
                        ),
                        
                        // Main Text field input
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onChanged: (val) {
                              chatProvider.setTyping(val.isNotEmpty);
                            },
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            ),
                            onSubmitted: (_) {
                              chatProvider.setTyping(false);
                              _handleSendMessage();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Floating send action
                GestureDetector(
                  onTap: _handleSendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
