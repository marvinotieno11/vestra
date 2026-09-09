import 'package:flutter/material.dart';

import 'ai_stylist_screen.dart';
import 'saved_outfits_screen.dart';
import 'for_you_screen.dart';
import 'my_style_screen.dart';
import 'trending_screen.dart';
import 'occasions_screen.dart';

class OutfitsScreen extends StatelessWidget {
  const OutfitsScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  void _openAIStylist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AIStylistScreen()),
    );
  }

  void _openSavedOutfits(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedOutfitsScreen()),
    );
  }

  void _openForYou(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForYouScreen()),
    );
  }

  void _openTrending(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrendingScreen()),
    );
  }

  void _openOccasions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OccasionsScreen()),
    );
  }

  void _openMyStyle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyStyleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,

      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'VESTRA',
          style: TextStyle(
            color: gold,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
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
              const Text(
                'Your outfits.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Build, save and discover looks made for you.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // BUILD OUTFIT
              GestureDetector(
                onTap: () => _openAIStylist(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: gold.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFF24200F),
                              borderRadius: BorderRadius.circular(17),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: gold,
                              size: 26,
                            ),
                          ),

                          const Spacer(),

                          const Icon(
                            Icons.arrow_forward_ios,
                            color: gold,
                            size: 17,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Build an outfit',
                        style: TextStyle(
                          color: softWhite,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Let Vestra create a look using your wardrobe.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: gold,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: const Text(
                          'STYLE ME',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // SAVED OUTFITS
              GestureDetector(
                onTap: () => _openSavedOutfits(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: gold.withValues(alpha: 0.22)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24200F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.bookmark_outline,
                          color: gold,
                          size: 27,
                        ),
                      ),

                      const SizedBox(width: 15),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved looks',
                              style: TextStyle(
                                color: softWhite,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'View outfits you saved.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: gold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // EXPLORE
              const Text(
                'Explore looks',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Discover different ways to dress.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),

              const SizedBox(height: 16),

              // FOR YOU + TRENDING
              Row(
                children: [
                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.auto_awesome_outlined,
                      title: 'For You',
                      subtitle: 'Personalized',
                      onTap: () => _openForYou(context),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.trending_up_outlined,
                      title: 'Trending',
                      subtitle: 'What is popular',
                      onTap: () => _openTrending(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // OCCASIONS + MY STYLE
              Row(
                children: [
                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.event_outlined,
                      title: 'Occasions',
                      subtitle: 'Dress for it',
                      onTap: () => _openOccasions(context),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: _CategoryCard(
                      icon: Icons.palette_outlined,
                      title: 'My Style',
                      subtitle: 'Your aesthetic',
                      onTap: () => _openMyStyle(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // VESTRA TIP
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withValues(alpha: 0.16)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: gold, size: 23),

                    SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vestra tip',
                            style: TextStyle(
                              color: gold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Add more pieces to your wardrobe to give '
                            'Vestra more options when creating your looks.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
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
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryCard({
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
        constraints: const BoxConstraints(minHeight: 155),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF24200F),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: gold, size: 22),
            ),

            const SizedBox(height: 15),

            Text(
              title,
              style: const TextStyle(
                color: softWhite,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 5),

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
