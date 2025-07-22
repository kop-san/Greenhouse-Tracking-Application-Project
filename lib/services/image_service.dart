import 'dart:io';
import 'dart:developer' as developer;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../config/app_config.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService;
  final AuthService _authService;

  ImageService({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        developer.log('No image selected', name: 'ImageService');
        return null;
      }

      developer.log('Image picked successfully: ${pickedFile.path}',
          name: 'ImageService');
      return File(pickedFile.path);
    } catch (e) {
      developer.log('Error picking image: $e', name: 'ImageService', error: e);
      return null;
    }
  }

  Future<String?> uploadImage({
    required File imageFile,
    required String endpoint,
    required Map<String, String> fields,
    required String token,
  }) async {
    try {
      var uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      developer.log('Uploading image to: $uri', name: 'ImageService');

      var request = http.MultipartRequest('POST', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Add other fields
      request.fields.addAll(fields);
      developer.log('Request fields: ${request.fields}', name: 'ImageService');

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        developer.log('Image uploaded successfully', name: 'ImageService');
        return responseData;
      } else if (response.statusCode == 401) {
        // Try to refresh the token
        developer.log('Token expired, attempting to refresh...',
            name: 'ImageService');

        // Use AuthService to refresh token
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          final newToken = await _apiService.getToken();
          if (newToken != null) {
            // Retry the upload with the new token
            request = http.MultipartRequest('POST', uri);
            request.headers['Authorization'] = 'Bearer $newToken';

            // Create a new multipart file since the old one was consumed
            stream = http.ByteStream(imageFile.openRead());
            length = await imageFile.length();
            multipartFile = http.MultipartFile(
              'image',
              stream,
              length,
              filename: path.basename(imageFile.path),
            );
            request.files.add(multipartFile);
            request.fields.addAll(fields);

            response = await request.send();
            responseData = await response.stream.bytesToString();

            if (response.statusCode == 201 || response.statusCode == 200) {
              developer.log('Image uploaded successfully after token refresh',
                  name: 'ImageService');
              return responseData;
            }
          }
        }

        developer.log(
            'Upload failed even after token refresh: ${response.statusCode}',
            name: 'ImageService',
            error: responseData);
        return null;
      } else {
        developer.log('Upload failed with status: ${response.statusCode}',
            name: 'ImageService', error: responseData);
        return null;
      }
    } catch (e) {
      developer.log('Error uploading image', name: 'ImageService', error: e);
      return null;
    }
  }

  Future<String?> updateImageWithPut({
    required File imageFile,
    required String endpoint,
    required Map<String, String> fields,
    required String token,
  }) async {
    try {
      var uri = Uri.parse('${AppConfig.apiBaseUrl}$endpoint');
      developer.log('Updating image at: $uri', name: 'ImageService');

      var request = http.MultipartRequest('PUT', uri);

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the image file
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: path.basename(imageFile.path),
      );
      request.files.add(multipartFile);

      // Add other fields
      request.fields.addAll(fields);
      developer.log('Request fields: ${request.fields}', name: 'ImageService');

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        developer.log('Image updated successfully', name: 'ImageService');
        return responseData;
      } else if (response.statusCode == 401) {
        // Try to refresh the token
        developer.log('Token expired, attempting to refresh...',
            name: 'ImageService');

        // Use AuthService to refresh token
        final refreshed = await _authService.refreshToken();
        if (refreshed) {
          final newToken = await _apiService.getToken();
          if (newToken != null) {
            // Retry the update with the new token
            request = http.MultipartRequest('PUT', uri);
            request.headers['Authorization'] = 'Bearer $newToken';

            // Create a new multipart file since the old one was consumed
            stream = http.ByteStream(imageFile.openRead());
            length = await imageFile.length();
            multipartFile = http.MultipartFile(
              'image',
              stream,
              length,
              filename: path.basename(imageFile.path),
            );
            request.files.add(multipartFile);
            request.fields.addAll(fields);

            response = await request.send();
            responseData = await response.stream.bytesToString();

            if (response.statusCode == 200) {
              developer.log('Image updated successfully after token refresh',
                  name: 'ImageService');
              return responseData;
            }
          }
        }

        developer.log(
            'Update failed even after token refresh: ${response.statusCode}',
            name: 'ImageService',
            error: responseData);
        return null;
      } else {
        developer.log('Update failed with status: ${response.statusCode}',
            name: 'ImageService', error: responseData);
        return null;
      }
    } catch (e) {
      developer.log('Error updating image', name: 'ImageService', error: e);
      return null;
    }
  }
}
