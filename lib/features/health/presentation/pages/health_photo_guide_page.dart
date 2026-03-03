import 'package:flutter/material.dart';
import 'package:well_paw/core/theme/app_colors.dart';
import 'package:well_paw/features/health/presentation/pages/health_upload_image_page.dart';

class HealthPhotoGuidePage extends StatelessWidget {
  const HealthPhotoGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF4),
      body: SafeArea(
        child: Column(
          children: [
            _FlowTopBar(
              title: 'คำแนะนำการถ่ายภาพ',
              onClose: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECF5),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'เคล็ดลับสำหรับภาพที่ดี',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 14),
                          _GuideRow(text: 'ถ่ายในที่ที่มีแสงสว่างเพียงพอ'),
                          SizedBox(height: 10),
                          _GuideRow(text: 'ตรวจสอบให้ภาพชัดเจน ไม่เบลอ'),
                          SizedBox(height: 10),
                          _GuideRow(text: 'ถ่ายบริเวณที่มีอาการใกล้ชิด'),
                          SizedBox(height: 10),
                          _GuideRow(text: 'หลีกเลี่ยงแสงแฟลชส่องตรง'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'ตัวอย่างภาพ',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _SampleImageCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1591530294104-6c7ef6c7f6ac?auto=format&fit=crop&w=1200&q=80',
                      tag: 'ภาพชัดเจน',
                      tagColor: Color(0xFF06C755),
                    ),
                    const SizedBox(height: 14),
                    const _SampleImageCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=1200&q=80',
                      tag: 'แสงเพียงพอ',
                      tagColor: Color(0xFF06C755),
                    ),
                    const SizedBox(height: 14),
                    const _SampleImageCard(
                      imageUrl:
                          'https://images.unsplash.com/photo-1592754862816-1a21a4ea2281?auto=format&fit=crop&w=1200&q=80',
                      tag: 'ภาพเบลอ',
                      tagColor: Color(0xFFFF3B4A),
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const HealthUploadImagePage(),
                            ),
                          );
                        },
                        child: const Text(
                          'เข้าใจแล้ว - เริ่มถ่ายภาพ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.primaryBlue,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 18,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SampleImageCard extends StatelessWidget {
  const _SampleImageCard({
    required this.imageUrl,
    required this.tag,
    required this.tagColor,
  });

  final String imageUrl;
  final String tag;
  final Color tagColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 8.3,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD8DCE6),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 36,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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

class _FlowTopBar extends StatelessWidget {
  const _FlowTopBar({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F7F8),
        border: Border(bottom: BorderSide(color: Color(0xFFE1E4EC))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
