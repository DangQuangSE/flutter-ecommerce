class SizeOptionDraft {
  String name;
  int displayOrder;

  SizeOptionDraft({required this.name, required this.displayOrder});

  SizeOptionDraft copyWith({String? name, int? displayOrder}) {
    return SizeOptionDraft(
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
