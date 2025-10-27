import 'package:flutter/material.dart';
import 'package:food_delivery_customer/constants/colors.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile
              _buildProfileHeader(media),
              const SizedBox(height: 30),
              
              // Account Sections
              _buildSectionTitle('Account Settings'),
              _buildAccountCard(context),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Preferences'),
              _buildPreferencesCard(context),
              const SizedBox(height: 20),
              
              _buildSectionTitle('Support'),
              _buildSupportCard(context),
              const SizedBox(height: 30),
              
              // Logout Button
              Center(
                child: SizedBox(
                  width: media.width * 0.6,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Handle logout
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red[400], size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[400],
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
      ),
    );
  }

  Widget _buildProfileHeader(Size media) {
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
              image: const DecorationImage(
                image: AssetImage('assets/images/profile.jpg'), // Replace with your asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // User Name
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TColor.primaryText,
            ),
          ),
          const SizedBox(height: 5),
          
          // User Email
          Text(
            'john.doe@example.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 15),
          
          // Edit Profile Button
          SizedBox(
            width: media.width * 0.4,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                side: BorderSide(color: TColor.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                // Handle edit profile
              },
              child: Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 14,
                  color: TColor.primary,
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

  Widget _buildAccountCard(BuildContext context) {
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
          _buildListTile(
            icon: Icons.payment,
            title: 'Payment Methods',
            onTap: () {
              // Navigate to payment methods
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.location_on,
            title: 'Saved Addresses',
            onTap: () {
              // Navigate to saved addresses
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.history,
            title: 'Order History',
            onTap: () {
              // Navigate to order history
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(BuildContext context) {
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
          _buildListTile(
            icon: Icons.notifications,
            title: 'Notifications',
            trailing: Switch(
              value: true,
              activeColor: TColor.primary,
              onChanged: (value) {
                // Handle notification toggle
              },
            ),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            trailing: Switch(
              value: false,
              activeColor: TColor.primary,
              onChanged: (value) {
                // Handle dark mode toggle
              },
            ),
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () {
              // Navigate to language selection
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
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
          _buildListTile(
            icon: Icons.help,
            title: 'Help Center',
            onTap: () {
              // Navigate to help center
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.support_agent,
            title: 'Contact Support',
            onTap: () {
              // Navigate to contact support
            },
          ),
          _buildDivider(),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              // Navigate to privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
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
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: TColor.primaryText,
        ),
      ),
      subtitle: subtitle != null ? Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ) : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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