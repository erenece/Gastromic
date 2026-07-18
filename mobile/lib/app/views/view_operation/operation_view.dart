import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_operation/view_model/operation_view_model.dart';
import 'package:gastromic/app/views/view_operation/widgets/operation_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class OperationView extends StatelessWidget with OperationWidgets {
  OperationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OperationViewModel()..add(OperationInitialEvent()),
      child: BlocBuilder<OperationViewModel, OperationState>(
        builder: (context, state) {
          final viewModel = context.read<OperationViewModel>();

          if (state.status == ViewStatus.loading) {
            return Scaffold(
              backgroundColor: context.cBackground,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: context.cBackground,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: mapArea(
                            context,
                            venues: state.filteredVenues,
                            selectedVenueId: state.selectedVenueId,
                            onPinTap: (id) =>
                                viewModel.add(OperationVenueSelectedEvent(id)),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => context.router.maybePop(),
                            child: Container(
                              padding: context.paddingLow,
                              decoration: BoxDecoration(
                                color: context.cSurface.withValues(alpha: 0.95),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: context.cTextPrimary,
                              ),
                            ),
                          ),
                        ),
                        if (state.selectedVenue != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: venueCard(
                              context,
                              venue: state.selectedVenue!,
                              onDetail: () => context.router.push(
                                VenueDetailViewRoute(
                                  venueId: state.selectedVenue!.id,
                                ),
                              ),
                              onClose: () =>
                                  viewModel.add(OperationCardClosedEvent()),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: filters(
                        context,
                        priceRange: state.priceRange,
                        busynessThreshold: state.busynessThreshold,
                        openNowOnly: state.openNowOnly,
                        onPriceChanged: (r) =>
                            viewModel.add(OperationPriceRangeChangedEvent(r)),
                        onBusynessChanged: (b) =>
                            viewModel.add(OperationBusynessChangedEvent(b)),
                        onOpenNowChanged: (_) =>
                            viewModel.add(OperationOpenNowToggledEvent()),
                      ),
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
