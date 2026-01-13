import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/character/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onFavoriteToggle;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Row(
            children: [
              // Character Image
              CachedNetworkImage(
                imageUrl: character.image,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => const SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(Icons.person, size: 50),
                ),
              ),
              const SizedBox(width: 12),
              // Character Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.circle,
                        '${character.status} - ${character.species}',
                        _getStatusColor(character.status),
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.location_on,
                        character.location.name,
                        Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Favorite Star Button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: Icon(
                character.isFavorite ? Icons.star : Icons.star_border,
                color: character.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color statusColor) {
    return Row(
      children: [
        Icon(icon, size: 12, color: statusColor),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
