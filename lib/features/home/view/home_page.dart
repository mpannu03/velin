import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/recent/recent.dart';
import 'package:velin/core/result/result.dart';

import '../home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: BlocListener<HomeBloc, HomeState>(
        listenWhen: (previous, current) =>
            previous.openToken != current.openToken,
        listener: (context, state) => context.go('/reader'),
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final bloc = context.read<HomeBloc>();
            return HomeView(
              viewModel: HomeViewModel(
                recentDocuments: state.recentDocuments,
                isOpening: state.isOpening,
                onRecentDocumentSelected: (RecentDocument document) {
                  bloc.add(HomeRecentDocumentSelected(document));
                },
                onOpenDocument: () => bloc.add(const HomeOpenRequested()),
                onBrowseTools: () => context.go('/tools'),
                thumbnailLoader: (path) async {
                  final result = await getIt<ThumbnailRepository>().get(path);
                  return switch (result) {
                    Success(:final data) => data,
                    Failure() => null,
                  };
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
