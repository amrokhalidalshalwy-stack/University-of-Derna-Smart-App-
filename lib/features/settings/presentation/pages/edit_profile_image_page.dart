import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

final profileImagePathProvider = FutureProvider.autoDispose<String?>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final path = prefs.getString('profile_image_path');
  if (path == null || path.isEmpty) return null;
  if (kIsWeb) return path;
  if (!File(path).existsSync()) return null;
  return path;
});

class EditProfileImagePage extends ConsumerStatefulWidget {
  const EditProfileImagePage({super.key});

  @override
  ConsumerState<EditProfileImagePage> createState() =>
      _EditProfileImagePageState();
}

class _EditProfileImagePageState extends ConsumerState<EditProfileImagePage> {
  final _picker = ImagePicker();
  XFile? _previewImage;
  bool _isSaving = false;

  Future<bool> _ensurePermission(ImageSource source) async {
    if (kIsWeb) return true;
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      return status.isGranted;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      if (Platform.isAndroid) {
        final storage = await Permission.storage.request();
        return storage.isGranted;
      }
    }
    final photos = await Permission.photos.request();
    return photos.isGranted;
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final granted = await _ensurePermission(source);
    if (!granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorPrefix)),
      );
      return;
    }
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _previewImage = picked);
  }

  void _showSourcePicker() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChangePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.editProfilePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<ImageProvider?> _getImageProvider(String? localPath) async {
    if (_previewImage != null) {
      if (kIsWeb) {
        final bytes = await _previewImage!.readAsBytes();
        return MemoryImage(bytes);
      } else {
        return FileImage(File(_previewImage!.path));
      }
    } else if (localPath != null && !kIsWeb) {
      return FileImage(File(localPath));
    }
    return null;
  }

  // ✅ المفتاح الآن يُقرأ من ملف .env بدل أن يكون مكتوباً مباشرة في الكود.
  Future<String> _uploadToImgBB(XFile image) async {
    final l10n = AppLocalizations.of(context)!;

    final apiKey = dotenv.env['IMGBB_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(l10n.imageUploadConfigMissing);
    }

    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.post(
      Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
      body: {'image': base64Image},
    );
    if (response.statusCode != 200) {
      throw Exception(l10n.imageUploadFailed(response.statusCode.toString()));
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final success = json['success'] as bool? ?? false;
    if (!success) throw Exception(l10n.imageUploadRejected);
    final url = json['data']['url'] as String?;
    if (url == null || url.isEmpty) throw Exception(l10n.imageUrlMissing);
    return url;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authStateChangesProvider).value;
    if (user == null || _previewImage == null) return;

    setState(() => _isSaving = true);
    try {
      final downloadUrl = await _uploadToImgBB(_previewImage!);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImage': downloadUrl,
        'profilePhotoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString('profile_image_path', _previewImage!.path);

      ref.invalidate(profileImagePathProvider);
      ref.invalidate(userDataProvider(user.uid));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdateSuccess)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}$e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ✅ دالة إزالة الصورة
  Future<void> _removeImage() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImage': FieldValue.delete(),
        'profilePhotoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.remove('profile_image_path');

      ref.invalidate(profileImagePathProvider);
      ref.invalidate(userDataProvider(user.uid));

      if (!mounted) return;
      setState(() => _previewImage = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileUpdateSuccess)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.errorPrefix}$e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ✅ نافذة تأكيد الحذف — أصبحت تستخدم l10n بالكامل بدل نصوص عربية ثابتة
  Future<void> _confirmAndRemove() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.removeImageTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        content: Text(
          l10n.removeImageConfirm,
          style: const TextStyle(fontFamily: 'Cairo'),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: const TextStyle(fontFamily: 'Cairo')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              l10n.removeImageAction,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Theme.of(ctx).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) _removeImage();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final auth = ref.watch(authStateChangesProvider);
    final localPath = ref.watch(profileImagePathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.editProfilePhoto,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: auth.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.pleaseLogin));
          }

          final profile = ref.watch(userDataProvider(user.uid));
          return profile.when(
            data: (data) {
              final name = data?['fullName'] as String? ?? l10n.defaultStudentName;
              final id = data?['universityId'] as String? ?? '—';
              final email = data?['email'] as String? ?? user.email ?? '—';
              final remoteUrl = data?['profileImage'] as String? ??
                  data?['profilePhotoUrl'] as String?;

              return FutureBuilder<ImageProvider?>(
                future: _getImageProvider(localPath.value),
                builder: (context, snapshot) {
                  ImageProvider? avatarProvider = snapshot.data;
                  if (avatarProvider == null && remoteUrl != null) {
                    avatarProvider = NetworkImage(remoteUrl);
                  }

                  // ✅ هل يوجد صورة فعلية؟
                  final hasImage = avatarProvider != null;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 64,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      backgroundImage: avatarProvider,
                                      child: avatarProvider == null
                                          ? Icon(
                                              Icons.person,
                                              size: 64,
                                              color: theme.colorScheme.primary,
                                            )
                                          : null,
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Material(
                                        color: theme.colorScheme.primary,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          onTap: _isSaving ? null : _showSourcePicker,
                                          customBorder: const CircleBorder(),
                                          child: const Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isSaving) ...[
                                  const SizedBox(height: 16),
                                  const LinearProgressIndicator(),
                                  const SizedBox(height: 8),
                                  Text(l10n.save, style: theme.textTheme.bodySmall),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.person, color: theme.colorScheme.primary),
                                title: Text(l10n.fullName),
                                subtitle: Text(name),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.badge, color: theme.colorScheme.primary),
                                title: Text(l10n.registrationNumberPrefix),
                                subtitle: Text(id),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.email, color: theme.colorScheme.primary),
                                title: Text(l10n.emailLabel),
                                subtitle: Text(email),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ زر الحفظ
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: (_previewImage == null || _isSaving) ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check_rounded),
                            label: Text(l10n.profileSaveChanges),
                          ),
                        ),

                        // ✅ زر الإزالة — يظهر فقط إذا كانت هناك صورة
                        if (hasImage) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _isSaving ? null : _confirmAndRemove,
                              icon: Icon(
                                Icons.delete_outline,
                                color: theme.colorScheme.error,
                              ),
                              label: Text(
                                l10n.removeImageTitle,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.colorScheme.error),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.authError)),
      ),
    );
  }
}