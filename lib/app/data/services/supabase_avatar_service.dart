import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swaranusaquiz/app/data/providers/supabase_config.dart';

class SupabaseAvatarService {
  const SupabaseAvatarService._();

  static Future<String> uploadAvatar({
    required String uid,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase belum dikonfigurasi. Jalankan app dengan SUPABASE_URL dan SUPABASE_PUBLISHABLE_KEY.',
      );
    }

    final version = DateTime.now().millisecondsSinceEpoch;
    final path = '$uid/profile_$version.jpg';
    final bucket = Supabase.instance.client.storage.from(
      SupabaseConfig.avatarBucket,
    );

    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        cacheControl: '3600',
        contentType: contentType,
      ),
    );

    final publicUrl = bucket.getPublicUrl(path);
    return publicUrl;
  }

  static Future<void> deleteAvatarByUrl(String avatarUrl) async {
    final path = _pathFromPublicUrl(avatarUrl);
    if (path == null) return;

    final bucket = Supabase.instance.client.storage.from(
      SupabaseConfig.avatarBucket,
    );
    await bucket.remove([path]);
  }

  static String? _pathFromPublicUrl(String avatarUrl) {
    final uri = Uri.tryParse(avatarUrl);
    if (uri == null) return null;

    final publicIndex = uri.pathSegments.indexOf('public');
    if (publicIndex == -1 || uri.pathSegments.length <= publicIndex + 2) {
      return null;
    }

    final bucketName = uri.pathSegments[publicIndex + 1];
    if (bucketName != SupabaseConfig.avatarBucket) return null;

    return uri.pathSegments.sublist(publicIndex + 2).join('/');
  }
}
