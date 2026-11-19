import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_wave.dart';
import '../widgets/brand_logo.dart';

class _Page {
  final String image;
  final String titleStart; // navy part of the title
  final String titleEnd; // red part of the title
  final String body;
  const _Page(this.image, this.titleStart, this.titleEnd, this.body);
}

/// Screen 1 - Onboarding (3 intro pages using PageView).
/// Layout: logo, illustration, page dots, two-tone title, short text,
/// one wide button, Back below it (pages 2-3), navy + red wave at the bottom.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Page(
      'assets/images/onboarding_1.png',
      'Stay Safe During ',
      'Disasters',
      'Your safety matters most. SafeHaven helps you find emergency '
          'shelters when you need them.',
    ),
    _Page(
      'assets/images/onboarding_2.png',
      'Find Nearby ',
      'Shelters',
      'Use your location to see the closest shelters, with their distance, '
          'address, places left and whether they are open.',
    ),
    _Page(
      'assets/images/onboarding_3.png',
      'Stay ',
      'Informed',
      'Trusted admins keep shelter information up to date, so you can '
          'check everything in one place before you go.',
    ),
  ];

  bool get _first => _index == 0;
  bool get _last => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goLogin() => Navigator.pushNamed(context, '/login');

  void _next() {
    if (_last) {
      _goLogin();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  void _back() => _controller.previousPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2, bottom: 2),
              child: BrandLogoRow(),
            ),

            // ---- Pages (each page scrolls if the phone is small) ----
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageContent(
                    page: _pages[i], index: i, count: _pages.length),
              ),
            ),

            // ---- Main button: Next (navy) / Get Started (blue) ----
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 12, 28, 0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _last ? AppTheme.accent : AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: _last ? 3 : 0,
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: Text(_last ? 'Get Started' : 'Next'),
                ),
              ),
            ),

            // ---- Back (pages 2-3). Page 1 has no Skip; the space is kept
            //      so the layout does not jump between pages. ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 2),
              child: SizedBox(
                height: 30,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: _first
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: _back,
                          child: const Text('Back',
                              style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent)),
                        ),
                ),
              ),
            ),

            // ---- Design pattern at the bottom ----
            const BottomWave(height: 34),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _Page page;
  final int index;
  final int count;
  const _PageContent(
      {required this.page, required this.index, required this.count});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              // The picture has its own white wave at the bottom, so it blends
              // into the white page below it.
              // Full width (covers both sides) but shorter: the picture is
              // cropped a little, and its bottom edge is cut in a soft curve.
              AspectRatio(
                aspectRatio: 1.28,
                child: ClipPath(
                  clipper: _CurveClipper(),
                  child: Image.asset(
                    page.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.7),
                  ),
                ),
              ),
              // ---- Page dots (right under the picture, above the title) ----
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(count, (i) {
                  final active = i == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color:
                          active ? AppTheme.primary : const Color(0xFFC9CED6),
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 10, 28, 8),
                child: Column(
                  children: [
                    Text.rich(
                      TextSpan(
                        style: text.headlineMedium?.copyWith(fontSize: 28),
                        children: [
                          TextSpan(
                              text: page.titleStart,
                              style: const TextStyle(color: AppTheme.primary)),
                          TextSpan(
                              text: page.titleEnd,
                              style: const TextStyle(color: AppTheme.accent)),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: text.bodyMedium
                          ?.copyWith(fontSize: 15.5, color: AppTheme.ink),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuts the bottom of the picture in a soft curve (centre is higher than the
/// edges), like the white wave in the original design.
class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const depth = 12.0;
    return Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
          size.width / 2, size.height - 2 * depth, size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
