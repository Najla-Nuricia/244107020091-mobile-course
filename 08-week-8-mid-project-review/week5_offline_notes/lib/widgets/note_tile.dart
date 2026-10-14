import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(note.title),
      subtitle: Text(
        note.body.isEmpty ? 'Tidak ada isi' : note.body,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: CircleAvatar(child: Text('${note.id ?? '-'}')),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            const Chip(
              label: Text('Belum tersinkron'),
              avatar: Icon(Icons.cloud_upload_outlined, size: 16),
            )
          else
            const Icon(Icons.check_circle_outline),
          if (onDelete != null)
            IconButton(
              tooltip: 'Hapus catatan',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
    );
  }
}
