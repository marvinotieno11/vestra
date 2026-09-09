import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'number': '01',
      'title': 'YOUR STYLE',
      'description':
          'Discover your personal style and let Vestra understand what makes your look uniquely yours.',
    },
    {
      'number': '02',
      'title': 'YOUR WARDROBE',
      'description':
          'Build your digital wardrobe and let Vestra create outfits from the pieces you already own.',
    },
    {
      'number': '03',
      'title': 'YOUR AI STYLIST',
      'description':
          'Get intelligent outfit recommendations for your mood, occasion, weather and personal style.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VESTRA',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 5,
                    ),
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page['number']!,
                          style: TextStyle(
                            color: AppColors.accent.withValues(alpha: 0.9),
                            fontSize: 14,
                            letterSpacing: 3,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          page['title']!,
                          style: AppTextStyles.title.copyWith(
                            fontSize: 38,
                            letterSpacing: 4,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: 50,
                          height: 1,
                          color: AppColors.accent,
                        ),

                        const SizedBox(height: 24),

                        Text(
                          page['description']!,
                          style: AppTextStyles.body.copyWith(
                            fontSize: 17,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 40),

                        Container(
                          width: double.infinity,
                          height: 1,
                          color: AppColors.secondary.withValues(alpha: 0.15),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 30),
              child: Column(
                children: [
                  Row(
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: isActive ? 32 : 8,
                        height: 3,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.accent
                              : AppColors.secondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'BEGIN YOUR STYLE JOURNEY'
                            : 'NEXT',
                        style: AppTextStyles.button.copyWith(
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
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
