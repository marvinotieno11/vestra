import 'package:flutter/material.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trending.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Discover styles and looks people are loving right now.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // TRENDING NOW
              const Text(
                'Trending now',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Looks making an impact right now.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 16),

              _buildTrendingLook(
                title: 'Modern Afro-Fusion',
                subtitle: 'Relaxed tailoring with African influence.',
                icon: Icons.checkroom_outlined,
              ),

              const SizedBox(height: 13),

              _buildTrendingLook(
                title: 'Dark Minimalism',
                subtitle: 'Clean silhouettes, dark tones and sharp details.',
                icon: Icons.style_outlined,
              ),

              const SizedBox(height: 13),

              _buildTrendingLook(
                title: 'Elevated Streetwear',
                subtitle: 'Relaxed pieces with a refined finish.',
                icon: Icons.directions_run_outlined,
              ),

              const SizedBox(height: 30),

              // POPULAR STYLES
              const Text(
                'Popular styles',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildStyleChip('Afro-Fusion'),
                  _buildStyleChip('Minimalist'),
                  _buildStyleChip('Luxury'),
                  _buildStyleChip('Streetwear'),
                  _buildStyleChip('Avant-Garde'),
                  _buildStyleChip('Smart Casual'),
                ],
              ),

              const SizedBox(height: 30),

              // TRENDING PIECES
              const Text(
                'Trending pieces',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Pieces currently influencing modern looks.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildPieceCard(
                      icon: Icons.dry_cleaning_outlined,
                      title: 'Tailored Coats',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildPieceCard(
                      icon: Icons.checkroom_outlined,
                      title: 'Wide Trousers',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildPieceCard(
                      icon: Icons.layers_outlined,
                      title: 'Layered Looks',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildPieceCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Statement Accessories',
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
                    Icon(Icons.auto_awesome_outlined, color: gold, size: 23),

                    SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vestra trend tip',
                            style: TextStyle(
                              color: gold,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Trends are inspiration. The best look is '
                            'the one that still feels like you.',
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

  Widget _buildTrendingLook({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF24200F),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: gold, size: 30),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(Icons.arrow_forward_ios, color: gold, size: 15),
        ],
      ),
    );
  }

  Widget _buildStyleChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gold.withValues(alpha: 0.22)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: softWhite,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPieceCard({required IconData icon, required String title}) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFF24200F),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: gold, size: 22),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              color: softWhite,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
