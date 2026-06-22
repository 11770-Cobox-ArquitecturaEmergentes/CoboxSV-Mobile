import 'package:cobox_sv_mobile/features/profile/domain/entities/profile_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/entities/vehicle_entity.dart';
import 'package:cobox_sv_mobile/features/profile/domain/repository/profile_repository.dart';

class MockProfileRepositoryImpl implements ProfileRepository {
  MockProfileRepositoryImpl();

  ProfileEntity _profile = ProfileEntity(
    id: 'drv-001',
    name: 'Carlos Mendez',
    email: 'carlos.mendez@cobox.com',
    phone: '+54 11 4567-8900',
    employeeId: 'DRV-001',
    licenseNumber: 'D12345678',
    licenseExpiry: DateTime(2028, 12, 31),
    role: 'Conductor',
    vehicle: VehicleEntity(
      id: 'veh-001',
      plate: 'ABC-1234',
      brand: 'Mercedes-Benz',
      model: 'Actros 2546',
      year: 2024,
      type: 'Camion de carga',
      color: 'Blanco',
      capacity: 18.0,
      fuelType: 'Diesel',
    ),
  );

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {}

  @override
  Future<ProfileEntity> getProfile() async => _profile;

  @override
  Future<ProfileEntity> updateProfile(ProfileEntity profile) async {
    _profile = profile;
    return _profile;
  }

  @override
  Future<String> uploadPhoto(String filePath) async {
    _profile = _profile.copyWith(photoUrl: 'mock://$filePath');
    return _profile.photoUrl!;
  }
}
