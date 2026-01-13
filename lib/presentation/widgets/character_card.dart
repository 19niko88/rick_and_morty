import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rick_and_morty/config/config.dart';
import 'package:rick_and_morty/domain/domain.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onFavoriteToggle;
  final String? heroTag;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onFavoriteToggle,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveHeroTag = heroTag ?? 'character_image_${character.id}';
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.router.push(CharacterDetailsRoute(
          id: character.id,
          heroTag: effectiveHeroTag,
        )),
        child: Stack(
          children: [
            Row(
              children: [
                Hero(
                  tag: effectiveHeroTag,
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    width: 120.sp,
                    height: 120.sp,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 120.sp,
                      height: 120.sp,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) =>  SizedBox(
                      width: 120.sp,
                      height: 120.sp,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                ),
                 SizedBox(width: 12.sp),
                Expanded(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(vertical: 8.0.sp, horizontal: 4.0.sp),
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
                         SizedBox(height: 4.sp),
                        _buildInfoRow(
                          Icons.circle,
                          '${character.status} - ${character.species}',
                          _getStatusColor(character.status),
                        ),
                         SizedBox(height: 4.sp),
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
              top: 4.sp,
              right: 4.sp,
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
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color statusColor) {
    return Row(
      children: [
        Icon(icon, size: 12, color: statusColor),
         SizedBox(width: 4.sp),
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
