import 'package:flutter/material.dart';

import '../../ai/ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _service = AiService();
  final _questionController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _messages = <_ChatMessage>[];
  bool _sending = false;

  @override
  void dispose() {
    _questionController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _sending) return;
    setState(() {
      _messages.add(_ChatMessage(text: question, isUser: true));
      _questionController.clear();
      _sending = true;
    });
    try {
      final answer = await _service.ask(question);
      if (mounted) {
        setState(
          () => _messages.add(_ChatMessage(text: answer, isUser: false)),
        );
      }
    } catch (error) {
      if (mounted) {
        if (error is ApiKeyMissingException) {
          await _configureApiKey();
          setState(() => _messages.removeLast());
        } else {
          setState(() {
            _messages.add(
              _ChatMessage(text: 'Terjadi kesalahan: $error', isUser: false),
            );
          });
        }
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<bool> _configureApiKey() async {
    _apiKeyController.clear();
    final key = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur API key Gemini'),
        content: TextField(
          controller: _apiKeyController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'API key'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _apiKeyController.text),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (key == null || key.trim().isEmpty) return false;
    try {
      await _service.saveApiKey(key);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API key disimpan secara aman.')),
        );
      }
      return true;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan API key: $error')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            tooltip: 'Atur API key',
            icon: const Icon(Icons.key_outlined),
            onPressed: _configureApiKey,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text('Tanyakan sesuatu untuk memulai percakapan.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Card(
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(message.text),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_sending) const LinearProgressIndicator(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _questionController,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis pertanyaan...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kirim',
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
