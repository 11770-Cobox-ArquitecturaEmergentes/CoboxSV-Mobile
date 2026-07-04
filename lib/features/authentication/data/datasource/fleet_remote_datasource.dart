import 'package:cobox_sv_mobile/core/api/dio_client.dart';
import 'package:cobox_sv_mobile/core/api/endpoints.dart';

class FleetRemoteDataSource {
  final DioClient _client;

  FleetRemoteDataSource(this._client);

  Future<Map<String, dynamic>?> getDriverByEmail(String email) async {
    final response = await _client.get(
      Endpoints.driverSearch,
      queryParameters: {'email': email},
    );
    return response.data as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>> createDriver({
    required String email,
    required String licenceNumber,
  }) async {
    final response = await _client.post(
      Endpoints.drivers,
      data: {
        'email': email,
        'licenceNumber': licenceNumber,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}