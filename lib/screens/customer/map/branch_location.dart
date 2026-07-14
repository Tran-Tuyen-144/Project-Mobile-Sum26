import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

enum NearbyKind {
  cafe('Pet Caf\u00e9', Icons.local_cafe_rounded, AppColors.mint),
  spa('Pet Spa', Icons.spa_rounded, AppColors.lavender),
  hospital('Pet Hospital', Icons.local_hospital_rounded, AppColors.sky);

  final String label;
  final IconData icon;
  final Color color;
  const NearbyKind(this.label, this.icon, this.color);
}

class BranchLocation {
  final String name, address, distance, travelTime, openTime, phone, busyness;
  final NearbyKind kind;
  final double rating;
  final List<String> services;
  const BranchLocation({
    required this.name,
    required this.kind,
    required this.address,
    required this.distance,
    required this.travelTime,
    required this.openTime,
    required this.phone,
    required this.rating,
    required this.busyness,
    required this.services,
  });
}

const branchLocations = <BranchLocation>[
  BranchLocation(
    name: 'PetHub Qu\u1eadn 1',
    kind: NearbyKind.cafe,
    address: '12 Nguy\u1ec5n Hu\u1ec7, Qu\u1eadn 1, TP. H\u1ed3 Ch\u00ed Minh',
    distance: '1.2 km',
    travelTime: '6 ph\u00fat',
    openTime: '08:00 - 22:00',
    phone: '028 3822 0915',
    rating: 4.8,
    busyness: '\u0110\u00f4ng v\u1eeba',
    services: ['Pet Caf\u00e9', '\u0110\u1eb7t b\u00e0n', 'Khu vui ch\u01a1i'],
  ),
  BranchLocation(
    name: 'PetHub B\u00ecnh Th\u1ea1nh',
    kind: NearbyKind.hospital,
    address:
        '45 X\u00f4 Vi\u1ebft Ngh\u1ec7 T\u0129nh, B\u00ecnh Th\u1ea1nh, TP. H\u1ed3 Ch\u00ed Minh',
    distance: '2.8 km',
    travelTime: '12 ph\u00fat',
    openTime: '08:00 - 21:30',
    phone: '028 3899 1920',
    rating: 4.7,
    busyness: '\u00cdt kh\u00e1ch',
    services: [
      'Kh\u00e1m th\u00fa y',
      'Ti\u00eam ph\u00f2ng',
      'X\u00e9t nghi\u1ec7m',
    ],
  ),
  BranchLocation(
    name: 'PetHub Th\u1ee7 \u0110\u1ee9c',
    kind: NearbyKind.spa,
    address:
        '88 V\u00f5 V\u0103n Ng\u00e2n, Th\u1ee7 \u0110\u1ee9c, TP. H\u1ed3 Ch\u00ed Minh',
    distance: '5.4 km',
    travelTime: '19 ph\u00fat',
    openTime: '08:30 - 21:00',
    phone: '028 3722 3308',
    rating: 4.6,
    busyness: '\u0110\u00f4ng kh\u00e1ch',
    services: [
      'T\u1eafm spa',
      'C\u1eaft t\u1ec9a',
      'L\u01b0u tr\u00fa th\u00fa c\u01b0ng',
    ],
  ),
  BranchLocation(
    name: 'PetHub Qu\u1eadn 7',
    kind: NearbyKind.cafe,
    address:
        '20 Nguy\u1ec5n Th\u1ecb Th\u1eadp, Qu\u1eadn 7, TP. H\u1ed3 Ch\u00ed Minh',
    distance: '6.1 km',
    travelTime: '23 ph\u00fat',
    openTime: '09:00 - 22:00',
    phone: '028 3777 5001',
    rating: 4.5,
    busyness: '\u0110\u00f4ng v\u1eeba',
    services: ['Pet Caf\u00e9', '\u0110\u1eb7t ti\u1ec7c', 'Khu vui ch\u01a1i'],
  ),
];

enum PetFriendlyKind {
  park('C\u00f4ng vi\u00ean', Icons.park_rounded),
  cafe('Caf\u00e9 th\u00fa c\u01b0ng', Icons.local_cafe_rounded),
  lawn('B\u00e3i c\u1ecf', Icons.grass_rounded),
  walk('\u0110i d\u1ea1o', Icons.directions_walk_rounded),
  playground('Khu vui ch\u01a1i', Icons.toys_rounded);

  final String label;
  final IconData icon;
  const PetFriendlyKind(this.label, this.icon);
}

class PlaceReview {
  final int stars;
  final String comment, author;
  const PlaceReview({
    required this.stars,
    required this.comment,
    this.author = 'B\u1ea1n',
  });
  Map<String, dynamic> toJson() => {
    'stars': stars,
    'comment': comment,
    'author': author,
  };
  factory PlaceReview.fromJson(Map<String, dynamic> j) => PlaceReview(
    stars: (j['stars'] as num?)?.toInt() ?? 5,
    comment: j['comment'] as String? ?? '',
    author: j['author'] as String? ?? 'B\u1ea1n',
  );
}

class PetFriendlyPlace {
  final String id, name, address, description, openTime, imageUrl;
  final PetFriendlyKind kind;
  final double rating;
  final List<PlaceReview> reviews;
  const PetFriendlyPlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.address,
    required this.description,
    required this.openTime,
    this.imageUrl = '',
    this.rating = 0,
    this.reviews = const [],
  });
  PetFriendlyPlace copyWith({double? rating, List<PlaceReview>? reviews}) =>
      PetFriendlyPlace(
        id: id,
        name: name,
        kind: kind,
        address: address,
        description: description,
        openTime: openTime,
        imageUrl: imageUrl,
        rating: rating ?? this.rating,
        reviews: reviews ?? this.reviews,
      );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'kind': kind.name,
    'address': address,
    'description': description,
    'openTime': openTime,
    'imageUrl': imageUrl,
    'rating': rating,
    'reviews': reviews.map((x) => x.toJson()).toList(),
  };
  factory PetFriendlyPlace.fromJson(Map<String, dynamic> j) => PetFriendlyPlace(
    id: j['id'] as String? ?? '',
    name: j['name'] as String? ?? '',
    kind: PetFriendlyKind.values.firstWhere(
      (x) => x.name == j['kind'],
      orElse: () => PetFriendlyKind.park,
    ),
    address: j['address'] as String? ?? '',
    description: j['description'] as String? ?? '',
    openTime: j['openTime'] as String? ?? 'C\u1ea3 ng\u00e0y',
    imageUrl: j['imageUrl'] as String? ?? '',
    rating: (j['rating'] as num?)?.toDouble() ?? 0,
    reviews: ((j['reviews'] as List?) ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PlaceReview.fromJson)
        .toList(),
  );
}

const defaultPetFriendlyPlaces = <PetFriendlyPlace>[
  PetFriendlyPlace(
    id: 'tao-dan',
    name: 'C\u00f4ng vi\u00ean Tao \u0110\u00e0n',
    kind: PetFriendlyKind.park,
    address: '55C Nguy\u1ec5n Th\u1ecb Minh Khai, Qu\u1eadn 1',
    description:
        'Kh\u00f4ng gian xanh, ph\u00f9 h\u1ee3p d\u1eaft th\u00fa c\u01b0ng \u0111i d\u1ea1o v\u00e0o s\u00e1ng s\u1edbm.',
    openTime: '05:00 - 22:00',
    rating: 4.6,
    reviews: [
      PlaceReview(
        stars: 5,
        comment: 'R\u1ed9ng r\u00e3i v\u00e0 nhi\u1ec1u b\u00f3ng m\u00e1t.',
        author: 'Minh Anh',
      ),
    ],
  ),
  PetFriendlyPlace(
    id: 'paws-beans',
    name: 'Paws & Beans',
    kind: PetFriendlyKind.cafe,
    address: '18 L\u00ea V\u0103n S\u1ef9, Ph\u00fa Nhu\u1eadn',
    description:
        'Caf\u00e9 th\u00e2n thi\u1ec7n v\u1edbi th\u00fa c\u01b0ng, c\u00f3 n\u01b0\u1edbc u\u1ed1ng v\u00e0 g\u00f3c vui ch\u01a1i.',
    openTime: '08:00 - 21:30',
    rating: 4.7,
  ),
];

extension BranchLocationLegacyFields on BranchLocation {
  String get category => kind.label;
  IconData get icon => kind.icon;
  Color get color => kind.color;
}

const List<String> branchCategories = [
  'T\u1ea5t c\u1ea3',
  'Pet Caf\u00e9',
  'Pet Spa',
  'Pet Hospital',
];
