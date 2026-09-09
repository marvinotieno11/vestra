import 'package:flutter/material.dart';

import 'outfits_store.dart';

class SavedOutfitsScreen extends StatefulWidget {
  const SavedOutfitsScreen({super.key});

  @override
  State<SavedOutfitsScreen> createState() => _SavedOutfitsScreenState();
}

class _SavedOutfitsScreenState extends State<SavedOutfitsScreen> {
  static const Color gold = Color(0xFFD4AF37);

  static const Color black = Color(0xFF090909);

  static const Color card = Color(0xFF151515);

  static const Color softWhite = Color(0xFFF5F1E8);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    await OutfitStore.loadOutfits();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedOutfits = OutfitStore.savedOutfits;

    return Scaffold(
      backgroundColor: black,

      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'SAVED OUTFITS',
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your looks.',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Keep the outfits you love '
                      'and come back to them anytime.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 28),

                    if (savedOutfits.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: List.generate(savedOutfits.length, (index) {
                          return _SavedOutfitCard(
                            outfit: savedOutfits[index],
                            onDelete: () async {
                              await OutfitStore.removeOutfit(index);

                              if (!mounted) {
                                return;
                              }

                              setState(() {});
                            },
                          );
                        }),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 45),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: const Column(
        children: [
          Icon(Icons.bookmark_outline, color: gold, size: 42),

          SizedBox(height: 20),

          Text(
            'No saved outfits yet',
            style: TextStyle(
              color: softWhite,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 9),

          Text(
            'Create a look with the AI Stylist '
            'and save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SAVED OUTFIT CARD
// ================================================================

class _SavedOutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final VoidCallback onDelete;

  const _SavedOutfitCard({required this.outfit, required this.onDelete});

  static const Color gold = Color(0xFFD4AF37);

  static const Color card = Color(0xFF151515);

  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    final String occasion = outfit['occasion']?.toString() ?? 'Personal Look';

    final String outfitName = outfit['outfitName']?.toString() ?? 'Saved Look';

    final String description = outfit['description']?.toString() ?? '';

    final String reasoning = outfit['reasoning']?.toString() ?? '';

    final List<Map<String, String>> items = List<Map<String, String>>.from(
      outfit['items'] ?? [],
    );

    final wardrobeItems = items
        .where((item) => item['isSuggested'] != 'true')
        .toList();

    final suggestedItems = items
        .where((item) => item['isSuggested'] == 'true')
        .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================
          // HEADER
          // ====================================================
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF24200F),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.checkroom_outlined,
                  color: gold,
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outfitName,
                      style: const TextStyle(
                        color: softWhite,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      occasion,
                      style: const TextStyle(color: gold, fontSize: 12),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              ),
            ],
          ),

          // ====================================================
          // DESCRIPTION
          // ====================================================
          if (description.isNotEmpty) ...[
            const SizedBox(height: 15),

            Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],

          // ====================================================
          // YOUR WARDROBE
          // ====================================================
          if (wardrobeItems.isNotEmpty) ...[
            const SizedBox(height: 20),

            const Text(
              'FROM YOUR WARDROBE',
              style: TextStyle(
                color: gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: 10),

            ...wardrobeItems.map(
              (item) => _SavedPiece(item: item, suggested: false),
            ),
          ],

          // ====================================================
          // VESTRA SUGGESTIONS
          // ====================================================
          if (suggestedItems.isNotEmpty) ...[
            const SizedBox(height: 18),

            const Text(
              'VEStra SUGGESTED',
              style: TextStyle(
                color: gold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: 10),

            ...suggestedItems.map(
              (item) => _SavedPiece(item: item, suggested: true),
            ),
          ],

          // ====================================================
          // REASONING
          // ====================================================
          if (reasoning.isNotEmpty) ...[
            const SizedBox(height: 15),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF201D16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: gold, size: 18),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      reasoning,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ================================================================
// SAVED PIECE
// ================================================================

class _SavedPiece extends StatelessWidget {
  final Map<String, String> item;
  final bool suggested;

  const _SavedPiece({required this.item, required this.suggested});

  static const Color gold = Color(0xFFD4AF37);

  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    final name = item['name'] ?? 'Unnamed item';

    final category = item['category'] ?? '';

    final color = item['color'] ?? '';

    final fit = item['fit'] ?? '';

    final notes = item['notes'] ?? '';

    final details = <String>[];

    if (color.isNotEmpty) {
      details.add(color);
    }

    if (fit.isNotEmpty) {
      details.add(fit);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: suggested ? gold.withValues(alpha: 0.25) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            suggested ? Icons.auto_awesome : Icons.check_circle_outline,
            color: gold,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: softWhite,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                if (details.isNotEmpty)
                  Text(
                    details.join(' • '),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),

                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    notes,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],

                const SizedBox(height: 4),

                Text(
                  suggested ? 'VEStra suggestion' : 'YOUR WARDROBE',
                  style: TextStyle(
                    color: suggested ? gold : Colors.white38,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),

          Text(
            category,
            style: const TextStyle(color: Colors.white54, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
