import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/widget/favorite_button.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_state.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';

/// [FavoriteButton] bound to the app-wide [FavoritesCubit] by property id.
class PropertyFavoriteButton extends StatelessWidget {
  const PropertyFavoriteButton({
    required this.property,
    this.variant = FavoriteButtonVariant.onSurface,
    super.key,
  });

  final PropertyEntity property;
  final FavoriteButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) => state.isFavorite(property.id),
      builder: (context, isFavorite) => FavoriteButton(
        isFavorite: isFavorite,
        variant: variant,
        onPressed: () => context.read<FavoritesCubit>().toggle(property),
      ),
    );
  }
}
