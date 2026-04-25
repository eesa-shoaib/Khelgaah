import 'package:frontend/core/api/api_models.dart';

double facilityRating(FacilityDto facility) {
  final bucket = (facility.id % 7) * 0.1;
  return 4.2 + bucket;
}

String facilityCategoryLabel(FacilityDto facility) {
  return facility.sport.trim().isEmpty ? facility.type : facility.sport;
}
