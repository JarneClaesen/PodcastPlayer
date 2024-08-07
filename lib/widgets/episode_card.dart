import 'dart:typed_data';
import 'package:flutter/material.dart';

class EpisodeCard extends StatelessWidget {
  final String episodeTitle;
  final double progressPercentage;
  final VoidCallback onTap;
  final Uint8List? albumArtData;
  final int episodeNumber;  // Added for episode number

  const EpisodeCard({
    Key? key,
    required this.episodeTitle,
    required this.progressPercentage,
    required this.onTap,
    this.albumArtData,
    required this.episodeNumber,  // Required for episode number
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: albumArtData != null
                        ? Image.memory(
                      albumArtData!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    )
                        : Image.asset(
                      'assets/images/placeholder.jpg',
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$episodeNumber: $episodeTitle",  // Episode number added
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 100),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progressPercentage,
                                minHeight: 4,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}