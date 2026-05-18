import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageCacheHelper{
  ImageCacheHelper._internal();
  static final ImageCacheHelper _instance= ImageCacheHelper._internal();

  factory ImageCacheHelper() => _instance; //returns existing singleton

  // directory for storing images
  Directory? imageDirectory;

  // initialize directory if doesn't exists
  Future<void> init() async {
    final appDir= await getApplicationDocumentsDirectory();
    final dir= Directory('${appDir.path}/vehicle_images');
    if(! await dir.exists()){
      await dir.create(recursive: true);
    }
    imageDirectory= dir;
  }

  // Copy user photo to permanent storage
  Future<String?> saveImage(String? sourcePath, int vehicleId) async {
    if(sourcePath == null || sourcePath.isEmpty) return null;

    try{
      await init();
      final sourceFile= File(sourcePath);
      if(! await sourceFile.exists()) return null;

      final extension= path.extension(sourcePath);
      final fileName= 'vehicle_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final destinationPath= '${imageDirectory!.path}/$fileName';

      await sourceFile.copy(destinationPath);
      return destinationPath;
    }catch(e){
      print('Failed to save image to cache directory: $e');
      return null;
    }
  }

  //Download from URL + save permanently
  Future<String?> downloadAndSaveImage(String url, int vehicleId) async {
    try {
      await init();
      final extension= path.extension(url);
      final fileName= 'vehicle_${vehicleId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final localPath= '${imageDirectory!.path}/$fileName}';

      final response= await http.get(Uri.parse(url));

      if(response.statusCode == 200){
        final file= File(localPath);  //Creates a reference to a file at your custom path, it doesnot create a file yet.
        await file.writeAsBytes(response.bodyBytes);  //Physically writes those bytes(raw binary data of the image) to disk
        return localPath;
      }
    }catch(e){
      print('Failed to download image: $e');
      return null;
    }
  }

  // Check if local file exists
  Future<bool> localImageExists(String? path) async {
    if (path == null || path.isEmpty) return false;
    try {
      final file = File(path);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Delete image file
  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print('Image deleted: $path');
      }
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  // Get all local images
  Future<List<File>> getAllLocalImages() async{
    await init();
    final files = await imageDirectory!.list().toList();
    return files.whereType<File>().toList();
  }

  // Cleat all images
  Future<void> clearAllImages() async{
    await init();
    final files= await imageDirectory!.list().toList();
    for(final file in files){
      await file.delete();
    }
    print('All images cleared.');
  }

}