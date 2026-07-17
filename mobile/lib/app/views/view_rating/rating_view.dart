import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_rating/view_model/rating_view_model.dart';
import 'package:gastromic/app/views/view_rating/widgets/rating_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class RatingView extends StatelessWidget with RatingWidgets {
  RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RatingViewModel()..add(RatingInitialEvent()),
      child: BlocConsumer<RatingViewModel, RatingState>(
        listener: (context, state) {
          if (state.status == ViewStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
          if (state.isSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Değerlendirmeniz kaydedildi')),
            );
          }
        },
        builder: (context, state) {
          final viewModel = context.read<RatingViewModel>();

          return Scaffold(
            backgroundColor: context.cBackground,
            appBar: AppBar(
              backgroundColor: context.cBackground,
              title: Text('Puanlama', style: context.titleLarge),
            ),
            body: SafeArea(
              child:
                  state.status == ViewStatus.loading &&
                      state.nearbyVisits.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.nearbyVisits.isEmpty
                  ? emptyState(context)
                  : SingleChildScrollView(
                      padding: context.paddingNormal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Deneyiminizi değerlendirin ve size özel avantajlardan yararlanın.',
                            style: context.bodyMedium,
                          ),
                          context.sizedHeightBoxNormal,
                          ...state.nearbyVisits.map((visit) {
                            final isSelected =
                                state.selectedVenueId == visit.venueId;
                            if (isSelected) {
                              return ratingForm(
                                context,
                                visit: visit,
                                starRating: state.starRating,
                                commentController: viewModel.commentController,
                                canSubmit: state.canSubmit,
                                isLoading: state.status == ViewStatus.loading,
                                onStarChanged: (r) =>
                                    viewModel.add(RatingStarChangedEvent(r)),
                                onCommentChanged: (c) =>
                                    viewModel.add(RatingCommentChangedEvent(c)),
                                onSubmit: () =>
                                    viewModel.add(RatingSubmittedEvent()),
                                onClose: () =>
                                    viewModel.add(RatingFormClosedEvent()),
                              );
                            }
                            return venueCard(
                              context,
                              visit: visit,
                              onTap: () => viewModel.add(
                                RatingVenueSelectedEvent(visit.venueId),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
