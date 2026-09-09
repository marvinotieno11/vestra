import 'package:flutter/material.dart';
import 'style_preferences.dart';
import 'style_preferences_store.dart';

class MyStyleScreen extends StatefulWidget {
  const MyStyleScreen({super.key});

  @override
  State<MyStyleScreen> createState() => _MyStyleScreenState();
}

class _MyStyleScreenState extends State<MyStyleScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStyle();
  }

  Future<void> _loadStyle() async {
    await StylePreferencesStore.loadPreferences();

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  Future<void> _editStyle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StylePreferencesScreen()),
    );

    if (!mounted) return;

    await _loadStyle();
  }

  Future<void> _refreshStyle() async {
    setState(() {
      _loading = true;
    });

    await StylePreferencesStore.loadPreferences();

    if (!mounted) return;

    setState(() {
      _loading = false;
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
          'MY STYLE',
          style: TextStyle(
            color: gold,
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
        iconTheme: const IconThemeData(color: gold),
        actions: [
          IconButton(
            onPressed: _refreshStyle,
            icon: const Icon(Icons.refresh_outlined, color: gold),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : RefreshIndicator(
                color: gold,
                backgroundColor: card,
                onRefresh: _refreshStyle,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),

                      const SizedBox(height: 25),

                      _buildSection(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Your styles',
                        subtitle: 'The aesthetics that define your look.',
                        values: StylePreferencesStore.selectedStyles,
                      ),

                      const SizedBox(height: 16),

                      _buildSection(
                        icon: Icons.checkroom_outlined,
                        title: 'Preferred fits',
                        subtitle: 'The silhouettes you feel best in.',
                        values: StylePreferencesStore.selectedFits,
                      ),

                      const SizedBox(height: 16),

                      _buildSection(
                        icon: Icons.palette_outlined,
                        title: 'Your colors',
                        subtitle: 'The palette you naturally gravitate toward.',
                        values: StylePreferencesStore.selectedColors,
                      ),

                      const SizedBox(height: 24),

                      _buildEditButton(),

                      const SizedBox(height: 22),

                      _buildVestraMessage(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHero() {
    final styleCount = StylePreferencesStore.selectedStyles.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF24200F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome, color: gold, size: 27),
          ),

          const SizedBox(height: 18),

          const Text(
            'Your style.',
            style: TextStyle(
              color: softWhite,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            styleCount == 0
                ? 'Start defining the style Vestra should know you by.'
                : 'A personal style profile built around what you love to wear.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              _stat('${StylePreferencesStore.selectedStyles.length}', 'Styles'),
              const SizedBox(width: 24),
              _stat('${StylePreferencesStore.selectedFits.length}', 'Fits'),
              const SizedBox(width: 24),
              _stat('${StylePreferencesStore.selectedColors.length}', 'Colors'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: gold,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Set<String> values,
  }) {
    final items = values.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: 13),
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
            ],
          ),

          const SizedBox(height: 17),

          if (items.isEmpty)
            _buildEmpty()
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF24200F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gold.withValues(alpha: 0.32)),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: softWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Nothing selected yet.',
        style: TextStyle(color: Colors.white38, fontSize: 12),
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _editStyle,
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text(
          'EDIT MY STYLE',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildVestraMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: gold.withValues(alpha: 0.15)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: gold, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vestra knows your style.',
                  style: TextStyle(
                    color: gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your preferences help Vestra personalize '
                  'your outfit recommendations and future AI styling.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
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
}
