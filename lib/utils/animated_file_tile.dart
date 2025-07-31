import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedFileTile extends StatelessWidget {
  final String fileName;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AnimatedFileTile({
    Key? key,
    required this.fileName,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
            title: Text(
              fileName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete, // Call the delete callback
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.blue),
              ],
            ),
            tileColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
