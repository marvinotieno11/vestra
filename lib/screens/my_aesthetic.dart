import 'package:flutter/material.dart';
import 'my_aesthetic_store.dart';

class MyAestheticScreen extends StatefulWidget {
  const MyAestheticScreen({super.key});

  @override
  State<MyAestheticScreen> createState() => _MyAestheticScreenState();
}

class _MyAestheticScreenState extends State<MyAestheticScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  final List<String> aesthetics = [
    'Minimal',
    'Luxury',
    'Afro-fusion',
    'Streetwear',
    'Avant-garde',
    'Classic',
    'Vintage',
    'Editorial',
    'Contemporary',
    'Neo-noir',
    'Dune',
    'Experimental',
    'Old Money',
    'Modern',
    'Monochrome',
    'Utility',
    'Retro',
    'Futuristic',
  ];

  late Set<String> selectedAesthetics;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    selectedAesthetics = {};

    _loadAesthetics();
  }

  Future<void> _loadAesthetics() async {
    await MyAestheticStore.loadAesthetics();

    if (!mounted) return;

    setState(() {
      selectedAesthetics = Set<String>.from(
        MyAestheticStore.selectedAesthetics,
      );

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
          'MY AESTHETIC',
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
                      'Define your aesthetic.',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Choose the visual identities that represent you. '
                      'Your aesthetic helps Vestra understand the overall '
                      'look and feeling you want your outfits to have.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Your aesthetic',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Text(
                      'Select one or more aesthetics.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: aesthetics.map((aesthetic) {
                        final bool isSelected = selectedAesthetics.contains(
                          aesthetic,
                        );

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedAesthetics.remove(aesthetic);
                              } else {
                                selectedAesthetics.add(aesthetic);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 17,
                              vertical: 13,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? gold : card,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: isSelected
                                    ? gold
                                    : gold.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) ...[
                                  const Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  aesthetic,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : softWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    _buildCurrentAesthetic(),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(19),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: gold.withValues(alpha: 0.18)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: gold, size: 23),

                          SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              'Vestra will use your aesthetic together '
                              'with your wardrobe and style preferences '
                              'when personalizing future recommendations.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAesthetic,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
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
                                'SAVE MY AESTHETIC',
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

  Widget _buildCurrentAesthetic() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your current aesthetic',
            style: TextStyle(
              color: softWhite,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          if (selectedAesthetics.isEmpty)
            const Text(
              'Select the aesthetics that represent you.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedAesthetics.map((aesthetic) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24200F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: gold.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    aesthetic,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAesthetic() async {
    if (selectedAesthetics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose at least one aesthetic before saving.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await MyAestheticStore.saveAesthetics(selectedAesthetics);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your aesthetic has been saved.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }
}
