import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:anythingz/features/address/domain/models/address_model.dart';
import 'package:anythingz/features/location/domain/models/zone_data_model.dart';
import 'package:anythingz/features/rental_module/domain/repository/taxi_repository_interface.dart';
import 'package:anythingz/features/rental_module/domain/services/taxi_location_service_interface.dart';

class TaxiLocationService implements TaxiLocationServiceInterface{
  TaxiRepositoryInterface taxiRepositoryInterface;
  TaxiLocationService({required this.taxiRepositoryInterface});


}