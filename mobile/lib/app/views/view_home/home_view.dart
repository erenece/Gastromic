import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gastromic/app/routes/app_router.dart';
import 'package:gastromic/app/views/view_home/view_model/home_view_model.dart';
import 'package:gastromic/app/views/view_home/widgets/home_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class HomeView extends StatelessWidget {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeViewModel()..add(HomeInitialEvent()),
      child: const _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent();

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent>
    with HomeWidgets, WidgetsBindingObserver {
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
      context.read<HomeViewModel>().add(HomeProximityCheckEvent());
      context.read<HomeViewModel>().add(HomeRefreshEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.cBackground,
          body: SafeArea(
            child: state.status == ViewStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      final vm = context.read<HomeViewModel>();
                      vm.add(HomeRefreshEvent());
                      await vm.stream.skip(1).first;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: context.paddingNormal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header(context, locationName: state.locationName),
                          if (state.activeNearbyVisit != null) ...[
                            context.sizedHeightBoxNormal,
                            activeVisitCard(
                              context,
                              visit: state.activeNearbyVisit!,
                              onRateTap: () {
                                AutoTabsRouter.of(context).setActiveIndex(2);
                              },
                            ),
                          ],
                          context.sizedHeightBoxNormal,
                          mapCard(
                            context,
                            onExplore: () {
                              context.router.push(OperationViewRoute());
                            },
                            userLat: state.userLat,
                            userLng: state.userLng,
                            venues: state.nearbyVenues,
                          ),
                          context.sizedHeightBoxMedium,
                          nearbySection(
                            context,
                            venues: state.nearbyVenues,
                            onVenueTap: (venue) {
                              context.router.push(
                                VenueDetailViewRoute(venueId: venue.id),
                              );
                            },
                            onSeeAll: () {},
                          ),
                          context.sizedHeightBoxMedium,
                          favoritesSection(
                            context,
                            venues: state.favoriteVenues,
                            onVenueTap: (venue) {
                              context.router.push(
                                VenueDetailViewRoute(venueId: venue.id),
                              );
                            },
                          ),
                          context.sizedHeightBoxMedium,
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
