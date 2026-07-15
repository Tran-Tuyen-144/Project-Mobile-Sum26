import 'package:flutter/material.dart';
import '../../../../../theme/app_colors.dart';

class AdminHotelScreen extends StatelessWidget {
  const AdminHotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Phòng Lưu Trú', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          bool isOccupied = index == 0 || index == 2;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOccupied ? AppColors.lavender.withOpacity(0.2) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lavender, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Phòng 0${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                    Icon(Icons.door_front_door_rounded, color: isOccupied ? Colors.deepPurple[300] : AppColors.cream),
                  ],
                ),
                if (isOccupied) ...[
                  const Text('Bé Mochi\nLưu: 2 ngày', style: TextStyle(color: AppColors.textSoft, fontSize: 13, height: 1.5)),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[300],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Check-out', style: TextStyle(fontSize: 12)),
                  )
                ] else ...[
                  const Center(child: Text('Trống', style: TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.bold))),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.lavender),
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Check-in', style: TextStyle(fontSize: 12, color: AppColors.textDark)),
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}