import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../storage/service_booking_storage.dart';
import '../../theme/app_colors.dart';
import '../../widgets/section_title.dart';
import '../../widgets/soft_card.dart';

class ServiceRequestAdminScreen extends StatefulWidget {
  const ServiceRequestAdminScreen({super.key});

  @override
  State<ServiceRequestAdminScreen> createState() =>
      _ServiceRequestAdminScreenState();
}

class _ServiceRequestAdminScreenState extends State<ServiceRequestAdminScreen> {
  List<ServiceBookingRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final requests = await ServiceBookingStorage.loadRequests();
    if (!mounted) return;
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  Future<void> _confirmRequest(ServiceBookingRequest request) async {
    await ServiceBookingStorage.confirmRequest(request.id);
    await _loadRequests();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xác nhận lịch cho ${request.petName}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newCount = _requests
        .where((request) => request.status == ServiceBookingStatus.sent)
        .length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Lịch dịch vụ gửi về'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
          children: [
            _AdminHeader(newCount: newCount),
            const SizedBox(height: 22),
            SectionTitle(
              title: 'Thông báo lịch mới',
              actionText: '${_requests.length} lịch',
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_requests.isEmpty)
              const SoftCard(
                color: Colors.white,
                child: Text('Chưa có yêu cầu dịch vụ nào từ khách hàng.'),
              )
            else
              ..._requests.map(
                (request) => _AdminRequestCard(
                  request: request,
                  onConfirm: request.status == ServiceBookingStatus.sent
                      ? () => _confirmRequest(request)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final int newCount;

  const _AdminHeader({required this.newCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.mint,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: AppColors.textDark,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin nhận lịch',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  newCount == 0
                      ? 'Không còn lịch mới cần xác nhận.'
                      : 'Có $newCount lịch dịch vụ mới gửi về admin.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminRequestCard extends StatelessWidget {
  final ServiceBookingRequest request;
  final VoidCallback? onConfirm;

  const _AdminRequestCard({required this.request, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _statusColor(request.status),
                  child: Icon(
                    _statusIcon(request.status),
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.serviceName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${request.customerName} • ${request.phone}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: request.status),
              ],
            ),
            const SizedBox(height: 12),
            _AdminInfoLine(
              icon: Icons.calendar_month_rounded,
              text: request.endDay.isEmpty
                  ? '${request.startDay} • ${request.time}'
                  : '${request.startDay} - ${request.endDay}',
            ),
            const SizedBox(height: 8),
            _AdminInfoLine(
              icon: Icons.pets_rounded,
              text: '${request.petName} • ${request.petType}',
            ),
            const SizedBox(height: 8),
            _AdminInfoLine(
              icon: Icons.spa_rounded,
              text: request.packageName.isEmpty
                  ? request.serviceCategory
                  : request.packageName,
            ),
            if (request.note.isNotEmpty) ...[
              const SizedBox(height: 8),
              _AdminInfoLine(icon: Icons.note_alt_outlined, text: request.note),
            ],
            if (request.status == ServiceBookingStatus.sent) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Xác nhận lịch'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(ServiceBookingStatus status) {
    return switch (status) {
      ServiceBookingStatus.sent => AppColors.sky,
      ServiceBookingStatus.confirmed => AppColors.mint,
    };
  }

  IconData _statusIcon(ServiceBookingStatus status) {
    return switch (status) {
      ServiceBookingStatus.sent => Icons.notifications_active_rounded,
      ServiceBookingStatus.confirmed => Icons.check_circle_rounded,
    };
  }
}

class _AdminInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AdminInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ServiceBookingStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ServiceBookingStatus.sent => AppColors.sky,
      ServiceBookingStatus.confirmed => AppColors.mint,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
