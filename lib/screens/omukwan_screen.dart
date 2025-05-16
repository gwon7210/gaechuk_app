import 'package:flutter/material.dart';

class OmukwanScreen extends StatelessWidget {
  const OmukwanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 제목
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: const Text(
              '오묵완',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A3A4A),
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          // 본문
          const Expanded(
            child: Center(
              child: Text(
                '임시페이지',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3A3A4A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
