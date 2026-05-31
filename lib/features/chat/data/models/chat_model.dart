import '../../domain/entities/chat_entity.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.senderName,
    required super.senderAvatar,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.isOnline,
    super.tag,
    super.associatedProductImage,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      lastMessage: json['lastMessage'] as String,
      lastMessageTime: json['lastMessageTime'] as String,
      unreadCount: json['unreadCount'] as int,
      isOnline: json['isOnline'] as bool,
      tag: json['tag'] as String?,
      associatedProductImage: json['associatedProductImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
      'tag': tag,
      'associatedProductImage': associatedProductImage,
    };
  }

  static List<ChatModel> get mockChats => [
        const ChatModel(
          id: 'chat-support',
          senderName: 'CSKH SPORT PRO',
          senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs',
          lastMessage: 'Chào anh A, SPORT PRO rất vui được hỗ trợ...',
          lastMessageTime: '09:45',
          unreadCount: 1,
          isOnline: true,
          tag: 'Shop',
          associatedProductImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDfNUm_0FHTlwMSO97i6w_ybGmHoVLk34xXuVJ138ODeFyymicdmeoElKE4Dw81L669C3EY5e3nBvEaHO2ATTV4XRAbGpQa9oJk7YDslOWIh5l3Cet1fbGGmoW6374uazzBD6RKNWmaZ_9VmgeDnFssIy9zvvN1_YLcGOe8LXyWG63NcbpAyus8mOU5IT6-HZBiyV8msC80n3Zzr4JIoddV8XatdZ_RGD-GClcpI9keO_oHzq8zRr6z6giBAQ6BwerYe3LWlHOp31c',
        ),
        const ChatModel(
          id: 'chat-designer',
          senderName: 'Đội Thiết Kế 3D',
          senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNsCK1XmJqRobnD3tTy1kqfZCiNRjmHFuY5-2iQjp7h2mHUl93vToASiJxhC5EyQh9e9qD8sC8475sch3upof5rUoyE1lSnllXoUBF8z8Ddzx69UqXe0h3QDJE8YvTACRYdkP2Cykjnk5jo69OYKcksxwlnG4_dqbKriaAlbcWaBkEga6EhjgjWEglj2oUv5Hb0EOl-b7garyTBdgSomBqCTWYBkwiVqASyiNP0pGZE3lyjz3-DoEKY4sn41DnqBgeQJ6dLX3zCoM',
          lastMessage: 'Tuyệt vời. Đội ngũ thiết kế sẽ gửi bản vẽ trong 2h...',
          lastMessageTime: '09:50',
          unreadCount: 0,
          isOnline: true,
          tag: 'Hỗ trợ',
          associatedProductImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuC7QUqexWT8UObnocEW75IOV54pAgFrmMun4rvJuQhpsaEwEiB6J8a4WUnYc5qH3PyrJsdYr6jIVtINUJl7V-OlWpzFcChekbfSX-LZUIUlwMDmNGa6RbBZRyk-675LI0dRv7IUd_qeHLWtr9LKi-E6fwFCOuCbve308GWI6KDc4pdd5doLKTC0mmt_g8Hte_HAaXme3zp7_XFJ3tW-jTfXpkIbhZH0QpnqEOxjJzRHHsGKUdNxi5BNqy3zWEhPAeP2PEdFT5InfZA',
        ),
        const ChatModel(
          id: 'chat-shipping',
          senderName: 'Vận chuyển Hỏa tốc',
          senderAvatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDwk--53DEF-YXoLpWnUJSPlGIz5Brxpx_mZebOw8AGNE7n_oLzT-gBctcCz9DozLPzWiAYdyRQJkzYconebUR88s2yqg_zS3XMGuK5LZpW6aV9j7ZoNZZ8GA1qcKlmOHdfjAvJ--CV30TjBrJWajMjR0FWgsYIVAXM83XxGjQYoO2IYZL4oliOrAxYGH5oEgyLBnNVV9o953-KLQCjqQStBxlklX_3mTOGqzp314VRDiuJYri2oMKjES_CXplAPv9kHCa0M_tpEhk',
          lastMessage: 'Đơn hàng #SP2024-8839 đã đến trạm phân phối HN...',
          lastMessageTime: 'Hôm qua',
          unreadCount: 0,
          isOnline: false,
          tag: 'Đơn hàng',
          associatedProductImage: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCbXbEZkYN1PdBUeNwKfJKjjlBmd9AR-t3-OPPhAkxmS-Mgz39vRedxqhOq56wfXTGDPZbfO8HoGyJO5Qe5y34MjqP8pNlntjOGCbOz4huinr3D1M3fBM9zdSaNreqm8JVPI7GaG5s7z6Ol4nZNEt9w_BS5mLwpzD_KieykR9Jljkmk90gdb-zkjv55_oik-Ls1z_O6DBp-rgO6h81liKqVsjE71gmEQjfTU28A42cFidqRRk_MuQaKDdET5xZBolS-dRy434N85hg',
        ),
      ];
}
