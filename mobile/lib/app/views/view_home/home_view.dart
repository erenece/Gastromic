import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gastromic/app/views/view_home/view_model/home_view_model.dart';
import 'package:gastromic/app/views/view_home/widgets/home_widgets.dart';
import 'package:gastromic/core/enums/view_status.dart';
import 'package:gastromic/core/extensions/core_extensions.dart';

@RoutePage()
class HomeView extends StatelessWidget with HomeWidgets {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeViewModel()..add(HomeInitialEvent()),
      child: BlocBuilder<HomeViewModel, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: context.cBackground,
            body: SafeArea(
              child: state.status == ViewStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: context.paddingNormal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          header(context, locationName: state.locationName),
                          context.sizedHeightBoxNormal,
                          mapCard(context, onExplore: () {}),
                          context.sizedHeightBoxMedium,
                          nearbySection(
                            context,
                            venues: state.nearbyVenues,
                            onVenueTap: (venue) {},
                            onSeeAll: () {},
                          ),
                          context.sizedHeightBoxMedium,
                          favoritesSection(
                            context,
                            venues: state.favoriteVenues,
                            onVenueTap: (venue) {},
                          ),
                          context.sizedHeightBoxMedium,
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
