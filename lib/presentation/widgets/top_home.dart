import 'package:flutter/material.dart';

class TopHomeWidget extends StatelessWidget {
  const TopHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(40),
          bottomLeft: Radius.circular(40),
        ),
        color: Color(0xff52BF95),
      ),
      child: Image.asset(
        'assets/images/masjid2.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
