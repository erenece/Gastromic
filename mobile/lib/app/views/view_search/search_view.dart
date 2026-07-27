import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_search/view_model/search_view_model.dart';
import 'package:gastromic/app/views/view_search/widgets/search_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';
import 'package:gastromic/core/models/venue_model.dart';

@RoutePage()
class SearchView extends StatelessWidget with SearchWidgets {
  SearchView({super.key});

  void _openVenue(BuildContext context, SearchViewModel viewModel, VenueModel venue) {
    final query = viewModel.searchController.text.trim();
    if (query.isNotEmpty) {
      viewModel.add(SearchVenueSelectedEvent(query));
    }
    context.router.push(VenueDetailViewRoute(venueId: venue.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchViewModel()..add(SearchInitialEvent()),
      child: BlocBuilder<SearchViewModel, SearchState>(
        builder: (context, state) {
          final viewModel = context.read<SearchViewModel>();
          return Scaffold(
            backgroundColor: context.cBackground,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: context.paddingNormal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBar(
                      context,
                      controller: viewModel.searchController,
                      onChanged: (value) =>
                          viewModel.add(SearchQueryChangedEvent(value)),
                      onSubmitted: (value) =>
                          viewModel.add(SearchSubmittedEvent(value)),
                      onFilterTap: () {},
                    ),
                    context.sizedHeightBoxNormal,
                    if (state.status == ViewStatus.loading &&
                        state.recentSearches.isEmpty &&
                        state.frequentVenues.isEmpty)
                      Padding(
                        padding: context.paddingHigh,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (state.isSearching) ...[
                      if (state.status == ViewStatus.loading)
                        Padding(
                          padding: context.onlyBottomPaddingNormal,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: context.cPrimary,
                                ),
                              ),
                              context.sizedWidthBoxLow,
                              Text('Aranıyor...', style: context.bodyMedium),
                            ],
                          ),
                        ),
                      if (state.query.trim().length == 1)
                        Padding(
                          padding: context.paddingHigh,
                          child: Center(
                            child: Text(
                              'Aramak için en az 2 karakter girin',
                              style: context.bodyMedium,
                            ),
                          ),
                        )
                      else
                        resultsList(
                          context,
                          results: state.results,
                          onVenueTap: (venue) =>
                              _openVenue(context, viewModel, venue),
                        ),
                    ] else ...[
                      recentSection(
                        context,
                        recentSearches: state.recentSearches,
                        onRecentTap: (query) =>
                            viewModel.add(SearchRecentTappedEvent(query)),
                        onClear: () => viewModel.add(SearchClearRecentEvent()),
                      ),
                      context.sizedHeightBoxMedium,
                      frequentGrid(
                        context,
                        venues: state.frequentVenues,
                        onVenueTap: (venue) =>
                            _openVenue(context, viewModel, venue),
                      ),
                    ],
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
