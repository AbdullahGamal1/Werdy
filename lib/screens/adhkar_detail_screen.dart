import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:werdy/models/dhikr.dart';
import 'package:werdy/providers/settings_provider.dart';
import 'package:werdy/utils/app_strings.dart';
import 'package:werdy/utils/app_theme.dart';

class AdhkarDetailScreen extends StatefulWidget {
  final String title;
  final List<Dhikr> adhkarList;

  const AdhkarDetailScreen({
    super.key,
    required this.title,
    required this.adhkarList,
  });

  @override
  State<AdhkarDetailScreen> createState() => _AdhkarDetailScreenState();
}

class _AdhkarDetailScreenState extends State<AdhkarDetailScreen> {
  late List<int> _counters;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _counters = List.filled(widget.adhkarList.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: const TextStyle(
          color: AppTheme.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / widget.adhkarList.length,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppTheme.secondaryColor,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.adhkarList.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final dhikr = widget.adhkarList[index];
                final progress = _counters[index] / dhikr.count;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${index + 1} / ${widget.adhkarList.length}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        dhikr.text,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.getFont(
                          settings.fontFamily,
                          fontSize: settings.fontSize,
                          height: 1.8,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (dhikr.count > 1) ...[
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_counters[index] < dhikr.count) {
                                  setState(() {
                                    _counters[index]++;
                                  });
                                  if (_counters[index] == dhikr.count) {
                                    // Optional: Auto advance or vibrate
                                    if (index < widget.adhkarList.length - 1) {
                                      Future.delayed(
                                        const Duration(milliseconds: 500),
                                        () {
                                          _pageController.nextPage(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _counters[index] == dhikr.count
                                      ? AppTheme.primaryColor
                                      : AppTheme.secondaryColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (_counters[index] == dhikr.count
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.secondaryColor)
                                              .withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: _counters[index] == dhikr.count
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 40,
                                        )
                                      : Text(
                                          '${dhikr.count - _counters[index]}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _counters[index] = 0;
                            });
                          },
                          child: Text(
                            AppStrings.get('reset', settings.languageCode),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
