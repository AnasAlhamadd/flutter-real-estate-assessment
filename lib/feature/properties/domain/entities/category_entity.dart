import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({required this.slug, required this.name});

  final String slug;

  /// English display name from the API. Localized labels are a UI concern.
  final String name;

  @override
  List<Object?> get props => [slug, name];
}
