import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:food_delivery_customer/constants/colors.dart';
import 'package:food_delivery_customer/controller/user_controller.dart';
import 'package:food_delivery_customer/views/screens/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile header
              Obx(() => _buildProfileHeader(userController)),

              const SizedBox(height: 30),
              _buildSectionTitle('Personal Information'),
              Obx(() => _buildPersonalInfoCard(userController)),

              const SizedBox(height: 30),
              _buildSectionTitle('Account Information'),
              Obx(() => _buildAccountInfoCard(userController)),

              const SizedBox(height: 30),
              _buildLogoutButton(userController),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(UserController userController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _showLogoutConfirmation(userController),
          child: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(UserController userController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              userController.logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserController userController) {
    final user = userController.userObs.value;
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Center(
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TColor.primary.withOpacity(0.2),
                width: 2,
              ),
              color: TColor.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.person,
              size: 50,
              color: TColor.primary,
            ),
          ),
          const SizedBox(height: 15),
          // User Name
          Text(
            user.displayName,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          // User Email
          Text(
            user.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          // Edit Profile Button
          SizedBox(
            width: 150,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Get.to(() => EditProfilePage());
              },
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: TColor.primaryText.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(UserController userController) {
    final user = userController.userObs.value;
    if (user == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.person,
            title: 'Full Name',
            value: user.fullName,
            onTap: () {
              Get.to(() => EditProfilePage(initialField: 'name'));
            },
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.phone,
            title: 'Phone Number',
            value: user.phone ?? 'Not set',
            onTap: () {
              Get.to(() => EditProfilePage(initialField: 'phone'));
            },
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.email,
            title: 'Email Address',
            value: user.email,
            onTap: () {
              Get.to(() => EditProfilePage(initialField: 'email'));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(UserController userController) {
    final user = userController.userObs.value;
    if (user == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.badge,
            title: 'Account Type',
            value: user.userType.toUpperCase(),
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.verified,
            title: 'Verification Status',
            value: user.isVerified ? 'Verified' : 'Not Verified',
            valueColor: user.isVerified ? Colors.green : Colors.orange,
          ),
          _buildDivider(),
          _buildInfoTile(
            icon: Icons.calendar_today,
            title: 'Member Since',
            value: user.createdAt != null
                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                : 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: TColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: TColor.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: valueColor ?? TColor.primaryText,
        ),
      ),
      trailing: onTap != null
          ? Icon(Icons.edit, color: TColor.primary, size: 20)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      minLeadingWidth: 10,
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }
}
