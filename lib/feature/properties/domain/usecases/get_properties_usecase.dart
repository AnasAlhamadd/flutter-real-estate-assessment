import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/properties_page_entity.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/repositories/properties_repository.dart';

class GetPropertiesUseCase
    implements UseCase<PropertiesPageEntity, PageParams> {
  const GetPropertiesUseCase(this._repository);

  final PropertiesRepository _repository;

  @override
  Future<Either<Failure, PropertiesPageEntity>> call(PageParams params) =>
      _repository.getProperties(page: params.page);
}

class PageParams extends Equatable {
  const PageParams({required this.page}) : assert(page >= 0);

  final int page;

  @override
  List<Object?> get props => [page];
}
