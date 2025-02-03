import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  WebSocketChannel? _channel;
  final String _url;
  final Duration _reconnectDelay;
  final Function(dynamic) _onMessage;
  final Function() _onReconnect;

  WebSocketManager(this._url, this._onMessage, this._onReconnect,
      [this._reconnectDelay = const Duration(seconds: 5)]);

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(_url));

    _channel!.stream.listen(
      (message) {
        try {
          final decodedMessage = jsonDecode(message);
          _onMessage(decodedMessage);
        } catch (e) {
          print('Error decoding message: $e');
        }
      },
      onDone: () {
        print('WebSocket closed');
        _reconnect();
      },
      onError: (error) {
        print('WebSocket error: $error');
        _reconnect();
      },
    );
  }

  void _reconnect() {
    Future.delayed(_reconnectDelay, () {
      connect();
      _onReconnect();
    });
  }

  void send(dynamic message) {
    if (_channel != null) {
      _channel!.sink.add(message);
    }
  }

//   void send(dynamic message) {
//   if (_channel != null) {
//     _channel!.sink.add(message);
//   } else {
//     print('WebSocket is not connected. Attempting to reconnect...');
//     _reconnect();
//   }
// }


  void dispose() {
    _channel?.sink.close();
  }
}
