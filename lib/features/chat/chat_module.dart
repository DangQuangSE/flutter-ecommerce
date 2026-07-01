import 'package:get_it/get_it.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:flutter_ecommerce/features/chat/data/datasources/chat_socket_client.dart';
import 'package:flutter_ecommerce/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_ecommerce/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_chats_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_ecommerce/features/chat/domain/usecases/send_message_usecase.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';

void setupChatModule(GetIt sl) {
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<ChatSocketClient>(
    () => ChatSocketClient(sl<AuthTokenStorage>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () =>
        ChatRepositoryImpl(sl<ChatRemoteDataSource>(), sl<ChatSocketClient>()),
  );
  sl.registerLazySingleton<GetChatsUseCase>(
    () => GetChatsUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetMessagesUseCase>(
    () => GetMessagesUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<ChatCubit>(
    () => ChatCubit(
      getChatsUseCase: sl<GetChatsUseCase>(),
      getMessagesUseCase: sl<GetMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      repository: sl<ChatRepository>(),
    ),
  );
}
