import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// [property] is the listing item passed by the opening screen until the
/// details arrive, so the page shows its title, image and price at once.
/// Detail-only fields (description, images, reviews) are complete only when
/// [status] is [RequestStatus.success].
class PropertyDetailsState extends Equatable {
  const PropertyDetailsState({
    this.status = RequestStatus.initial,
    this.property,
    this.failure,
  });

  final RequestStatus status;
  final PropertyEntity? property;
  final Failure? failure;

  bool get hasDetails => status == RequestStatus.success;

  PropertyDetailsState copyWith({
    RequestStatus? status,
    ValueGetter<PropertyEntity?>? property,
    ValueGetter<Failure?>? failure,
  }) => PropertyDetailsState(
    status: status ?? this.status,
    property: property != null ? property() : this.property,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, property, failure];
}
