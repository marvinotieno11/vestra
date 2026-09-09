import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'user_account_store.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    final String fullName = UserAccountStore.fullName?.trim().isNotEmpty == true
        ? UserAccountStore.fullName!.trim()
        : 'Vestra User';

    final String email = UserAccountStore.email?.trim().isNotEmpty == true
        ? UserAccountStore.email!.trim()
        : 'No email available';

    final String firstName = fullName.split(' ').first;

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'PROFILE',
          style: TextStyle(
            color: gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        iconTheme: const IconThemeData(color: gold),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: gold.withValues(alpha: 0.30)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF24200F),
                        border: Border.all(color: gold, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: gold,
                        size: 40,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: softWhite,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF24200F),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: gold.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'WELCOME, ${firstName.toUpperCase()}',
                        style: const TextStyle(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Account',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Account Information',
                subtitle: 'View your name and email address',
                onTap: () {
                  _showAccountInformation(context, fullName, email);
                },
              ),

              const SizedBox(height: 12),

              _ProfileOption(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Manage your Vestra experience',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              const Text(
                'About your profile',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 15),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withValues(alpha: 0.15)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: gold, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'VESTRA',
                          style: TextStyle(
                            color: gold,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Your profile is for your account and app '
                      'settings. Your style identity, wardrobe and '
                      'outfits live in their dedicated areas of Vestra.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountInformation(
    BuildContext context,
    String fullName,
    String email,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'ACCOUNT INFORMATION',
                  style: TextStyle(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                _AccountDetail(
                  icon: Icons.person_outline,
                  label: 'FULL NAME',
                  value: fullName,
                ),

                const SizedBox(height: 18),

                _AccountDetail(
                  icon: Icons.email_outlined,
                  label: 'EMAIL',
                  value: email,
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: gold.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'CLOSE',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: gold.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF24200F),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: gold, size: 23),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: softWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: gold),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AccountDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF24200F),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: gold, size: 21),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: gold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                value,
                style: const TextStyle(
                  color: softWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
