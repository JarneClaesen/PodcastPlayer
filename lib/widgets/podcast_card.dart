import 'dart:typed_data';
import 'package:flutter/material.dart';

class PodcastCard extends StatelessWidget {
  final String podcastTitle;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool showCheckbox;
  final ValueChanged<bool?>? onCheckboxChanged;
  final Uint8List? albumArtData; // Added for album art

  const PodcastCard({
    Key? key,
    required this.podcastTitle,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    this.showCheckbox = false,
    this.onCheckboxChanged,
    this.albumArtData, // Added for album art
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
            onLongPress: onLongPress,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  if (showCheckbox)
                    Checkbox(
                      value: isSelected,
                      onChanged: onCheckboxChanged,
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8), // Define the radius
                    child: albumArtData != null
                        ? Image.memory(
                      albumArtData!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    )
                        : Image.asset( // Changed to Image.asset
                      'assets/images/placeholder.jpg', // Local asset path
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                  ),
                  SizedBox(width: 8), // Spacing between image and text
                  Flexible(
                    child: Text(
                      podcastTitle,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
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
