import 'package:get/get.dart';

class DesignDataService extends GetxService {
  static DesignDataService get instance => Get.find();
  
  // Store user answers from all three questionnaires
  final RxMap<String, dynamic> creativeBriefData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> refinedConceptData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> finalDetailsData = <String, dynamic>{}.obs;
  
  // Creative Brief Methods
  void updateCreativeBrief(String key, dynamic value) {
    creativeBriefData[key] = value;
  }
  
  void setCreativeBriefData(Map<String, dynamic> data) {
    creativeBriefData.value = data;
  }
  
  Map<String, dynamic> getCreativeBriefData() {
    // ignore: invalid_use_of_protected_member
    return Map<String, dynamic>.from(creativeBriefData.value);
  }
  
  // Refined Concept Methods
  void updateRefinedConcept(String key, dynamic value) {
    refinedConceptData[key] = value;
  }
  
  void setRefinedConceptData(Map<String, dynamic> data) {
    refinedConceptData.value = data;
  }
  
  Map<String, dynamic> getRefinedConceptData() {
    // ignore: invalid_use_of_protected_member
    return Map<String, dynamic>.from(refinedConceptData.value);
  }
  
  // Final Details Methods
  void updateFinalDetails(String key, dynamic value) {
    finalDetailsData[key] = value;
  }
  
  void setFinalDetailsData(Map<String, dynamic> data) {
    finalDetailsData.value = data;
  }
  
  Map<String, dynamic> getFinalDetailsData() {
    // ignore: invalid_use_of_protected_member
    return Map<String, dynamic>.from(finalDetailsData.value);
  }
  
  // Get all data combined
  Map<String, dynamic> getAllDesignData() {
    return {
      'creativeBrief': getCreativeBriefData(),
      'refinedConcept': getRefinedConceptData(),
      'finalDetails': getFinalDetailsData(),
    };
  }
  
  // Clear all data
  void clearAllData() {
    creativeBriefData.clear();
    refinedConceptData.clear();
    finalDetailsData.clear();
  }
  
  // Check if all questionnaires are completed
  bool isAllDataComplete() {
    return creativeBriefData.isNotEmpty && 
           refinedConceptData.isNotEmpty && 
           finalDetailsData.isNotEmpty;
  }
  
  // Generate a comprehensive design prompt
  String generateDesignPrompt() {
    final allData = getAllDesignData();
    final creativeBrief = allData['creativeBrief'] as Map<String, dynamic>;
    final refinedConcept = allData['refinedConcept'] as Map<String, dynamic>;
    final finalDetails = allData['finalDetails'] as Map<String, dynamic>;
    
    StringBuffer prompt = StringBuffer();
    prompt.write('Design a fashion garment with the following specifications: ');
    
    // Add creative brief details
    if (creativeBrief.containsKey('garmentType')) {
      prompt.write('${creativeBrief['garmentType']} ');
    }
    if (creativeBrief.containsKey('targetAudience')) {
      prompt.write('for ${creativeBrief['targetAudience']}, ');
    }
    if (creativeBrief.containsKey('occasion')) {
      prompt.write('suitable for ${creativeBrief['occasion']}, ');
    }
    
    // Add refined concept details
    if (refinedConcept.containsKey('style')) {
      prompt.write('with ${refinedConcept['style']} style, ');
    }
    if (refinedConcept.containsKey('colors')) {
      prompt.write('using colors: ${refinedConcept['colors']}, ');
    }
    if (refinedConcept.containsKey('materials')) {
      prompt.write('made from ${refinedConcept['materials']}, ');
    }
    
    // Add final details
    if (finalDetails.containsKey('fit')) {
      prompt.write('with ${finalDetails['fit']} fit, ');
    }
    if (finalDetails.containsKey('details')) {
      prompt.write('featuring ${finalDetails['details']}, ');
    }
    if (finalDetails.containsKey('finishing')) {
      prompt.write('finished with ${finalDetails['finishing']}. ');
    }
    
    prompt.write('Create a professional fashion illustration showing the complete garment design, high quality, detailed, fashion sketch style.');
    // print('object: ${prompt.toString()}');
    return prompt.toString();
  }
}