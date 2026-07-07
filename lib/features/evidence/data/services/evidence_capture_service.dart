import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cobox_sv_mobile/features/evidence/data/models/evidence_models.dart';
import 'package:cobox_sv_mobile/features/evidence/data/services/evidence_id_service.dart';

class EvidenceCaptureService {
  EvidenceCaptureService({
    ImagePicker? picker,
  }) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<EvidenceDraft?> captureImage({
    required ImageSource source,
    required int driverId,
    required int orderId,
    required int routeId,
    required String type,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (picked == null) return null;

    final clientEvidenceId = newClientUuid();
    final sourceFile = File(picked.path);
    final file = await _persistPickedFile(sourceFile, clientEvidenceId);
    final sizeBytes = await file.length();
    final sha256Hash = await sha256.bind(file.openRead()).first;
    final position = await _tryCurrentPosition();

    return EvidenceDraft(
      clientEvidenceId: clientEvidenceId,
      filePath: file.path,
      driverId: driverId,
      orderId: orderId,
      routeId: routeId,
      type: type,
      mimeType: _mimeType(file.path),
      sizeBytes: sizeBytes,
      sha256: sha256Hash.toString(),
      capturedAt: DateTime.now().toUtc(),
      latitude: position?.latitude,
      longitude: position?.longitude,
      accuracyMeters: position?.accuracy,
      speedKmh: position == null ? null : position.speed * 3.6,
    );
  }

  Future<Position?> _tryCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  String _mimeType(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<File> _persistPickedFile(File source, String clientEvidenceId) async {
    final extension = _extension(source.path);
    final appDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${appDirectory.path}${Platform.pathSeparator}cobox_evidence',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return source.copy(
      '${directory.path}${Platform.pathSeparator}$clientEvidenceId$extension',
    );
  }

  String _extension(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return '.png';
    if (normalized.endsWith('.webp')) return '.webp';
    return '.jpg';
  }
}
