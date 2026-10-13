import 'package:equatable/equatable.dart';

/// The eight facilities of Figma `1:4316`, in design order.
enum PropertyFacility {
  carParking,
  swimmingPool,
  gym,
  restaurant,
  wifi,
  petCenter,
  sportCenter,
  laundry,
}

enum AgentRole { owner }

class AgentEntity extends Equatable {
  const AgentEntity({
    required this.name,
    required this.role,
    required this.phone,
  });

  final String name;
  final AgentRole role;

  /// Dialable number, e.g. `+15550100`.
  final String phone;

  @override
  List<Object?> get props => [name, role, phone];
}

/// Details sections DummyJSON has no data for (reference §4.6, Q4): stats
/// row, Agent, Facilities, Location and review likes.
class PropertyExtrasEntity extends Equatable {
  const PropertyExtrasEntity({
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqft,
    required this.agent,
    required this.facilities,
    required this.address,
    this.reviewLikes = const [],
  });

  final int bedrooms;
  final int bathrooms;
  final int areaSqft;
  final AgentEntity agent;
  final List<PropertyFacility> facilities;
  final String address;

  /// Like count per review, by review index. Reviews past the end of the
  /// list show no count.
  final List<int> reviewLikes;

  @override
  List<Object?> get props => [
    bedrooms,
    bathrooms,
    areaSqft,
    agent,
    facilities,
    address,
    reviewLikes,
  ];
}
