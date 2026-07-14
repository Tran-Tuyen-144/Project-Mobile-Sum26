import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../storage/pet_friendly_place_storage.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';
import 'branch_location.dart';

class CustomerMapScreen extends StatefulWidget {
  const CustomerMapScreen({super.key});
  @override
  State<CustomerMapScreen> createState() => _CustomerMapScreenState();
}

class _CustomerMapScreenState extends State<CustomerMapScreen> {
  NearbyKind? _filter;
  String _keyword = '';
  bool _locating = false;
  LatLng? _currentLocation;
  String _locationMessage = 'Đang dA�ng vị trA� gần đA�ng để hiển thị kết quả.';
  List<PetFriendlyPlace> _places = [...defaultPetFriendlyPlaces];
  final Set<String> _savedPlaceIds = {};

  @override
  void initState() {
    super.initState();
    _loadPlaces();
    _requestLocation();
  }

  Future<void> _loadPlaces() async {
    final saved = await PetFriendlyPlaceStorage.load();
    if (mounted && saved.isNotEmpty)
      setState(() => _places = [...defaultPetFriendlyPlaces, ...saved]);
  }

  Future<void> _requestLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _locationMessage =
            'HA�y bật dịch vụ vị trA� để cập nhật khoảng cA�ch chA�nh xA�c.';
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _locationMessage =
            'Bạn chưa cấp quyền vị trA�; đang hiển thị cA�c cơ sở gần nhất.';
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _locationMessage = 'Da cap nhat vi tri cua ban tren ban do.';
      _currentLocation = LatLng(position.latitude, position.longitude);
    } catch (_) {
      /*
      _currentLocation = LatLng(position.latitude, position.longitude);
          'ĐA� cập nhật vị trA� của bạn (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}).';
    } catch (_) {
      */
      _locationMessage =
          'KhA�ng thể lấy GPS; đang hiển thị cA�c cơ sở gần nhất.';
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  List<BranchLocation> get _branches => branchLocations
      .where(
        (b) =>
            (_filter == null || b.kind == _filter) &&
            (b.name.toLowerCase().contains(_keyword.toLowerCase()) ||
                b.address.toLowerCase().contains(_keyword.toLowerCase())),
      )
      .toList();
  Future<void> _openDirections(String address) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address)}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted)
      _notice('KhA�ng thể mở Google Maps trA�n thiết bị nA�y.');
  }

  Future<void> _call(String phone) async {
    if (!await launchUrl(Uri(scheme: 'tel', path: phone.replaceAll(' ', ''))) &&
        mounted)
      _notice('KhA�ng thể mở ứng dụng gọi điện.');
  }

  void _notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _savePlaces() => PetFriendlyPlaceStorage.save(
    _places
        .where((p) => !defaultPetFriendlyPlaces.any((x) => x.id == p.id))
        .toList(),
  );

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroCard(
          onLocate: _locating ? null : _requestLocation,
          message: _locationMessage,
          locating: _locating,
        ),
        const SizedBox(height: 18),
        _GoogleNearbyMap(
          branches: _branches,
          currentLocation: _currentLocation,
          locating: _locating,
          onLocate: _requestLocation,
          onTap: _showBranch,
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) => setState(() => _keyword = value),
          decoration: const InputDecoration(
            hintText: 'Tìm cửa hàng hoặc địa chỉ...',
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dịch vụ PetHub gần bạn',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'Tất cả',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              ...NearbyKind.values.map(
                (kind) => _FilterChip(
                  label: kind.label,
                  icon: kind.icon,
                  selected: _filter == kind,
                  onTap: () => setState(() => _filter = kind),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ..._branches.map(
          (branch) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _BranchCard(
              branch: branch,
              onTap: () => _showBranch(branch),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pet-friendly Zones',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _showAddPlace,
              icon: const Icon(Icons.add),
              label: const Text('ThA�m địa điểm'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'CA�ng viA�n, quA�n cafA�, bA�i cỏ vA� khu vui chơi thA�n thiện với thA� cưng.',
          style: TextStyle(color: AppColors.textSoft),
        ),
        const SizedBox(height: 12),
        ..._places.map(
          (place) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PlaceCard(
              place: place,
              saved: _savedPlaceIds.contains(place.id),
              onTap: () => _showPlace(place),
            ),
          ),
        ),
      ],
    ),
  );

  void _showBranch(BranchLocation branch) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BranchSheet(
      branch: branch,
      onDirections: () => _openDirections(branch.address),
      onCall: () => _call(branch.phone),
      onBook: () {
        Navigator.pop(context);
        context.push('/services');
      },
    ),
  );
  void _showPlace(PetFriendlyPlace place) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlaceSheet(
      place: place,
      saved: _savedPlaceIds.contains(place.id),
      onDirections: () => _openDirections(place.address),
      onShare: () => SharePlus.instance.share(
        ShareParams(
          title: place.name,
          text: '${place.name}\n${place.address}\n${place.description}',
        ),
      ),
      onToggleSaved: () {
        setState(() {
          _savedPlaceIds.contains(place.id)
              ? _savedPlaceIds.remove(place.id)
              : _savedPlaceIds.add(place.id);
        });
        Navigator.pop(context);
      },
      onReview: (review) async {
        final index = _places.indexWhere((item) => item.id == place.id);
        final reviews = [..._places[index].reviews, review];
        final rating =
            reviews.fold<double>(0, (sum, item) => sum + item.stars) /
            reviews.length;
        setState(
          () => _places[index] = _places[index].copyWith(
            reviews: reviews,
            rating: rating,
          ),
        );
        await _savePlaces();
        if (mounted) _notice('Cảm ơn bạn đA� đA�nh giA� địa điểm.');
      },
    ),
  );
  void _showAddPlace() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddPlaceSheet(
      onSave: (place) async {
        setState(() => _places.add(place));
        await _savePlaces();
        if (mounted) _notice('ĐA� thA�m địa điểm Pet-friendly.');
      },
    ),
  );
}

class _HeroCard extends StatelessWidget {
  final VoidCallback? onLocate;
  final String message;
  final bool locating;
  const _HeroCard({
    required this.onLocate,
    required this.message,
    required this.locating,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(26),
      gradient: const LinearGradient(colors: [AppColors.sky, AppColors.cream]),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.near_me_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Nearby — PetHub gần bạn',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onLocate,
              icon: locating
                  ? const SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
              label: const Text('Vị trA�'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          message,
          style: const TextStyle(color: AppColors.textSoft, height: 1.35),
        ),
      ],
    ),
  );
}

class _GoogleNearbyMap extends StatefulWidget {
  final List<BranchLocation> branches;
  final LatLng? currentLocation;
  final bool locating;
  final VoidCallback onLocate;
  final ValueChanged<BranchLocation> onTap;

  const _GoogleNearbyMap({
    required this.branches,
    required this.currentLocation,
    required this.locating,
    required this.onLocate,
    required this.onTap,
  });

  @override
  State<_GoogleNearbyMap> createState() => _GoogleNearbyMapState();
}

class _GoogleNearbyMapState extends State<_GoogleNearbyMap> {
  static const _hoChiMinhCity = LatLng(10.7769, 106.7009);
  GoogleMapController? _mapController;
  static const _coordinates = <String, LatLng>{
    'PetHub Qu\u1eadn 1': LatLng(10.7731, 106.7041),
    'PetHub B\u00ecnh Th\u1ea1nh': LatLng(10.8018, 106.7102),
    'PetHub Th\u1ee7 \u0110\u1ee9c': LatLng(10.8506, 106.7710),
    'PetHub Qu\u1eadn 7': LatLng(10.7296, 106.7218),
  };

  @override
  void didUpdateWidget(covariant _GoogleNearbyMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocation != oldWidget.currentLocation &&
        widget.currentLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(widget.currentLocation!, 14.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      ...widget.branches.map(
        (branch) => Marker(
          markerId: MarkerId(branch.name),
          position: _coordinates[branch.name]!,
          infoWindow: InfoWindow(title: branch.name, snippet: branch.address),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            branch.kind == NearbyKind.hospital
                ? BitmapDescriptor.hueAzure
                : branch.kind == NearbyKind.spa
                    ? BitmapDescriptor.hueViolet
                    : BitmapDescriptor.hueOrange,
          ),
          onTap: () => widget.onTap(branch),
        ),
      ),
      if (widget.currentLocation != null)
        Marker(
          markerId: const MarkerId('current-location'),
          position: widget.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Vi tri cua ban'),
          zIndex: 2,
        ),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.currentLocation ?? _hoChiMinhCity,
                zoom: 12.5,
              ),
              markers: markers,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
            ),
            Positioned(
              top: 14,
              left: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Ban do PetHub',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 14,
              bottom: 14,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                elevation: 3,
                child: IconButton(
                  tooltip: 'Vi tri cua toi',
                  onPressed: widget.locating ? null : widget.onLocate,
                  icon: widget.locating
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: AppColors.primary,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _OldNearbyMap extends StatelessWidget {
  final List<BranchLocation> branches;
  final ValueChanged<BranchLocation> onTap;
  const _OldNearbyMap({required this.branches, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(
    height: 215,
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5EE),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Stack(
      children: [
        const Center(
          child: Icon(
            Icons.person_pin_circle_rounded,
            size: 62,
            color: AppColors.primary,
          ),
        ),
        ...branches.asMap().entries.map((e) {
          final offsets = [
            const Offset(34, 35),
            const Offset(220, 42),
            const Offset(65, 130),
            const Offset(230, 136),
          ];
          final branch = e.value;
          final offset = offsets[e.key % offsets.length];
          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: InkWell(
              onTap: () => onTap(branch),
              child: Tooltip(
                message: branch.name,
                child: CircleAvatar(
                  backgroundColor: branch.kind.color,
                  child: Icon(branch.kind.icon, color: AppColors.textDark),
                ),
              ),
            ),
          );
        }),
        const Positioned(
          left: 14,
          bottom: 12,
          child: Text(
            'Chọn marker để xem đường đi vA� thời gian di chuyển',
            style: TextStyle(fontSize: 11, color: AppColors.textSoft),
          ),
        ),
      ],
    ),
  );
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 5)],
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _BranchCard extends StatelessWidget {
  final BranchLocation branch;
  final VoidCallback onTap;
  const _BranchCard({required this.branch, required this.onTap});
  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: branch.kind.color,
          child: Icon(branch.kind.icon, color: AppColors.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branch.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                branch.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSoft),
              ),
              const SizedBox(height: 7),
              Text(
                '★ ${branch.rating}   •   ${branch.distance}   •   ${branch.travelTime}',
                style: const TextStyle(color: AppColors.textSoft),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded),
      ],
    ),
  );
}

class _PlaceCard extends StatelessWidget {
  final PetFriendlyPlace place;
  final bool saved;
  final VoidCallback onTap;
  const _PlaceCard({
    required this.place,
    required this.saved,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.peach,
          child: Icon(place.kind.icon, color: AppColors.textDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                place.kind.label,
                style: const TextStyle(color: AppColors.textSoft),
              ),
              const SizedBox(height: 4),
              Text(
                '★ ${place.rating.toStringAsFixed(1)}  •  ${place.openTime}',
                style: const TextStyle(color: AppColors.textSoft),
              ),
            ],
          ),
        ),
        Icon(
          saved ? Icons.favorite_rounded : Icons.chevron_right_rounded,
          color: saved ? Colors.redAccent : AppColors.textSoft,
        ),
      ],
    ),
  );
}

class _BranchSheet extends StatelessWidget {
  final BranchLocation branch;
  final VoidCallback onDirections, onCall, onBook;
  const _BranchSheet({
    required this.branch,
    required this.onDirections,
    required this.onCall,
    required this.onBook,
  });
  @override
  Widget build(BuildContext context) => _Sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetTitle(
          icon: branch.kind.icon,
          color: branch.kind.color,
          title: branch.name,
          subtitle: branch.address,
        ),
        const SizedBox(height: 16),
        _InfoGrid(
          items: [
            ('Khoảng cA�ch', branch.distance),
            ('Di chuyển', branch.travelTime),
            ('Giờ mở cửa', branch.openTime),
            ('Trạng thA�i', 'Đang mở'),
            ('ĐA�nh giA�', '${branch.rating}/5'),
            ('Độ đA�ng', branch.busyness),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          'Dịch vụ đang cA�',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: branch.services.map((x) => Chip(label: Text(x))).toList(),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Chỉ đường'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: onCall,
              icon: const Icon(Icons.call_rounded),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Đặt dịch vụ'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PlaceSheet extends StatelessWidget {
  final PetFriendlyPlace place;
  final bool saved;
  final VoidCallback onDirections, onShare, onToggleSaved;
  final ValueChanged<PlaceReview> onReview;
  const _PlaceSheet({
    required this.place,
    required this.saved,
    required this.onDirections,
    required this.onShare,
    required this.onToggleSaved,
    required this.onReview,
  });
  @override
  Widget build(BuildContext context) => _Sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetTitle(
          icon: place.kind.icon,
          color: AppColors.peach,
          title: place.name,
          subtitle: place.address,
        ),
        const SizedBox(height: 14),
        Text(
          place.description,
          style: const TextStyle(color: AppColors.textSoft, height: 1.35),
        ),
        const SizedBox(height: 14),
        _InfoGrid(
          items: [
            ('Giờ mở cửa', place.openTime),
            ('ĐA�nh giA�', '${place.rating.toStringAsFixed(1)}/5'),
            ('BA�nh luận', '${place.reviews.length}'),
          ],
        ),
        const SizedBox(height: 14),
        if (place.reviews.isNotEmpty) ...[
          const Text(
            'BA�nh luận gần đA�y',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          ...place.reviews
              .take(2)
              .map(
                (r) => Text(
                  '★ ${r.stars}  ${r.author}: ${r.comment}',
                  style: const TextStyle(color: AppColors.textSoft),
                ),
              ),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.directions_rounded),
              label: const Text('Chỉ đường'),
            ),
            OutlinedButton.icon(
              onPressed: onToggleSaved,
              icon: Icon(
                saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              ),
              label: Text(saved ? 'ĐA� lưu' : 'Lưu'),
            ),
            OutlinedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share_rounded),
              label: const Text('Chia sẻ'),
            ),
            FilledButton.icon(
              onPressed: () => _ReviewDialog.show(context, onReview),
              icon: const Icon(Icons.star_rounded),
              label: const Text('ĐA�nh giA�'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Sheet extends StatelessWidget {
  final Widget child;
  const _Sheet({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    decoration: const BoxDecoration(
      color: AppColors.cream,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SafeArea(top: false, child: SingleChildScrollView(child: child)),
  );
}

class _SheetTitle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _SheetTitle({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 27,
        backgroundColor: color,
        child: Icon(icon, color: AppColors.textDark),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(subtitle, style: const TextStyle(color: AppColors.textSoft)),
          ],
        ),
      ),
    ],
  );
}

class _InfoGrid extends StatelessWidget {
  final List<(String, String)> items;
  const _InfoGrid({required this.items});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: items
        .map(
          (x) => Container(
            width: 150,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  x.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSoft,
                  ),
                ),
                Text(
                  x.$2,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

class _ReviewDialog extends StatefulWidget {
  final ValueChanged<PlaceReview> onSave;
  const _ReviewDialog({required this.onSave});
  static void show(BuildContext context, ValueChanged<PlaceReview> onSave) {
    showDialog(
      context: context,
      builder: (_) => _ReviewDialog(onSave: onSave),
    );
  }

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  int _stars = 5;
  final _comment = TextEditingController();
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('��nh gi� d?a di?m'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: () => setState(() => _stars = index + 1),
              icon: Icon(
                index < _stars
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        TextField(
          controller: _comment,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Chia s? tr?i nghi?m c?a b?n...',
          ),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('H?y'),
      ),
      FilledButton(
        onPressed: () {
          widget.onSave(
            PlaceReview(stars: _stars, comment: _comment.text.trim()),
          );
          Navigator.pop(context);
        },
        child: const Text('G?i'),
      ),
    ],
  );
}

class _AddPlaceSheet extends StatefulWidget {
  final ValueChanged<PetFriendlyPlace> onSave;
  const _AddPlaceSheet({required this.onSave});
  @override
  State<_AddPlaceSheet> createState() => _AddPlaceSheetState();
}

class _AddPlaceSheetState extends State<_AddPlaceSheet> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _address = TextEditingController(),
      _description = TextEditingController(),
      _image = TextEditingController();
  PetFriendlyKind _kind = PetFriendlyKind.park;
  bool _gettingGps = false;
  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _description.dispose();
    _image.dispose();
    super.dispose();
  }

  Future<void> _gps() async {
    setState(() => _gettingGps = true);
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied)
        p = await Geolocator.requestPermission();
      if (p != LocationPermission.denied &&
          p != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        _address.text =
            'Vị trA� GPS: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}';
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _gettingGps = false);
    }
  }

  @override
  Widget build(BuildContext context) => _Sheet(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ThA�m địa điểm Pet-friendly',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 14),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'TA�n địa điểm'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lA�ng nhập tA�n địa điểm'
                    : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _kind,
                decoration: const InputDecoration(labelText: 'Loại địa điểm'),
                items: PetFriendlyKind.values
                    .map(
                      (x) => DropdownMenuItem(value: x, child: Text(x.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _kind = v!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(
                  labelText: 'Địa chỉ',
                  suffixIcon: IconButton(
                    onPressed: _gettingGps ? null : _gps,
                    icon: _gettingGps
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Nhập địa chỉ hoặc lấy GPS'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _description,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'MA� tả'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(
                  labelText: 'HA�nh ảnh (đường dẫn/URL, khA�ng bắt buộc)',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (!_form.currentState!.validate()) return;
                    widget.onSave(
                      PetFriendlyPlace(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: _name.text.trim(),
                        kind: _kind,
                        address: _address.text.trim(),
                        description: _description.text.trim(),
                        openTime: 'Chưa cập nhật',
                        imageUrl: _image.text.trim(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('XA�c nhận thA�m địa điểm'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
