class BriefQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String type; // 'chips', 'chips_categorized', 'text', 'image', 'checkbox'
  final bool allowMultiple;
  final Map<String, List<String>>? categories; // Optional: for categorized chips

  BriefQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
    this.allowMultiple = false,
    this.categories,
  });
}

class BriefAnswer {
  final String questionId;
  final List<String> selectedOptions;
  final String? textInput;

  BriefAnswer({
    required this.questionId,
    this.selectedOptions = const [],
    this.textInput,
  });
}
