import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'wardrobe_store.dart';
import '../services/vestra_wardrobe_ai_service.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Color(0xFF090909);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  final ImagePicker _imagePicker = ImagePicker();

  static const String _backendUrl = String.fromEnvironment(
    'VESTRA_BACKEND_URL',
    defaultValue: 'http://localhost:3000',
  );

  List<Map<String, String>> get wardrobe => WardrobeStore.items;

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Tops',
    'Bottoms',
    'Dresses',
    'Skirts',
    'Jumpsuits',
    'Shoes',
    'Outerwear',
    'Accessories',
    'Bags',
    'Headwear',
    'Activewear',
    'Swimwear',
    'Traditional Wear',
    'Pet Clothing',
  ];

  bool _isLoading = true;

  List<Map<String, String>> get filteredWardrobe {
    if (selectedCategory == 'All') {
      return wardrobe;
    }

    return wardrobe
        .where((item) => item['category'] == selectedCategory)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  // ================================================================
  // LOAD WARDROBE
  // ================================================================

  Future<void> _loadWardrobe() async {
    await WardrobeStore.loadItems();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: black,
        elevation: 0,
        title: const Text(
          'MY WARDROBE',
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
                      'Your wardrobe.',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add the pieces you own so Vestra can '
                      'understand your wardrobe and build '
                      'personalized looks around it.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildWardrobeStats(),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _showAddItemSheet,
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'ADD CLOTHING ITEM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
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
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      'Categories',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 14),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final bool isSelected = selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 9),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 11,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? gold : card,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? gold
                                        : gold.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : softWhite,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your pieces',
                          style: TextStyle(
                            color: softWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${filteredWardrobe.length}',
                          style: const TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    if (filteredWardrobe.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        children: filteredWardrobe.map((item) {
                          return _WardrobeItemCard(
                            item: item,
                            onEdit: () => _showEditItemSheet(item),
                            onDelete: () => _deleteItem(item),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // ================================================================
  // WARDROBE STATS
  // ================================================================

  Widget _buildWardrobeStats() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.3)),
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
            child: const Icon(Icons.checkroom_outlined, color: gold, size: 27),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${wardrobe.length}',
                style: const TextStyle(
                  color: gold,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'items in your wardrobe',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState() {
    final bool isAll = selectedCategory == 'All';
    final String title = isAll
        ? 'Your wardrobe is empty'
        : 'No ${selectedCategory.toLowerCase()} yet';
    final String description = isAll
        ? 'Add pieces you already own and Vestra will learn what is available to you.'
        : 'You do not have any ${selectedCategory.toLowerCase()} in your wardrobe yet. Add one and Vestra will keep it organized here.';
    final String buttonLabel = isAll
        ? 'ADD YOUR FIRST ITEM'
        : 'ADD ${selectedCategory.toUpperCase()}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 38),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF24200F),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              isAll
                  ? Icons.checkroom_outlined
                  : _categoryIcon(selectedCategory),
              color: gold,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: softWhite,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddItemSheet,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              buttonLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: .7,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Tops':
        return Icons.checkroom_outlined;
      case 'Bottoms':
        return Icons.dry_cleaning_outlined;
      case 'Dresses':
      case 'Skirts':
        return Icons.woman_outlined;
      case 'Jumpsuits':
        return Icons.accessibility_new_outlined;
      case 'Shoes':
        return Icons.shopping_bag_outlined;
      case 'Outerwear':
        return Icons.layers_outlined;
      case 'Accessories':
        return Icons.watch_outlined;
      case 'Bags':
        return Icons.shopping_bag_outlined;
      case 'Headwear':
        return Icons.face_outlined;
      case 'Activewear':
        return Icons.fitness_center_outlined;
      case 'Swimwear':
        return Icons.pool_outlined;
      case 'Traditional Wear':
        return Icons.auto_awesome_outlined;
      case 'Pet Clothing':
        return Icons.pets_outlined;
      default:
        return Icons.checkroom_outlined;
    }
  }

  // ================================================================
  // ADD ITEM SHEET
  // ================================================================

  // ================================================================
  // ADD TO WARDROBE CHOOSER
  // ================================================================

  void _showAddItemSheet() {
    _showSingleItemSheet();
  }

  void _showSingleItemSheet() {
    final colorController = TextEditingController();
    final notesController = TextEditingController();

    String category = 'Tops';
    String? imageData;
    String? aiDetectedName;
    bool isPickingImage = false;
    bool isAnalyzingImage = false;

    final Map<String, String> details = {};

    showModalBottomSheet(
      context: context,
      backgroundColor: black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final fields = _getCategoryFields(category);

            Future<void> selectImage(ImageSource source) async {
              setSheetState(() {
                isPickingImage = true;
                isAnalyzingImage = false;
              });

              try {
                final XFile? picked = await _imagePicker.pickImage(
                  source: source,
                  imageQuality: 80,
                  maxWidth: 1200,
                  maxHeight: 1200,
                );

                if (picked == null) {
                  setSheetState(() {
                    isPickingImage = false;
                  });
                  return;
                }

                final bytes = await picked.readAsBytes();
                final encodedImage = base64Encode(bytes);

                setSheetState(() {
                  imageData = encodedImage;
                  isPickingImage = false;
                  isAnalyzingImage = true;
                });

                try {
                  final detected =
                      await VestraWardrobeAIService.analyzeClothingPhoto(
                        imageBase64: encodedImage,
                      );

                  if (!sheetContext.mounted) return;

                  final detectedCategory = detected['category']?.trim() ?? '';

                  final detectedColor = detected['color']?.trim() ?? '';

                  final detectedStyle = detected['style']?.trim() ?? '';

                  final detectedFit = detected['fit']?.trim() ?? '';

                  final detectedLength = detected['length']?.trim() ?? '';

                  final detectedMaterial = detected['material']?.trim() ?? '';

                  final detectedPattern = detected['pattern']?.trim() ?? '';

                  final detectedNotes = detected['notes']?.trim() ?? '';

                  setSheetState(() {
                    isAnalyzingImage = false;

                    aiDetectedName = detected['name']?.trim().isNotEmpty == true
                        ? detected['name']!.trim()
                        : null;

                    if (categories.contains(detectedCategory) &&
                        detectedCategory != 'All') {
                      category = detectedCategory;
                    }

                    if (detectedColor.isNotEmpty &&
                        detectedColor.toLowerCase() != 'unknown') {
                      colorController.text = detectedColor;
                    }

                    details.clear();

                    final fieldsForCategory = _getCategoryFields(category);

                    void setDetailIfValid(String label, String value) {
                      if (value.isEmpty || value.toLowerCase() == 'unknown') {
                        return;
                      }

                      Map<String, dynamic>? matchingField;

                      for (final field in fieldsForCategory) {
                        if (field['label'] == label) {
                          matchingField = field;
                          break;
                        }
                      }

                      if (matchingField == null) {
                        return;
                      }

                      final options = List<String>.from(
                        matchingField['options'] as List,
                      );

                      final exactMatch = options.firstWhere(
                        (option) => option.toLowerCase() == value.toLowerCase(),
                        orElse: () => '',
                      );

                      if (exactMatch.isNotEmpty) {
                        details[label] = exactMatch;
                      }
                    }

                    setDetailIfValid('Style', detectedStyle);

                    setDetailIfValid('Fit', detectedFit);

                    setDetailIfValid('Length', detectedLength);

                    setDetailIfValid('Material', detectedMaterial);

                    setDetailIfValid('Pattern', detectedPattern);

                    if (detectedNotes.isNotEmpty &&
                        detectedNotes.toLowerCase() != 'unknown') {
                      notesController.text = detectedNotes;
                    }
                  });
                } on VestraWardrobeAIException catch (error) {
                  if (!sheetContext.mounted) return;

                  setSheetState(() {
                    isAnalyzingImage = false;
                  });

                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Photo added, but Vestra could not '
                        'analyze it. ${error.message}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (_) {
                  if (!sheetContext.mounted) return;

                  setSheetState(() {
                    isAnalyzingImage = false;
                  });

                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Photo added, but Vestra could not '
                        'analyze it. You can still enter '
                        'the details manually.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {
                setSheetState(() {
                  isPickingImage = false;
                  isAnalyzingImage = false;
                });

                if (!sheetContext.mounted) return;

                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to select that image.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: gold,
                            size: 20,
                          ),
                          tooltip: 'Back to wardrobe',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Add to your wardrobe',
                            style: TextStyle(
                              color: softWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Add a photo so Vestra can use your '
                      'actual clothing in future outfit visuals.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =================================================
                    // PHOTO
                    // =================================================
                    _buildPhotoPicker(
                      imageData: imageData,
                      isPickingImage: isPickingImage,
                      isAnalyzingImage: isAnalyzingImage,
                      onCamera: () {
                        selectImage(ImageSource.camera);
                      },
                      onGallery: () {
                        selectImage(ImageSource.gallery);
                      },
                      onRemove: () {
                        setSheetState(() {
                          imageData = null;
                          aiDetectedName = null;
                          isAnalyzingImage = false;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    if (isAnalyzingImage)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF24200F),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: gold,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'VESTRA IS ANALYZING YOUR CLOTHING...',
                                style: TextStyle(
                                  color: gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 25),

                    // =================================================
                    // CATEGORY
                    // =================================================
                    const Text(
                      'Category',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gold.withValues(alpha: 0.25)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          isExpanded: true,
                          dropdownColor: card,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: gold,
                          ),
                          style: const TextStyle(
                            color: softWhite,
                            fontSize: 14,
                          ),
                          items: categories
                              .where((item) => item != 'All')
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setSheetState(() {
                              category = value;
                              details.clear();
                              aiDetectedName = null;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =================================================
                    // COLOR
                    // =================================================
                    _WardrobeTextField(
                      controller: colorController,
                      label: 'Color',
                      hint: 'e.g. Black, cream, burgundy, multicolor',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Item details',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...fields.map((field) {
                      final String label = field['label'] as String;

                      final List<String> options = List<String>.from(
                        field['options'] as List,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: _DynamicDropdown(
                          label: label,
                          value: details[label] ?? '',
                          options: options,
                          onChanged: (value) {
                            setSheetState(() {
                              details[label] = value ?? '';
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 5),

                    // =================================================
                    // NOTES
                    // =================================================
                    _WardrobeTextField(
                      controller: notesController,
                      label: 'Notes',
                      hint: 'Anything Vestra should know about this piece...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // PREVIEW
                    // =================================================
                    _buildItemPreview(
                      category: category,
                      color: colorController.text,
                      details: details,
                    ),

                    const SizedBox(height: 20),

                    // =================================================
                    // ADD
                    // =================================================
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (colorController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter the color.'),
                              ),
                            );
                            return;
                          }

                          final String generatedName =
                              (aiDetectedName?.trim().isNotEmpty == true)
                              ? aiDetectedName!.trim()
                              : _generateItemName(
                                  category,
                                  colorController.text.trim(),
                                  details,
                                );

                          final Map<String, String> item = {
                            'name': generatedName,
                            'category': category,
                            'color': colorController.text.trim(),
                            'notes': notesController.text.trim(),
                          };

                          if (imageData != null && imageData!.isNotEmpty) {
                            item['imageData'] = imageData!;
                          }

                          for (final entry in details.entries) {
                            item[_normalizeKey(entry.key)] = entry.value;
                          }

                          await WardrobeStore.addItem(item);

                          if (!mounted) return;

                          setState(() {});

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                imageData != null
                                    ? 'Item and photo added to your wardrobe.'
                                    : 'Item added to your wardrobe.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'ADD ITEM',
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
            );
          },
        );
      },
    );
  }

  // ================================================================
  // EDIT WARDROBE ITEM
  // ================================================================

  void _showEditItemSheet(Map<String, String> item) {
    final colorController = TextEditingController(text: item['color'] ?? '');

    final notesController = TextEditingController(text: item['notes'] ?? '');

    String category = item['category'] ?? 'Tops';
    String? imageData = item['imageData'];

    final Map<String, String> details = {};

    void loadDetailsForCategory(String selectedCategory) {
      details.clear();

      final ignoredKeys = {
        'id',
        'name',
        'category',
        'color',
        'notes',
        'imageData',
      };

      final fields = _getCategoryFields(selectedCategory);

      for (final entry in item.entries) {
        if (ignoredKeys.contains(entry.key) || entry.value.isEmpty) {
          continue;
        }

        for (final field in fields) {
          final label = field['label'] as String;
          if (_normalizeKey(label) == entry.key) {
            final options = List<String>.from(field['options'] as List);
            final matchingOption = options.firstWhere(
              (option) => option.toLowerCase() == entry.value.toLowerCase(),
              orElse: () => '',
            );

            if (matchingOption.isNotEmpty) {
              details[label] = matchingOption;
            }
            break;
          }
        }
      }
    }

    loadDetailsForCategory(category);

    showModalBottomSheet(
      context: context,
      backgroundColor: black,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final fields = _getCategoryFields(category);

            Future<void> pickReplacementImage(ImageSource source) async {
              try {
                final XFile? picked = await _imagePicker.pickImage(
                  source: source,
                  imageQuality: 80,
                  maxWidth: 1200,
                  maxHeight: 1200,
                );

                if (picked == null) return;

                final bytes = await picked.readAsBytes();

                setSheetState(() {
                  imageData = base64Encode(bytes);
                });
              } catch (_) {
                if (!sheetContext.mounted) return;

                ScaffoldMessenger.of(sheetContext).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to select that image.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 25,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Edit wardrobe item',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      item['name'] ?? 'Clothing item',
                      style: const TextStyle(color: gold, fontSize: 13),
                    ),

                    const SizedBox(height: 22),

                    _buildPhotoPicker(
                      imageData: imageData,
                      isPickingImage: false,
                      isAnalyzingImage: false,
                      onCamera: () {
                        pickReplacementImage(ImageSource.camera);
                      },
                      onGallery: () {
                        pickReplacementImage(ImageSource.gallery);
                      },
                      onRemove: () {
                        setSheetState(() {
                          imageData = null;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Category',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: gold.withValues(alpha: 0.25)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          isExpanded: true,
                          dropdownColor: card,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: gold,
                          ),
                          style: const TextStyle(
                            color: softWhite,
                            fontSize: 14,
                          ),
                          items: categories
                              .where((item) => item != 'All')
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setSheetState(() {
                              category = value;
                              loadDetailsForCategory(category);
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    _WardrobeTextField(
                      controller: colorController,
                      label: 'Color',
                      hint: 'e.g. Black, cream, burgundy, multicolor',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Item details',
                      style: TextStyle(
                        color: softWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...fields.map((field) {
                      final String label = field['label'] as String;
                      final List<String> options = List<String>.from(
                        field['options'] as List,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13),
                        child: _DynamicDropdown(
                          label: label,
                          value: details[label] ?? '',
                          options: options,
                          onChanged: (value) {
                            setSheetState(() {
                              details[label] = value ?? '';
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 5),

                    _WardrobeTextField(
                      controller: notesController,
                      label: 'Notes',
                      hint: 'Anything Vestra should know about this piece...',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 25),

                    _buildItemPreview(
                      category: category,
                      color: colorController.text,
                      details: details,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (colorController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter the color.'),
                              ),
                            );
                            return;
                          }

                          final updatedItem = Map<String, String>.from(item);

                          updatedItem['category'] = category;
                          updatedItem['color'] = colorController.text.trim();
                          updatedItem['notes'] = notesController.text.trim();

                          // Regenerate the display name from the edited
                          // category, color, and clothing details so the
                          // name stays synchronized with the item.
                          updatedItem['name'] = _generateItemName(
                            category,
                            colorController.text.trim(),
                            details,
                          );

                          if (imageData == null || imageData!.isEmpty) {
                            updatedItem.remove('imageData');
                          } else {
                            updatedItem['imageData'] = imageData!;
                          }

                          final oldFields = _getCategoryFields(
                            item['category'] ?? category,
                          );

                          for (final field in oldFields) {
                            updatedItem.remove(
                              _normalizeKey(field['label'] as String),
                            );
                          }

                          for (final entry in details.entries) {
                            if (entry.value.isNotEmpty) {
                              updatedItem[_normalizeKey(entry.key)] =
                                  entry.value;
                            }
                          }

                          try {
                            await WardrobeStore.updateItem(updatedItem);

                            if (!mounted) return;

                            setState(() {});
                            Navigator.pop(sheetContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Wardrobe item updated successfully.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (error) {
                            if (!sheetContext.mounted) return;

                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                content: Text('Could not update item: $error'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'SAVE CHANGES',
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
            );
          },
        );
      },
    );
  }

  // ================================================================
  // PHOTO PICKER
  // ================================================================

  Widget _buildPhotoPicker({
    required String? imageData,
    required bool isPickingImage,
    required bool isAnalyzingImage,
    required VoidCallback onCamera,
    required VoidCallback onGallery,
    required VoidCallback onRemove,
  }) {
    final bool hasImage = imageData != null && imageData.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(21),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 230,
                    child: Image.memory(
                      base64Decode(imageData),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: gold,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFF24200F),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      isPickingImage
                          ? Icons.hourglass_top
                          : Icons.add_a_photo_outlined,
                      color: gold,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Add a photo',
                    style: TextStyle(
                      color: softWhite,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Use a clear photo of the clothing piece.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (isPickingImage || isAnalyzingImage)
                        ? null
                        : onCamera,
                    icon: const Icon(Icons.camera_alt_outlined, size: 19),
                    label: const Text(
                      'CAMERA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: BorderSide(color: gold.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: (isPickingImage || isAnalyzingImage)
                        ? null
                        : onGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 19),
                    label: const Text(
                      'GALLERY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: BorderSide(color: gold.withValues(alpha: 0.45)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // ITEM PREVIEW
  // ================================================================

  Widget _buildItemPreview({
    required String category,
    required String color,
    required Map<String, String> details,
  }) {
    final previewName = _generateItemName(category, color, details);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF24200F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: gold, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              previewName,
              style: const TextStyle(
                color: gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // GENERATE ITEM NAME
  // ================================================================

  String _generateItemName(
    String category,
    String color,
    Map<String, String> details,
  ) {
    final List<String> parts = [];

    if (color.trim().isNotEmpty) {
      parts.add(color.trim());
    }

    final importantKeys = [
      'fit',
      'style',
      'shoeType',
      'accessoryType',
      'dressType',
      'skirtType',
      'length',
      'material',
    ];

    for (final key in importantKeys) {
      final value = details[key];

      if (value != null && value.isNotEmpty && !parts.contains(value)) {
        parts.add(value);
      }
    }

    final String base = _categoryBaseName(category);

    if (parts.isEmpty) {
      return base;
    }

    return '${parts.join(' ')} $base';
  }

  String _categoryBaseName(String category) {
    switch (category) {
      case 'Tops':
        return 'top';

      case 'Bottoms':
        return 'trousers';

      case 'Dresses':
        return 'dress';

      case 'Skirts':
        return 'skirt';

      case 'Jumpsuits':
        return 'jumpsuit';

      case 'Shoes':
        return 'shoes';

      case 'Outerwear':
        return 'outerwear';

      case 'Accessories':
        return 'accessory';

      case 'Bags':
        return 'bag';

      case 'Headwear':
        return 'headwear';

      case 'Activewear':
        return 'activewear';

      case 'Swimwear':
        return 'swimwear';

      case 'Traditional Wear':
        return 'traditional wear';

      case 'Pet Clothing':
        return 'pet clothing';

      default:
        return 'clothing item';
    }
  }

  // ================================================================
  // NORMALIZE KEY
  // ================================================================

  String _normalizeKey(String label) {
    return label
        .replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toLowerCase() + word.substring(1),
        )
        .join();
  }

  // ================================================================
  // CATEGORY INTELLIGENCE
  // ================================================================

  List<Map<String, dynamic>> _getCategoryFields(String category) {
    switch (category) {
      case 'Tops':
        return [
          {
            'label': 'Fit',
            'options': ['Slim', 'Regular', 'Relaxed', 'Oversized', 'Cropped'],
          },
          {
            'label': 'Sleeve',
            'options': [
              'Short sleeve',
              'Long sleeve',
              'Sleeveless',
              '3/4 sleeve',
              'Tank',
              'Off shoulder',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Linen',
              'Denim',
              'Wool',
              'Silk',
              'Knit',
              'Leather',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Pattern',
            'options': [
              'Plain',
              'Striped',
              'Checked',
              'Graphic',
              'Floral',
              'Patterned',
              'Embroidered',
              'Other',
            ],
          },
        ];

      case 'Bottoms':
        return [
          {
            'label': 'Fit',
            'options': [
              'Skinny',
              'Slim',
              'Straight',
              'Relaxed',
              'Baggy',
              'Wide-leg',
              'Flared',
            ],
          },
          {
            'label': 'Length',
            'options': [
              'Shorts',
              'Cropped',
              'Ankle',
              'Full length',
              'Extra long',
            ],
          },
          {
            'label': 'Rise',
            'options': ['Low rise', 'Mid rise', 'High rise', 'Not applicable'],
          },
          {
            'label': 'Material',
            'options': [
              'Denim',
              'Cotton',
              'Linen',
              'Wool',
              'Leather',
              'Synthetic',
              'Other',
            ],
          },
        ];

      case 'Dresses':
        return [
          {
            'label': 'Style',
            'options': [
              'Bodycon',
              'A-line',
              'Slip',
              'Shirt dress',
              'Wrap',
              'Maxi',
              'Mini',
              'Midi',
              'Ball gown',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed', 'Oversized'],
          },
          {
            'label': 'Length',
            'options': ['Mini', 'Midi', 'Maxi', 'Floor length'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Linen',
              'Silk',
              'Satin',
              'Knit',
              'Denim',
              'Wool',
              'Synthetic',
              'Other',
            ],
          },
        ];

      case 'Skirts':
        return [
          {
            'label': 'Style',
            'options': [
              'Pencil',
              'A-line',
              'Pleated',
              'Wrap',
              'Denim',
              'Cargo',
              'Circle',
              'Asymmetrical',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed'],
          },
          {
            'label': 'Length',
            'options': ['Mini', 'Midi', 'Maxi', 'Floor length'],
          },
          {
            'label': 'Material',
            'options': [
              'Denim',
              'Cotton',
              'Linen',
              'Silk',
              'Leather',
              'Wool',
              'Synthetic',
              'Other',
            ],
          },
        ];

      case 'Jumpsuits':
        return [
          {
            'label': 'Fit',
            'options': [
              'Fitted',
              'Regular',
              'Relaxed',
              'Oversized',
              'Wide-leg',
            ],
          },
          {
            'label': 'Length',
            'options': ['Short', 'Ankle', 'Full length'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Linen',
              'Denim',
              'Silk',
              'Knit',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Casual',
              'Utility',
              'Formal',
              'Minimal',
              'Statement',
              'Other',
            ],
          },
        ];

      case 'Shoes':
        return [
          {
            'label': 'Shoe type',
            'options': [
              'Sneakers',
              'Boots',
              'Loafers',
              'Dress shoes',
              'Sandals',
              'Slides',
              'Heels',
              'Flats',
              'Platforms',
              'Other',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Leather',
              'Suede',
              'Canvas',
              'Mesh',
              'Rubber',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Classic',
              'Sporty',
              'Formal',
              'Chunky',
              'Luxury',
              'Streetwear',
              'Traditional',
            ],
          },
          {
            'label': 'Use',
            'options': [
              'Everyday',
              'Work',
              'Formal',
              'Sport',
              'Travel',
              'Special occasion',
              'Other',
            ],
          },
        ];

      case 'Outerwear':
        return [
          {
            'label': 'Fit',
            'options': ['Slim', 'Regular', 'Relaxed', 'Oversized'],
          },
          {
            'label': 'Length',
            'options': [
              'Cropped',
              'Waist length',
              'Hip length',
              'Knee length',
              'Long',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Leather',
              'Denim',
              'Wool',
              'Cotton',
              'Linen',
              'Fur',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Blazer',
              'Jacket',
              'Coat',
              'Trench',
              'Bomber',
              'Cardigan',
              'Cape',
              'Other',
            ],
          },
        ];

      case 'Accessories':
        return [
          {
            'label': 'Accessory type',
            'options': [
              'Watch',
              'Necklace',
              'Bracelet',
              'Ring',
              'Belt',
              'Scarf',
              'Glasses',
              'Brooch',
              'Other',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Leather',
              'Metal',
              'Gold',
              'Silver',
              'Fabric',
              'Wood',
              'Plastic',
              'Mixed',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Classic',
              'Luxury',
              'Streetwear',
              'Statement',
              'Traditional',
              'Sporty',
              'Other',
            ],
          },
          {
            'label': 'Use',
            'options': [
              'Everyday',
              'Work',
              'Formal',
              'Casual',
              'Special occasion',
              'Travel',
              'Other',
            ],
          },
        ];

      case 'Bags':
        return [
          {
            'label': 'Bag type',
            'options': [
              'Tote',
              'Crossbody',
              'Shoulder bag',
              'Backpack',
              'Clutch',
              'Handbag',
              'Waist bag',
              'Other',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Leather',
              'Suede',
              'Canvas',
              'Fabric',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Luxury',
              'Classic',
              'Streetwear',
              'Statement',
              'Utility',
              'Other',
            ],
          },
          {
            'label': 'Use',
            'options': [
              'Everyday',
              'Work',
              'Travel',
              'Formal',
              'Casual',
              'Other',
            ],
          },
        ];

      case 'Headwear':
        return [
          {
            'label': 'Type',
            'options': [
              'Cap',
              'Beanie',
              'Bucket hat',
              'Fedora',
              'Beret',
              'Headwrap',
              'Other',
            ],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Wool',
              'Straw',
              'Leather',
              'Fabric',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Classic',
              'Streetwear',
              'Luxury',
              'Traditional',
              'Statement',
              'Other',
            ],
          },
          {
            'label': 'Use',
            'options': [
              'Everyday',
              'Sport',
              'Formal',
              'Travel',
              'Special occasion',
              'Other',
            ],
          },
        ];

      case 'Activewear':
        return [
          {
            'label': 'Type',
            'options': [
              'Sports bra',
              'Tank',
              'Training top',
              'Leggings',
              'Joggers',
              'Shorts',
              'Track pants',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed', 'Oversized'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Performance',
              'Mesh',
              'Nylon',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Use',
            'options': [
              'Gym',
              'Running',
              'Training',
              'Yoga',
              'Sport',
              'Casual',
              'Other',
            ],
          },
        ];

      case 'Swimwear':
        return [
          {
            'label': 'Type',
            'options': [
              'Swimsuit',
              'Bikini',
              'Swim shorts',
              'Swim trunks',
              'Rash guard',
              'Cover-up',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed'],
          },
          {
            'label': 'Material',
            'options': ['Nylon', 'Polyester', 'Spandex', 'Synthetic', 'Other'],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Sporty',
              'Luxury',
              'Statement',
              'Classic',
              'Other',
            ],
          },
        ];

      case 'Traditional Wear':
        return [
          {
            'label': 'Type',
            'options': [
              'Robe',
              'Tunic',
              'Kaftan',
              'Wrap',
              'Headwrap',
              'Set',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed', 'Oversized'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Linen',
              'Silk',
              'Wool',
              'Handwoven',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'African',
              'Asian',
              'Middle Eastern',
              'Indigenous',
              'Ceremonial',
              'Contemporary',
              'Other',
            ],
          },
        ];

      case 'Pet Clothing':
        return [
          {
            'label': 'Type',
            'options': [
              'Shirt',
              'Sweater',
              'Jacket',
              'Dress',
              'Bandana',
              'Costume',
              'Harness',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Knit',
              'Denim',
              'Fleece',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Style',
            'options': [
              'Minimal',
              'Classic',
              'Streetwear',
              'Luxury',
              'Playful',
              'Traditional',
              'Other',
            ],
          },
        ];

      default:
        return [
          {
            'label': 'Style',
            'options': ['Minimal', 'Classic', 'Casual', 'Statement', 'Other'],
          },
          {
            'label': 'Material',
            'options': [
              'Cotton',
              'Linen',
              'Leather',
              'Wool',
              'Synthetic',
              'Other',
            ],
          },
          {
            'label': 'Fit',
            'options': ['Fitted', 'Regular', 'Relaxed', 'Oversized'],
          },
        ];
    }
  }

  // ================================================================
  // DELETE
  // ================================================================

  Future<void> _deleteItem(Map<String, String> item) async {
    await WardrobeStore.removeItem(item);

    if (!mounted) return;

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from your wardrobe.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ====================================================================
// DYNAMIC DROPDOWN
// ====================================================================

class _DynamicDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DynamicDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: softWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: gold.withValues(alpha: 0.25)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: const Text(
                'Select',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              isExpanded: true,
              dropdownColor: card,
              icon: const Icon(Icons.keyboard_arrow_down, color: gold),
              style: const TextStyle(color: softWhite, fontSize: 14),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// TEXT FIELD
// ====================================================================

class _WardrobeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _WardrobeTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: softWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: softWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: card,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.25)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: gold.withValues(alpha: 0.25)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              borderSide: BorderSide(color: gold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// WARDROBE ITEM CARD
// ====================================================================

class _WardrobeItemCard extends StatelessWidget {
  final Map<String, String> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WardrobeItemCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color gold = Color(0xFFD4AF37);
  static const Color card = Color(0xFF151515);
  static const Color softWhite = Color(0xFFF5F1E8);

  IconData _getIcon() {
    switch (item['category']) {
      case 'Tops':
        return Icons.checkroom_outlined;

      case 'Bottoms':
        return Icons.dry_cleaning_outlined;

      case 'Dresses':
        return Icons.woman_outlined;

      case 'Skirts':
        return Icons.woman_outlined;

      case 'Jumpsuits':
        return Icons.accessibility_new_outlined;

      case 'Shoes':
        return Icons.shopping_bag_outlined;

      case 'Outerwear':
        return Icons.layers_outlined;

      case 'Accessories':
        return Icons.watch_outlined;

      case 'Bags':
        return Icons.shopping_bag_outlined;

      case 'Headwear':
        return Icons.face_outlined;

      case 'Activewear':
        return Icons.fitness_center_outlined;

      case 'Swimwear':
        return Icons.pool_outlined;

      case 'Traditional Wear':
        return Icons.auto_awesome_outlined;

      case 'Pet Clothing':
        return Icons.pets_outlined;

      default:
        return Icons.checkroom_outlined;
    }
  }

  String _buildDetails() {
    final ignored = {'id', 'name', 'category', 'color', 'notes', 'imageData'};

    final details = <String>[];

    for (final entry in item.entries) {
      if (ignored.contains(entry.key)) {
        continue;
      }

      if (entry.value.isNotEmpty) {
        details.add(entry.value);
      }
    }

    return details.join(' • ');
  }

  Widget _buildImage() {
    final imageData = item['imageData'];

    if (imageData != null && imageData.isNotEmpty) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Image.memory(
            base64Decode(imageData),
            width: 76,
            height: 76,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildIcon();
            },
          ),
        );
      } catch (_) {
        return _buildIcon();
      }
    }

    return _buildIcon();
  }

  Widget _buildIcon() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: const Color(0xFF24200F),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Icon(_getIcon(), color: gold, size: 28),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = item['color'] ?? '';

    final details = _buildDetails();

    final hasPhoto = item['imageData'] != null && item['imageData']!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Clothing item',
                  style: const TextStyle(
                    color: softWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${item['category']} • '
                  '${color.isEmpty ? 'Color not specified' : color}',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),

                if (hasPhoto) ...[
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Icon(Icons.photo_outlined, color: gold, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Photo added',
                        style: TextStyle(
                          color: gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],

                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: const TextStyle(color: gold, fontSize: 11),
                  ),
                ],

                if ((item['notes'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item['notes']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),

          PopupMenuButton<String>(
            color: card,
            icon: const Icon(Icons.more_vert, color: Colors.white54),
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: gold, size: 20),
                    SizedBox(width: 10),
                    Text('Edit', style: TextStyle(color: softWhite)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text('Delete', style: TextStyle(color: softWhite)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
