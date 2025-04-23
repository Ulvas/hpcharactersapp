import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HouseDetailsScreen extends StatefulWidget {
  final String house;

  const HouseDetailsScreen({super.key, required this.house});

  @override
  _HouseDetailsScreenState createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  late Future<List<dynamic>> characters;
  final dio = Dio();
  bool _isCardOpen = false;
  Map<String, dynamic>? _selectedCharacter;

  @override
  void initState() {
    super.initState();
    characters = fetchCharactersByHouse(widget.house);
  }

  Future<List<dynamic>> fetchCharactersByHouse(String house) async {
    try {
      final response = await dio.get('https://hp-api.onrender.com/api/characters');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List<dynamic>;

        return data.where((character) {
          final charHouse = character['house'] ?? '';
          if (house == 'Others') {
            return charHouse.isEmpty;
          } else {
            return charHouse == house;
          }
        }).toList();
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      throw Exception('Failed to load characters: $e');
    }
  }

  Widget buildCharacterImage(String? imageUrl, String? gender) {
    String placeholderPath;

    if (gender == 'female') {
      placeholderPath = 'assets/images/femalePH.jpg';
    } else {
      placeholderPath = 'assets/images/malePH.jpg';
    }

    const double imageSize = 90;

    Widget imageWidget;

    if (imageUrl != null && imageUrl.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            placeholderPath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        placeholderPath,
        width: imageSize,
        height: imageSize,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageWidget,
    );
  }

  void _openCharacterCard(Map<String, dynamic> character) {
    setState(() {
      _isCardOpen = true;
      _selectedCharacter = character;
    });
  }

  void _closeCharacterCard() {
    setState(() {
      _isCardOpen = false;
      _selectedCharacter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/houses/${widget.house}BG.png',
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/houses/${widget.house}.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder<List<dynamic>>(
              future: characters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final characters = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: characters.length,
                    itemBuilder: (context, index) {
                      final character = characters[index];
                      final name = character['name'] ?? 'Unknown';
                      final imageUrl = character['image'];
                      final gender = character['gender'];
                      final house = character['house'];

                      return GestureDetector(
                        onTap: () => _openCharacterCard(character),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: house != null && house.isNotEmpty
                                ? DecorationImage(
                              image: AssetImage('assets/houses/${house}BG.png'),
                              fit: BoxFit.cover,
                            )
                                : null,
                            color: house == null || house.isEmpty
                                ? Colors.grey[300]
                                : null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildCharacterImage(imageUrl, gender),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_isCardOpen && _selectedCharacter != null) ...[
            GestureDetector(
              onTap: _closeCharacterCard,
              child: Container(
                color: Colors.black.withOpacity(0.6),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: Material(
                color: Colors.white,
                elevation: 5,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/houses/${_selectedCharacter?['house']}BG.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            const SizedBox(height: 16),
                            buildCharacterImage(
                                _selectedCharacter?['image'], _selectedCharacter?['gender']),
                            const SizedBox(height: 16),
                            Text(
                              _selectedCharacter?['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'House: ${_selectedCharacter?['house'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Actor: ${_selectedCharacter?['actor'] ?? 'Unknown'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Patronus: ${_selectedCharacter?['patronus'] ?? 'None'}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
