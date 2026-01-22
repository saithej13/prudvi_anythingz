import 'dart:convert';

import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anythingz/api/api_client.dart';
import 'package:anythingz/features/address/domain/models/address_model.dart';
import 'package:anythingz/features/location/domain/models/zone_data_model.dart';
import 'package:anythingz/features/rental_module/rental_location_screen/domain/repository/taxi_repository_interface.dart';
import 'package:anythingz/util/app_constants.dart';

class TaxiRepository implements TaxiRepositoryInterface{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  TaxiRepository({required this.sharedPreferences, required this.apiClient});

}