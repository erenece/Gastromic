import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_venue_detail/view_model/venue_detail_view_model.dart';
import 'package:gastromic/app/views/view_venue_detail/widgets/venue_detail_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/services/pending_visit_service.dart';
import 'package:gastromic/core/utils/maps_launcher.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

@RoutePage()
class VenueDetailView extends StatelessWidget with VenueDetailWidgets {
  final String venueId;

  VenueDetailView({super.key, this.venueId = 'mock-1'});

  void _goBack(BuildContext context) {
    final router = context.router;
    if (router.canPop()) {
      router.pop();
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          VenueDetailViewModel()..add(VenueDetailInitialEvent(venueId)),
      child: BlocBuilder<VenueDetailViewModel, VenueDetailState>(
        builder: (context, state) {
          final viewModel = context.read<VenueDetailViewModel>();

          if (state.status == ViewStatus.loading || state.venue == null) {
            return Scaffold(
              backgroundColor: context.cBackground,
              appBar: AppBar(
                backgroundColor: context.cBackground,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _goBack(context),
                ),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == ViewStatus.failure) {
            return Scaffold(
              backgroundColor: context.cBackground,
              appBar: AppBar(
                backgroundColor: context.cBackground,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _goBack(context),
                ),
              ),
              body: Center(
                child: Text(
                  state.errorMessage ?? 'Bir hata oluştu',
                  style: context.bodyMedium,
                ),
              ),
            );
          }

          final venue = state.venue!;

          return Scaffold(
            backgroundColor: context.cBackground,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hero(
                        context,
                        venue: venue,
                        isFavorite: state.isFavorite,
                        onToggleFavorite: () =>
                            viewModel.add(VenueDetailToggleFavoriteEvent()),
                      ),
                      Padding(
                        padding: context.paddingNormal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            aiSummary(
                              context,
                              summary: venue.aiSummary,
                              description: venue.description,
                              checks: venue.preferenceChecks,
                              userAllergens: venue.userAllergens,
                              userConditions: venue.userConditions,
                              userDailyMode: venue.userDailyMode,
                            ),
                            context.sizedHeightBoxMedium,
                            features(context, features: venue.features),
                            context.sizedHeightBoxMedium,
                            dishes(context, dishes: venue.dishes),
                            context.sizedHeightBoxMedium,
                            reviews(
                              context,
                              reviews: venue.reviews,
                              onSeeAll: () {},
                            ),
                            context.sizedHeightBoxMedium,
                            locationSection(context, venue: venue),
                            context.sizedHeightBoxMedium,
                            PrimaryButton(
                              label: 'Yol Tarifi',
                              onPressed: () async {
                                try {
                                  await PendingVisitService().createFromVenue(
                                    venueId: venue.id,
                                    venueName: venue.name,
                                    category: venue.category,
                                    location: venue.location,
                                    imageUrl: venue.imageUrl,
                                    rating: venue.rating,
                                    latitude: venue.latitude,
                                    longitude: venue.longitude,
                                  );
                                  await MapsLauncher.openDirections(
                                    latitude: venue.latitude,
                                    longitude: venue.longitude,
                                    label: venue.name,
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }
                                }
                              },
                            ),
                            context.sizedHeightBoxMedium,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _goBack(context),
                        child: Container(
                          padding: context.paddingLow,
                          decoration: BoxDecoration(
                            color: context.cSurface.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: context.cTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
