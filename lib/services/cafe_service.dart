import 'package:supabase_flutter/supabase_flutter.dart';

class CafeService {
  final _db = Supabase.instance.client;

  Future<List> getCafes() async {
    return await _db.from('cafes').select();
  }

  Future createCafe(String name, double lat, double lng) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _db.from('cafes').insert({
      'name': name,
      'lat': lat,
      'lng': lng,
      'user_id': userId,
    });
  }

  Future updateCafe(String id, String name) async {
    await _db.from('cafes').update({'name': name}).eq('id', id);
  }

  Future deleteCafe(String id) async {
    await _db.from('cafes').delete().eq('id', id);
  }
}
