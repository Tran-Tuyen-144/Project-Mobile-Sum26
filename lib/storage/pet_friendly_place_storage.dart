import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/customer/map/branch_location.dart';

class PetFriendlyPlaceStorage {
  static const _key = 'pet_friendly_places';
  static Future<List<PetFriendlyPlace>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? [])
        .map((value) {
          try {
            return PetFriendlyPlace.fromJson(
              jsonDecode(value) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<PetFriendlyPlace>()
        .toList();
  }

  static Future<void> save(List<PetFriendlyPlace> places) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      places.map((place) => jsonEncode(place.toJson())).toList(),
    );
  }
}
