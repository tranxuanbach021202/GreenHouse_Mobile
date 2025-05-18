import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'notification_service.dart';

class WebSocketService {
  StompClient? _stompClient;
  final String userId;

  WebSocketService(this.userId);

  void connect() {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://localhost:8088/ws', // nếu chạy trên thiết bị thật => đổi sang IP LAN
        onConnect: _onConnect,
        onStompError: (frame) => print('STOMP error: ${frame.body}'),
        onWebSocketError: (error) => print('WebSocket error: $error'),
        reconnectDelay: Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    final destination = '/topic/invitations/$userId';
    print('🟢 Connected. Subscribing to $destination');

    _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          final data = jsonDecode(frame.body!);
          print('📩 Lời mời nhận được: $data');

          // NotificationService.showNotification(
          //   id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // tránh trùng ID
          //   title: 'Lời mời tham gia dự án',
          //   body: '${data['inviterName']} mời bạn vào "${data['projectName']}"',
          // );
        }
      },
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}
