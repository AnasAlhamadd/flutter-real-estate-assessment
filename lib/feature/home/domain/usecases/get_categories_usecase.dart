import 'package:dartz/dartz.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/usecase/usecase.dart';
import 'package:flutter_real_estate_assessment/feature/home/domain/repositories/home_repository.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/category_entity.dart';

class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  const GetCategoriesUseCase(this._repository);

  final HomeRepository _repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) =>
      _repository.getCategories();
}
