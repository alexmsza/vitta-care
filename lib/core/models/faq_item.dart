class FaqItem {
  final int id;
  final String category;
  final String question;
  final String answer;
  final int order;
  final List<String> targetRoles;
  final DateTime? updatedAt;

  FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    required this.order,
    required this.targetRoles,
    this.updatedAt,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        id: json['id'] as int,
        category: json['category'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        order: json['order'] as int? ?? 0,
        targetRoles: (json['target_roles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['professional', 'family'],
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );
}
