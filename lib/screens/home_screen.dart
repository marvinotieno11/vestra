import 'package:flutter/material.dart';

import 'outfits_screen.dart';
import 'ai_stylist_screen.dart';
import 'wardrobe_screen.dart';
import 'saved_outfits_screen.dart';
import 'profile_screen.dart';
import 'style_preferences.dart';
import 'style_preferences_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadStylePreferences();
  }

  Future<void> _loadStylePreferences() async {
    await StylePreferencesStore.loadPreferences();

    if (mounted) {
      setState(() {});
    }
  }

  void _onNavigationTapped(int index) {
    if (index == 0) {
      setState(() {
        selectedIndex = 0;
      });
      return;
    }

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OutfitsScreen()),
      );
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIStylistScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }
  }

  void _openWardrobe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WardrobeScreen()),
    );
  }

  void _openSavedOutfits() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedOutfitsScreen()),
    );
  }

  void _openAIStylist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIStylistScreen()),
    );
  }

  void _openOutfits() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OutfitsScreen()),
    );
  }

  void _openMyStyle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StylePreferencesScreen()),
    );

    await _loadStylePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final styles = StylePreferencesStore.selectedStyles;
    final fits = StylePreferencesStore.selectedFits;
    final colors = StylePreferencesStore.selectedColors;

    return Scaffold(
      backgroundColor: black,

      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'WELCOME TO VESTRA',
          style: TextStyle(
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your style, your way.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your personal AI fashion companion.',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 28),

              // ---------------------------------------------------------
              // AI STYLIST
              // ---------------------------------------------------------
              _HomeFeatureCard(
                icon: Icons.auto_awesome,
                title: 'AI STYLIST',
                subtitle: 'Create a look from your wardrobe.',
                onTap: _openAIStylist,
                featured: true,
              ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------
              // MY STYLE
              // ---------------------------------------------------------
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'My Style',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: _openMyStyle,
                    child: const Text(
                      'EDIT',
                      style: TextStyle(
                        color: gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _openMyStyle,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withValues(alpha: 0.25)),
                  ),
                  child: styles.isEmpty && fits.isEmpty && colors.isEmpty
                      ? _buildEmptyStyle()
                      : _buildStyleSummary(styles, fits, colors),
                ),
              ),

              const SizedBox(height: 20),

              // ---------------------------------------------------------
              // WARDROBE + SAVED LOOKS
              // ---------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: _HomeSmallCard(
                      icon: Icons.checkroom_outlined,
                      title: 'Wardrobe',
                      subtitle: 'Your pieces',
                      onTap: _openWardrobe,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _HomeSmallCard(
                      icon: Icons.bookmark_outline,
                      title: 'Saved Looks',
                      subtitle: 'Your favorites',
                      onTap: _openSavedOutfits,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ---------------------------------------------------------
              // OUTFITS
              // ---------------------------------------------------------
              _HomeFeatureCard(
                icon: Icons.style_outlined,
                title: 'OUTFITS',
                subtitle: 'Build and explore your outfit collection.',
                onTap: _openOutfits,
              ),
            ],
          ),
        ),
      ),

      // ---------------------------------------------------------------
      // BOTTOM NAVIGATION
      // ---------------------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: black,
        selectedItemColor: gold,
        unselectedItemColor: Colors.white38,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavigationTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom_outlined),
            activeIcon: Icon(Icons.checkroom),
            label: 'Outfits',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI Stylist',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStyle() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF24200F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.auto_awesome_outlined, color: gold, size: 24),
        ),

        const SizedBox(width: 14),

        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Define your style',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: 5),

              Text(
                'Choose your preferred styles, fits and colors.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),

        const Icon(Icons.chevron_right, color: gold, size: 21),
      ],
    );
  }

  Widget _buildStyleSummary(
    Set<String> styles,
    Set<String> fits,
    Set<String> colors,
  ) {
    final List<String> summaryItems = [
      ...styles.take(2),
      ...fits.take(1),
      ...colors.take(1),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF24200F),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.checkroom_outlined, color: gold, size: 24),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your fashion preferences',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: summaryItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF24200F),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              if (styles.length + fits.length + colors.length >
                  summaryItems.length)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Tap to view or edit all preferences',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        const Icon(Icons.chevron_right, color: gold, size: 21),
      ],
    );
  }
}

// =======================================================================
// FEATURE CARD
// =======================================================================

class _HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool featured;

  const _HomeFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.featured = false,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(featured ? 22 : 20),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: gold.withValues(alpha: featured ? 0.35 : 0.22),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFF24200F),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: gold, size: 28),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// SMALL HOME CARD
// =======================================================================

class _HomeSmallCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeSmallCard({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: const Color(0xFF24200F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: gold, size: 23),
            ),

            const SizedBox(height: 14),

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
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
