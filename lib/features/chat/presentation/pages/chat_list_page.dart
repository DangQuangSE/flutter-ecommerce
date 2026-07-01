import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/list/chat_list_app_bar.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/list/chat_list_error_view.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/list/chat_list_filters.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/list/chat_room_list.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChatCubit>().loadChats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() => _searchQuery = value);
  }

  void _handleFilterChanged(String value) {
    setState(() => _selectedFilter = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: const ChatListAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatListFilters(
            searchController: _searchController,
            selectedFilter: _selectedFilter,
            searchQuery: _searchQuery,
            onSearchChanged: _handleSearchChanged,
            onFilterChanged: _handleFilterChanged,
          ),
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return switch (state) {
                  ChatLoading() => const AppLoadingView(),
                  ChatsLoaded(:final chats) => ChatRoomList(
                      chats: chats,
                      selectedFilter: _selectedFilter,
                      searchQuery: _searchQuery,
                    ),
                  ChatError(:final message) => ChatListErrorView(
                      message: message,
                      onRetry: context.read<ChatCubit>().loadChats,
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
