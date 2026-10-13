import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';

/// this mock: DummyJSON products have no bedrooms, bathrooms, area, agent,
/// facilities, address or review likes, but the Figma Details screen
/// (`1:4273`) shows them. The values are the Figma sample data, the same for
/// every property, until a real source exists; replace this class with a
/// remote data source then (decision 2026-10-13, reference §4.6).
class PropertyExtrasMockDataSource {
  const PropertyExtrasMockDataSource();

  /// this mock: Figma sample values; the phone number is a reserved
  /// fictional 555-01xx number, so the dialer never reaches a real person.
  static const PropertyExtrasEntity sample = PropertyExtrasEntity(
    bedrooms: 8,
    bathrooms: 3,
    areaSqft: 2000,
    agent: AgentEntity(
      name: 'Natasya Wilodra',
      role: AgentRole.owner,
      phone: '+15550100',
    ),
    facilities: PropertyFacility.values,
    address: 'Grand City St. 100, New York, United States',
    reviewLikes: [938, 254, 61],
  );

  Future<PropertyExtrasEntity> getPropertyExtras(int propertyId) async =>
      sample;
}
