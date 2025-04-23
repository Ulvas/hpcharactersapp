import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class HouseDetailsScreen extends StatefulWidget {
  final String house;

  const HouseDetailsScreen({super.key, required this.house});

  @override
  State<HouseDetailsScreen> createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  late Future<List<dynamic>> characters;
  final dio = Dio();
  bool isCardOpen = false;
  Map<String, dynamic>? selectedCharacter;

  @override
  void initState() {
    super.initState();
    characters = fetchCharacters(widget.house);
  }

  Future<List<dynamic>> fetchCharacters(String house) async {
    try {
      final res = await dio.get('https://hp-api.onrender.com/api/characters');
      if (res.statusCode == 200) {
        final all = res.data as List<dynamic>;
        return all.where((char) {
          final h = char['house'] ?? '';
          return house == 'Others' ? h.isEmpty : h == house;
        }).toList();
      } else {
        throw Exception('Request failed');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }

  Widget buildImage(String? url, String? gender) {
    final fallback = gender == 'female'
        ? 'assets/images/femalePH.jpg'
        : 'assets/images/malePH.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url != null && url.isNotEmpty
          ? Image.network(
        url,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => Image.asset(
          fallback,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
        ),
      )
          : Image.asset(
        fallback,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }

  void openCard(Map<String, dynamic> char) {
    setState(() {
      selectedCharacter = char;
      isCardOpen = true;
    });
  }

  void closeCard() {
    setState(() {
      isCardOpen = false;
      selectedCharacter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgPath = 'assets/houses/${widget.house}BG.png';
    final logoPath = 'assets/houses/${widget.house}.png';

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(bgPath, height: 120, fit: BoxFit.cover),
          ),
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Center(child: Image.asset(logoPath, height: 60)),
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

                final items = snapshot.data ?? [];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final c = items[i];
                      final house = c['house'] ?? '';
                      return GestureDetector(
                        onTap: () => openCard(c),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: house.isNotEmpty
                                ? DecorationImage(
                              image: AssetImage('assets/houses/${house}BG.png'),
                              fit: BoxFit.cover,
                            )
                                : null,
                            color: house.isEmpty ? Colors.grey[300] : null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withOpacity(0.5),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildImage(c['image'], c['gender']),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: Text(
                                    c['name'] ?? 'Unknown',
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
          if (isCardOpen && selectedCharacter != null)
            ...[
              GestureDetector(
                onTap: closeCard,
                child: Container(
                  color: Colors.black54,
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
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/houses/${selectedCharacter!['house']}BG.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              buildImage(
                                  selectedCharacter!['image'], selectedCharacter!['gender']),
                              const SizedBox(height: 16),
                              Text(
                                selectedCharacter!['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'House: ${selectedCharacter!['house'] ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Actor: ${selectedCharacter!['actor'] ?? 'Unknown'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Patronus: ${selectedCharacter!['patronus'] ?? 'None'}',
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
