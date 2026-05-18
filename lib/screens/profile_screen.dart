import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _statusController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.currentUser?.name ?? '');
    _statusController = TextEditingController(text: authProvider.currentUser?.status ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _saveProfileChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.updateProfile(
      name: _nameController.text.trim(),
      status: _statusController.text.trim(),
    );
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile details updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User profile session has expired.')),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Settings & Profile',
          style: TextStyle(fontFamily: 'Outfit'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 1. HUGE PREMIUM PROFILE CARD
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                  ),
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    backgroundImage: NetworkImage(user.profileImage),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile image upload is mocked.')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. PROFILE DATA FORM
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PERSONAL DATA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_isEditing) {
                            _saveProfileChanges();
                          } else {
                            setState(() {
                              _isEditing = true;
                            });
                          }
                        },
                        child: Text(
                          _isEditing ? 'Save' : 'Edit',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Username Field
                  _isEditing
                      ? TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline, color: AppColors.primary),
                          title: const Text('Full Name', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                  
                  const Divider(height: 24),
                  
                  // Status Bio Field
                  _isEditing
                      ? TextField(
                          controller: _statusController,
                          decoration: const InputDecoration(
                            labelText: 'Status Bio',
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.secondary),
                          title: const Text('Status Quote', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          subtitle: Text(
                            user.status,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        
                  const Divider(height: 24),

                  // Email Field (Readonly)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alternate_email_rounded, color: AppColors.accent),
                    title: const Text('Email Address', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 3. SETTINGS & THEMING
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder.withOpacity(0.5) : AppColors.lightBorder,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark theme mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Enables low brightness UI styling'),
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    value: themeProvider.isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (bool val) {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.security_rounded, color: Colors.teal),
                    title: const Text('Security & Encryption', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Chat backup logs and security tokens'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Security parameters are secure.')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // 4. SIGN OUT BUTTON (DANGER ZONE)
            GestureDetector(
              onTap: () {
                authProvider.logout();
                context.go('/login');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white),
                      SizedBox(width: 10),
                      Text(
                        'Sign Out of Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
