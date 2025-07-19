class BriefQuestion {
  final String id;
  final String question;
  final List<String> options;
  final String type; // 'chips' or 'text'
  final bool allowMultiple;

  BriefQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.type,
    this.allowMultiple = false,
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
