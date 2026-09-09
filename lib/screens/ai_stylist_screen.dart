import 'package:flutter/material.dart';

import 'wardrobe_store.dart';
import 'style_preferences_store.dart';
import 'my_aesthetic_store.dart';
import 'outfit_result_screen.dart';

import '../services/vestra_styling_engine.dart';

class AIStylistScreen extends StatefulWidget {
  const AIStylistScreen({super.key});

  @override
  State<AIStylistScreen> createState() => _AIStylistScreenState();
}

class _AIStylistScreenState extends State<AIStylistScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  String selectedOccasion = 'Casual';

  final TextEditingController requestController = TextEditingController();

  final List<String> occasions = VestraStylingEngine.occasionOptions;

  final List<Map<String, String>> selectedItems = [];

  List<Map<String, String>> get wardrobe => WardrobeStore.items;

  Set<String> get selectedStyles => StylePreferencesStore.selectedStyles;

  Set<String> get selectedFits => StylePreferencesStore.selectedFits;

  Set<String> get selectedColors => StylePreferencesStore.selectedColors;

  Set<String> get selectedAesthetics => MyAestheticStore.selectedAesthetics;

  @override
  void dispose() {
    requestController.dispose();
    super.dispose();
  }

  // ============================================================
  // SELECT / DESELECT WARDROBE ITEM
  // ============================================================

  void _toggleItem(Map<String, String> item) {
    setState(() {
      final index = selectedItems.indexWhere(
        (selected) =>
            selected['name'] == item['name'] &&
            selected['category'] == item['category'],
      );

      if (index >= 0) {
        selectedItems.removeAt(index);
      } else {
        selectedItems.add(Map<String, String>.from(item));
      }
    });
  }

  bool _isSelected(Map<String, String> item) {
    return selectedItems.any(
      (selected) =>
          selected['name'] == item['name'] &&
          selected['category'] == item['category'],
    );
  }

  // ============================================================
  // CREATE THREE LOOKS
  // ============================================================

  void _createLook() {
    if (wardrobe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your wardrobe is empty. Add some pieces first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final personalizedRequest = _buildPersonalizedRequest();

    final results = VestraStylingEngine.generateLooks(
      occasion: selectedOccasion,
      request: personalizedRequest,
      selectedItems: selectedItems,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OutfitResultScreen(
          occasion: selectedOccasion,
          request: personalizedRequest,
          results: results,
        ),
      ),
    );
  }

  // ============================================================
  // PERSONALIZED REQUEST
  // ============================================================

  String _buildPersonalizedRequest() {
    final details = <String>[];

    final typedRequest = requestController.text.trim();

    if (typedRequest.isNotEmpty) {
      details.add(typedRequest);
    }

    if (selectedStyles.isNotEmpty) {
      details.add(
        'Preferred styles: '
        '${selectedStyles.join(', ')}.',
      );
    }

    if (selectedFits.isNotEmpty) {
      details.add(
        'Preferred fits: '
        '${selectedFits.join(', ')}.',
      );
    }

    if (selectedColors.isNotEmpty) {
      details.add(
        'Preferred colors: '
        '${selectedColors.join(', ')}.',
      );
    }

    if (selectedAesthetics.isNotEmpty) {
      details.add(
        'Personal aesthetic: '
        '${selectedAesthetics.join(', ')}.',
      );
    }

    return details.join(' ');
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
          'AI STYLIST',
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
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your personal stylist.',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tell Vestra what you want to wear '
                'and let it build looks around your '
                'actual wardrobe.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 25),

              _buildIntroCard(),

              const SizedBox(height: 25),

              _buildPersonalStyleCard(),

              const SizedBox(height: 30),

              // ==================================================
              // OCCASION
              // ==================================================
              const Text(
                'What are you dressing for?',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose a starting point, or describe '
                'something completely different below.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 9,
                runSpacing: 9,
                children: occasions.map((occasion) {
                  final selected = selectedOccasion == occasion;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOccasion = occasion;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? gold : card,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? gold : gold.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        occasion,
                        style: TextStyle(
                          color: selected ? Colors.black : softWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // FREE FORM REQUEST
              // ==================================================
              const Text(
                'Tell your stylist more',
                style: TextStyle(
                  color: softWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'You can give Vestra any instruction you want.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: requestController,
                maxLines: 5,
                style: const TextStyle(color: softWhite, fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'Example: Build something avant-garde '
                      'around my black dress, make it dramatic '
                      'but suitable for an art exhibition.',
                  hintStyle: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  filled: true,
                  fillColor: card,
                  contentPadding: const EdgeInsets.all(17),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: gold.withValues(alpha: 0.25)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: gold.withValues(alpha: 0.25)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    borderSide: BorderSide(color: gold, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // WARDROBE
              // ==================================================
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Choose from your wardrobe',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  Text(
                    '${selectedItems.length} selected',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              const Text(
                'Optional: select specific pieces. '
                'If you select nothing, Vestra can '
                'consider the whole wardrobe.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              if (wardrobe.isEmpty)
                _buildEmptyWardrobe()
              else
                Column(
                  children: wardrobe.map((item) {
                    return _buildWardrobeSelectionCard(item);
                  }).toList(),
                ),

              const SizedBox(height: 25),

              // ==================================================
              // CREATE
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _createLook,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text(
                    'CREATE 3 LOOKS',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRO CARD
  // ============================================================

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_awesome, color: gold, size: 30),

          SizedBox(width: 15),

          Expanded(
            child: Text(
              'Vestra builds looks from the pieces '
              'you actually own and follows the '
              'instructions you give it.',
              style: TextStyle(
                color: softWhite,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STYLE PROFILE
  // ============================================================

  Widget _buildPersonalStyleCard() {
    final hasPreferences =
        selectedStyles.isNotEmpty ||
        selectedFits.isNotEmpty ||
        selectedColors.isNotEmpty;

    final hasAesthetic = selectedAesthetics.isNotEmpty;

    if (!hasPreferences && !hasAesthetic) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: const Row(
          children: [
            Icon(Icons.person_outline, color: gold, size: 25),
            SizedBox(width: 13),
            Expanded(
              child: Text(
                'Your personal style has not been '
                'set yet. Vestra can still style '
                'your wardrobe.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, color: gold, size: 23),
              SizedBox(width: 10),
              Text(
                'YOUR STYLE PROFILE',
                style: TextStyle(
                  color: gold,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          if (selectedStyles.isNotEmpty)
            _styleProfileRow('Styles', selectedStyles),

          if (selectedFits.isNotEmpty) _styleProfileRow('Fits', selectedFits),

          if (selectedColors.isNotEmpty)
            _styleProfileRow('Colors', selectedColors),

          if (selectedAesthetics.isNotEmpty)
            _styleProfileRow('Aesthetic', selectedAesthetics),
        ],
      ),
    );
  }

  Widget _styleProfileRow(String title, Set<String> values) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 75,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ),

          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values.map((value) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24200F),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY WARDROBE
  // ============================================================

  Widget _buildEmptyWardrobe() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.checkroom_outlined, color: gold, size: 42),

          SizedBox(height: 14),

          Text(
            'Your wardrobe is empty',
            style: TextStyle(
              color: softWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 7),

          Text(
            'Add clothing pieces to your wardrobe '
            'first, then come back here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WARDROBE CARD
  // ============================================================

  Widget _buildWardrobeSelectionCard(Map<String, String> item) {
    final selected = _isSelected(item);

    return GestureDetector(
      onTap: () => _toggleItem(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF211C0C) : card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? gold : gold.withValues(alpha: 0.2),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF24200F),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _getCategoryIcon(item['category']),
                color: gold,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Unnamed item',
                    style: const TextStyle(
                      color: softWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${item['category'] ?? 'Item'} • '
                    '${item['color']?.isEmpty == true ? 'Color not specified' : item['color']}',
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),

                  if (item['fit']?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      item['fit']!,
                      style: const TextStyle(color: gold, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),

            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? gold : Colors.transparent,
                border: Border.all(
                  color: selected ? gold : Colors.white38,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.black, size: 17)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vestra considers',
            style: TextStyle(
              color: softWhite,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '• Your occasion\n'
            '• Your actual wardrobe\n'
            '• Specific pieces you select\n'
            '• Pieces mentioned in your request\n'
            '• Your style preferences\n'
            '• Your aesthetic\n'
            '• Your free-form instructions\n'
            '• Garment structure\n'
            '• Context such as petwear\n'
            '• Three different styling directions',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.7),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CATEGORY ICON
  // ============================================================

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
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

      case 'pet clothing':
        return Icons.pets_outlined;

      default:
        return Icons.checkroom_outlined;
    }
  }
}
