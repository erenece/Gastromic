import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_rating/view_model/rating_view_model.dart';
import 'package:gastromic/app/views/view_rating/widgets/rating_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class RatingView extends StatelessWidget {
  RatingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RatingViewModel()..add(RatingInitialEvent()),
      child: const _RatingViewContent(),
    );
  }
}

class _RatingViewContent extends StatefulWidget {
  const _RatingViewContent();

  @override
  State<_RatingViewContent> createState() => _RatingViewContentState();
}

class _RatingViewContentState extends State<_RatingViewContent>
    with RatingWidgets, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<RatingViewModel>().add(RatingProximityCheckEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RatingViewModel, RatingState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage &&
              curr.errorMessage != null) ||
          (!prev.isSubmitted && curr.isSubmitted),
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
        if (state.isSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Değerlendirmeniz kaydedildi')),
          );
        }
      },
      builder: (context, state) {
        final viewModel = context.read<RatingViewModel>();
        final hasPending = state.nearbyVisits.isNotEmpty;
        final hasHistory = state.pastReviews.isNotEmpty;
        final isInitialLoading =
            state.status == ViewStatus.loading && !hasPending && !hasHistory;

        return Scaffold(
          backgroundColor: context.cBackground,
          appBar: AppBar(
            backgroundColor: context.cBackground,
            title: Text('Puanlama', style: context.titleLarge),
          ),
          body: SafeArea(
            child: isInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : !hasPending && !hasHistory
                ? emptyState(context)
                : SingleChildScrollView(
                    padding: context.paddingNormal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasPending) ...[
                          Text(
                            'Mekana ulaştınız — deneyiminizi değerlendirin.',
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
                                isLoading: state.isSubmitting,
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
                        if (hasHistory) ...[
                          if (hasPending) context.sizedHeightBoxMedium,
                          historySection(
                            context,
                            reviews: state.pastReviews,
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
