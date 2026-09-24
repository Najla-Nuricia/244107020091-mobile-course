import 'package:flutter/material.dart';

import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

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
      trailing: note.dirty
          ? const Chip(
              label: Text('Belum tersinkron'),
              avatar: Icon(Icons.cloud_upload_outlined, size: 16),
            )
          : const Icon(Icons.check_circle_outline),
    );
  }
}
