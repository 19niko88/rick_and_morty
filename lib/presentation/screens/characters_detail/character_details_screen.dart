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
    return BlocProvider(
      create: (context) =>
          getIt<CharacterDetailsBloc>()..add(CharacterDetailsEvent.fetch(id)),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: BlocBuilder<CharacterDetailsBloc, CharacterDetailsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (message) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      message.contains('offline')
                          ? 'Data not available offline'
                          : 'Loading error: $message',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 450.sp,
          pinned: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(color: Colors.black87),
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
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Light Gradient Overlay
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black26,
                        Colors.transparent,
                        Colors.white70,
                        Colors.white,
                      ],
                      stops: [0.0, 0.4, 0.85, 1.0],
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
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.sp),
                      Text(
                        '${character.species} • ${character.gender}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
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
              _buildSectionTitle('Status & Species'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildLightChip(
                    character.status,
                    _getStatusColor(character.status),
                  ),
                  _buildLightChip(character.species, Colors.blueGrey),
                  _buildLightChip(character.gender, Colors.indigo),
                  if (character.type.isNotEmpty)
                    _buildLightChip(character.type, Colors.teal),
                ],
              ),
              SizedBox(height: 32.sp),
              _buildSectionTitle('About'),
              SizedBox(height: 12.sp),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50], // Very light background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  '${character.name} is a ${character.species.toLowerCase()} character. '
                  'The current status is ${character.status.toLowerCase()}. '
                  'Appeared in ${character.episode.length} episodes.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
              ),
               SizedBox(height: 32.sp),
              _buildSectionTitle('Information Details'),
               SizedBox(height: 16.sp),
              _buildLightInfoTile(
                Icons.public,
                'Origin',
                character.origin.name,
              ),
              _buildLightInfoTile(
                Icons.location_on,
                'Last Location',
                character.location.name,
              ),
              _buildLightInfoTile(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLightChip(String label, Color color) {
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

  Widget _buildLightInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0.sp),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueGrey, size: 20),
          ),
          SizedBox(width: 16.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.sp),
                Divider(color: Colors.grey[100]),
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
