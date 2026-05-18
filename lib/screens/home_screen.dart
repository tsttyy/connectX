import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/user_card.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      Provider.of<ChatProvider>(context, listen: false).setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    
    final currentUser = authProvider.currentUser;
    final activeUsers = chatProvider.users.where((user) => user.isOnline).toList();

    return Scaffold(
      appBar: CustomAppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.push('/profile'),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: currentUser != null 
                    ? NetworkImage(currentUser.profileImage) 
                    : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ConnectX',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  currentUser != null ? 'Hello, ${currentUser.name}' : 'Syncing...',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications are up to date!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Elegant Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search chats, people...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Custom animated Tab Bar selectors
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: isDark ? AppColors.darkBorder.withOpacity(0.3) : AppColors.lightBorder,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Chats'),
              Tab(text: 'Active Now'),
            ],
          ),

          // Main scrolling viewport
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. CHATS TAB
                RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 800));
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      // Active users horizontal bar
                      if (activeUsers.isNotEmpty && _searchController.text.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'ACTIVE NOW',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: activeUsers.length,
                            itemBuilder: (context, index) {
                              final activeUser = activeUsers[index];
                              return GestureDetector(
                                onTap: () {
                                  chatProvider.setActiveChat(activeUser.uid);
                                  context.push('/chat/${activeUser.uid}');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(activeUser.profileImage),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                color: AppColors.online,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark ? AppColors.darkBackground : Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          activeUser.name.split(' ')[0],
                                          style: const TextStyle(fontSize: 11),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Divider(thickness: 0.5),
                        ),
                      ],

                      // Vertical message threads list
                      if (chatProvider.users.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No active chats found',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatProvider.users.length,
                          itemBuilder: (context, index) {
                            final user = chatProvider.users[index];
                            final history = chatProvider.getMessagesForUser(user.uid);
                            final lastMsg = history.isNotEmpty ? history.last : null;
                            final unread = chatProvider.getUnreadCount(user.uid);

                            return UserCard(
                              user: user,
                              lastMessage: lastMsg,
                              unreadCount: unread,
                              onTap: () {
                                chatProvider.setActiveChat(user.uid);
                                context.push('/chat/${user.uid}');
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),

                // 2. ACTIVE NOW TAB
                ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: activeUsers.length,
                  itemBuilder: (context, index) {
                    final user = activeUsers[index];
                    return UserCard(
                      user: user,
                      unreadCount: 0,
                      onTap: () {
                        chatProvider.setActiveChat(user.uid);
                        context.push('/chat/${user.uid}');
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Starts a quick new conversation modal
          showModalBottomSheet(
            context: context,
            backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Conversation',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.people_alt_outlined, color: Colors.white),
                      ),
                      title: const Text('Create Group Chat'),
                      subtitle: const Text('Connect with up to 100 members'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group features are in Phase 2 development.')),
                        );
                      },
                    ),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.secondary.withOpacity(0.8),
                        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                      ),
                      title: const Text('Scan QR Code'),
                      subtitle: const Text('Scan user profile to add immediately'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Camera access is not configured.')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }
}
