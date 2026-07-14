import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class AdminHospitalScreen extends StatelessWidget {
  const AdminHospitalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bệnh Án Thú Y',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.sky,
        child: const Icon(Icons.add_rounded, color: AppColors.textDark),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildMedicalRecord(
            'Bé Milu (Chó mặt xệ)',
            'Triệu chứng: Biếng ăn, ủ rũ',
            'BSTY. Hoàng Nam',
            'Đang chờ khám',
          ),
          _buildMedicalRecord(
            'Bé Bông (Mèo ta)',
            'Tiêm vaccine dại mũi 1',
            'BSTY. Minh Châu',
            'Đã xong',
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecord(
    String petName,
    String symptoms,
    String doctor,
    String status,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sky, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                petName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: status == 'Đã xong' ? AppColors.cream : AppColors.sky,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            symptoms,
            style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.cream),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.medical_information_rounded,
                size: 16,
                color: AppColors.textSoft,
              ),
              const SizedBox(width: 8),
              Text(
                'Phụ trách: $doctor',
                style: const TextStyle(color: AppColors.textSoft, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
