import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/core/recent/recent.dart';

import '../home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(HomeStarted()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => HomeView(
          viewModel: HomeViewModel(
            recentDocuments: state.recentDocuments,
            onRecentDocumentSelected: (RecentDocument document) {
              context.read<HomeBloc>().add(
                HomeRecentDocumentSelected(document),
              );
              context.go('reader');
            },
          ),
        ),
      ),
    );
  }
}
