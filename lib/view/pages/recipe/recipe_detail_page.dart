import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recipeapp/core/services/recipe_service.dart';
import 'package:recipeapp/view/pages/recipe/add_edit_recipe_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditRecipePage(recipe: recipe),
                ),
              );
              if (updated == true) {
                Navigator.pop(context, 'deleted');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Delete Recipe'),
                  content: Text('Are you sure you want to delete this recipe?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await RecipeService.deleteRecipe(recipe['id']);
                Navigator.pop(context, 'deleted');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            recipe['image'].startsWith('http')
                ? Image.network(
                    recipe['image'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(recipe['image']),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 16),
            Text(
              'Cuisine: ${recipe['cuisine']}',
              style: TextStyle(fontSize: 16),
            ),
            Text('Difficulty: ${recipe['difficulty']}'),
            Text('Servings: ${recipe['servings']}'),
            Text('Prep Time: ${recipe['prepTimeMinutes']} min'),
            Text('Cook Time: ${recipe['cookTimeMinutes']} min'),
            Text('Calories: ${recipe['caloriesPerServing']}'),
            Text(
              'Rating: ${recipe['rating']} (${recipe['reviewCount']} reviews)',
            ),
            const SizedBox(height: 16),
            Text(
              'Tags: ${(recipe['tags'] as String?)?.split('|').join(', ') ?? ''}',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredients:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(recipe['ingredients'] as String)
                    .split('|')
                    .asMap()
                    .entries
                    .map((entry) => Text('${entry.key + 1}. ${entry.value}')),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...(recipe['instructions'] as String)
                    .split('|')
                    .asMap()
                    .entries
                    .map((entry) => Text('${entry.key + 1}. ${entry.value}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
