import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_sizes.dart';
import 'package:flutter_real_estate_assessment/core/constant/app_text_keys.dart';
import 'package:flutter_real_estate_assessment/core/constant/colors_app.dart';
import 'package:flutter_real_estate_assessment/core/enums/request_status.dart';
import 'package:flutter_real_estate_assessment/core/services/phone_dialer.dart';
import 'package:flutter_real_estate_assessment/core/widget/app_divider.dart';
import 'package:flutter_real_estate_assessment/core/widget/custom_text.dart';
import 'package:flutter_real_estate_assessment/core/widget/error_view.dart';
import 'package:flutter_real_estate_assessment/feature/favorites/presentation/widget/favorites_failure_listener.dart';
import 'package:flutter_real_estate_assessment/feature/properties/domain/entities/property_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/domain/entities/property_extras_entity.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_cubit.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/cubit/property_details_state.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_agent.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_facilities.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_gallery.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_header.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_hero.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_location.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_overview.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_price_bar.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_reviews.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_skeleton.dart';
import 'package:flutter_real_estate_assessment/feature/property_details/presentation/widget/details_top_bar.dart';
import 'package:flutter_real_estate_assessment/injection_container.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Property Details (Figma `1:4236`), route `/property/:id`.
///
/// [initialProperty] is the listing item from the opening screen: its title,
/// image, rating and price show at once while the full details load.
class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({
    required this.id,
    this.initialProperty,
    this.clock = DateTime.now,
    super.key,
  });

  final int id;
  final PropertyEntity? initialProperty;

  /// Source of "now" for the review times.
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<PropertyDetailsCubit>()..load(id, initial: initialProperty),
      child: PropertyDetailsView(clock: clock, phoneDialer: sl<PhoneDialer>()),
    );
  }
}

/// Details content for a [PropertyDetailsCubit] provided above it.
class PropertyDetailsView extends StatelessWidget {
  const PropertyDetailsView({
    required this.phoneDialer,
    this.clock = DateTime.now,
    super.key,
  });

  final DateTime Function() clock;
  final PhoneDialer phoneDialer;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocBuilder<PropertyDetailsCubit, PropertyDetailsState>(
        builder: (context, state) {
          final property = state.property;
          return Scaffold(
            backgroundColor: ColorsApp.white,
            bottomNavigationBar: property == null
                ? null
                : DetailsPriceBar(
                    price: property.price,
                    onBooking: () => showDetailsMessage(
                      context,
                      AppTextKeys.detailsNotAvailable,
                    ),
                  ),
            body: FavoritesFailureListener(
              child: switch (property) {
                final property? => _DetailsContent(
                  state: state,
                  property: property,
                  clock: clock,
                  phoneDialer: phoneDialer,
                ),
                null when state.status == RequestStatus.failure =>
                  _DetailsFailure(state: state),
                null => const Stack(
                  children: [
                    Positioned.fill(child: DetailsSkeleton()),
                    DetailsTopBar(),
                  ],
                ),
              },
            ),
          );
        },
      ),
    );
  }
}

/// One snackbar at a time, like the Auth "not available" notice.
void showDetailsMessage(BuildContext context, String key) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: CustomText(key)));
}

/// Nothing to show yet: the error with its retry under a back button.
class _DetailsFailure extends StatelessWidget {
  const _DetailsFailure({required this.state});

  final PropertyDetailsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const DetailsTopBar(),
        Expanded(
          child: ErrorView(
            failure: state.failure!,
            onRetry: context.read<PropertyDetailsCubit>().retry,
          ),
        ),
      ],
    );
  }
}

class _DetailsContent extends StatefulWidget {
  const _DetailsContent({
    required this.state,
    required this.property,
    required this.clock,
    required this.phoneDialer,
  });

  final PropertyDetailsState state;
  final PropertyEntity property;
  final DateTime Function() clock;
  final PhoneDialer phoneDialer;

  @override
  State<_DetailsContent> createState() => _DetailsContentState();
}

class _DetailsContentState extends State<_DetailsContent> {
  static const Duration _showImageDuration = Duration(milliseconds: 400);

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Gallery tile tap: that photo in the hero, scrolled into view.
  void _showImage(int index) {
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(index);
      _scrollController.jumpTo(0);
      return;
    }
    _pageController.animateToPage(
      index,
      duration: _showImageDuration,
      curve: Curves.easeOutCubic,
    );
    _scrollController.animateTo(
      0,
      duration: _showImageDuration,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _callAgent(AgentEntity agent) async {
    final opened = await widget.phoneDialer.dial(agent.phone);
    if (!opened && mounted) {
      showDetailsMessage(context, AppTextKeys.detailsCallFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: DetailsHero(
            imageUrls: property.imageUrls.isNotEmpty
                ? property.imageUrls
                : [property.thumbnailUrl],
            controller: _pageController,
            topBar: DetailsTopBar(property: property),
          ),
        ),
        SliverSafeArea(
          top: false,
          bottom: false,
          sliver: SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.screenHorizontalPadding.w,
              vertical: AppSizes.detailsBodyVerticalPadding.h,
            ),
            sliver: SliverList.list(children: _sections(context)),
          ),
        ),
      ],
    );
  }

  List<Widget> _sections(BuildContext context) {
    final state = widget.state;
    final property = widget.property;
    final sections = <Widget>[
      DetailsHeader(
        property: property,
        reviewCount: state.hasDetails ? property.reviews.length : null,
        extras: state.hasDetails ? state.extras : null,
      ),
      const AppDivider(),
      ...switch (state.status) {
        RequestStatus.success => _detailSections(property, state.extras),
        RequestStatus.failure => [
          ErrorView(
            failure: state.failure!,
            onRetry: context.read<PropertyDetailsCubit>().retry,
          ),
        ],
        _ => [const DetailsOverview.loading()],
      },
    ];
    final gap = SizedBox(height: AppSizes.detailsSectionGap.h);
    return [
      for (var index = 0; index < sections.length; index++) ...[
        if (index > 0) gap,
        sections[index],
      ],
    ];
  }

  /// Figma order. Agent, Facilities and Location come from [extras] (mock
  /// data, reference §4.6) and are hidden without them. The gallery needs a
  /// second photo to add anything to the hero.
  List<Widget> _detailSections(
    PropertyEntity property,
    PropertyExtrasEntity? extras,
  ) {
    final description = property.description?.trim() ?? '';
    return [
      if (extras != null)
        DetailsAgent(
          agent: extras.agent,
          onChat: () =>
              showDetailsMessage(context, AppTextKeys.detailsNotAvailable),
          onCall: () => _callAgent(extras.agent),
        ),
      if (description.isNotEmpty) DetailsOverview(description: description),
      if (extras != null && extras.facilities.isNotEmpty)
        DetailsFacilities(facilities: extras.facilities),
      if (property.imageUrls.length > 1)
        DetailsGallery(imageUrls: property.imageUrls, onImageTap: _showImage),
      if (extras != null) DetailsLocation(address: extras.address),
      if (property.reviews.isNotEmpty)
        DetailsReviews(
          rating: property.rating,
          reviews: property.reviews,
          now: widget.clock(),
          likes: extras?.reviewLikes ?? const [],
        ),
    ];
  }
}
