import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:samiti_app/core/resusable_widgets/custom_action_card.dart';
import 'package:samiti_app/core/resusable_widgets/custom_appbar.dart';
import 'package:samiti_app/core/resusable_widgets/section_header.dart';
import 'package:samiti_app/features/auth/view_model/auth_view_model.dart';

import '../../../core/constants/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authviewmodel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: CustomAppBar(title: 'My Profile'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SectionHeader(title: 'Account Details'),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [AppColors.dark,AppColors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.darkGrey,
                          blurRadius: 10,
                          offset: const Offset(0, 5)
                      )
                    ]
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.person, size: 40, color: AppColors.dark),
                    ),
                    const SizedBox(height: 8,),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Text('System Administrator', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
              ],
            ),
          ),
              const SizedBox(height: 12,),
              SectionHeader(title: 'Preferences'),

              CustomActionCard(icon: Icons.lock_outline, title: 'Change Password'),
              CustomActionCard(icon: Icons.edit_outlined, title: 'Edit Profile'),
              CustomActionCard(icon: Icons.help_outline, title: 'Help & Support'),
              const SizedBox(height: 12,),

              const SizedBox(height: 12,),
              // 4. Logout Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context)=> AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel",style: TextStyle(color: AppColors.dark),),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context); // Close dialog
                                await context.read<AuthViewModel>().logout(); // Clear token/state
                                if (context.mounted) {
                                  context.goNamed('login'); // Redirect to login
                                }
                              },
                              child: const Text("Logout", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                            ),
                          ],
                    )
                    );
                    } ,
                  icon: Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
