import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/usecases/get_property_details_usecase.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_state.dart';

/// Loads one property by id (`GET /products/{id}` through the use case).
/// A failure keeps the listing item, so only the detail sections are
/// replaced by the error and its retry.
class PropertyDetailsCubit extends Cubit<PropertyDetailsState> {
  PropertyDetailsCubit({required this._getPropertyDetails})
    : super(const PropertyDetailsState());

  final GetPropertyDetailsUseCase _getPropertyDetails;
  int? _id;

  /// [initial] is shown while loading when its id matches [id].
  Future<void> load(int id, {PropertyEntity? initial}) async {
    _id = id;
    emit(
      PropertyDetailsState(
        status: RequestStatus.loading,
        property: initial?.id == id ? initial : null,
      ),
    );
    await _fetch(id);
  }

  /// Repeats the last request. Ignored while one is running.
  Future<void> retry() async {
    final id = _id;
    if (id == null || state.status == RequestStatus.loading) return;
    emit(state.copyWith(status: RequestStatus.loading, failure: () => null));
    await _fetch(id);
  }

  Future<void> _fetch(int id) async {
    final result = await _getPropertyDetails(PropertyDetailsParams(id: id));
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(status: RequestStatus.failure, failure: () => failure),
      ),
      (property) => emit(
        PropertyDetailsState(status: RequestStatus.success, property: property),
      ),
    );
  }
}
