import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/locator/service_locator.dart';
import '../../blocs/character_details/character_details_bloc.dart';
import '../../../domain/models/character/character.dart';

@RoutePage()
class CharacterDetailsScreen extends StatelessWidget {
  final int id;
  final String? heroTag;

  const CharacterDetailsScreen({
    super.key,
    required this.id,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CharacterDetailsBloc>()..add(CharacterDetailsEvent.fetch(id)),
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
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<CharacterDetailsBloc>().add(CharacterDetailsEvent.fetch(id)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              loaded: (character) => _CharacterDetailsBody(
                character: character,
                heroTag: heroTag,
              ),
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

  const _CharacterDetailsBody({
    required this.character,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header with Light Gradient
        SliverAppBar(
          expandedHeight: 450,
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
                      child: const Icon(Icons.person, size: 100, color: Colors.grey),
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
                        Colors.black26, // Top shadow for back button visibility
                        Colors.transparent,
                        Colors.white70,
                        Colors.white,
                      ],
                      stops: [0.0, 0.4, 0.85, 1.0],
                    ),
                  ),
                ),
                // Title and basic info on top of gradient
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
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
                      const SizedBox(height: 4),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildSectionTitle('Status & Species'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildLightChip(character.status, _getStatusColor(character.status)),
                  _buildLightChip(character.species, Colors.blueGrey),
                  _buildLightChip(character.gender, Colors.indigo),
                  if (character.type.isNotEmpty) _buildLightChip(character.type, Colors.teal),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('About'),
              const SizedBox(height: 12),
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
                    color: Colors.black.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Information Details'),
              const SizedBox(height: 16),
              _buildLightInfoTile(Icons.public, 'Origin', character.origin.name),
              _buildLightInfoTile(Icons.location_on, 'Last Location', character.location.name),
              _buildLightInfoTile(Icons.history, 'First Created', character.created.toLocal().toString().split(' ')[0]),
              const SizedBox(height: 60),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLightInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blueGrey, size: 20),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
