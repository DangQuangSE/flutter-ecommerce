class PagedResult<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int page;
  final bool isLast;

  const PagedResult({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.page,
    required this.isLast,
  });

  factory PagedResult.fromSpringPage(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    final content = (json['content'] as List?)
            ?.map((e) => mapper(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PagedResult(
      content: content,
      totalElements: json['totalElements'] as int? ?? content.length,
      totalPages: json['totalPages'] as int? ?? 1,
      page: json['number'] as int? ?? 0,
      isLast: json['last'] as bool? ?? true,
    );
  }
}
