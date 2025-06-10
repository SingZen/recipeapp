// lib/services/recipe_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recipeapp/db/recipe_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeService {
  static Future<void> initRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('recipes_initialized') ?? false;

    if (!isInitialized) {
      final db = await RecipeDatabase.getDatabase();

      final response = await http.get(
        Uri.parse('https://dummyjson.com/recipes'),
      );
      final data = jsonDecode(response.body);

      for (var json in data['recipes']) {
        await db.insert('recipes', {
          'id': json['id'],
          'name': json['name'],
          'ingredients': (json['ingredients'] as List).join('|'),
          'instructions': (json['instructions'] as List).join('|'),
          'prepTimeMinutes': json['prepTimeMinutes'],
          'cookTimeMinutes': json['cookTimeMinutes'],
          'servings': json['servings'],
          'difficulty': json['difficulty'],
          'cuisine': json['cuisine'],
          'caloriesPerServing': json['caloriesPerServing'],
          'tags': (json['tags'] as List).join('|'),
          'userId': json['userId'],
          'image': json['image'],
          'rating': json['rating'],
          'reviewCount': json['reviewCount'],
          'mealType': (json['mealType'] as List).join('|'),
        });
      }

      await prefs.setBool('recipes_initialized', true);
    }
  }

  static Future<void> refreshFromApi() async {
    final url = Uri.parse('https://dummyjson.com/recipes');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> recipes = data['recipes'];

      final db = await RecipeDatabase.getDatabase();

      // Clear old data
      await db.delete('recipes');

      // Insert new data
      for (var r in recipes) {
        await db.insert('recipes', {
          'id': r['id'],
          'name': r['name'],
          'ingredients': (r['ingredients'] as List).join('|'),
          'instructions': (r['instructions'] as List).join('|'),
          'prepTimeMinutes': r['prepTimeMinutes'],
          'cookTimeMinutes': r['cookTimeMinutes'],
          'servings': r['servings'],
          'difficulty': r['difficulty'],
          'cuisine': r['cuisine'],
          'caloriesPerServing': r['caloriesPerServing'],
          'tags': (r['tags'] as List).join('|'),
          'userId': r['userId'],
          'image': r['image'],
          'rating': r['rating'],
          'reviewCount': r['reviewCount'],
          'mealType': (r['mealType'] as List).join(', '),
        });
      }
    } else {
      throw Exception('Failed to fetch recipes from API');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await RecipeDatabase.getDatabase();
    return await db.query('recipes');
  }

  static Future<List<String>> getAllCuisines() async {
    final db = await RecipeDatabase.getDatabase();
    final result = await db.rawQuery('SELECT DISTINCT cuisine FROM recipes');
    return result.map((row) => row['cuisine'].toString()).toList();
  }

  static Future<int> insertRecipe(Map<String, dynamic> recipe) async {
    final db = await RecipeDatabase.getDatabase();
    return await db.insert('recipes', recipe);
  }

  static Future<int> updateRecipe(int id, Map<String, dynamic> recipe) async {
    final db = await RecipeDatabase.getDatabase();
    return await db.update('recipes', recipe, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteRecipe(int id) async {
    final db = await RecipeDatabase.getDatabase();
    return await db.delete('recipes', where: 'id = ?', whereArgs: [id]);
  }
}
