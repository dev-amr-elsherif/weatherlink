import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class BlynkRemoteDataSource {
  Future<double> getPinValue(String pin);
  Future<void> updatePinValue(String pin, dynamic value);
}

class BlynkRemoteDataSourceImpl implements BlynkRemoteDataSource {
  final http.Client client;

  BlynkRemoteDataSourceImpl({required this.client});

  @override
  Future<double> getPinValue(String pin) async {
    final url = Uri.parse(
      '${AppConstants.blynkBaseUrl}/get?token=${AppConstants.blynkAuthToken}&pin=$pin',
    );
    final response = await client.get(url);

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final valString = decoded[0].toString();
          final val = double.tryParse(valString);
          if (val != null) {
            return val;
          }
        } else if (decoded != null) {
          final val = double.tryParse(decoded.toString());
          if (val != null) {
            return val;
          }
        }
        throw ServerException();
      } catch (_) {
        // Handle potential FormatException gracefully if response payload is plain raw text
        final cleaned = response.body.replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').trim();
        final val = double.tryParse(cleaned);
        if (val != null) {
          return val;
        }
        throw ServerException();
      }
    } else {
      throw ServerException();
    }
  }

  @override
  Future<void> updatePinValue(String pin, dynamic value) async {
    final url = Uri.parse(
      '${AppConstants.blynkBaseUrl}/update?token=${AppConstants.blynkAuthToken}&pin=$pin&value=$value',
    );
    final response = await client.get(url);

    if (response.statusCode != 200) {
      throw ServerException();
    }
  }
}
