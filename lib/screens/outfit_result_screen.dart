import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../services/vestra_styling_engine.dart';
import 'outfits_store.dart';

class OutfitResultScreen extends StatefulWidget {
  final String occasion;
  final String request;
  final List<VestraStylingResult> results;

  const OutfitResultScreen({
    super.key,
    required this.occasion,
    required this.request,
    required this.results,
  });

  @override
  State<OutfitResultScreen> createState() => _OutfitResultScreenState();
}

class _OutfitResultScreenState extends State<OutfitResultScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  final Set<int> savedLooks = {};

  // ============================================================
  // SAVE LOOK
  // ============================================================

  Future<void> _saveLook(int index, VestraStylingResult result) async {
    if (savedLooks.contains(index)) {
      return;
    }

    final items = <Map<String, String>>[];

    // Add every selected wardrobe piece.
    result.selectedPieces.forEach((category, item) {
      final savedItem = Map<String, String>.from(item);

      savedItem['category'] = item['category'] ?? category;

      savedItem['name'] = item['name'] ?? 'Unnamed item';

      savedItem['color'] = item['color'] ?? '';

      savedItem['fit'] = item['fit'] ?? '';

      savedItem['notes'] = item['notes'] ?? '';

      items.add(savedItem);
    });

    // Also include actual suggested wardrobe pieces if the
    // styling engine supplied them.
    for (final suggested in result.suggestedPieces) {
      final suggestedItem = Map<String, String>.from(suggested);

      final category = suggestedItem['category'] ?? '';

      final name = suggestedItem['name'] ?? '';

      // Only add a suggested piece when it represents an
      // actual wardrobe item. Generic missing-piece suggestions
      // should not become fake wardrobe entries.
      final isWardrobeItem =
          suggestedItem['source'] == 'wardrobe' ||
          suggestedItem['imageData']?.isNotEmpty == true ||
          suggestedItem['imageBase64']?.isNotEmpty == true;

      if (!isWardrobeItem) {
        continue;
      }

      if (category.isEmpty && name.isEmpty) {
        continue;
      }

      suggestedItem['category'] = category.isNotEmpty ? category : 'Other';

      suggestedItem['name'] = name.isNotEmpty ? name : 'Unnamed item';

      suggestedItem['color'] = suggestedItem['color'] ?? '';

      suggestedItem['fit'] = suggestedItem['fit'] ?? '';

      suggestedItem['notes'] = suggestedItem['notes'] ?? '';

      // Prevent the same item from being added twice.
      final alreadyIncluded = items.any(
        (existing) =>
            existing['name'] == suggestedItem['name'] &&
            existing['category'] == suggestedItem['category'],
      );

      if (!alreadyIncluded) {
        items.add(suggestedItem);
      }
    }

    if (items.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('There are no wardrobe pieces to save.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    // ==========================================================
    // SAVE TO OUTFIT STORE
    // ==========================================================

    await OutfitStore.addOutfit(
      outfitName: result.outfitName,
      description: result.description,
      reasoning: result.reasoning,
      occasion: widget.occasion,
      items: items,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      savedLooks.add(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${result.outfitName} saved to your collection.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'YOUR VESTRA LOOKS',
          style: TextStyle(
            color: gold,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
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
              _buildHeader(),

              const SizedBox(height: 28),

              const Text(
                'Your options',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Each look is built from the wardrobe '
                'pieces Vestra considered compatible.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),

              const SizedBox(height: 18),

              ...List.generate(widget.results.length, (index) {
                return _buildLookCard(index, widget.results[index]);
              }),

              if (widget.request.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildRequestCard(),
              ],

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text(
                    'CREATE THREE MORE LOOKS',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: gold,
                    side: BorderSide(color: gold.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: gold, size: 32),

          const SizedBox(height: 18),

          const Text(
            'Three Ways To Wear It',
            style: TextStyle(
              color: softWhite,
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.occasion,
            style: const TextStyle(
              color: gold,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Vestra created three different '
            'styling directions using the actual '
            'wardrobe information available.',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOOK CARD
  // ============================================================

  Widget _buildLookCard(int index, VestraStylingResult result) {
    final isSaved = savedLooks.contains(index);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======================================================
          // LOOK NUMBER
          // ======================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF24200F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LOOK ${index + 1}',
                  style: const TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              Icon(
                index == 0 ? Icons.star : Icons.auto_awesome,
                color: gold,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ======================================================
          // NAME
          // ======================================================
          Text(
            result.outfitName,
            style: const TextStyle(
              color: softWhite,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            result.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // VISUAL LOOK BOARD
          // ======================================================
          _buildVisualLookBoard(result),

          const SizedBox(height: 20),

          const Text(
            'THE PIECES',
            style: TextStyle(
              color: gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 12),

          if (result.selectedPieces.isNotEmpty)
            ...result.selectedPieces.entries.map((entry) {
              return _OutfitPieceCard(category: entry.key, item: entry.value);
            })
          else
            _buildNoPieces(),

          const SizedBox(height: 16),

          // ======================================================
          // WHY THIS LOOK
          // ======================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF201D16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, color: gold, size: 20),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    result.reasoning,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // MISSING PIECES
          // ======================================================
          if (result.missingPieces.isNotEmpty) ...[
            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF201818),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COULD BE COMPLETED WITH',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...result.missingPieces.map((missing) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '• ${missing['name'] ?? 'Complementary piece'}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // ======================================================
          // RECOMMENDATIONS
          // ======================================================
          if (result.recommendations.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'STYLING NOTES',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  ...result.recommendations.map((recommendation) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        '• $recommendation',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const SizedBox(height: 18),

          // ======================================================
          // SAVE
          // ======================================================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSaved ? null : () => _saveLook(index, result),
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              label: Text(
                isSaved ? 'LOOK SAVED' : 'SAVE THIS LOOK',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSaved ? const Color(0xFF24200F) : gold,
                foregroundColor: isSaved ? gold : Colors.black,
                disabledBackgroundColor: const Color(0xFF24200F),
                disabledForegroundColor: gold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VISUAL LOOK BOARD
  // ============================================================

  Widget _buildVisualLookBoard(VestraStylingResult result) {
    final pieces = result.selectedPieces.entries.toList();

    return Container(
      width: double.infinity,
      height: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: pieces.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: gold, size: 34),
                  SizedBox(height: 10),
                  Text(
                    'VESTRA LOOK BOARD',
                    style: TextStyle(
                      color: gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Visual representation will appear here.',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'VESTRA LOOK BOARD',
                    style: TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: pieces.map((entry) {
                        return _buildVisualPiece(entry.value);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // VISUAL PIECE
  // ============================================================

  Widget _buildVisualPiece(Map<String, String> item) {
    final imageData = item['imageData'] ?? item['imageBase64'] ?? '';

    if (imageData.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(imageData);

        return Container(
          width: 105,
          height: 125,
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        );
      } catch (_) {
        // If the image cannot be decoded,
        // use the placeholder below.
      }
    }

    return Container(
      width: 105,
      height: 125,
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_categoryIcon(item['category'] ?? ''), color: gold, size: 30),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item['name'] ?? item['category'] ?? 'Piece',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: softWhite,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  //
  // This belongs to the result screen state because
  // _buildVisualPiece() uses it.
  // ============================================================

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tops':
        return Icons.checkroom_outlined;

      case 'bottoms':
        return Icons.dry_cleaning_outlined;

      case 'dresses':
        return Icons.checkroom_outlined;

      case 'skirts':
        return Icons.checkroom_outlined;

      case 'jumpsuits':
        return Icons.checkroom_outlined;

      case 'shoes':
        return Icons.directions_walk_outlined;

      case 'outerwear':
        return Icons.layers_outlined;

      case 'accessories':
        return Icons.watch_outlined;

      case 'bags':
        return Icons.shopping_bag_outlined;

      case 'headwear':
        return Icons.face_outlined;

      case 'activewear':
        return Icons.fitness_center_outlined;

      case 'swimwear':
        return Icons.pool_outlined;

      case 'traditional wear':
        return Icons.checkroom_outlined;

      case 'pet clothing':
        return Icons.pets_outlined;

      default:
        return Icons.checkroom_outlined;
    }
  }

  // ============================================================
  // REQUEST CARD
  // ============================================================

  Widget _buildRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF24200F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: gold, size: 21),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YOUR REQUEST',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  widget.request,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NO PIECES
  // ============================================================

  Widget _buildNoPieces() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201818),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Text(
        'Vestra could not find enough compatible '
        'wardrobe pieces for this direction.',
        style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
      ),
    );
  }
}

// ============================================================================
// OUTFIT PIECE CARD
// ============================================================================

class _OutfitPieceCard extends StatelessWidget {
  final String category;
  final Map<String, String> item;

  const _OutfitPieceCard({required this.category, required this.item});

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF111111);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    final name = item['name']?.trim().isNotEmpty == true
        ? item['name']!.trim()
        : 'Unnamed item';

    final color = item['color']?.trim() ?? '';

    final fit = item['fit']?.trim() ?? '';

    final notes = item['notes']?.trim() ?? '';

    final details = <String>[];

    if (color.isNotEmpty) {
      details.add(color);
    }

    if (fit.isNotEmpty) {
      details.add(fit);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: gold.withValues(alpha: 0.15)),
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
            child: Icon(_categoryIcon(category), color: gold, size: 23),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    color: gold,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  name,
                  style: const TextStyle(
                    color: softWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (details.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    details.join(' • '),
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                ],

                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tops':
        return Icons.checkroom_outlined;

      case 'bottoms':
        return Icons.dry_cleaning_outlined;

      case 'dresses':
        return Icons.checkroom_outlined;

      case 'skirts':
        return Icons.checkroom_outlined;

      case 'jumpsuits':
        return Icons.checkroom_outlined;

      case 'shoes':
        return Icons.directions_walk_outlined;

      case 'outerwear':
        return Icons.layers_outlined;

      case 'accessories':
        return Icons.watch_outlined;

      case 'bags':
        return Icons.shopping_bag_outlined;

      case 'headwear':
        return Icons.face_outlined;

      case 'activewear':
        return Icons.fitness_center_outlined;

      case 'swimwear':
        return Icons.pool_outlined;

      case 'traditional wear':
        return Icons.checkroom_outlined;

      case 'pet clothing':
        return Icons.pets_outlined;

      default:
        return Icons.checkroom_outlined;
    }
  }
}
