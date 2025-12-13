import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdy/utils/app_theme.dart';
import 'package:werdy/utils/arab_numeral_converter.dart';

class SurahHeaderDelegate extends SliverPersistentHeaderDelegate {
  final int surahNumber;
  final String surahName;
  final int verseCount;
  final String revelationType;
  final double expandedHeight;
  final double topPadding;

  SurahHeaderDelegate({
    required this.surahNumber,
    required this.surahName,
    required this.verseCount,
    required this.revelationType,
    required this.expandedHeight,
    required this.topPadding,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = shrinkOffset / maxExtent;
    final isCollapsed = progress > 0.4;

    // Calculate opacities
    final expandedOpacity = (1 - progress * 2).clamp(0.0, 1.0);
    final collapsedOpacity = (progress - 0.5) * 2;
    final titleOpacity = collapsedOpacity.clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: isCollapsed
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(26), // 0.1 * 255
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Pattern or Gradient
          if (!isCollapsed)
            Positioned(
              right: -50,
              bottom: -50,
              child: Opacity(
                opacity: 0.1 * expandedOpacity,
                child: Image.asset(
                  'assets/images/koran.png',
                  width: 200,
                  height: 200,
                  errorBuilder: (c, e, s) => const SizedBox(),
                ),
              ),
            ),

          // Expanded Data
          Positioned(
            top: expandedHeight / 2 - 40,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: expandedOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ArabNumeralConverter.convert(surahNumber),
                      style: GoogleFonts.amiri(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surahName,
                    style: GoogleFonts.amiri(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Text(
                    '${ArabNumeralConverter.convert(verseCount)} آيات',
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withAlpha(26), // 0.1 * 255
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      revelationType == 'Mecca' ? 'مكية' : 'مدنية',
                      style: GoogleFonts.amiri(
                        fontSize: 14,
                        color: AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsed AppBar
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isCollapsed
                    ? Theme.of(context).iconTheme.color
                    : AppTheme.primaryColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            title: Opacity(
              opacity: titleOpacity,
              child: Text(
                surahName,
                style: GoogleFonts.amiri(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: isCollapsed
                      ? Theme.of(context).iconTheme.color
                      : AppTheme.primaryColor,
                ),
                onPressed: () {
                  // Show surah info/details
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + topPadding;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
