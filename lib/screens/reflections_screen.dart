import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:werdy/utils/app_theme.dart';

class Reflection {
  final String title;
  final String content;
  final String source; // e.g. Tafsir Ibn Kathir, or Scholar Name
  final String? verseReference; // e.g. "Al-Baqarah: 286"

  const Reflection({
    required this.title,
    required this.content,
    required this.source,
    this.verseReference,
  });
}

class ReflectionsScreen extends StatelessWidget {
  const ReflectionsScreen({super.key});

  final List<Reflection> reflections = const [
    Reflection(
      title: 'طمأنينة القلب',
      content:
          'الذكر ليس مجرد كلمات ترددها اللسان، بل هو حالة يعيشها القلب. "ألا بذكر الله تطمئن القلوب" تعني أن القلق والاضطراب لا يزولان إلا حين يتصل القلب بخالقه.',
      source: 'لطائف قرآنية',
      verseReference: 'الرعد: 28',
    ),
    Reflection(
      title: 'الصبر الجميل',
      content:
          'الصبر الجميل هو الذي لا شكوى فيه للخلق. يعقوب عليه السلام قال "إنما أشكو بثي وحزني إلى الله"، فلم يشتكِ لأبنائه رغم ألم الفراق.',
      source: 'قصص الأنبياء',
      verseReference: 'يوسف: 86',
    ),
    Reflection(
      title: 'ولا تيأسوا',
      content:
          'اليأس كفر بنعمة الله وقدرته. مهما ضاقت الأسباب، فإن قدرة الله أوسع. لا ييأس من روح الله إلا القوم الكافرون، لأن المؤمن يعلم أن الله على كل شيء قدير.',
      source: 'تدبرات',
      verseReference: 'يوسف: 87',
    ),
    Reflection(
      title: 'الاستغفار',
      content:
          'كان الحسن البصري يقول: "أكثروا من الاستغفار في بيوتكم، وعلى موائدكم، وفي طرقكم، وفي أسواقكم، فإنكم لا تدرون متى تنزل المغفرة".',
      source: 'الحسن البصري',
    ),
    Reflection(
      title: 'التوكل الحقيقي',
      content:
          'التوكل هو عمل القلب، والأخذ بالأسباب هو عمل الجوارح. الجوارح تعمل وكأن كل شيء يعتمد على الأسباب، والقلب يتوكل وكأن الأسباب لا قيمة لها.',
      source: 'ابن القيم',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فوائد وتدبرات'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reflections.length,
        itemBuilder: (context, index) {
          final item = reflections[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.content,
                    style: GoogleFonts.amiri(
                      fontSize: 18,
                      height: 1.8,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.source,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (item.verseReference != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.verseReference!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
