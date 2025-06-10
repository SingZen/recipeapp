import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:recipeapp/core/services/recipe_service.dart';

class AddEditRecipePage extends StatefulWidget {
  final Map<String, dynamic>? recipe;

  const AddEditRecipePage({super.key, this.recipe});

  @override
  State<AddEditRecipePage> createState() => _AddEditRecipePageState();
}

class _AddEditRecipePageState extends State<AddEditRecipePage> {
  String? _localImagePath;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!['name'] ?? '';
      _cuisineController.text = widget.recipe!['cuisine'] ?? '';
      _ingredientsController.text = widget.recipe!['ingredients'] ?? '';
      _instructionsController.text = widget.recipe!['instructions'] ?? '';
      _localImagePath = widget.recipe!['image'] ?? '';
    }
  }

  Future<String?> pickAndConvertImageToWebP() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final webpBytes = await compressToWebP(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}.webp';
    final savedPath = path.join(appDir.path, fileName);

    final file = File(savedPath);
    await file.writeAsBytes(webpBytes);
    return savedPath;
  }

  Future<Uint8List> compressToWebP(Uint8List inputBytes) async {
    final result = await FlutterImageCompress.compressWithList(
      inputBytes,
      minHeight: 1080,
      minWidth: 1080,
      quality: 90,
      format: CompressFormat.webp,
    );
    print("Original: ${inputBytes.length}, Compressed: ${result.length}");
    return result;
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final newRecipe = {
      'name': _nameController.text,
      'cuisine': _cuisineController.text,
      'image': _localImagePath,
      'ingredients': _ingredientsController.text,
      'instructions': _instructionsController.text,
      'prepTimeMinutes': 30,
      'cookTimeMinutes': 60,
      'servings': 5,
      'difficulty': 'Easy',
      'caloriesPerServing': 200,
      'tags': 'Food|Main course',
      'userId': 1,
      'rating': 4.0,
      'reviewCount': 50,
      'mealType': 'Breakfast',
    };

    if (widget.recipe != null) {
      // EDIT
      await RecipeService.updateRecipe(widget.recipe!['id'], newRecipe);
    } else {
      // ADD
      await RecipeService.insertRecipe(newRecipe);
    }

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Recipe' : 'Add Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _cuisineController,
                decoration: InputDecoration(labelText: 'Cuisine'),
              ),
              TextButton.icon(
                icon: Icon(Icons.image),
                label: Text(
                  _localImagePath == null ? 'Pick Image' : 'Change Image',
                ),
                onPressed: () async {
                  final path = await pickAndConvertImageToWebP();
                  if (path != null) {
                    setState(() => _localImagePath = path);
                  }
                },
              ),
              if (_localImagePath != null)
                _localImagePath!.startsWith('http')
                    ? Image.network(
                        _localImagePath!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_localImagePath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Ingredients (| separated)',
                ),
              ),
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instructions (| separated)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
