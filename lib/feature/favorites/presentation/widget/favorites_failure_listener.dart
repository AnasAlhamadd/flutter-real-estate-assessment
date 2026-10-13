import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/error/failure_message.dart';
import 'package:flutter_real_estate_assessment/core/error/failures.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/cubit/favorites_state.dart';

/// Shows a snackbar when a favorite can't be added or saved.
class FavoritesFailureListener extends StatelessWidget {
  const FavoritesFailureListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoritesCubit, FavoritesState>(
      listenWhen: (previous, current) =>
          current.failure != null && previous.failure != current.failure,
      listener: (context, state) => ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: CustomText(_messageKey(state.failure!))),
        ),
      child: child,
    );
  }

  /// A failed save is a local write problem, not "no cached data".
  static String _messageKey(Failure failure) => failure is CacheFailure
      ? AppTextKeys.favoritesSaveFailed
      : failure.messageKey;
}
