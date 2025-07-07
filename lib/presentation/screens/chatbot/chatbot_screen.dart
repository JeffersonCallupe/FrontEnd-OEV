import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<List<Message>> {
  ChatNotifier() : super([]);
  final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: "https://agent-470f8f0e0603da1d8551-vnc7h.ondigitalocean.app/api/v1/",
      // headers: {"Authorization": "Bearer LP0_1V55hh5Llm5aalw0MQLpcetVZPEo"},
      baseUrl: "https://ieoytyq5zhb23qvtcpwdopcy.agents.do-ai.run/api/v1/chat/completions",
      headers: {"Authorization": "Bearer KQiGvICbEqld9-tsiBPnCg0_-b4JqujV"},
    ),
  );
// oAmWJsXqmHRRp2Zl1T6t_d22AbwHiX2X
// KQiGvICbEqld9-tsiBPnCg0_-b4JqujV

  Future<void> sendMessage(String content) async {
    state = [...state, Message(content: content, isUser: true)];
    state = [...state, Message(content: "OEV Bot typing...", isUser: false)];
    try {
      final response = await _dio.post("chat/completions", data: {
        "model": "llama-3.1-instruct-8b",
        "messages": [
          {"role": "user", "content": content}
        ]
      });
      final reply = response.data["choices"][0]["message"]["content"];
      state = [...state.sublist(0, state.length - 1), Message(content: reply, isUser: false)];
    } catch (e) {
      state = [...state.sublist(0, state.length - 1), Message(content: "Error al obtener respuesta", isUser: false)];
    }
  }

  void clearChat() {
    state = [];
  }

  void startConversation() {
    state = [Message(content: "Hola! ¿En qué puedo ayudarte hoy?", isUser: false)];
  }
}

class Message {
  final String content;
  final bool isUser;
  Message({required this.content, required this.isUser});
}

class ChatScreen extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Center(
            child: Text('OEV Chatbot', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyChatUI(ref) 
              : _buildChatMessages(ref, messages), 
        ),
        if (messages.isNotEmpty) _buildChatControls(context, ref), // Controles cuando hay mensajes
      ],
    );
  }

  /// UI cuando el chat está vacío
  Widget _buildEmptyChatUI(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smart_toy_rounded, size: 100, color: Colors.white),
          ElevatedButton(
            onPressed: () => ref.read(chatProvider.notifier).startConversation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Iniciar conversación',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// UI del chat con mensajes
  Widget _buildChatMessages(WidgetRef ref, List<Message> messages) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blueAccent : const Color.fromARGB(255, 60, 60, 80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            if (index == 0 && message.content == "Hola! ¿En qué puedo ayudarte hoy?") _buildQuickReplyButtonList(ref),
          ],
        );
      },
    );
  }

  /// Botones de respuestas rápidas
  Widget _buildQuickReplyButtonList(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuickReplyButton(ref, "¿Cómo funcionan los cursos?"),
          _buildQuickReplyButton(ref, "¿Cuánto cuesta un curso?"),
          _buildQuickReplyButton(ref, "¿Recibo un certificado?"),
        ],
      ),
    );
  }

  Widget _buildQuickReplyButton(WidgetRef ref, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        onPressed: () => ref.read(chatProvider.notifier).sendMessage(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 50, 50, 70),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  /// Controles del chat (input y botón de finalizar)
  Widget _buildChatControls(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () => _showConfirmationDialog(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Finalizar chat',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 45, 45, 60),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    ref.read(chatProvider.notifier).sendMessage(_controller.text);
                    _controller.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Modal de confirmación para finalizar el chat
  Future<void> _showConfirmationDialog(WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: ref.context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 45, 45, 60),
          title: const Text("Confirmar", style: TextStyle(color: Colors.white)),
          content: const Text("¿Deseas finalizar el chat?", style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar", style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Aceptar", style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
    if (confirm == true) ref.read(chatProvider.notifier).clearChat();
  }
}
