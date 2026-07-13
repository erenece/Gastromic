import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_search/view_model/search_view_model.dart';
import 'package:gastromic/app/views/view_search/widgets/search_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class SearchView extends StatelessWidget with SearchWidgets {
  SearchView({super.key});

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
                      onChanged: (v) =>
                          viewModel.add(SearchQueryChangedEvent(v)),
                      onFilterTap: () {
                        // filtre paneli
                      },
                    ),
                    context.sizedHeightBoxNormal,
                    if (state.status == ViewStatus.loading)
                      Padding(
                        padding: context.paddingHigh,
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (state.isSearching)
                      resultsList(
                        context,
                        results: state.results,
                        onVenueTap: (venue) {
                          //  VenueDetailView
                        },
                      )
                    else ...[
                      recentSection(
                        context,
                        recentSearches: state.recentSearches,
                        onRecentTap: (q) =>
                            viewModel.add(SearchRecentTappedEvent(q)),
                        onClear: () => viewModel.add(SearchClearRecentEvent()),
                      ),
                      context.sizedHeightBoxMedium,
                      frequentGrid(
                        context,
                        venues: state.frequentVenues,
                        onVenueTap: (venue) {
                          //  VenueDetailView
                        },
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
