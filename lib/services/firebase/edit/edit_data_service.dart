import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditDataService {
  static final EditDataService _instance = EditDataService._internal();
  factory EditDataService() => _instance;
  EditDataService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  // Get complete tech pack data including all questionnaire data
  Future<Map<String, dynamic>?> getTechPackEditData(String techPackId) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Fetching edit data for tech pack: $techPackId');

      // Get tech pack document
      final techPackDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tech_packs')
          .doc(techPackId)
          .get();

      if (!techPackDoc.exists) {
        print('Tech pack document not found');
        return null;
      }

      final techPackData = techPackDoc.data() as Map<String, dynamic>;
      print('Tech pack data found: ${techPackData.keys}');

      // Get design questionnaire data from designs collection
      Map<String, dynamic>? designQuestionnaireData;
      
      // Try to get from tech pack first (new structure)
      if (techPackData.containsKey('design_questionnaire')) {
        designQuestionnaireData = techPackData['design_questionnaire'] as Map<String, dynamic>?;
        print('Design questionnaire found in tech pack');
      } else {
        // Fallback: Get from designs collection (old structure)
        designQuestionnaireData = await _getDesignQuestionnaireFromDesigns(techPackData);
      }

      return {
        'techPackData': techPackData,
        'designQuestionnaire': designQuestionnaireData ?? {},
        'techPackDetails': techPackData['tech_pack_details'] ?? {},
      };
    } catch (e) {
      print('Error fetching tech pack edit data: $e');
      return null;
    }
  }

  // Fallback method to get design questionnaire from designs collection
  Future<Map<String, dynamic>?> _getDesignQuestionnaireFromDesigns(Map<String, dynamic> techPackData) async {
    try {
      final selectedDesignUrl = techPackData['selected_design_image_url'] as String?;
      if (selectedDesignUrl == null) return null;

      // Get designs document
      final designsDoc = await _firestore
          .collection('designs')
          .doc(currentUserId)
          .get();

      if (!designsDoc.exists) return null;

      final designsData = designsDoc.data();
      final designs = designsData?['designs'] as List<dynamic>? ?? [];

      // Find the design with matching URL
      for (var design in designs) {
        final designMap = design as Map<String, dynamic>;
        if (designMap['selectedDesignImageUrl'] == selectedDesignUrl) {
          return {
            'creativeBrief': designMap['creativeBrief'] ?? {},
            'refinedConcept': designMap['refinedConcept'] ?? {},
            'finalDetails': designMap['finalDetails'] ?? {},
          };
        }
      }

      return null;
    } catch (e) {
      print('Error fetching design questionnaire: $e');
      return null;
    }
  }

  // Update tech pack with edited data
  Future<void> updateTechPackData({
    required String techPackId,
    required Map<String, dynamic> designQuestionnaireData,
    Map<String, dynamic>? techPackDetailsData,
    String? newProjectName,
    String? newCollectionName,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      print('Updating tech pack: $techPackId');

      Map<String, dynamic> updateData = {
        'design_questionnaire': designQuestionnaireData,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (techPackDetailsData != null) {
        updateData['tech_pack_details'] = techPackDetailsData;
      }

      if (newProjectName != null) {
        updateData['project_name'] = newProjectName;
      }

      if (newCollectionName != null) {
        updateData['collection_name'] = newCollectionName;
      }

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('tech_packs')
          .doc(techPackId)
          .update(updateData);

      print('Tech pack updated successfully');
    } catch (e) {
      print('Error updating tech pack: $e');
      throw Exception('Failed to update tech pack: $e');
    }
  }

  // Parse questionnaire data from Firebase into UI-friendly format
  Map<String, dynamic> parseQuestionnaireForEdit(Map<String, dynamic> questionnaireData) {
    Map<String, dynamic> parsedData = {};

    // Parse creative brief data
    final creativeBrief = questionnaireData['creativeBrief'] as Map<String, dynamic>? ?? {};
    if (creativeBrief.isNotEmpty) {
      parsedData['creativeBrief'] = {
        'garment_type': creativeBrief['garmentType'] ?? '',
        'style': creativeBrief['style'] ?? '',
        'target_audience': creativeBrief['targetAudience'] ?? '',
        'occasion': creativeBrief['occasion'] ?? '',
        'inspiration': creativeBrief['inspiration'] ?? '',
        'colors': creativeBrief['colors'] ?? '',
        'fabrics': creativeBrief['fabrics'] ?? '',
      };
    }

    // Parse refined concept data
    final refinedConcept = questionnaireData['refinedConcept'] as Map<String, dynamic>? ?? {};
    if (refinedConcept.isNotEmpty) {
      parsedData['refinedConcept'] = {
        'garment_type': refinedConcept['silhouette'] ?? '',
        'specific_features': refinedConcept['features'] ?? '',
        'seasonal_constraint': refinedConcept['season'] ?? '',
        'target_budget': refinedConcept['budget'] ?? '',
        'functionalities_values': refinedConcept['values'] ?? '',
      };
    }

    // Parse final details data
    final finalDetails = questionnaireData['finalDetails'] as Map<String, dynamic>? ?? {};
    if (finalDetails.isNotEmpty) {
      parsedData['finalDetails'] = {
        'target_season': finalDetails['season'] ?? '',
        'target_budget': finalDetails['budget'] ?? '',
        'desired_features': finalDetails['features'] ?? '',
        'additional_details': finalDetails['additionalDetails'] ?? '',
      };
    }

    return parsedData;
  }

  // Parse tech pack details from Firebase into UI-friendly format
  Map<String, dynamic> parseTechPackDetailsForEdit(Map<String, dynamic> techPackDetails) {
    return {
      'materials': {
        'mainFabric': techPackDetails['materials']?['mainFabric'] ?? '',
        'secondaryMaterials': techPackDetails['materials']?['secondaryMaterials'] ?? '',
        'fabricProperties': techPackDetails['materials']?['fabricProperties'] ?? '',
      },
      'colors': {
        'primaryColor': techPackDetails['colors']?['primaryColor'] ?? '',
        'alternateColorways': techPackDetails['colors']?['alternateColorways'] ?? '',
        'pantone': techPackDetails['colors']?['pantone'] ?? '',
      },
      'sizes': {
        'sizeRange': techPackDetails['sizes']?['sizeRange'] ?? '',
        'measurementChart': techPackDetails['sizes']?['measurementChart'] ?? '',
        'measurementImage': techPackDetails['sizes']?['measurementImage'] ?? '',
      },
      'technical': {
        'accessories': techPackDetails['technical']?['accessories'] ?? '',
        'stitching': techPackDetails['technical']?['stitching'] ?? '',
        'decorativeStitching': techPackDetails['technical']?['decorativeStitching'] ?? '',
      },
      'labeling': {
        'logoPlacement': techPackDetails['labeling']?['logoPlacement'] ?? '',
        'labelsNeeded': techPackDetails['labeling']?['labelsNeeded'] ?? '',
        'qrCode': techPackDetails['labeling']?['qrCode'] ?? '',
      },
      'packaging': {
        'packagingType': techPackDetails['packaging']?['packagingType'] ?? '',
        'foldingInstructions': techPackDetails['packaging']?['foldingInstructions'] ?? '',
        'inserts': techPackDetails['packaging']?['inserts'] ?? '',
      },
      'production': {
        'costPerPiece': techPackDetails['production']?['costPerPiece'] ?? '',
        'quantity': techPackDetails['production']?['quantity'] ?? '',
        'deliveryDate': techPackDetails['production']?['deliveryDate'] ?? '',
      },
    };
  }
}