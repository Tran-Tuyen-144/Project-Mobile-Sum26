import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingsListScreen extends StatelessWidget {
  const BookingsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách booking')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có booking nào'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final customer = data['customerName'] ?? '-';
              final pet = data['petName'] ?? '-';
              final time = data['requestedTime'] ?? '';
              final note = data['note'] ?? '';
              final status = data['status'] ?? '';
              final ts = data['createdAt'];
              String created = '';
              try {
                if (ts is Timestamp) {
                  created = ts.toDate().toLocal().toString();
                } else if (ts is DateTime) {
                  created = ts.toLocal().toString();
                }
              } catch (_) {}

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text('$customer — $pet'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (time.isNotEmpty) Text('Thời gian: $time'),
                      if (note.isNotEmpty) Text('Ghi chú: $note'),
                      Text('Trạng thái: $status'),
                    ],
                  ),
                  trailing: Text(
                    created.isNotEmpty ? created.split('.').first : '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
