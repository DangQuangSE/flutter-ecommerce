import 'package:dio/dio.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_socket_client.dart';
import 'package:flutter_ecommerce/features/chat/data/models/chat_model.dart';
import 'package:flutter_ecommerce/features/chat/data/models/message_model.dart';
import 'package:flutter_ecommerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailingChatRemoteDataSource implements ChatRemoteDataSource {
  @override
  Future<List<ChatModel>> getConversations() {
    final request = RequestOptions(path: '/api/chat/conversations');
    throw DioException.badResponse(
      statusCode: 500,
      requestOptions: request,
      response: Response<Map<String, dynamic>>(
        requestOptions: request,
        statusCode: 500,
        data: const {
          'message': 'DioException [bad response]: internal server details',
        },
      ),
    );
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) =>
      throw UnimplementedError();

  @override
  Future<MessageModel> sendMessage(String conversationId, String content) =>
      throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('getChats hides internal details from a Dio 500 response', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final socket = ChatSocketClient(AuthTokenStorage(LocalStorage(preferences)));
    final repository = ChatRepositoryImpl(_FailingChatRemoteDataSource(), socket);

    final result = await repository.getChats();

    expect(result, isA<ResultFailure<List<ChatEntity>>>());
    final failure = (result as ResultFailure<List<ChatEntity>>).failure;
    expect(failure, isA<NetworkFailure>());
    expect((failure as NetworkFailure).statusCode, 500);
    expect(
      failure.message,
      'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.',
    );

    await repository.dispose();
  });
}
