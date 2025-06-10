import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  final String username;
  final String password;

  ChatPage({required this.username, required this.password});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Make socket nullable to handle cases where it might not be initialized
  IO.Socket? socket;
  List<_ChatMessage> messages = [];
  TextEditingController _controller = TextEditingController();
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _performLogin(); // Start login process
  }

  Future<void> _performLogin() async {
    print('Attempting to log in for user: ${widget.username}');
    try {
      final response = await http.post(
        Uri.parse('http://37.63.57.37:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': widget.username,
          'password': widget.password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _authToken = responseData['token'];
        });

        _connectSocket();
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please check credentials.')),
        );
      }
    } catch (e) {
      print('Error during login process: $e');
      // Provide user feedback for network issues
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error or server unreachable during login.')),
      );
    }
  }

  void _connectSocket() {
    if (_authToken == null) {
      print('Authentication token is null, cannot connect to socket. Aborting _connectSocket.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot connect to chat: authentication failed.')),
      );
      return; // Prevent connecting without a token
    }

    final String socketUrl = 'http://37.63.57.37:3000'; // ** IMPORTANT: Adjust this URL **
    // For Android Emulator: http://10.0.2.2:3000
    // For Physical Device: http://YOUR_MACHINE_IP_ADDRESS:3000

    print('Attempting to connect to Socket.IO at $socketUrl with token: $_authToken');

    // Initialize the socket
    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {'token': _authToken},
    });

    socket!.connect(); // Use `!` because we've just initialized it above

    // --- Socket Event Listeners (Crucial for Debugging) ---
    socket!.onConnect((_) {
      socket!.emit('join', widget.username); // Still emit join after successful connection

    });

    socket!.onConnectError((err) {
      print('Socket Connect Error: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat connection error: $err')),
      );
    });

    socket!.onConnectTimeout((err) {
      print('Socket Connect Timeout: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat connection timed out: $err')),
      );
    });

    socket!.onError((err) {
      print('Socket General Error: $err');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat error: $err')),
      );
    });

    socket!.onDisconnect((reason) {
      print('Socket Disconnected: $reason');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disconnected from chat: $reason')),
      );
    });

    socket!.on('message', (data) {
      if (data is Map && data.containsKey('username') && data.containsKey('message')) {
        setState(() {
          messages.add(
            _ChatMessage(
              username: data['username'],
              message: data['message'],
            ),
          );
        });
      } else {
        print('Received invalid message format: $data');
      }
    });

    socket!.onAny((event, data) {
      print('Socket Event: $event, Data: $data');
    });
  }

  void _sendMessage() {
    // Only attempt to send if the socket is initialized and connected
    if (socket != null && socket!.connected && _controller.text.trim().isNotEmpty) {
      print('Sending message: ${_controller.text.trim()}');
      socket!.emit('message', {
        'message': _controller.text.trim(),
        'username': widget.username,
      });
      _controller.clear();
    } else if (socket == null || !socket!.connected) {
      print('Cannot send message: Socket not connected.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot send message: Not connected to chat.')),
      );
    }
  }

  @override
  void dispose() {
    // Only dispose if the socket was actually initialized
    socket?.dispose(); // Use `?.` for null-safe disposal
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Room (${widget.username})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.username == widget.username;

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.username,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 4),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(
                            fontSize: 16,
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String username;
  final String message;

  _ChatMessage({required this.username, required this.message});
}