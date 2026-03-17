// test/features/pos/data/repositories/favorites_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_pos/features/pos/data/repositories/favorites_repository.dart';

void main() {
  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });

  test('FavoritesRepository: add and retrieve favorite product IDs', () async {
    final repo = FavoritesRepository();

    await repo.addFavorite('product_1');
    await repo.addFavorite('product_2');

    final favorites = await repo.getFavorites();
    expect(favorites, contains('product_1'));
    expect(favorites, contains('product_2'));
    expect(favorites.length, 2);
  });

  test('FavoritesRepository: remove favorite', () async {
    final repo = FavoritesRepository();

    await repo.addFavorite('product_1');
    expect(await repo.isFavorite('product_1'), true);

    await repo.removeFavorite('product_1');
    expect(await repo.isFavorite('product_1'), false);
  });

  test('FavoritesRepository: toggle favorite', () async {
    final repo = FavoritesRepository();

    expect(await repo.toggleFavorite('product_1'), true); // Added
    expect(await repo.toggleFavorite('product_1'), false); // Removed
  });
}
