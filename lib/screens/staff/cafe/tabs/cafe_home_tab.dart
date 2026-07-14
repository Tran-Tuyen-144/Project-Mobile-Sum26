import 'package:flutter/material.dart';
import '../../../../models/staff/staff_task.dart';
import '../../../../storage/staff_task_storage.dart';
import '../../../../theme/app_colors.dart';

class CafeHomeTab extends StatelessWidget {
  const CafeHomeTab({super.key});

  void _showTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          return FutureBuilder<List<StaffTask>>(
            future: StaffTaskStorage.getTodayTasks('cafe'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              final tasks = snapshot.data ?? [];

              if (tasks.isEmpty) {
                return const Center(child: Text("Hôm nay chưa có công việc nào!", style: TextStyle(color: AppColors.textSoft)));
              }

              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: tasks.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text('Danh sách công việc', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    );
                  }

                  final task = tasks[index - 1];
                  return StatefulBuilder(
                      builder: (context, setModalState) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: task.isCompleted ? AppColors.peach : AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              side: BorderSide(color: task.isCompleted ? AppColors.primarySoft : AppColors.cream),
                              borderRadius: BorderRadius.circular(16)
                          ),
                          child: CheckboxListTile(
                            title: Text('${task.timeSlot} - ${task.title}',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.bold,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                )),
                            subtitle: Text(task.description, style: const TextStyle(color: AppColors.textSoft)),
                            value: task.isCompleted,
                            activeColor: AppColors.primary,
                            checkColor: AppColors.surface,
                            onChanged: (val) async {
                              final newValue = val ?? false;
                              setModalState(() {
                                tasks[index - 1] = task.copyWith(isCompleted: newValue);
                              });

                              bool success = await StaffTaskStorage.updateTaskStatus(task.id, newValue);
                              if (!success) {
                                setModalState(() {
                                  tasks[index - 1] = task.copyWith(isCompleted: !newValue);
                                });
                              }
                            },
                          ),
                        );
                      }
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PetHub Staff', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Khung Chào mừng đồng bộ màu Peach của Cafe
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.peach,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primarySoft, width: 1.5),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chào Nguyễn Minh An,", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                SizedBox(height: 8),
                Text("Chúc bạn làm việc thật năng suất hôm nay nhé!", style: TextStyle(fontSize: 15, color: AppColors.textSoft, fontWeight: FontWeight.w600)),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text('Workboard', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 12),

          InkWell(
            onTap: () => _showTaskModal(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cream, width: 2),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.task_alt, color: AppColors.primary, size: 28)
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Công việc hôm nay", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        SizedBox(height: 4),
                        Text("Chạm vào để xem & cập nhật tiến độ", style: TextStyle(color: AppColors.textSoft, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.textSoft)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}