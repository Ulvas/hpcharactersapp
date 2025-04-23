import 'package:dio/dio.dart';

class CharacterApiService {
  final Dio _dio = Dio();

  Future<List<Map<String, dynamic>>> fetchCharacters(String house) async {
    try {
      final response = await _dio.get('https://hp-api.onrender.com/api/characters/house/$house');

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> characters = [];
        for (var character in response.data) {
          characters.add({
            'name': character['name'],
            'gender': character['gender'],
            'house': character['house'],
            'image': character['image'] ?? '',
            'dateOfBirth': character['dateOfBirth'],
            'actor': character['actor'],
            'patronus': character['patronus'],
            'alive': character['alive'],
            'wizard': character['wizard'],
          });
        }
        return characters;
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }
}
