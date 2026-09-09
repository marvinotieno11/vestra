import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'user_account_store.dart';
import 'wardrobe_store.dart';
import 'outfits_store.dart';
import 'style_preferences_store.dart';
import 'my_aesthetic_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  static const String _notificationsKey = 'vestra_notifications_enabled';
  static const String _appearanceKey = 'vestra_appearance';

  bool _notificationsEnabled = true;
  String _appearance = 'Dark';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

      _appearance = prefs.getString(_appearanceKey) ?? 'Dark';

      _loading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_notificationsKey, value);

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _setAppearance(String value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_appearanceKey, value);

    if (!mounted) return;

    setState(() {
      _appearance = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value == 'Dark'
              ? 'Dark appearance selected.'
              : 'System appearance selected.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String firstName =
        UserAccountStore.fullName?.trim().isNotEmpty == true
        ? UserAccountStore.fullName!.trim().split(' ').first
        : 'there';

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        iconTheme: const IconThemeData(color: gold),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your settings.',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Make Vestra feel right for you, $firstName.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // PREFERENCES
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _SettingsSwitch(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: _notificationsEnabled
                          ? 'Vestra notifications are enabled'
                          : 'Vestra notifications are disabled',
                      value: _notificationsEnabled,
                      onChanged: _setNotifications,
                    ),

                    const SizedBox(height: 12),

                    _SettingsOption(
                      icon: Icons.dark_mode_outlined,
                      title: 'Appearance',
                      subtitle: 'Currently using $_appearance appearance',
                      onTap: _showAppearance,
                    ),

                    const SizedBox(height: 30),

                    // ACCOUNT
                    const Text(
                      'Account',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _SettingsOption(
                      icon: Icons.person_outline,
                      title: 'Account Information',
                      subtitle: 'View your Vestra account details',
                      onTap: _showAccountInformation,
                    ),

                    const SizedBox(height: 30),

                    // PRIVACY
                    const Text(
                      'Privacy & Data',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _SettingsOption(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy & Data',
                      subtitle: 'Manage your locally stored Vestra data',
                      onTap: _showPrivacyAndData,
                    ),

                    const SizedBox(height: 30),

                    // ABOUT
                    const Text(
                      'About Vestra',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _SettingsOption(
                      icon: Icons.info_outline,
                      title: 'About Vestra',
                      subtitle: 'Learn more about your AI fashion companion',
                      onTap: _showAboutVestra,
                    ),

                    const SizedBox(height: 12),

                    _SettingsOption(
                      icon: Icons.description_outlined,
                      title: 'Terms & Privacy',
                      subtitle: 'Vestra legal information',
                      onTap: _showTermsAndPrivacy,
                    ),

                    const SizedBox(height: 35),

                    // SIGN OUT
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _confirmSignOut,
                        icon: const Icon(Icons.logout, color: gold),
                        label: const Text(
                          'SIGN OUT',
                          style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: gold.withValues(alpha: 0.45)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Center(
                      child: Text(
                        'VESTRA',
                        style: TextStyle(
                          color: gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Center(
                      child: Text(
                        'Your AI fashion companion',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Center(
                      child: Text(
                        'Version 1.0.0',
                        style: TextStyle(color: Colors.white24, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ------------------------------------------------------------
  // APPEARANCE
  // ------------------------------------------------------------

  void _showAppearance() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
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

                const SizedBox(height: 24),

                const Text(
                  'APPEARANCE',
                  style: TextStyle(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Choose how Vestra should appear.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),

                const SizedBox(height: 20),

                _AppearanceChoice(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark',
                  subtitle: 'Vestra\'s signature black and gold experience',
                  selected: _appearance == 'Dark',
                  onTap: () async {
                    await _setAppearance('Dark');

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                ),

                const SizedBox(height: 10),

                _AppearanceChoice(
                  icon: Icons.settings_suggest_outlined,
                  title: 'System',
                  subtitle: 'Follow your device appearance setting',
                  selected: _appearance == 'System',
                  onTap: () async {
                    await _setAppearance('System');

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ACCOUNT INFORMATION
  // ------------------------------------------------------------

  void _showAccountInformation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
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

                const SizedBox(height: 24),

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
                  value: UserAccountStore.fullName ?? 'Not available',
                ),

                const SizedBox(height: 18),

                _AccountDetail(
                  icon: Icons.email_outlined,
                  label: 'EMAIL',
                  value: UserAccountStore.email ?? 'Not available',
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

  // ------------------------------------------------------------
  // PRIVACY & DATA
  // ------------------------------------------------------------

  void _showPrivacyAndData() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
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

                const SizedBox(height: 24),

                const Text(
                  'PRIVACY & DATA',
                  style: TextStyle(
                    color: gold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Vestra currently stores some information locally '
                  'on this device so your wardrobe, outfits and '
                  'preferences can remain available when you return.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _confirmClearFashionData();
                    },
                    icon: const Icon(Icons.delete_outline, color: gold),
                    label: const Text(
                      'CLEAR MY FASHION DATA',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: gold.withValues(alpha: 0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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

  void _confirmClearFashionData() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Clear fashion data?',
            style: TextStyle(color: softWhite, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will remove your saved wardrobe items, saved '
            'outfits, style preferences and saved aesthetic data '
            'from this device. Your Vestra account itself will not '
            'be deleted.',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await WardrobeStore.clearWardrobe();
                await OutfitStore.clearOutfits();
                await StylePreferencesStore.clearPreferences();
                await MyAestheticStore.clearAesthetics();

                if (!mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your fashion data has been cleared.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'CLEAR DATA',
                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // ABOUT
  // ------------------------------------------------------------

  void _showAboutVestra() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

                const Icon(Icons.auto_awesome, color: gold, size: 38),

                const SizedBox(height: 14),

                const Text(
                  'VESTRA',
                  style: TextStyle(
                    color: gold,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Your AI fashion companion',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Vestra is designed to help you understand your '
                  'style, organize what you own and create outfits '
                  'that feel like you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.white30, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TERMS & PRIVACY
  // ------------------------------------------------------------

  void _showTermsAndPrivacy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            child: SingleChildScrollView(
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

                  const SizedBox(height: 24),

                  const Text(
                    'TERMS & PRIVACY',
                    style: TextStyle(
                      color: gold,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Vestra is currently in development. '
                    'The complete Terms of Service and Privacy Policy '
                    'will be added before Vestra is released publicly.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'For the current development version, Vestra '
                      'stores selected app information locally on '
                      'your device.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

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
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // SIGN OUT
  // ------------------------------------------------------------

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Sign out?',
            style: TextStyle(color: softWhite, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to sign out of Vestra?',
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                UserAccountStore.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                'SIGN OUT',
                style: TextStyle(color: gold, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// SETTINGS OPTION
// ============================================================

class _SettingsOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsOption({
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

// ============================================================
// SETTINGS SWITCH
// ============================================================

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: softWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),

          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: gold,
            activeTrackColor: gold.withValues(alpha: 0.35),
            inactiveThumbColor: Colors.white54,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// APPEARANCE CHOICE
// ============================================================

class _AppearanceChoice extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AppearanceChoice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF24200F) : const Color(0xFF101010),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? gold : gold.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: gold, size: 23),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: softWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                const Icon(Icons.check_circle, color: gold, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT DETAIL
// ============================================================

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
