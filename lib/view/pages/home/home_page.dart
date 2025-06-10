import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recipeapp/core/services/recipe_service.dart';
import 'package:recipeapp/view/pages/profile/profile_page.dart';
import 'package:recipeapp/view/pages/recipe/add_edit_recipe_page.dart';
import 'package:recipeapp/view/pages/recipe/recipe_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  List<String> _cuisines = ['All'];
  List<String> _mealTypes = ['All'];
  String _selectedCuisine = 'All';
  String _selectedMealType = 'All';
  String _sortBy = 'Name';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCuisinesAndRecipes();
  }

  Future<void> _loadCuisinesAndRecipes() async {
    final allRecipes = await RecipeService.getAllRecipes();

    final cuisines = allRecipes
        .map((r) => r['cuisine'] as String)
        .toSet()
        .toList();
    final mealTypes = allRecipes
        .expand((r) => (r['mealType'] as String).split(', '))
        .toSet()
        .toList();

    cuisines.sort();
    mealTypes.sort();

    setState(() {
      _cuisines = ['All', ...cuisines];
      _mealTypes = ['All', ...mealTypes];
      _recipes = allRecipes;
      _filteredRecipes = _applyFiltersAndSorting(allRecipes);
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _applyFiltersAndSorting(
    List<Map<String, dynamic>> recipes,
  ) {
    var filtered = recipes.where((r) {
      final matchCuisine =
          _selectedCuisine == 'All' || r['cuisine'] == _selectedCuisine;
      final matchMeal =
          _selectedMealType == 'All' ||
          (r['mealType'] as String).contains(_selectedMealType);
      return matchCuisine && matchMeal;
    }).toList();

    if (_sortBy == 'Name') {
      filtered.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_sortBy == 'Rating') {
      filtered.sort(
        (b, a) => (a['rating'] as num).compareTo(b['rating'] as num),
      );
    }

    return filtered;
  }

  void _onFilterChanged() {
    setState(() {
      _filteredRecipes = _applyFiltersAndSorting(_recipes);
    });
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, width: 60, height: 60, fit: BoxFit.cover);
    } else {
      return Image.file(
        File(imagePath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Refresh Recipe'),
                  content: Text('This will refresh the recipe list from API'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                setState(() => _isLoading = true);
                await RecipeService.refreshFromApi();
                await _loadCuisinesAndRecipes();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 12,
                    children: [
                      DropdownButton<String>(
                        value: _selectedCuisine,
                        onChanged: (val) {
                          setState(() => _selectedCuisine = val!);
                          _onFilterChanged();
                        },
                        items: _cuisines
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                      ),
                      DropdownButton<String>(
                        value: _selectedMealType,
                        onChanged: (val) {
                          setState(() => _selectedMealType = val!);
                          _onFilterChanged();
                        },
                        items: _mealTypes
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                      ),
                      DropdownButton<String>(
                        value: _sortBy,
                        onChanged: (val) {
                          setState(() => _sortBy = val!);
                          _onFilterChanged();
                        },
                        items: ['Name', 'Rating']
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text('Sort by $s'),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: _buildImage(recipe['image']),
                          title: Text(recipe['name']),
                          subtitle: Text(
                            'Cuisine: ${recipe['cuisine']} | Rating: ${recipe['rating']}',
                          ),
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RecipeDetailPage(recipe: recipe),
                              ),
                            );

                            if (result == 'deleted') {
                              _loadCuisinesAndRecipes(); // reload the list after deletion
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddEditRecipePage()),
          );
          if (result == true) _loadCuisinesAndRecipes(); // refresh
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
