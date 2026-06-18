import 'package:flutter_ecommerce/core/constants/api_constants.dart';
import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/features/chat/data/models/chat_model.dart';
import 'package:flutter_ecommerce/features/chat/data/models/message_model.dart';

abstract interface class ChatRemoteDataSource {
  Future<List<ChatModel>> getConversations();
  Future<List<MessageModel>> getMessages(String conversationId);
  Future<MessageModel> sendMessage(String conversationId, String content);
}

/// Talks to `/api/chat/**` over the shared [DioClient] (Bearer token attached
/// from the logged-in user). Any authenticated user may chat; an ADMIN sees the
/// whole support inbox.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _dioClient;

  const ChatRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ChatModel>> getConversations() async {
    final response = await _dioClient.dio
        .get<Map<String, dynamic>>(ApiConstants.chatConversations);
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await _dioClient.dio.get<Map<String, dynamic>>(
      '${ApiConstants.chatConversations}/$conversationId/messages',
    );
    final data = response.data?['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageModel> sendMessage(
      String conversationId, String content) async {
    final response = await _dioClient.dio.post<Map<String, dynamic>>(
      '${ApiConstants.chatConversations}/$conversationId/messages',
      data: {'content': content},
    );
    final data = response.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Phản hồi gửi tin nhắn không hợp lệ');
    }
    return MessageModel.fromJson(data);
  }
}
