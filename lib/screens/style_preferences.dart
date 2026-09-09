import 'package:flutter/material.dart';
import 'style_preferences_store.dart';

class StylePreferencesScreen extends StatefulWidget {
  const StylePreferencesScreen({super.key});

  @override
  State<StylePreferencesScreen> createState() => _StylePreferencesScreenState();
}

class _StylePreferencesScreenState extends State<StylePreferencesScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  final List<String> styles = [
    'Minimal',
    'Luxury',
    'Streetwear',
    'Afro-fusion',
    'Classic',
    'Avant-garde',
    'Vintage',
    'Casual',
    'Formal',
    'Smart Casual',
    'Sporty',
    'Preppy',
    'Relaxed',
  ];

  final List<String> fits = [
    'Slim',
    'Regular',
    'Relaxed',
    'Oversized',
    'Straight',
    'Loose',
  ];

  final List<String> colors = [
    'Black',
    'White',
    'Cream',
    'Brown',
    'Grey',
    'Blue',
    'Green',
    'Red',
    'Gold',
    'Beige',
    'Navy',
    'Burgundy',
  ];

  Set<String> selectedStyles = {};
  Set<String> selectedFits = {};
  Set<String> selectedColors = {};

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await StylePreferencesStore.loadPreferences();

    if (!mounted) return;

    setState(() {
      selectedStyles = Set<String>.from(StylePreferencesStore.selectedStyles);

      selectedFits = Set<String>.from(StylePreferencesStore.selectedFits);

      selectedColors = Set<String>.from(StylePreferencesStore.selectedColors);

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'EDIT MY STYLE',
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
                      'Refine your style.',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose the styles, fits and colors that best '
                      'represent you. Vestra will use these preferences '
                      'to personalize your fashion experience.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _sectionTitle('Your styles'),
                    const SizedBox(height: 7),
                    const Text(
                      'Select as many as describe your style.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    _optionWrap(options: styles, selected: selectedStyles),

                    const SizedBox(height: 32),

                    _sectionTitle('Your preferred fits'),
                    const SizedBox(height: 7),
                    const Text(
                      'Choose the silhouettes you feel most comfortable in.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    _optionWrap(options: fits, selected: selectedFits),

                    const SizedBox(height: 32),

                    _sectionTitle('Your colors'),
                    const SizedBox(height: 7),
                    const Text(
                      'Choose the colors you naturally enjoy wearing.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    _optionWrap(options: colors, selected: selectedColors),

                    const SizedBox(height: 28),

                    _buildSummary(),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _savePreferences,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: gold.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'SAVE MY STYLE',
                                style: TextStyle(
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
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: softWhite,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _optionWrap({
    required List<String> options,
    required Set<String> selected,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected.contains(option);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selected.remove(option);
              } else {
                selected.add(option);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? gold : card,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? gold : gold.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: Colors.black, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  option,
                  style: TextStyle(
                    color: isSelected ? Colors.black : softWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary() {
    final total =
        selectedStyles.length + selectedFits.length + selectedColors.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
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
            child: const Icon(Icons.auto_awesome, color: gold, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your style profile',
                  style: TextStyle(
                    color: softWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0
                      ? 'No preferences selected yet.'
                      : '$total preference${total == 1 ? '' : 's'} selected.',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    if (selectedStyles.isEmpty &&
        selectedFits.isEmpty &&
        selectedColors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one preference before saving.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await StylePreferencesStore.savePreferences(
      styles: selectedStyles,
      fits: selectedFits,
      colors: selectedColors,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your style preferences have been saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}
