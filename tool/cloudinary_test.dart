// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const cloudName = 'kxkbvskv';
  const uploadPreset = 'pethub_unsigned';

  const sampleImageUrl =
      'https://res.cloudinary.com/demo/image/upload/sample.jpg';

  final uploadUrl = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
  );

  final body = Uri(
    queryParameters: {
      'file': sampleImageUrl,
      'upload_preset': uploadPreset,
      'folder': 'pethub_test',
    },
  ).query;

  final client = HttpClient();

  try {
    final request = await client.postUrl(uploadUrl);

    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );

    request.write(body);

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('Upload failed');
      print('Status code: ${response.statusCode}');
      print(responseText);
      exit(1);
    }

    final data = jsonDecode(responseText) as Map<String, dynamic>;

    final secureUrl = data['secure_url'] as String;
    final publicId = data['public_id'] as String;
    final width = data['width'];
    final height = data['height'];
    final format = data['format'];
    final bytes = data['bytes'];

    print('Upload successful');
    print('Secure URL: $secureUrl');
    print('Public ID: $publicId');
    print('Width: $width');
    print('Height: $height');
    print('Format: $format');
    print('File size bytes: $bytes');

    // f_auto: Cloudinary tự chọn định dạng ảnh tối ưu.
    // q_auto: Cloudinary tự chọn chất lượng ảnh tối ưu.
    final transformedUrl = secureUrl.replaceFirst(
      '/upload/',
      '/upload/f_auto,q_auto/',
    );

    print(
      'Done! Click link below to see optimized version of the image. Check the size and the format.',
    );
    print(transformedUrl);
  } finally {
    client.close(force: true);
  }
}
