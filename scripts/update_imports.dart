import 'dart:io';

/// A utility script to update imports in files after moving them to the new directory structure.
/// 
/// Usage: dart scripts/update_imports.dart <file_path>
/// Example: dart scripts/update_imports.dart lib/widgets/expense/new_expense_widget.dart
void main(List<String> args) async {
  if (args.isEmpty) {
    print('Please provide a file path to update imports.');
    print('Usage: dart scripts/update_imports.dart <file_path>');
    return;
  }

  final filePath = args[0];
  final file = File(filePath);
  
  if (!await file.exists()) {
    print('File not found: $filePath');
    return;
  }
  
  await updateImports(filePath);
  print('Imports updated successfully in $filePath');
}

Future<void> updateImports(String filePath) async {
  final file = File(filePath);
  final content = await file.readAsString();
  
  // Determine the directory depth
  final pathSegments = filePath.split('/');
  final widgetsIndex = pathSegments.indexOf('widgets');
  
  if (widgetsIndex == -1 || widgetsIndex == pathSegments.length - 1) {
    print('File is not in a widgets subdirectory.');
    return;
  }
  
  // Calculate the relative path prefix
  final subdirectoryDepth = pathSegments.length - widgetsIndex - 1;
  final prefix = '../' * (subdirectoryDepth - 1);
  final rootPrefix = '../' * subdirectoryDepth;
  
  // Update import paths
  var updatedContent = content
    // Update model imports
    .replaceAll("import '../models/", "import '$rootPrefix../models/")
    // Update repository imports
    .replaceAll("import '../repositories/", "import '$rootPrefix../repositories/")
    // Update utils imports
    .replaceAll("import '../utils/", "import '$rootPrefix../utils/")
    // Update theme imports
    .replaceAll("import '../theme/", "import '$rootPrefix../theme/")
    // Update services imports
    .replaceAll("import '../services/", "import '$rootPrefix../services/")
    // Update database imports
    .replaceAll("import '../database/", "import '$rootPrefix../database/")
    // Update screens imports
    .replaceAll("import '../screens/", "import '$rootPrefix../screens/")
    // Update widgets imports that should now be relative to the subdirectory
    .replaceAll("import '../widgets/", "import '$prefix");
  
  // Write the updated content back to the file
  await file.writeAsString(updatedContent);
} 