import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryUploadResult {
  final String imageUrl;
  final String publicId;
  final int width;
  final int height;
  final String format;
  final int bytes;

  const CloudinaryUploadResult({
    required this.imageUrl,
    required this.publicId,
    required this.width,
    required this.height,
    required this.format,
    required this.bytes,
  });

  factory CloudinaryUploadResult.fromJson(Map<String, dynamic> json) {
    return CloudinaryUploadResult(
      imageUrl: json['secure_url'] as String? ?? '',
      publicId: json['public_id'] as String? ?? '',
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      format: json['format'] as String? ?? '',
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
    );
  }
}

class CloudinaryUploadService {
  CloudinaryUploadService._();

  static const String cloudName = 'kxkbvskv';
  static const String uploadPreset = 'pethub_unsigned';
  static const String uploadFolder = 'pethub_community';

  static const int maximumImagesPerPost = 5;

  static final ImagePicker _picker = ImagePicker();

  static Future<List<XFile>> pickImagesFromGallery() async {
    final images = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 1600,
    );

    return images.take(maximumImagesPerPost).toList();
  }

  static Future<CloudinaryUploadResult> uploadImageFile(XFile imageFile) async {
    final uploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/'
      '$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uploadUrl);

    request.fields['upload_preset'] = uploadPreset;
    request.fields['folder'] = uploadFolder;

    final imageBytes = await imageFile.readAsBytes();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: imageFile.name,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Upload ảnh thất bại: '
        '${response.statusCode} - ${response.body}',
      );
    }

    final decodedData = jsonDecode(response.body);

    if (decodedData is! Map) {
      throw Exception('Cloudinary trả về dữ liệu không hợp lệ.');
    }

    final data = Map<String, dynamic>.from(decodedData);

    final result = CloudinaryUploadResult.fromJson(data);

    if (result.imageUrl.isEmpty || result.publicId.isEmpty) {
      throw Exception('Cloudinary không trả về link ảnh hợp lệ.');
    }

    return result;
  }

  static String optimizedImageUrl(String imageUrl) {
    if (imageUrl.isEmpty) {
      return imageUrl;
    }

    if (!imageUrl.contains('/upload/')) {
      return imageUrl;
    }

    return imageUrl.replaceFirst('/upload/', '/upload/f_auto,q_auto/');
  }
}
