import '../screens/wardrobe_store.dart';
import '../screens/style_preferences_store.dart';
import '../screens/my_aesthetic_store.dart';

class VestraStylingResult {
  final String outfitName;
  final String description;
  final String reasoning;

  final Map<String, Map<String, String>> selectedPieces;

  final List<Map<String, String>> suggestedPieces;

  final List<Map<String, String>> missingPieces;

  final List<String> recommendations;

  final String occasion;
  final String userRequest;

  const VestraStylingResult({
    required this.outfitName,
    required this.description,
    required this.reasoning,
    required this.selectedPieces,
    required this.suggestedPieces,
    required this.missingPieces,
    required this.recommendations,
    required this.occasion,
    required this.userRequest,
  });

  bool get hasMissingPieces => missingPieces.isNotEmpty;
}

class VestraStylingEngine {
  // ============================================================
  // COMMON OCCASIONS
  // ============================================================

  static const List<String> occasionOptions = [
    'Casual',
    'Everyday',
    'Work',
    'Interview',
    'Business',
    'Business Casual',
    'Formal',
    'Wedding',
    'Dinner',
    'Date',
    'Party',
    'Night Out',
    'Travel',
    'Vacation',
    'Beach',
    'Brunch',
    'Concert',
    'Festival',
    'Art Exhibition',
    'Gallery Opening',
    'Photoshoot',
    'Runway',
    'Streetwear',
    'University',
    'Presentation',
    'Conference',
    'Graduation',
    'Funeral',
    'Traditional Event',
    'Sports',
    'Gym',
    'Swimming',
    'Outdoor',
  ];

  // ============================================================
  // CATEGORY DEFINITIONS
  // ============================================================

  static const Set<String> _onePieceCategories = {'dresses', 'jumpsuits'};

  static const Set<String> _topCategories = {'tops'};

  static const Set<String> _bottomCategories = {'bottoms', 'skirts'};

  static const Set<String> _shoeCategories = {'shoes'};

  static const Set<String> _outerwearCategories = {'outerwear'};

  static const Set<String> _accessoryCategories = {
    'accessories',
    'bags',
    'headwear',
  };

  static const Set<String> _petCategories = {'pet clothing'};

  // ============================================================
  // MAIN GENERATOR
  // ============================================================

  static List<VestraStylingResult> generateLooks({
    required String occasion,
    required String request,
    List<Map<String, String>>? selectedItems,
  }) {
    final wardrobe = WardrobeStore.items
        .map((item) => Map<String, String>.from(item))
        .toList();

    final selected = (selectedItems ?? [])
        .map((item) => Map<String, String>.from(item))
        .toList();

    final normalizedOccasion = occasion.trim().isEmpty
        ? 'Everyday'
        : occasion.trim();

    final normalizedRequest = request.trim();

    if (wardrobe.isEmpty) {
      return List.generate(
        3,
        (index) =>
            _emptyWardrobeResult(normalizedOccasion, normalizedRequest, index),
      );
    }

    final styles = StylePreferencesStore.selectedStyles
        .map((e) => e.toLowerCase())
        .toList();

    final fits = StylePreferencesStore.selectedFits
        .map((e) => e.toLowerCase())
        .toList();

    final colors = StylePreferencesStore.selectedColors
        .map((e) => e.toLowerCase())
        .toList();

    final aesthetics = MyAestheticStore.selectedAesthetics
        .map((e) => e.toLowerCase())
        .toList();

    final excluded = _extractExclusions(normalizedRequest);

    final requiredItems = _findRequiredItems(
      wardrobe,
      selected,
      normalizedRequest,
    );

    final context = _detectContext(
      selectedItems: selected,
      requiredItems: requiredItems,
      request: normalizedRequest,
    );

    final results = <VestraStylingResult>[];

    for (int lookIndex = 0; lookIndex < 3; lookIndex++) {
      results.add(
        _buildLook(
          wardrobe: wardrobe,
          selectedItems: selected,
          requiredItems: requiredItems,
          excluded: excluded,
          occasion: normalizedOccasion,
          request: normalizedRequest,
          styles: styles,
          fits: fits,
          colors: colors,
          aesthetics: aesthetics,
          context: context,
          lookIndex: lookIndex,
        ),
      );
    }

    return results;
  }

  static VestraStylingResult generateLook({
    required String occasion,
    required String request,
    List<Map<String, String>>? selectedItems,
  }) {
    return generateLooks(
      occasion: occasion,
      request: request,
      selectedItems: selectedItems,
    ).first;
  }

  // ============================================================
  // BUILD ONE LOOK
  // ============================================================

  static VestraStylingResult _buildLook({
    required List<Map<String, String>> wardrobe,
    required List<Map<String, String>> selectedItems,
    required List<Map<String, String>> requiredItems,
    required Set<String> excluded,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required String context,
    required int lookIndex,
  }) {
    final available = wardrobe.where((item) {
      if (_isExcluded(item, excluded)) {
        return false;
      }

      return _isContextCompatible(item, context);
    }).toList();

    /*
    ==============================================================
    CORE 2.0 PRINCIPLE

    If the user explicitly selected or mentioned a garment,
    that garment becomes an ANCHOR.

    Vestra does NOT replace the anchor simply because another
    item has a higher individual score.
    ============================================================== 
    */

    final anchors = requiredItems
        .where((item) => _isContextCompatible(item, context))
        .toList();

    final selectedPieces = <String, Map<String, String>>{};

    if (anchors.isNotEmpty) {
      for (final item in anchors) {
        _addPieceWithoutOverwriting(selectedPieces, item);
      }
    } else {
      final generatedAnchors = _chooseAnchors(
        available,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );

      for (final item in generatedAnchors) {
        _addPieceWithoutOverwriting(selectedPieces, item);
      }
    }

    // ============================================================
    // PET
    // ============================================================

    if (context == 'pet') {
      _completePetLook(
        selectedPieces: selectedPieces,
        wardrobe: available,
        occasion: occasion,
        request: request,
        styles: styles,
        fits: fits,
        colors: colors,
        aesthetics: aesthetics,
        lookIndex: lookIndex,
      );
    }
    // ============================================================
    // ONE PIECE
    // ============================================================
    else if (_containsCategory(selectedPieces, _onePieceCategories)) {
      _completeOnePieceLook(
        selectedPieces: selectedPieces,
        wardrobe: available,
        occasion: occasion,
        request: request,
        styles: styles,
        fits: fits,
        colors: colors,
        aesthetics: aesthetics,
        lookIndex: lookIndex,
      );
    }
    // ============================================================
    // SEPARATES
    // ============================================================
    else {
      _completeSeparateOrFlexibleLook(
        selectedPieces: selectedPieces,
        wardrobe: available,
        occasion: occasion,
        request: request,
        styles: styles,
        fits: fits,
        colors: colors,
        aesthetics: aesthetics,
        lookIndex: lookIndex,
      );
    }

    // ============================================================
    // SUPPORTING PIECES
    // ============================================================

    if (context == 'human') {
      _addSupportingPieces(
        selectedPieces: selectedPieces,
        wardrobe: available,
        occasion: occasion,
        request: request,
        styles: styles,
        fits: fits,
        colors: colors,
        aesthetics: aesthetics,
        lookIndex: lookIndex,
      );
    }

    // ============================================================
    // FINAL COMPATIBILITY CLEANUP
    // ============================================================

    _removeObviousConflicts(selectedPieces, occasion, request);

    // ============================================================
    // SUGGESTIONS
    // ============================================================

    final suggestions = _generateSuggestions(
      selectedPieces: selectedPieces,
      wardrobe: available,
      occasion: occasion,
      request: request,
      styles: styles,
      fits: fits,
      colors: colors,
      aesthetics: aesthetics,
      lookIndex: lookIndex,
      isPetLook: context == 'pet',
    );

    final missing = suggestions
        .where((item) => item['reason'] == 'missing')
        .map((item) => Map<String, String>.from(item))
        .toList();

    final cleanSuggestions = suggestions
        .where((item) => item['reason'] != 'missing')
        .map((item) {
          final copy = Map<String, String>.from(item);
          copy.remove('reason');
          return copy;
        })
        .toList();

    return VestraStylingResult(
      outfitName: _generateOutfitName(
        selectedPieces,
        occasion,
        request,
        lookIndex,
      ),
      description: _generateDescription(
        selectedPieces,
        cleanSuggestions,
        occasion,
        request,
        context == 'pet',
      ),
      reasoning: _generateReasoning(
        selectedPieces,
        occasion,
        request,
        requiredItems,
        context == 'pet',
      ),
      selectedPieces: selectedPieces,
      suggestedPieces: cleanSuggestions,
      missingPieces: missing,
      recommendations: _generateRecommendations(
        selectedPieces,
        occasion,
        request,
        context == 'pet',
      ),
      occasion: occasion,
      userRequest: request,
    );
  }

  // ============================================================
  // ANCHOR SELECTION
  // ============================================================

  static List<Map<String, String>> _chooseAnchors(
    List<Map<String, String>> wardrobe,
    String occasion,
    String request,
    List<String> styles,
    List<String> fits,
    List<String> colors,
    List<String> aesthetics,
    int lookIndex,
  ) {
    if (wardrobe.isEmpty) {
      return [];
    }

    final humanItems = wardrobe
        .where((item) => !_petCategories.contains(_category(item)))
        .toList();

    if (humanItems.isEmpty) {
      return [];
    }

    final ranked = humanItems.toList();

    ranked.sort(
      (a, b) =>
          _itemScore(
            b,
            occasion,
            request,
            styles,
            fits,
            colors,
            aesthetics,
          ).compareTo(
            _itemScore(a, occasion, request, styles, fits, colors, aesthetics),
          ),
    );

    // ------------------------------------------------------------
    // One-piece garments have structural priority.
    // ------------------------------------------------------------

    final onePieces = ranked
        .where((item) => _onePieceCategories.contains(_category(item)))
        .toList();

    if (onePieces.isNotEmpty) {
      return [onePieces[lookIndex % onePieces.length]];
    }

    // ------------------------------------------------------------
    // Separate garments
    // ------------------------------------------------------------

    final tops = ranked
        .where((item) => _topCategories.contains(_category(item)))
        .toList();

    final bottoms = ranked
        .where((item) => _bottomCategories.contains(_category(item)))
        .toList();

    final anchors = <Map<String, String>>[];

    if (tops.isNotEmpty) {
      anchors.add(tops[lookIndex % tops.length]);
    }

    if (bottoms.isNotEmpty) {
      anchors.add(bottoms[lookIndex % bottoms.length]);
    }

    if (anchors.isEmpty) {
      anchors.add(ranked[lookIndex % ranked.length]);
    }

    return anchors;
  }

  // ============================================================
  // ONE PIECE LOOK
  // ============================================================

  static void _completeOnePieceLook({
    required Map<String, Map<String, String>> selectedPieces,
    required List<Map<String, String>> wardrobe,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required int lookIndex,
  }) {
    /*
    A dress/jumpsuit is already the main outfit.

    We therefore NEVER add a random top or bottom.

    Instead Vestra looks for:
    1. appropriate footwear
    2. appropriate layer when necessary
    3. restrained accessories
    */

    _addBestCompatibleIfMissing(
      selectedPieces,
      wardrobe,
      _shoeCategories,
      occasion,
      request,
      styles,
      fits,
      colors,
      aesthetics,
      lookIndex,
    );

    if (_shouldUseOuterwear(occasion, request)) {
      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _outerwearCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );
    }
  }

  // ============================================================
  // SEPARATE / FLEXIBLE LOOK
  // ============================================================

  static void _completeSeparateOrFlexibleLook({
    required Map<String, Map<String, String>> selectedPieces,
    required List<Map<String, String>> wardrobe,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required int lookIndex,
  }) {
    final hasTop = _containsCategory(selectedPieces, _topCategories);

    final hasBottom = _containsCategory(selectedPieces, _bottomCategories);

    /*
    If the user selected a top only, find a compatible bottom.

    If the user selected a bottom only, find a compatible top.

    If neither exists, build the strongest complete structure.
    */

    if (hasTop && !hasBottom) {
      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _bottomCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );
    } else if (hasBottom && !hasTop) {
      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _topCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );
    } else if (!hasTop && !hasBottom) {
      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _topCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );

      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _bottomCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );
    }

    _addBestCompatibleIfMissing(
      selectedPieces,
      wardrobe,
      _shoeCategories,
      occasion,
      request,
      styles,
      fits,
      colors,
      aesthetics,
      lookIndex,
    );
  }

  // ============================================================
  // PET LOOK
  // ============================================================

  static void _completePetLook({
    required Map<String, Map<String, String>> selectedPieces,
    required List<Map<String, String>> wardrobe,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required int lookIndex,
  }) {
    final petItems = wardrobe
        .where((item) => _petCategories.contains(_category(item)))
        .toList();

    if (petItems.isEmpty) {
      return;
    }

    petItems.sort(
      (a, b) =>
          _itemScore(
            b,
            occasion,
            request,
            styles,
            fits,
            colors,
            aesthetics,
          ).compareTo(
            _itemScore(a, occasion, request, styles, fits, colors, aesthetics),
          ),
    );

    for (final item in petItems) {
      if (!_containsSameItem(selectedPieces, item)) {
        _addPieceWithoutOverwriting(selectedPieces, item);
      }

      if (selectedPieces.length >= 2) {
        break;
      }
    }
  }

  // ============================================================
  // SUPPORTING PIECES
  // ============================================================

  static void _addSupportingPieces({
    required Map<String, Map<String, String>> selectedPieces,
    required List<Map<String, String>> wardrobe,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required int lookIndex,
  }) {
    // ------------------------------------------------------------
    // Outerwear
    // ------------------------------------------------------------

    if (_shouldUseOuterwear(occasion, request)) {
      _addBestCompatibleIfMissing(
        selectedPieces,
        wardrobe,
        _outerwearCategories,
        occasion,
        request,
        styles,
        fits,
        colors,
        aesthetics,
        lookIndex,
      );
    }

    // ------------------------------------------------------------
    // Accessories
    // ------------------------------------------------------------

    final accessoryCandidates = wardrobe
        .where((item) => _accessoryCategories.contains(_category(item)))
        .where((item) => !_containsSameItem(selectedPieces, item))
        .toList();

    if (accessoryCandidates.isEmpty) {
      return;
    }

    accessoryCandidates.sort(
      (a, b) =>
          _compatibilityScore(
            b,
            selectedPieces,
            occasion,
            request,
            styles,
            fits,
            colors,
            aesthetics,
          ).compareTo(
            _compatibilityScore(
              a,
              selectedPieces,
              occasion,
              request,
              styles,
              fits,
              colors,
              aesthetics,
            ),
          ),
    );

    final bestAccessory = accessoryCandidates.first;

    /*
    Don't overload every outfit with accessories.

    The accessory is only added if it has a meaningful
    compatibility score.
    */

    final accessoryScore = _compatibilityScore(
      bestAccessory,
      selectedPieces,
      occasion,
      request,
      styles,
      fits,
      colors,
      aesthetics,
    );

    if (accessoryScore >= 5) {
      _addPieceWithoutOverwriting(selectedPieces, bestAccessory);
    }
  }

  // ============================================================
  // BEST COMPATIBLE ITEM
  // ============================================================

  static void _addBestCompatibleIfMissing(
    Map<String, Map<String, String>> selectedPieces,
    List<Map<String, String>> wardrobe,
    Set<String> categories,
    String occasion,
    String request,
    List<String> styles,
    List<String> fits,
    List<String> colors,
    List<String> aesthetics,
    int lookIndex,
  ) {
    if (_containsCategory(selectedPieces, categories)) {
      return;
    }

    final candidates = wardrobe
        .where((item) => categories.contains(_category(item)))
        .where((item) => !_containsSameItem(selectedPieces, item))
        .toList();

    if (candidates.isEmpty) {
      return;
    }

    candidates.sort(
      (a, b) =>
          _compatibilityScore(
            b,
            selectedPieces,
            occasion,
            request,
            styles,
            fits,
            colors,
            aesthetics,
          ).compareTo(
            _compatibilityScore(
              a,
              selectedPieces,
              occasion,
              request,
              styles,
              fits,
              colors,
              aesthetics,
            ),
          ),
    );

    /*
    For look variations, allow different strong candidates
    rather than returning the exact same combination three times.
    */

    final index = lookIndex < candidates.length ? lookIndex : 0;

    final chosen = candidates[index];

    _addPieceWithoutOverwriting(selectedPieces, chosen);
  }

  // ============================================================
  // COMPATIBILITY SCORING
  // ============================================================

  static int _compatibilityScore(
    Map<String, String> candidate,
    Map<String, Map<String, String>> selectedPieces,
    String occasion,
    String request,
    List<String> styles,
    List<String> fits,
    List<String> colors,
    List<String> aesthetics,
  ) {
    int score = _itemScore(
      candidate,
      occasion,
      request,
      styles,
      fits,
      colors,
      aesthetics,
    );

    final candidateCategory = _category(candidate);

    for (final selected in selectedPieces.values) {
      final selectedCategory = _category(selected);

      score += _pairScore(
        selected,
        candidate,
        selectedCategory,
        candidateCategory,
        occasion,
        request,
      );
    }

    /*
    Prefer coherent color relationships.
    */

    for (final selected in selectedPieces.values) {
      score += _colorCompatibility(selected, candidate);
    }

    return score;
  }

  static int _pairScore(
    Map<String, String> first,
    Map<String, String> second,
    String firstCategory,
    String secondCategory,
    String occasion,
    String request,
  ) {
    int score = 0;

    final combined =
        '${_itemText(first)} ${_itemText(second)} '
        '${occasion.toLowerCase()} ${request.toLowerCase()}';

    // ------------------------------------------------------------
    // Strong structural combinations
    // ------------------------------------------------------------

    if ((_topCategories.contains(firstCategory) &&
            _bottomCategories.contains(secondCategory)) ||
        (_bottomCategories.contains(firstCategory) &&
            _topCategories.contains(secondCategory))) {
      score += 10;
    }

    if ((_onePieceCategories.contains(firstCategory) &&
            _shoeCategories.contains(secondCategory)) ||
        (_shoeCategories.contains(firstCategory) &&
            _onePieceCategories.contains(secondCategory))) {
      score += 10;
    }

    if ((_topCategories.contains(firstCategory) &&
            _shoeCategories.contains(secondCategory)) ||
        (_shoeCategories.contains(firstCategory) &&
            _topCategories.contains(secondCategory))) {
      score += 4;
    }

    if ((_bottomCategories.contains(firstCategory) &&
            _shoeCategories.contains(secondCategory)) ||
        (_shoeCategories.contains(firstCategory) &&
            _bottomCategories.contains(secondCategory))) {
      score += 4;
    }

    // ------------------------------------------------------------
    // Occasion compatibility
    // ------------------------------------------------------------

    if (_containsAny(combined, [
      'interview',
      'business',
      'formal',
      'conference',
      'presentation',
    ])) {
      if (_containsAny(combined, [
        'tailored',
        'structured',
        'blazer',
        'trouser',
        'loafer',
        'pump',
        'heel',
        'dress',
        'minimal',
        'refined',
      ])) {
        score += 6;
      }

      if (_containsAny(combined, ['gym', 'sports', 'swim', 'beach'])) {
        score -= 10;
      }
    }

    if (_containsAny(combined, ['date', 'dinner', 'night out', 'evening'])) {
      if (_containsAny(combined, [
        'elegant',
        'refined',
        'silk',
        'satin',
        'leather',
        'dress',
        'heel',
        'loafer',
        'boot',
        'statement',
      ])) {
        score += 5;
      }
    }

    if (_containsAny(combined, [
      'streetwear',
      'street',
      'concert',
      'festival',
    ])) {
      if (_containsAny(combined, [
        'oversized',
        'wide',
        'cargo',
        'denim',
        'leather',
        'sneaker',
        'boot',
        'statement',
        'graphic',
      ])) {
        score += 5;
      }
    }

    // ------------------------------------------------------------
    // Avoid obvious activity conflicts
    // ------------------------------------------------------------

    if (_containsAny(combined, ['gym', 'sports', 'running', 'workout'])) {
      if (_containsAny(combined, [
        'heel',
        'formal',
        'blazer',
        'suit',
        'dress shoe',
      ])) {
        score -= 8;
      }
    }

    return score;
  }

  // ============================================================
  // COLOR COMPATIBILITY
  // ============================================================

  static int _colorCompatibility(
    Map<String, String> first,
    Map<String, String> second,
  ) {
    final firstColor = _normalizeColor(first['color'] ?? '');

    final secondColor = _normalizeColor(second['color'] ?? '');

    if (firstColor.isEmpty || secondColor.isEmpty) {
      return 0;
    }

    if (firstColor == secondColor) {
      return 2;
    }

    final neutrals = {
      'black',
      'white',
      'cream',
      'beige',
      'grey',
      'gray',
      'brown',
      'navy',
      'tan',
    };

    if (neutrals.contains(firstColor) && neutrals.contains(secondColor)) {
      return 4;
    }

    if (firstColor == 'black' || secondColor == 'black') {
      return 3;
    }

    if (firstColor == 'white' || secondColor == 'white') {
      return 3;
    }

    if ((firstColor == 'blue' && secondColor == 'orange') ||
        (firstColor == 'orange' && secondColor == 'blue')) {
      return 3;
    }

    if ((firstColor == 'purple' && secondColor == 'yellow') ||
        (firstColor == 'yellow' && secondColor == 'purple')) {
      return 3;
    }

    if ((firstColor == 'red' && secondColor == 'green') ||
        (firstColor == 'green' && secondColor == 'red')) {
      return -2;
    }

    return 1;
  }

  // ============================================================
  // ITEM SCORING
  // ============================================================

  static int _itemScore(
    Map<String, String> item,
    String occasion,
    String request,
    List<String> styles,
    List<String> fits,
    List<String> colors,
    List<String> aesthetics,
  ) {
    final text = _itemText(item);

    int score = 0;

    // ------------------------------------------------------------
    // Occasion
    // ------------------------------------------------------------

    for (final word in _words(occasion)) {
      if (word.length > 2 && text.contains(word)) {
        score += 6;
      }
    }

    // ------------------------------------------------------------
    // User request
    // ------------------------------------------------------------

    for (final word in _words(request)) {
      if (word.length > 2 && text.contains(word)) {
        score += 9;
      }
    }

    // ------------------------------------------------------------
    // Preferred styles
    // ------------------------------------------------------------

    for (final style in styles) {
      for (final word in _words(style)) {
        if (word.length > 2 && text.contains(word)) {
          score += 6;
        }
      }
    }

    // ------------------------------------------------------------
    // Preferred fits
    // ------------------------------------------------------------

    for (final fit in fits) {
      for (final word in _words(fit)) {
        if (word.length > 2 && text.contains(word)) {
          score += 5;
        }
      }
    }

    // ------------------------------------------------------------
    // Preferred colors
    // ------------------------------------------------------------

    for (final color in colors) {
      for (final word in _words(color)) {
        if (word.length > 2 && text.contains(word)) {
          score += 5;
        }
      }
    }

    // ------------------------------------------------------------
    // Aesthetics
    // ------------------------------------------------------------

    for (final aesthetic in aesthetics) {
      for (final word in _words(aesthetic)) {
        if (word.length > 2 && text.contains(word)) {
          score += 6;
        }
      }
    }

    final category = _category(item);

    // Structural priority.
    if (_onePieceCategories.contains(category)) {
      score += 10;
    }

    if (_shoeCategories.contains(category)) {
      score += 2;
    }

    return score;
  }

  // ============================================================
  // REQUIRED ITEMS
  // ============================================================

  static List<Map<String, String>> _findRequiredItems(
    List<Map<String, String>> wardrobe,
    List<Map<String, String>> selectedItems,
    String request,
  ) {
    final required = <Map<String, String>>[];

    // ------------------------------------------------------------
    // Explicit UI selections
    // ------------------------------------------------------------

    for (final selected in selectedItems) {
      final match = wardrobe.firstWhere(
        (item) => _sameItem(item, selected),
        orElse: () => selected,
      );

      if (!required.any((item) => _sameItem(item, match))) {
        required.add(match);
      }
    }

    // ------------------------------------------------------------
    // Natural language references
    // ------------------------------------------------------------

    final requestText = request.toLowerCase();

    for (final item in wardrobe) {
      final name = (item['name'] ?? '').trim().toLowerCase();

      final category = (item['category'] ?? '').trim().toLowerCase();

      final color = (item['color'] ?? '').trim().toLowerCase();

      final itemText = _itemText(item);

      bool mentioned = false;

      if (name.length > 2 && requestText.contains(name)) {
        mentioned = true;
      }

      if (!mentioned && color.length > 2 && requestText.contains(color)) {
        mentioned = true;
      }

      /*
      Only treat a category as an explicit reference when
      the user actually uses the category in the request.

      This prevents "dress" from being interpreted as gender.
      */

      if (!mentioned && category.length > 2 && requestText.contains(category)) {
        mentioned = true;
      }

      /*
      Also detect common garment vocabulary.
      */

      if (!mentioned) {
        final garmentWords = _garmentKeywordsForCategory(category);

        if (garmentWords.any(requestText.contains)) {
          if (itemTextContainsAny(itemText, garmentWords)) {
            mentioned = true;
          }
        }
      }

      if (mentioned && !required.any((existing) => _sameItem(existing, item))) {
        required.add(item);
      }
    }

    return required;
  }

  // ============================================================
  // EXCLUSIONS
  // ============================================================

  static Set<String> _extractExclusions(String request) {
    final result = <String>{};

    final lower = request.toLowerCase();

    final patterns = [
      RegExp(r"(?:don't use|do not use|without|avoid|exclude|no)\s+([^,.!?]+)"),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(lower)) {
        final value = match.group(1);

        if (value != null && value.trim().isNotEmpty) {
          result.addAll(_words(value));
        }
      }
    }

    return result;
  }

  static bool _isExcluded(Map<String, String> item, Set<String> excluded) {
    if (excluded.isEmpty) {
      return false;
    }

    final text = _itemText(item);

    for (final word in excluded) {
      if (word.length > 2 && text.contains(word)) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // CONTEXT
  // ============================================================

  static String _detectContext({
    required List<Map<String, String>> selectedItems,
    required List<Map<String, String>> requiredItems,
    required String request,
  }) {
    final combined = [
      request,
      ...selectedItems.map(_itemText),
      ...requiredItems.map(_itemText),
    ].join(' ').toLowerCase();

    if (_requestIndicatesPet(combined)) {
      return 'pet';
    }

    if (selectedItems.any((item) => _petCategories.contains(_category(item)))) {
      return 'pet';
    }

    if (requiredItems.any((item) => _petCategories.contains(_category(item)))) {
      return 'pet';
    }

    return 'human';
  }

  static bool _requestIndicatesPet(String request) {
    final text = request.toLowerCase();

    return text.contains('pet') ||
        text.contains('dog') ||
        text.contains('puppy') ||
        text.contains('cat') ||
        text.contains('kitten') ||
        text.contains('doggy') ||
        text.contains('feline') ||
        text.contains('canine');
  }

  static bool _isContextCompatible(Map<String, String> item, String context) {
    final itemIsPet = _petCategories.contains(_category(item));

    if (context == 'pet') {
      return itemIsPet;
    }

    return !itemIsPet;
  }

  // ============================================================
  // SUGGESTIONS
  // ============================================================

  static List<Map<String, String>> _generateSuggestions({
    required Map<String, Map<String, String>> selectedPieces,
    required List<Map<String, String>> wardrobe,
    required String occasion,
    required String request,
    required List<String> styles,
    required List<String> fits,
    required List<String> colors,
    required List<String> aesthetics,
    required int lookIndex,
    required bool isPetLook,
  }) {
    final suggestions = <Map<String, String>>[];

    if (isPetLook) {
      if (!_containsCategory(selectedPieces, _petCategories)) {
        suggestions.add(
          _suggestion(
            category: 'Pet Clothing',
            name: 'A complementary petwear piece',
            color: 'Coordinated',
            fit: 'Comfortable',
            notes: 'Suggested within the petwear context.',
            reason: 'missing',
          ),
        );
      }

      return suggestions;
    }

    final categories = selectedPieces.keys
        .map((key) => key.toLowerCase())
        .toSet();

    final hasOnePiece = categories.any(
      (category) => _onePieceCategories.contains(category),
    );

    final hasShoes = categories.contains('shoes');

    // ------------------------------------------------------------
    // Shoes
    // ------------------------------------------------------------

    if (!hasShoes) {
      suggestions.add(
        _suggestion(
          category: 'Shoes',
          name: _shoeSuggestion(occasion, request),
          color: _suggestedColor(selectedPieces),
          fit: 'Appropriate',
          notes:
              'Choose footwear that supports the occasion and the main garment.',
          reason: 'missing',
        ),
      );
    }

    // ------------------------------------------------------------
    // Layer
    // ------------------------------------------------------------

    if (_needsLayer(occasion, request) && !categories.contains('outerwear')) {
      suggestions.add(
        _suggestion(
          category: 'Outerwear',
          name: _outerwearSuggestion(occasion, request),
          color: _suggestedColor(selectedPieces),
          fit: 'Complementary',
          notes: 'A layer can adapt the silhouette to the requested setting.',
          reason: 'missing',
        ),
      );
    }

    // ------------------------------------------------------------
    // One-piece alternative logic
    // ------------------------------------------------------------

    if (hasOnePiece) {
      suggestions.add(
        _suggestion(
          category: 'Styling Direction',
          name: _onePieceDirection(occasion, request),
          color: 'Coordinated',
          fit: 'Context appropriate',
          notes:
              'The main garment remains the focal point; styling changes around it.',
          reason: 'direction',
        ),
      );
    }

    return suggestions;
  }

  static Map<String, String> _suggestion({
    required String category,
    required String name,
    required String color,
    required String fit,
    required String notes,
    required String reason,
  }) {
    return {
      'category': category,
      'name': name,
      'color': color,
      'fit': fit,
      'notes': notes,
      'reason': reason,
      'source': 'Vestra suggestion',
      'isSuggested': 'true',
    };
  }

  // ============================================================
  // CONFLICT CLEANUP
  // ============================================================

  static void _removeObviousConflicts(
    Map<String, Map<String, String>> selected,
    String occasion,
    String request,
  ) {
    final text = '$occasion $request'.toLowerCase();

    if (_containsAny(text, ['gym', 'workout', 'running', 'sports'])) {
      final keysToRemove = selected.entries
          .where(
            (entry) => _containsAny(_itemText(entry.value), [
              'heel',
              'pump',
              'formal',
              'loafer',
              'dress shoe',
            ]),
          )
          .map((entry) => entry.key)
          .toList();

      for (final key in keysToRemove) {
        /*
        Never remove the user's explicit anchor.

        This cleanup is intentionally conservative.
        */
        if (!_isCoreGarmentCategory(_category(selected[key]!))) {
          selected.remove(key);
        }
      }
    }
  }

  // ============================================================
  // TEXT GENERATION
  // ============================================================

  static String _generateOutfitName(
    Map<String, Map<String, String>> selected,
    String occasion,
    String request,
    int lookIndex,
  ) {
    final names = selected.values
        .map((item) => item['name']?.trim())
        .whereType<String>()
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.isNotEmpty) {
      return '${names.first} — ${_variationName(lookIndex)}';
    }

    return '${_capitalize(occasion)} — ${_variationName(lookIndex)}';
  }

  static String _variationName(int index) {
    switch (index) {
      case 0:
        return 'The Signature';

      case 1:
        return 'The Refined Direction';

      default:
        return 'The Alternative';
    }
  }

  static String _generateDescription(
    Map<String, Map<String, String>> selected,
    List<Map<String, String>> suggestions,
    String occasion,
    String request,
    bool isPetLook,
  ) {
    final pieces = selected.values
        .map((item) => item['name'] ?? item['category'] ?? 'piece')
        .toList();

    if (isPetLook) {
      return 'A coordinated petwear direction built around '
          '${pieces.join(', ')}.';
    }

    if (pieces.isEmpty) {
      return 'A flexible styling direction for $occasion.';
    }

    final mainPiece = _mainGarment(selected);

    if (mainPiece != null) {
      final name =
          mainPiece['name'] ?? mainPiece['category'] ?? 'the main piece';

      return 'A $occasion look built around $name, '
          'with the supporting pieces chosen to reinforce '
          'the requested setting and styling direction.';
    }

    return 'A $occasion styling direction built around '
        '${pieces.join(', ')}'
        '${suggestions.isNotEmpty ? ', with complementary pieces considered where needed.' : '.'}';
  }

  static String _generateReasoning(
    Map<String, Map<String, String>> selected,
    String occasion,
    String request,
    List<Map<String, String>> requiredItems,
    bool isPetLook,
  ) {
    if (isPetLook) {
      return 'Vestra detected a petwear context and restricted '
          'the styling to compatible petwear pieces.';
    }

    final mainPiece = _mainGarment(selected);

    final mainCategory = mainPiece == null ? '' : _category(mainPiece);

    if (requiredItems.isNotEmpty) {
      if (_onePieceCategories.contains(mainCategory)) {
        return 'The selected one-piece garment was treated as the '
            'primary styling anchor. Vestra kept the garment intact '
            'and adapted the footwear, layering and supporting details '
            'to the requested occasion instead of replacing it.';
      }

      return 'The pieces you specifically selected or mentioned '
          'were treated as styling anchors. Vestra built the rest of '
          'the outfit around those actual wardrobe pieces.';
    }

    final categories = selected.keys.join(', ');

    return 'Vestra evaluated the wardrobe against the occasion, '
        'request, preferences and garment structure, then selected '
        'compatible pieces rather than relying on a fixed outfit template. '
        'The resulting structure contains: $categories.';
  }

  static List<String> _generateRecommendations(
    Map<String, Map<String, String>> selected,
    String occasion,
    String request,
    bool isPetLook,
  ) {
    if (isPetLook) {
      return [
        'Keep additional pieces within the same petwear context.',
        'Prioritize comfort, movement and suitability for the animal.',
      ];
    }

    final recommendations = <String>[];

    final mainPiece = _mainGarment(selected);

    if (mainPiece != null &&
        _onePieceCategories.contains(_category(mainPiece))) {
      recommendations.add('Keep the main garment as the visual focal point.');
    } else {
      recommendations.add(
        'Maintain a clear relationship between the top, bottom and footwear.',
      );
    }

    recommendations.add(
      'Let the occasion determine the level of polish, structure and practicality.',
    );

    recommendations.add(
      'Use accessories and layers to reinforce the requested aesthetic rather than overpowering the core garment.',
    );

    return recommendations;
  }

  // ============================================================
  // PIECE MANAGEMENT
  // ============================================================

  static void _addPieceWithoutOverwriting(
    Map<String, Map<String, String>> selected,
    Map<String, String> item,
  ) {
    final baseCategory = item['category']?.trim().isNotEmpty == true
        ? item['category']!.trim()
        : 'Item';

    String key = baseCategory;

    int number = 2;

    while (selected.containsKey(key)) {
      key = '$baseCategory $number';
      number++;
    }

    selected[key] = Map<String, String>.from(item);
  }

  static bool _containsCategory(
    Map<String, Map<String, String>> selected,
    Set<String> categories,
  ) {
    return selected.keys.any((key) => categories.contains(key.toLowerCase()));
  }

  static bool _containsSameItem(
    Map<String, Map<String, String>> selected,
    Map<String, String> item,
  ) {
    return selected.values.any((existing) => _sameItem(existing, item));
  }

  // ============================================================
  // MAIN GARMENT
  // ============================================================

  static Map<String, String>? _mainGarment(
    Map<String, Map<String, String>> selected,
  ) {
    final onePiece = selected.values.where(
      (item) => _onePieceCategories.contains(_category(item)),
    );

    if (onePiece.isNotEmpty) {
      return onePiece.first;
    }

    final tops = selected.values.where(
      (item) => _topCategories.contains(_category(item)),
    );

    if (tops.isNotEmpty) {
      return tops.first;
    }

    final bottoms = selected.values.where(
      (item) => _bottomCategories.contains(_category(item)),
    );

    if (bottoms.isNotEmpty) {
      return bottoms.first;
    }

    return null;
  }

  static bool _isCoreGarmentCategory(String category) {
    return _onePieceCategories.contains(category) ||
        _topCategories.contains(category) ||
        _bottomCategories.contains(category);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static String _category(Map<String, String> item) {
    return (item['category'] ?? '').trim().toLowerCase();
  }

  static String _itemText(Map<String, String> item) {
    return item.values.join(' ').toLowerCase();
  }

  static List<String> _words(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();
  }

  static bool _sameItem(Map<String, String> a, Map<String, String> b) {
    final aName = (a['name'] ?? '').trim().toLowerCase();

    final bName = (b['name'] ?? '').trim().toLowerCase();

    final aCategory = (a['category'] ?? '').trim().toLowerCase();

    final bCategory = (b['category'] ?? '').trim().toLowerCase();

    if (aName.isNotEmpty &&
        bName.isNotEmpty &&
        aName == bName &&
        aCategory == bCategory) {
      return true;
    }

    final aImage = (a['imageData'] ?? a['imageBase64'] ?? '').trim();

    final bImage = (b['imageData'] ?? b['imageBase64'] ?? '').trim();

    if (aImage.isNotEmpty && bImage.isNotEmpty && aImage == bImage) {
      return true;
    }

    return false;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() + value.substring(1);
  }

  // ============================================================
  // GARMENT VOCABULARY
  // ============================================================

  static List<String> _garmentKeywordsForCategory(String category) {
    switch (category) {
      case 'dresses':
        return [
          'dress',
          'gown',
          'maxi dress',
          'mini dress',
          'midi dress',
          'evening dress',
        ];

      case 'tops':
        return [
          'shirt',
          'top',
          'blouse',
          'tee',
          't-shirt',
          'tank',
          'bodysuit',
          'sweater',
        ];

      case 'bottoms':
        return ['pants', 'trousers', 'jeans', 'shorts', 'cargo', 'leggings'];

      case 'skirts':
        return ['skirt', 'mini skirt', 'midi skirt', 'maxi skirt'];

      case 'jumpsuits':
        return ['jumpsuit', 'playsuit', 'romper'];

      case 'shoes':
        return [
          'shoes',
          'sneakers',
          'heels',
          'boots',
          'loafers',
          'sandals',
          'flats',
        ];

      case 'outerwear':
        return ['coat', 'jacket', 'trench', 'blazer', 'cardigan', 'vest'];

      default:
        return [];
    }
  }

  static bool itemTextContainsAny(String text, List<String> values) {
    for (final value in values) {
      if (text.contains(value.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // OCCASION INTELLIGENCE
  // ============================================================

  static bool _shouldUseOuterwear(String occasion, String request) {
    final text = '$occasion $request'.toLowerCase();

    return _containsAny(text, [
      'cold',
      'winter',
      'evening',
      'night',
      'layer',
      'layered',
      'jacket',
      'coat',
      'trench',
      'outdoor',
      'rain',
    ]);
  }

  static bool _needsLayer(String occasion, String request) {
    return _shouldUseOuterwear(occasion, request);
  }

  static String _shoeSuggestion(String occasion, String request) {
    final text = '$occasion $request'.toLowerCase();

    if (_containsAny(text, [
      'formal',
      'interview',
      'business',
      'conference',
      'presentation',
    ])) {
      return 'Refined professional footwear';
    }

    if (_containsAny(text, ['date', 'dinner', 'evening', 'night out'])) {
      return 'Polished evening footwear';
    }

    if (_containsAny(text, [
      'street',
      'streetwear',
      'casual',
      'everyday',
      'university',
    ])) {
      return 'Clean contemporary footwear';
    }

    if (_containsAny(text, [
      'runway',
      'avant-garde',
      'avant',
      'fashion',
      'photoshoot',
      'gallery',
    ])) {
      return 'Statement footwear';
    }

    if (_containsAny(text, ['beach', 'vacation', 'swimming'])) {
      return 'Lightweight open footwear';
    }

    if (_containsAny(text, ['gym', 'sports', 'running'])) {
      return 'Performance footwear';
    }

    return 'Complementary footwear';
  }

  static String _outerwearSuggestion(String occasion, String request) {
    final text = '$occasion $request'.toLowerCase();

    if (_containsAny(text, [
      'interview',
      'business',
      'conference',
      'presentation',
    ])) {
      return 'Structured blazer or tailored layer';
    }

    if (_containsAny(text, ['street', 'streetwear', 'concert', 'festival'])) {
      return 'Statement jacket or oversized layer';
    }

    if (_containsAny(text, ['evening', 'dinner', 'date', 'night'])) {
      return 'Refined evening layer';
    }

    return 'Complementary outer layer';
  }

  static String _onePieceDirection(String occasion, String request) {
    final text = '$occasion $request'.toLowerCase();

    if (_containsAny(text, ['interview', 'business', 'professional'])) {
      return 'Keep the dress clean, polished and structured';
    }

    if (_containsAny(text, ['date', 'dinner', 'evening', 'night out'])) {
      return 'Elevate the dress with refined evening details';
    }

    if (_containsAny(text, [
      'avant',
      'avant-garde',
      'runway',
      'fashion week',
      'editorial',
    ])) {
      return 'Push the silhouette and styling into a stronger editorial direction';
    }

    if (_containsAny(text, ['streetwear', 'street', 'concert', 'festival'])) {
      return 'Contrast the dress with contemporary street-oriented elements';
    }

    if (_containsAny(text, ['casual', 'everyday', 'university'])) {
      return 'Keep the dress relaxed and practical';
    }

    return 'Build the styling around the garment without competing with its silhouette';
  }

  static String _suggestedColor(Map<String, Map<String, String>> selected) {
    for (final item in selected.values) {
      final color = (item['color'] ?? '').trim();

      if (color.isNotEmpty) {
        return 'Complementary to $color';
      }
    }

    return 'Neutral';
  }

  // ============================================================
  // COLOR HELPERS
  // ============================================================

  static String _normalizeColor(String color) {
    final value = color.trim().toLowerCase();

    if (value.isEmpty) {
      return '';
    }

    if (value.contains('black')) {
      return 'black';
    }

    if (value.contains('white')) {
      return 'white';
    }

    if (value.contains('cream')) {
      return 'cream';
    }

    if (value.contains('beige')) {
      return 'beige';
    }

    if (value.contains('brown')) {
      return 'brown';
    }

    if (value.contains('navy')) {
      return 'navy';
    }

    if (value.contains('grey') || value.contains('gray')) {
      return 'grey';
    }

    if (value.contains('blue')) {
      return 'blue';
    }

    if (value.contains('red')) {
      return 'red';
    }

    if (value.contains('green')) {
      return 'green';
    }

    if (value.contains('yellow')) {
      return 'yellow';
    }

    if (value.contains('orange')) {
      return 'orange';
    }

    if (value.contains('purple')) {
      return 'purple';
    }

    if (value.contains('pink')) {
      return 'pink';
    }

    return value;
  }

  // ============================================================
  // GENERAL TEXT HELPERS
  // ============================================================

  static bool _containsAny(String text, List<String> values) {
    final lower = text.toLowerCase();

    for (final value in values) {
      if (lower.contains(value.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  // ============================================================
  // EMPTY WARDROBE
  // ============================================================

  static VestraStylingResult _emptyWardrobeResult(
    String occasion,
    String request,
    int index,
  ) {
    return VestraStylingResult(
      outfitName: '${_capitalize(occasion)} — ${_variationName(index)}',
      description:
          'Your wardrobe is currently empty, so Vestra cannot '
          'build a wardrobe-based look yet.',
      reasoning:
          'Add clothing pieces to your wardrobe and Vestra will '
          'style the actual items you own.',
      selectedPieces: const {},
      suggestedPieces: const [],
      missingPieces: const [],
      recommendations: const [
        'Add at least one wardrobe piece.',
        'Add photos and details for stronger future styling.',
      ],
      occasion: occasion,
      userRequest: request,
    );
  }
}
