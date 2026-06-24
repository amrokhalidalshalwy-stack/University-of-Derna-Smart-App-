/// Hive initialization and manual adapters for HifdhTracker.
library;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

// ── Manual Adapters ──────────────────────────────────────────────────────────

class SurahModelAdapter extends TypeAdapter<SurahModel> {
  @override
  final int typeId = 0;

  @override
  SurahModel read(BinaryReader reader) {
    return SurahModel(
      number: reader.readInt(),
      nameArabic: reader.readString(),
      nameEnglish: reader.readString(),
      nameTransliteration: reader.readString(),
      ayahCount: reader.readInt(),
      revelationType: reader.readString(),
      juzStart: reader.readInt(),
      pageStart: reader.readInt(),
      status: memorizationStatusFromJson(reader.readString()),
      memorizedAyahs: reader.readInt(),
    );
  }

  @override
  void write(BinaryWriter writer, SurahModel obj) {
    writer.writeInt(obj.number);
    writer.writeString(obj.nameArabic);
    writer.writeString(obj.nameEnglish);
    writer.writeString(obj.nameTransliteration);
    writer.writeInt(obj.ayahCount);
    writer.writeString(obj.revelationType);
    writer.writeInt(obj.juzStart);
    writer.writeInt(obj.pageStart);
    writer.writeString(memorizationStatusToJson(obj.status));
    writer.writeInt(obj.memorizedAyahs);
  }
}

class RevisionSessionModelAdapter extends TypeAdapter<RevisionSessionModel> {
  @override
  final int typeId = 1;

  @override
  RevisionSessionModel read(BinaryReader reader) {
    final raw = reader.readString();
    return RevisionSessionModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  void write(BinaryWriter writer, RevisionSessionModel obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}

class HalaqahModelAdapter extends TypeAdapter<HalaqahModel> {
  @override
  final int typeId = 2;

  @override
  HalaqahModel read(BinaryReader reader) {
    final raw = reader.readString();
    return HalaqahModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  void write(BinaryWriter writer, HalaqahModel obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}

class HalaqahMemberAdapter extends TypeAdapter<HalaqahMember> {
  @override
  final int typeId = 3;

  @override
  HalaqahMember read(BinaryReader reader) {
    final raw = reader.readString();
    return HalaqahMember.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  void write(BinaryWriter writer, HalaqahMember obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}

class UserModelAdapter extends TypeAdapter<HifzhUserModel> {
  @override
  final int typeId = 4;

  @override
  HifzhUserModel read(BinaryReader reader) {
    final raw = reader.readString();
    return HifzhUserModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  @override
  void write(BinaryWriter writer, HifzhUserModel obj) {
    writer.writeString(jsonEncode(obj.toJson()));
  }
}

// ── Init Method ───────────────────────────────────────────────────────────────

/// Initializes Hive and opens required boxes.
Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(SurahModelAdapter());
  Hive.registerAdapter(RevisionSessionModelAdapter());
  Hive.registerAdapter(HalaqahModelAdapter());
  Hive.registerAdapter(HalaqahMemberAdapter());
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<SurahModel>('surahs');
  await Hive.openBox<RevisionSessionModel>('sessions');
  await Hive.openBox<HalaqahModel>('halaqahs');
  await Hive.openBox('auth_cache');
  await Hive.openBox('user_prefs');
}
