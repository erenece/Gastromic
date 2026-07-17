import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_venue_detail/view_model/venue_detail_view_model.dart';
import 'package:gastromic/app/views/view_venue_detail/widgets/venue_detail_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/widgets/primary_button.dart';

@RoutePage()
class VenueDetailView extends StatelessWidget with VenueDetailWidgets {
  final String venueId;

  VenueDetailView({super.key, this.venueId = 'mock-1'});

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
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == ViewStatus.failure) {
            return Scaffold(
              backgroundColor: context.cBackground,
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
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hero(
                    context,
                    venue: venue,
                    isFavorite: state.isFavorite,
                    onBack: () => context.router.maybePop(),
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
                        ),
                        context.sizedHeightBoxMedium,
                        features(context, features: venue.features),
                        context.sizedHeightBoxMedium,
                        dishes(context, dishes: venue.dishes),
                        context.sizedHeightBoxMedium,
                        reviews(
                          context,
                          reviews: venue.reviews,
                          onSeeAll: () {
                            // tüm yorumlar sayfası
                          },
                        ),
                        context.sizedHeightBoxMedium,
                        locationSection(context, venue: venue),
                        context.sizedHeightBoxMedium,
                        PrimaryButton(
                          label: 'Yol Tarifi',
                          onPressed: () {
                            // google haritalar yönlendirme
                          },
                        ),
                        context.sizedHeightBoxMedium,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
