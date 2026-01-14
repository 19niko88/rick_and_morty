import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/presentation/widgets/widgets.dart';
import 'package:rick_and_morty/utils/utils.dart';
import 'package:rick_and_morty/domain/domain.dart';
import 'bloc/characters_bloc.dart';


@RoutePage()
class CharacterListScreen extends StatelessWidget {
  const CharacterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CharactersBloc>()..add(const CharactersEvent.fetch()),
      child: const _CharacterListView(),
    );
  }
}

class _CharacterListView extends StatelessWidget {
  const _CharacterListView();

  void _onScrollNotification(BuildContext context, ScrollNotification notification) {
    if (notification is! ScrollEndNotification) return;

    final metrics = notification.metrics;
    final thresholdReached = metrics.pixels >= metrics.maxScrollExtent * 0.9;

    if (!thresholdReached) return;

    final bloc = context.read<CharactersBloc>();
    final state = bloc.state;

    state.maybeMap(
      loaded: (s) {
        if (!s.hasReachedMax) {
          bloc.add(const CharactersEvent.fetch());
        }
      },
      orElse: () {},
    );
  }

  Future<void> _showFilterDialog(BuildContext context, CharactersState state) async {
    final (name, status, species, type, gender) = state.maybeMap(
      loaded: (s) => (s.name, s.status, s.species, s.type, s.gender),
      orElse: () => (null, null, null, null, null),
    );

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => CharacterFilterDialog(
        initialName: name,
        initialStatus: status,
        initialSpecies: species,
        initialType: type,
        initialGender: gender,
      ),
    );

    if (result != null && context.mounted) {
      context.read<CharactersBloc>().add(
            CharactersEvent.updateFilters(
              name: result['name'],
              status: result['status'],
              species: result['species'],
              type: result['type'],
              gender: result['gender'],
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CharactersBloc, CharactersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, themeState) {
                return PopupMenuButton<AppThemeModeEnum>(
                  icon: Icon(_getThemeIcon(themeState.mode)),
                  onSelected: (mode) {
                    context.read<ThemeBloc>().add(ThemeEvent.changed(mode));
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: AppThemeModeEnum.system,
                      child: Text('System'),
                    ),
                    PopupMenuItem(
                      value: AppThemeModeEnum.light,
                      child: Text('Light'),
                    ),
                    PopupMenuItem(
                      value: AppThemeModeEnum.dark,
                      child: Text('Dark'),
                    ),
                  ],
                );
              },
            ),
            title: const Text('Characters'),
            centerTitle: true,
            actions: [
              BlocBuilder<ConnectivityStatusBloc, ConnectivityStatusState>(
                builder: (context, connectivityState) {
                  if (connectivityState.isConnected) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(right: 8.0.sp),
                    child: Icon(Icons.cloud_off, color: Colors.red),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: state.maybeMap(
                    loaded: (s) =>
                    (s.name != null ||
                        s.status != null ||
                        s.species != null ||
                        s.type != null ||
                        s.gender != null)
                        ? Colors.blue
                        : null,
                    orElse: () => null,
                  ),
                ),
                onPressed: () => _showFilterDialog(context, state),
              ),
            ],
          ),
          body: Column(
            children: [
              state.maybeMap(
                loaded: (s) {
                  final activeFilters = [
                    if (s.name != null) 'Name: ${s.name}',
                    if (s.status != null) 'Status: ${s.status}',
                    if (s.species != null) 'Species: ${s.species}',
                    if (s.gender != null) 'Gender: ${s.gender}',
                    if (s.type != null) 'Type: ${s.type}',
                  ];

                  if (activeFilters.isEmpty) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
                    child: Row(
                      children: [
                        const Text('Filters active: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Wrap(
                              spacing: 4,
                              children: activeFilters.map((f) => _buildFilterChip(f)).toList(),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.read<CharactersBloc>().add(const CharactersEvent.clearFilters()),
                          child: const Text('Clear', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              Expanded(
                child: state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (characters, hasReachedMax, name, status, species, type, gender) {
                    if (characters.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('No characters found for these filters'),
                            TextButton(
                              onPressed: () => context.read<CharactersBloc>().add(const CharactersEvent.clearFilters()),
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<CharactersBloc>().add(const CharactersEvent.refresh());
                      },
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          _onScrollNotification(context, notification);
                          return false;
                        },
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.sp),
                          itemCount: hasReachedMax ? characters.length : characters.length + 1,
                          separatorBuilder: (context, index) => SizedBox(height: 12.sp),
                          itemBuilder: (context, index) {
                            if (index >= characters.length) {
                              return Center(child: Padding(padding: EdgeInsets.all(8.0.sp), child: CircularProgressIndicator()));
                            }
                            final character = characters[index];
                            return CharacterCard(
                              character: character,
                              heroTag: 'list_${character.id}',
                              onFavoriteToggle: () {
                                context.read<CharactersBloc>().add(
                                      CharactersEvent.toggleFavorite(character.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                  error: (message) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: $message'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CharactersBloc>().add(const CharactersEvent.refresh());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 10)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  IconData _getThemeIcon(AppThemeModeEnum mode) {
    return switch (mode) {
      AppThemeModeEnum.system => Icons.brightness_auto,
      AppThemeModeEnum.light => Icons.brightness_low,
      AppThemeModeEnum.dark => Icons.brightness_2,
    };
  }
}
