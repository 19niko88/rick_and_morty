import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';
import 'bloc/character_details_bloc.dart';

@RoutePage()
class CharacterDetailsScreen extends StatelessWidget {
  final int id;
  final String? heroTag;

  const CharacterDetailsScreen({super.key, required this.id, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocProvider(
      create: (context) =>
          getIt<CharacterDetailsBloc>()..add(CharacterDetailsEvent.fetch(id)),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: colorScheme.surface,
        body: BlocBuilder<CharacterDetailsBloc, CharacterDetailsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      message.contains('offline')
                          ? 'Data not available offline'
                          : 'Loading error: $message',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<CharacterDetailsBloc>().add(
                        CharacterDetailsEvent.fetch(id),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              loaded: (character) =>
                  _CharacterDetailsBody(character: character, heroTag: heroTag),
            );
          },
        ),
      ),
    );
  }
}

class _CharacterDetailsBody extends StatelessWidget {
  final Character character;
  final String? heroTag;

  const _CharacterDetailsBody({required this.character, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 450.sp,
          pinned: true,
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: BackButton(color: colorScheme.onSurface),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Header Image
                Hero(
                  tag: heroTag ?? 'character_image_${character.id}',
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ),
                // Gradient Overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        colorScheme.surface.withValues(alpha: 0.8),
                        colorScheme.surface,
                      ],
                      stops: const [0.0, 0.4, 0.85, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20.sp,
                  left: 20.sp,
                  right: 20.sp,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.sp),
                      Text(
                        '${character.species} • ${character.gender}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Details Content
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.sp, vertical: 24.sp),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle(context, 'Status & Species'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildLightChip(
                    context,
                    character.status,
                    _getStatusColor(character.status),
                  ),
                  _buildLightChip(context, character.species, colorScheme.secondary),
                  _buildLightChip(context, character.gender, colorScheme.tertiary),
                  if (character.type.isNotEmpty)
                    _buildLightChip(context, character.type, colorScheme.primary),
                ],
              ),
              SizedBox(height: 32.sp),
              _buildSectionTitle(context, 'About'),
              SizedBox(height: 12.sp),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  '${character.name} is a ${character.species.toLowerCase()} character. '
                  'The current status is ${character.status.toLowerCase()}. '
                  'Appeared in ${character.episode.length} episodes.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ),
               SizedBox(height: 32.sp),
              _buildSectionTitle(context, 'Information Details'),
               SizedBox(height: 16.sp),
              _buildLightInfoTile(
                context,
                Icons.public,
                'Origin',
                character.origin.name,
              ),
              _buildLightInfoTile(
                context,
                Icons.location_on,
                'Last Location',
                character.location.name,
              ),
              _buildLightInfoTile(
                context,
                Icons.history,
                'First Created',
                character.created.toLocal().toString().split(' ')[0],
              ),
               SizedBox(height: 60.sp),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildLightChip(BuildContext context, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLightInfoTile(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.sp),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onSecondaryContainer, size: 20),
          ),
          SizedBox(width: 16.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.sp),
                Divider(color: colorScheme.outlineVariant),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
