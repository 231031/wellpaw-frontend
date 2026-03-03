import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:well_paw/features/auth/data/storage/token_storage.dart';
import 'package:well_paw/features/food/data/services/food_plan_api_service.dart';
import 'package:well_paw/features/food/presentation/pages/manual_add_food_page.dart';

class ScanLabelPage extends StatefulWidget {
  const ScanLabelPage({super.key});

  @override
  State<ScanLabelPage> createState() => _ScanLabelPageState();
}

class _ScanLabelPageState extends State<ScanLabelPage> {
  final _picker = ImagePicker();
  final _tokenStorage = const TokenStorage();
  final _foodApi = FoodPlanApiService();

  bool _isProcessing = false;

  Future<void> _handlePickAndProcess(ImageSource source) async {
    if (_isProcessing) {
      return;
    }

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final token = await _tokenStorage.readAccessToken();
      if (token == null || token.isEmpty) {
        throw Exception('ไม่พบโทเคนสำหรับเข้าสู่ระบบ');
      }

      final imageFile = File(picked.path);
      final result = await _foodApi.requestNutritionOcr(
        accessToken: token,
        imageFile: imageFile,
      );

      if (!mounted) {
        return;
      }

      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ManualAddFoodPage(
            initialImageFile: imageFile,
            initialProtein: result.protein,
            initialFat: result.fat,
            initialMoisture: result.moisture,
            initialEnergy: result.energy,
          ),
        ),
      );

      if (saved == true && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สแกนฉลากไม่สำเร็จ: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF182C4C), Color(0xFF0B1A33)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Color(0x664D5A71),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFF7A9E4),
                      width: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'วางฉลากอาหารในกรอบ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ตรวจสอบให้แสงเพียงพอ (Ensure lighting is good)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 16),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CaptureAction(
                      label: 'ถ่ายภาพ',
                      icon: Icons.camera_alt_outlined,
                      active: true,
                      onTap: () => _handlePickAndProcess(ImageSource.camera),
                    ),
                    const SizedBox(width: 28),
                    _CaptureAction(
                      label: 'เลือกรูป',
                      icon: Icons.upload_outlined,
                      active: false,
                      onTap: () => _handlePickAndProcess(ImageSource.gallery),
                    ),
                  ],
                ),
                const SizedBox(height: 38),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: const Color(0x88000000),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'กำลังอ่านข้อมูลโภชนาการ...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CaptureAction extends StatelessWidget {
  const _CaptureAction({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: active ? Colors.white : const Color(0xFF4A5568),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? const Color(0xFF4472C4) : Colors.white,
                width: 5,
              ),
            ),
            child: Icon(
              icon,
              size: 42,
              color: active ? const Color(0xFF4472C4) : Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
