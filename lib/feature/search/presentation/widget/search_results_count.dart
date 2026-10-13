import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_styles.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';

/// "Found {n} results" above the list (Figma `1:4120` "Found 182
/// Apartments"; the API returns products, not apartments). [total] is the
/// API's match count, not the number of loaded items.
class SearchResultsCount extends StatelessWidget {
  const SearchResultsCount({required this.total, super.key});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: CustomText.plain(
        context.plural(AppTextKeys.searchFound, total),
        style: AppTextStyles.sectionTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
