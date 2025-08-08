class DesignModel {
  final String designId;
  final String userId;
  final Map<String, dynamic> questionnaire;
  final String designImageUrl;
  final bool selected;
  final DateTime createdAt;

  DesignModel({
    required this.designId,
    required this.userId,
    required this.questionnaire,
    required this.designImageUrl,
    required this.selected,
    required this.createdAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'designId': designId,
      'userId': userId,
      'questionnaire': questionnaire,
      'designImageUrl': designImageUrl,
      'selected': selected,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map (Firestore document)
  factory DesignModel.fromMap(Map<String, dynamic> map) {
    return DesignModel(
      designId: map['designId'] ?? '',
      userId: map['userId'] ?? '',
      questionnaire: Map<String, dynamic>.from(map['questionnaire'] ?? {}),
      designImageUrl: map['designImageUrl'] ?? '',
      selected: map['selected'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Create copy with updated fields
  DesignModel copyWith({
    String? designId,
    String? userId,
    Map<String, dynamic>? questionnaire,
    String? designImageUrl,
    bool? selected,
    DateTime? createdAt,
  }) {
    return DesignModel(
      designId: designId ?? this.designId,
      userId: userId ?? this.userId,
      questionnaire: questionnaire ?? this.questionnaire,
      designImageUrl: designImageUrl ?? this.designImageUrl,
      selected: selected ?? this.selected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DesignModel(designId: $designId, userId: $userId, selected: $selected, createdAt: $createdAt)';
  }
}