import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkMode = false;
  bool _emailAlerts = true;
  bool _smsAlerts = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),
          // Profile Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF1B5E20)),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showEditProfileDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.orange),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangePasswordDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.fingerprint, color: Colors.purple),
            title: const Text('Biometric Login'),
            subtitle: const Text('Use fingerprint to login'),
            trailing: Switch(
              value: _biometricEnabled,
              onChanged: (val) => setState(() => _biometricEnabled = val),
              activeColor: const Color(0xFF1B5E20),
            ),
          ),
          const Divider(),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive transaction alerts'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            activeColor: const Color(0xFF1B5E20),
            secondary: const Icon(Icons.notifications_active, color: Color(0xFF1B5E20)),
          ),
          SwitchListTile(
            title: const Text('Email Alerts'),
            subtitle: const Text('Receive statements via email'),
            value: _emailAlerts,
            onChanged: (val) => setState(() => _emailAlerts = val),
            activeColor: const Color(0xFF1B5E20),
            secondary: const Icon(Icons.email, color: Colors.blue),
          ),
          SwitchListTile(
            title: const Text('SMS Alerts'),
            subtitle: const Text('Receive alerts via SMS'),
            value: _smsAlerts,
            onChanged: (val) => setState(() => _smsAlerts = val),
            activeColor: const Color(0xFF1B5E20),
            secondary: const Icon(Icons.sms, color: Colors.green),
          ),
          const Divider(),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch to dark theme'),
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
            activeColor: const Color(0xFF1B5E20),
            secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text('Language'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(),

          // Security Section
          _buildSectionHeader('Security'),
          ListTile(
            leading: const Icon(Icons.security, color: Colors.green),
            title: const Text('Two-Factor Authentication'),
            subtitle: const Text('Add extra security layer'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTwoFactorDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.devices, color: Colors.blue),
            title: const Text('Active Sessions'),
            subtitle: const Text('Manage logged-in devices'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showActiveSessions(),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.orange),
            title: const Text('Login History'),
            subtitle: const Text('View recent login activity'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLoginHistory(),
          ),
          const Divider(),

          // Help & Support Section
          _buildSectionHeader('Help & Support'),
          ListTile(
            leading: const Icon(Icons.help, color: Colors.blue),
            title: const Text('FAQs'),
            subtitle: const Text('Frequently asked questions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showFAQs(),
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: const Text('Live Chat'),
            subtitle: const Text('Chat with our support team'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLiveChat(),
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.teal),
            title: const Text('Contact Us'),
            subtitle: const Text('+254 700 000 000'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling +254 700 000 000...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.red),
            title: const Text('Email Support'),
            subtitle: const Text('support@2nk.co.ke'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening email to support@2nk.co.ke...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.brown),
            title: const Text('Branch Locations'),
            subtitle: const Text('Find a branch near you'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showBranches(),
          ),
          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.grey),
            title: const Text('Terms & Conditions'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showTerms(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.grey),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPrivacyPolicy(),
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.grey),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .logout();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1B5E20),
          letterSpacing: 1,
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    nameCtrl.text = user?.fullName ?? '';
    phoneCtrl.text = user?.phoneNumber ?? '';
    emailCtrl.text = user?.email ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).updateProfile(
                fullName: nameCtrl.text,
                phone: phoneCtrl.text,
                email: emailCtrl.text,
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Passwords do not match!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Swahili', 'Kikuyu', 'Luo'].map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (val) {
                setState(() => _selectedLanguage = val!);
                Navigator.pop(ctx);
              },
              activeColor: const Color(0xFF1B5E20),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTwoFactorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text(
          'Enable 2FA to add an extra layer of security to your account. '
          'You will receive a verification code via SMS each time you login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('2FA enabled successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Active Sessions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.green),
              title: const Text('Samsung A17'),
              subtitle: const Text('Current device • Nairobi, KE'),
              trailing: const Chip(label: Text('Active', style: TextStyle(fontSize: 10))),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.laptop, color: Colors.grey),
              title: const Text('Windows PC'),
              subtitle: const Text('Last active: 2 days ago'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login History'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return ListTile(
              dense: true,
              leading: const Icon(Icons.login, color: Colors.green, size: 20),
              title: Text('Login ${index + 1}'),
              subtitle: Text('Nairobi, KE • ${DateTime.now().subtract(Duration(days: index)).toString().substring(0, 16)}'),
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFAQs() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _faqItem('How do I apply for a loan?', 'Go to the Loans section and fill out the application form with your details and guarantor information.'),
              _faqItem('How long does loan approval take?', 'Loans are typically approved within 24-48 hours after submission.'),
              _faqItem('What are the interest rates?', 'Interest rates range from 8% to 14% depending on the loan amount.'),
              _faqItem('How do I deposit money?', 'You can deposit through M-Pesa, bank transfer, or visit any 2NK SACCO branch.'),
              _faqItem('Is my money safe?', 'Yes, all deposits are protected and guaranteed by the SACCO.'),
              _faqItem('How do I withdraw savings?', 'Go to the Savings tab and click "Withdraw from Savings" to move money back to your main account.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            answer,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showLiveChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Live Chat Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Color(0xFF1B5E20),
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hello! How can we help you today?',
                      style: TextStyle(color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message sent! Support will respond shortly.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showBranches() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Our Branches'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _branchItem('Nairobi - Head Office', 'Moi Avenue, Nairobi', '+254 700 000 001'),
            _branchItem('Mombasa Branch', 'Nkrumah Road, Mombasa', '+254 700 000 002'),
            _branchItem('Kisumu Branch', 'Oginga Odinga Road, Kisumu', '+254 700 000 003'),
            _branchItem('Nakuru Branch', 'Kenyatta Avenue, Nakuru', '+254 700 000 004'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _branchItem(String name, String address, String phone) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.location_on, color: Color(0xFF1B5E20)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text('$address\n$phone', style: const TextStyle(fontSize: 12)),
    );
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('1. Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 5),
              Text('Members must be 18 years or older with valid identification documents.'),
              SizedBox(height: 15),
              Text('2. Savings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 5),
              Text('Minimum monthly savings of KES 500 is required to maintain active membership.'),
              SizedBox(height: 15),
              Text('3. Loans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 5),
              Text('Loans are subject to approval. Interest rates apply as per SACCO policy.'),
              SizedBox(height: 15),
              Text('4. Withdrawals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 5),
              Text('Withdrawals are processed within 24 hours. Maximum daily withdrawal limits apply.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('We are committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 15),
              Text('Data Collection', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('We collect only necessary information to provide our services including name, phone number, ID number, and transaction data.', style: TextStyle(fontSize: 13)),
              SizedBox(height: 15),
              Text('Data Protection', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text('Your data is encrypted and stored securely. We do not share your information with third parties.', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}