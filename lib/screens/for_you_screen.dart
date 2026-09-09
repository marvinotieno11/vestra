import 'package:flutter/material.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreenState();
}

class _ForYouScreenState extends State<ForYouScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  final List<Map<String, dynamic>> outfits = [
    {
      'name': 'The Minimalist',
      'description':
          'A clean, refined look built around simple silhouettes and timeless pieces.',
      'style': 'Minimalist',
      'occasion': 'Everyday',
      'items': [
        'Relaxed black shirt',
        'Cream trousers',
        'Minimal leather shoes',
        'Black watch',
      ],
      'reason': 'Matches your clean and refined aesthetic.',
    },
    {
      'name': 'Urban Edge',
      'description':
          'A modern streetwear look with relaxed proportions and subtle luxury.',
      'style': 'Streetwear',
      'occasion': 'Casual',
      'items': [
        'Oversized black jacket',
        'Wide-leg trousers',
        'Clean sneakers',
        'Silver accessories',
      ],
      'reason': 'A strong combination of relaxed fit and modern edge.',
    },
    {
      'name': 'Afro Luxe',
      'description':
          'A sophisticated Afro-fusion look combining contemporary tailoring with cultural character.',
      'style': 'Afro-Fusion',
      'occasion': 'Event',
      'items': [
        'Structured patterned shirt',
        'Tailored black trousers',
        'Leather sandals',
        'Statement necklace',
      ],
      'reason': 'Balances cultural expression with a luxury finish.',
    },
    {
      'name': 'After Dark',
      'description':
          'A darker evening look designed for a sophisticated and confident presence.',
      'style': 'Luxury',
      'occasion': 'Evening',
      'items': [
        'Black fitted shirt',
        'Black tailored trousers',
        'Long coat',
        'Leather boots',
      ],
      'reason': 'Perfect for a darker, sophisticated aesthetic.',
    },
  ];

  final Set<int> savedOutfits = {};

  void _openOutfit(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutfitDetailsScreen(
          outfit: outfits[index],
          isSaved: savedOutfits.contains(index),
          onSave: () {
            setState(() {
              if (savedOutfits.contains(index)) {
                savedOutfits.remove(index);
              } else {
                savedOutfits.add(index);
              }
            });
          },
        ),
      ),
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
          'FOR YOU',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Made for you.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Looks selected around your style and the way you dress.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              // PERSONALIZATION HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: gold.withValues(alpha: 0.18)),
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
                      child: const Icon(
                        Icons.auto_awesome,
                        color: gold,
                        size: 23,
                      ),
                    ),

                    const SizedBox(width: 13),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized picks',
                            style: TextStyle(
                              color: softWhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Vestra picked these looks for your aesthetic.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Recommended looks',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Tap a look to explore it.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 16),

              // OUTFIT CARDS
              ...List.generate(outfits.length, (index) {
                return _buildOutfitCard(index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOutfitCard(int index) {
    final outfit = outfits[index];
    final isSaved = savedOutfits.contains(index);

    return GestureDetector(
      onTap: () => _openOutfit(index),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: gold.withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // VISUAL PLACEHOLDER
            Container(
              height: 180,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF101010),
                borderRadius: BorderRadius.vertical(top: Radius.circular(21)),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.checkroom_outlined,
                      color: gold,
                      size: 48,
                    ),
                  ),

                  Positioned(
                    top: 13,
                    right: 13,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (savedOutfits.contains(index)) {
                            savedOutfits.remove(index);
                          } else {
                            savedOutfits.add(index);
                          }
                        });
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: isSaved ? gold : softWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left: 14,
                    bottom: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        outfit['style'],
                        style: const TextStyle(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(17, 15, 17, 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          outfit['name'],
                          style: const TextStyle(
                            color: softWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: gold,
                        size: 14,
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Text(
                    outfit['description'],
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: Colors.white38,
                        size: 15,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        outfit['occasion'],
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        'VIEW LOOK',
                        style: TextStyle(
                          color: gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================================
// OUTFIT DETAILS SCREEN
// =======================================================================

class OutfitDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> outfit;
  final bool isSaved;
  final VoidCallback onSave;

  const OutfitDetailsScreen({
    super.key,
    required this.outfit,
    required this.isSaved,
    required this.onSave,
  });

  @override
  State<OutfitDetailsScreen> createState() => _OutfitDetailsScreenState();
}

class _OutfitDetailsScreenState extends State<OutfitDetailsScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  late bool isSaved;

  @override
  void initState() {
    super.initState();
    isSaved = widget.isSaved;
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final outfit = widget.outfit;
    final items = List<String>.from(outfit['items']);

    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        iconTheme: const IconThemeData(color: gold),
        actions: [
          IconButton(
            onPressed: _toggleSave,
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: gold,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LOOK PREVIEW
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF101010),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: gold.withValues(alpha: 0.18)),
                ),
                child: const Center(
                  child: Icon(Icons.checkroom_outlined, color: gold, size: 65),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                outfit['name'],
                style: const TextStyle(
                  color: softWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                outfit['description'],
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  _InfoChip(
                    icon: Icons.palette_outlined,
                    text: outfit['style'],
                  ),

                  const SizedBox(width: 9),

                  _InfoChip(
                    icon: Icons.event_outlined,
                    text: outfit['occasion'],
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Text(
                'The look',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 13),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withValues(alpha: 0.16)),
                ),
                child: Column(
                  children: List.generate(items.length, (index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 13,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF24200F),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: gold,
                              size: 16,
                            ),
                          ),

                          const SizedBox(width: 11),

                          Expanded(
                            child: Text(
                              items[index],
                              style: const TextStyle(
                                color: softWhite,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 22),

              // WHY THIS LOOK
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: gold.withValues(alpha: 0.15)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.auto_awesome, color: gold, size: 21),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Why Vestra picked this',
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            outfit['reason'],
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // STYLE THIS LOOK
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Style this look with your wardrobe — coming next.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, color: Colors.black),
                  label: const Text(
                    'STYLE THIS LOOK',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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

// =======================================================================
// INFO CHIP
// =======================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  static const Color gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: gold.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 14),

          const SizedBox(width: 6),

          Text(
            text,
            style: const TextStyle(color: Colors.white60, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
