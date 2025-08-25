import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _apiKeyKey = 'openai_api_key';
  
  static Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
  }
  
  static Future<String?> getApiKey() async {
    return await _storage.read(key: _apiKeyKey);
  }
  
  static Future<String?> _convertImageToBase64(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        print('OpenAI: Image file does not exist at path: $imagePath');
        return null;
      }
      
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      print('OpenAI: Converted inspiration image to base64 (${bytes.length} bytes)');
      return base64String;
    } catch (e) {
      print('OpenAI: Error converting image to base64: $e');
      return null;
    }
  }
  
  static Future<List<String>> generateTechPackImages({
    required String prompt,
    required Map<String, String> referenceImages,
    int numberOfImages = 1,
    String size = '1024x1024',
  }) async {
    try {
      print('OpenAI: Starting tech pack image generation...');
      print('OpenAI: Prompt: ${prompt.substring(0, 100)}...');
      print('OpenAI: Reference images: ${referenceImages.keys.toList()}');
      
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        print('OpenAI: ERROR - API key not found!');
        throw Exception('OpenAI API key not found');
      }
      
      // Use the main design image as the primary reference
      String? primaryImagePath = referenceImages['selectedDesign'];
      String? primaryImageBase64;
      
      if (primaryImagePath != null && primaryImagePath.isNotEmpty) {
        // Check if it's already base64 data or a file path
        if (primaryImagePath.startsWith('iVBOR') || primaryImagePath.startsWith('/9j/') || primaryImagePath.startsWith('R0lGOD')) {
          // It's already base64 data
          primaryImageBase64 = primaryImagePath;
          print('OpenAI: Using selected design as primary reference (already base64)');
        } else {
          // It's a file path, convert to base64
          primaryImageBase64 = await _convertImageToBase64(primaryImagePath);
          if (primaryImageBase64 != null) {
            print('OpenAI: Using selected design as primary reference (converted from file)');
          }
        }
      }
      
      // Truncate prompt to 1000 characters if necessary
      String safePrompt = prompt.length > 1000 ? prompt.substring(0, 1000) : prompt;
      if (prompt.length > 1000) {
        print('OpenAI: Prompt was too long (${prompt.length}), truncated to 1000 characters.');
      }
      
      // Enhance prompt with reference information
      if (referenceImages.containsKey('measurementChart')) {
        safePrompt += '. Include detailed measurements and size specifications as shown in the reference chart.';
      }
      if (referenceImages.containsKey('labelReference')) {
        safePrompt += '. Use the uploaded label examples for accurate label styling and placement.';
      }

      print('OpenAI: API key found, making request with enhanced prompt...');

      http.Response response;
      
      if (primaryImageBase64 != null) {
        // Use /v1/images/edits endpoint with form data when primary image is available
        print('OpenAI: Using /v1/images/edits endpoint with reference images');
        
        final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/images/edits'));
        request.headers['Authorization'] = 'Bearer $apiKey';
        
        // Add form fields
        request.fields['model'] = 'gpt-image-1';
        request.fields['prompt'] = safePrompt;
        request.fields['size'] = size;
        request.fields['n'] = numberOfImages.toString();
        
        // Add the primary image as the main reference
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          base64Decode(primaryImageBase64),
          filename: 'primary_reference.png',
        ));
        
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Use regular generation endpoint when no primary image
        print('OpenAI: Using /v1/images/generations endpoint (no primary reference image)');
        response = await http.post(
          Uri.parse('$_baseUrl/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-image-1',
            'prompt': safePrompt,
            'n': numberOfImages,
            'size': size,
          }),
        );
      }

      print('OpenAI: Response status code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('OpenAI: Tech pack image generation successful!');
        final data = jsonDecode(response.body);
        final List<dynamic> imageData = data['data'];
        
        List<String> base64Images = [];
        
        for (int i = 0; i < imageData.length; i++) {
          print('OpenAI: Adding tech pack image ${i + 1} base64 data.');
          base64Images.add(imageData[i]['b64_json']);
        }
        
        print('OpenAI: Total tech pack images generated: ${base64Images.length}');
        return base64Images;
      } else {
        print('OpenAI: Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate tech pack images: $e');
    }
  }

  static Future<List<String>> generateDesignImages({
    required String prompt,
    int numberOfImages = 3,
    String size = '1024x1024',
    String? inspirationImagePath,
  }) async {
    try {
      print('OpenAI: Starting image generation...');
      print('OpenAI: Prompt for images: $prompt');
      print('OpenAI: Number of images requested: $numberOfImages');
      print('OpenAI: Inspiration image path: ${inspirationImagePath ?? 'none'}');
      
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        print('OpenAI: ERROR - API key not found!');
        throw Exception('OpenAI API key not found');
      }
      
      // Convert inspiration image to base64 if provided
      String? inspirationBase64;
      if (inspirationImagePath != null && inspirationImagePath.isNotEmpty) {
        inspirationBase64 = await _convertImageToBase64(inspirationImagePath);
        if (inspirationBase64 != null) {
          print('OpenAI: Including inspiration image in generation request');
        }
      }
      
      // Truncate prompt to 1000 characters if necessary
      String safePrompt = prompt.length > 1000 ? prompt.substring(0, 1000) : prompt;
      if (prompt.length > 1000) {
        print('OpenAI: Prompt was too long (${prompt.length}), truncated to 1000 characters.');
      }

      print('OpenAI: API key found, making request to DALL-E 3...');

      http.Response response;
      
      if (inspirationBase64 != null) {
        // Use /v1/images/edits endpoint with form data when inspiration image is provided
        print('OpenAI: Using /v1/images/edits endpoint with inspiration image');
        
        final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/images/edits'));
        request.headers['Authorization'] = 'Bearer $apiKey';
        
        // Add form fields
        request.fields['model'] = 'gpt-image-1';
        request.fields['prompt'] = safePrompt;
        request.fields['size'] = size;
        request.fields['n'] = numberOfImages.toString();
        
        // Add the base64 image as a file
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          base64Decode(inspirationBase64),
          filename: 'base64decoded.png',
        ));
        
        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Use regular /v1/images/generations endpoint when no inspiration image
        print('OpenAI: Using /v1/images/generations endpoint (no inspiration image)');
        response = await http.post(
          Uri.parse('$_baseUrl/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-image-1',
            'prompt': safePrompt,
            'n': numberOfImages,
            'size': size,
          }),
        );
      }

      print('OpenAI: Response status code:  [32m${response.statusCode} [0m');
      
      if (response.statusCode == 200) {
        print('OpenAI: Image generation successful!');
        final data = jsonDecode(response.body);
        final List<dynamic> imageData = data['data'];
        
        List<String> base64Images = [];
        
        // Extract all base64 images from the response
        for (int i = 0; i < imageData.length; i++) {
          print('OpenAI: Adding image ${i + 1} base64 data.');
          base64Images.add(imageData[i]['b64_json']);
        }
        
        print('OpenAI: Total images generated: ${base64Images.length}');
        return base64Images;
      } else {
        print('OpenAI: Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate images: $e');
    }
  }
  
  static Future<String> generateVisualPrompt({
    required Map<String, dynamic> creativeBrief,
    required Map<String, dynamic> refinedConcept,
    required Map<String, dynamic> finalDetails,
  }) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final systemPrompt = '''
You are a fashion design assistant. Based on user inputs from creative brief, refined concept, and final details, create a detailed visual prompt for generating fashion design images.

The prompt should be specific, descriptive, and suitable for DALL-E 3 image generation.
Include details about:
- Garment type and style
- Colors and patterns
- Materials and textures  
- Fit and silhouette
- Target audience
- Occasion/use case
- Any specific design elements mentioned

Make the prompt clear, concise, and visually descriptive.
''';

      final userMessage = '''
Please create a detailed visual prompt for fashion design based on these inputs:

Creative Brief: ${jsonEncode(creativeBrief)}
Refined Concept: ${jsonEncode(refinedConcept)}
Final Details: ${jsonEncode(finalDetails)}

Generate a comprehensive visual prompt that captures all the key design elements.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate visual prompt: $e');
    }
  }
  
//   static Future<Map<String, String>> generateTechPackPrompts({
//     required Map<String, dynamic> creativeBrief,
//     required Map<String, dynamic> refinedConcept,
//     required Map<String, dynamic> finalDetails,
//     required Map<String, dynamic> techPackDetails,
//     required String selectedDesignPrompt,
//   }) async {
//     try {
//       final apiKey = await getApiKey();
//       if (apiKey == null || apiKey.isEmpty) {
//         throw Exception('OpenAI API key not found');
//       }

//       final systemPrompt = '''
// You are a fashion tech pack expert. Based on user inputs from their questionnaire answers, selected design, and tech pack details, create two separate detailed prompts for generating tech pack images:

// 1. MANUFACTURING LAYOUT PROMPT - for a comprehensive tech pack layout with all specifications
// 2. TECHNICAL FLAT DRAWING PROMPT - for detailed technical flat drawings with annotations

// Both prompts should be highly specific, professional, and suitable for DALL-E 3 image generation.
// The images should be based on the selected design and incorporate all user-provided information.
// ''';

//       final userMessage = '''
// Please create two detailed prompts for tech pack image generation based on these inputs:

// SELECTED DESIGN PROMPT: $selectedDesignPrompt

// QUESTIONNAIRE DATA:
// Creative Brief: ${jsonEncode(creativeBrief)}
// Refined Concept: ${jsonEncode(refinedConcept)}
// Final Details: ${jsonEncode(finalDetails)}

// TECH PACK SPECIFICATIONS:
// ${jsonEncode(techPackDetails)}

// Generate two separate prompts:
// 1. "manufacturing_prompt" - for a professional manufacturing tech pack layout image with all sections, color swatches, specifications, and organized information blocks
// 2. "technical_flat_prompt" - for technical flat drawings with detailed annotations, measurements, and construction details

// Format your response as JSON with these two keys. Make sure both prompts reference the selected design and incorporate all the user's specifications for accurate, pixel-clear results.
// ''';

//       final response = await http.post(
//         Uri.parse('$_baseUrl/chat/completions'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $apiKey',
//         },
//         body: jsonEncode({
//           'model': 'gpt-4',
//           'messages': [
//             {'role': 'system', 'content': systemPrompt},
//             {'role': 'user', 'content': userMessage},
//           ],
//           'max_tokens': 1500,
//           'temperature': 0.7,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final content = data['choices'][0]['message']['content'];
        
//         // Try to parse as JSON, fallback to manual extraction if needed
//         try {
//           final promptsJson = jsonDecode(content);
//           return {
//             'manufacturing_prompt': promptsJson['manufacturing_prompt'] ?? '',
//             'technical_flat_prompt': promptsJson['technical_flat_prompt'] ?? '',
//           };
//         } catch (e) {
//           // Fallback parsing if JSON parsing fails
//           return _extractPromptsFromText(content);
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         throw Exception('OpenAI API Error: ${errorData['error']['message']}');
//       }
//     } catch (e) {
//       throw Exception('Failed to generate tech pack prompts: $e');
//     }
//   }
  
//   static Map<String, String> _extractPromptsFromText(String text) {
//     // Fallback method to extract prompts if JSON parsing fails
//     final lines = text.split('\n');
//     String manufacturingPrompt = '';
//     String technicalFlatPrompt = '';
    
//     bool inManufacturing = false;
//     bool inTechnical = false;
    
//     for (String line in lines) {
//       if (line.toLowerCase().contains('manufacturing_prompt') || 
//           line.toLowerCase().contains('manufacturing layout')) {
//         inManufacturing = true;
//         inTechnical = false;
//         continue;
//       } else if (line.toLowerCase().contains('technical_flat_prompt') || 
//                  line.toLowerCase().contains('technical flat')) {
//         inManufacturing = false;
//         inTechnical = true;
//         continue;
//       }
      
//       if (inManufacturing && line.trim().isNotEmpty) {
//         manufacturingPrompt += line.trim() + ' ';
//       } else if (inTechnical && line.trim().isNotEmpty) {
//         technicalFlatPrompt += line.trim() + ' ';
//       }
//     }
    
//     return {
//       'manufacturing_prompt': manufacturingPrompt.trim(),
//       'technical_flat_prompt': technicalFlatPrompt.trim(),
//     };
//   }
// }

// REPLACE YOUR EXISTING generateTechPackPrompts FUNCTION WITH THIS:
// static Future<Map<String, String>> generateTechPackPrompts({
//   required Map<String, dynamic> creativeBrief,
//   required Map<String, dynamic> refinedConcept,
//   required Map<String, dynamic> finalDetails,
//   required Map<String, dynamic> techPackDetails,
//   required String selectedDesignPrompt,
// }) async {
//   // Extract key information directly - no GPT-4 API call needed
//   final garmentType = creativeBrief['garmentType'] ?? '';
//   final primaryColor = techPackDetails['colors']?['primaryColor'] ?? '';
//   final alternateColor = techPackDetails['colors']?['alternateColorways'] ?? '';
//   final pantone = techPackDetails['colors']?['pantone'] ?? '';
//   final mainFabric = techPackDetails['materials']?['mainFabric'] ?? '';
//   final secondaryMaterial = techPackDetails['materials']?['secondaryMaterials'] ?? '';
//   final sizeRange = techPackDetails['sizes']?['sizeRange'] ?? '';
//   final accessories = techPackDetails['technical']?['accessories'] ?? '';
//   final stitching = techPackDetails['technical']?['stitching'] ?? '';
//   final decorativeStitching = techPackDetails['technical']?['decorativeStitching'] ?? '';
//   final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
//   final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
//   final packagingType = techPackDetails['packaging']?['packagingType'] ?? '';
//   final foldingInstructions = techPackDetails['packaging']?['foldingInstructions'] ?? '';
//   final costPerPiece = techPackDetails['production']?['costPerPiece'] ?? '';
//   final quantity = techPackDetails['production']?['quantity'] ?? '';
//   final deliveryDate = techPackDetails['production']?['deliveryDate'] ?? '';
//   final style = creativeBrief['style'] ?? '';
//   final features = refinedConcept['features'] ?? 'Cuban collar';

//   // Create focused, short prompts under 1000 characters
//   final manufacturingPrompt = '''Professional tech pack specification sheet for ${style.toLowerCase()} ${garmentType.toLowerCase()}. Organized layout with sections: MATERIALS (${mainFabric}, ${secondaryMaterial} with swatches), COLORS (${primaryColor} primary, ${alternateColor} alternate, Pantone ${pantone} with color swatches), SIZES table (${sizeRange} with measurements), LABELS (${logoPlacement} placement, ${labelsNeeded}), PACKAGING (${packagingType}, ${foldingInstructions}), PRODUCTION (${costPerPiece}/piece, ${quantity} qty, ${deliveryDate}), TECHNICAL (${accessories}, ${stitching}, ${decorativeStitching}). White background, professional grid layout, fashion industry standard.''';

//   final technicalFlatPrompt = '''Technical flat drawing ${style.toLowerCase()} ${garmentType.toLowerCase()} with ${features}. Black line art on white background. Front/back views with detailed measurements, seam allowances, construction notes. Show: ${features} construction, ${accessories} placement, ${stitching} details, ${decorativeStitching}, sleeve/cuff construction, hem details, ${logoPlacement} label position. Include dimension lines, measurement points A-F, topstitching callouts, professional technical annotations. Fashion industry flat drawing standard.''';

//   print('Manufacturing prompt (${manufacturingPrompt.length} chars): ${manufacturingPrompt.substring(0, math.min(100, manufacturingPrompt.length))}...');
//   print('Technical prompt (${technicalFlatPrompt.length} chars): ${technicalFlatPrompt.substring(0, math.min(100, technicalFlatPrompt.length))}...');

//   return {
//     'manufacturing_prompt': manufacturingPrompt,
//     'technical_flat_prompt': technicalFlatPrompt,
//   };
// }
// }

static Future<Map<String, String>> generateTechPackPrompts({
  required Map<String, dynamic> creativeBrief,
  required Map<String, dynamic> refinedConcept,
  required Map<String, dynamic> finalDetails,
  required Map<String, dynamic> techPackDetails,
  required String selectedDesignPrompt,
}) async {
  // Extract key information directly - no GPT-4 API call needed
  final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  final primaryColor = techPackDetails['colors']?['primaryColor'] ?? 'blue';
  final alternateColor = techPackDetails['colors']?['alternateColorways'] ?? 'navy';
  final pantone = techPackDetails['colors']?['pantone'] ?? '#0066CC';
  final mainFabric = techPackDetails['materials']?['mainFabric'] ?? 'cotton';
  final secondaryMaterial = techPackDetails['materials']?['secondaryMaterials'] ?? 'polyester lining';
  final sizeRange = techPackDetails['sizes']?['sizeRange'] ?? 'XS-XL';
  final accessories = techPackDetails['technical']?['accessories'] ?? 'zipper';
  final stitching = techPackDetails['technical']?['stitching'] ?? 'single stitch';
  final decorativeStitching = techPackDetails['technical']?['decorativeStitching'] ?? 'contrast topstitch';
  final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? 'chest';
  // final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? 'brand';
  final packagingType = techPackDetails['packaging']?['packagingType'] ?? 'polybag';
  // final foldingInstructions = techPackDetails['packaging']?['foldingInstructions'] ?? 'fold neatly';
  final costPerPiece = techPackDetails['production']?['costPerPiece'] ?? '\$25';
  final quantity = techPackDetails['production']?['quantity'] ?? '100';
  final deliveryDate = techPackDetails['production']?['deliveryDate'] ?? 'TBD';
  // final style = creativeBrief['style'] ?? 'casual';
  final features = refinedConcept['features'] ?? 'standard collar';

  // Manufacturing prompt - clean and organized
  final manufacturingPrompt = '''Professional fashion tech pack specification sheet for ${garmentType}. Clean organized grid layout with distinct sections: MATERIALS (${mainFabric}, ${secondaryMaterial} written in proper text), COLORS (${primaryColor}, ${alternateColor}, Pantone ${pantone} with color blocks), SIZES (${sizeRange} measurement chart), TECHNICAL (${accessories}, ${stitching}, ${decorativeStitching} the ${garmentType} is shown in  ${primaryColor} ), LABELS (${logoPlacement} placement), PACKAGING (${packagingType}), PRODUCTION (${costPerPiece}, ${quantity}units, ${deliveryDate}). White background, professional typography, complete layout visible.''';

  // DETAILED Technical flat prompt - with proper framing instructions
//   final technicalFlatPrompt = '''Professional technical flat drawing layout for ${garmentType} on white background. Layout: FRONT view (left 40% of image), BACK view (right 40% of image) with  1% spacing each and enusre .. Black line art with detailed annotations. Show: ${features} construction, ${accessories} placement, ${stitching} details, ${decorativeStitching}. Include measurement arrows labeled, seam allowances (1.3cm), construction callouts, Topstitching details shown in magnified circles, labeled with type (single, double) and stitch spacing in mm.
// .  Include dimension arrows with measurement text in centimeters (cm) for *all garment parts*.
// . All Two views completely visible within image boundaries with proper margins And not cutoff the image Ensure to show complete image in image boundaries. Fashion industry technical drawing standard.''';
final technicalFlatPrompt = '''
Professional technical flat drawing layout for ${garmentType} on a clean white background.

Layout:
- FRONT view (left) and BACK view (right) arranged horizontally with equal spacing and proper margins.
- All views completely visible within image boundaries.

Style:
- Black line art, precise vector quality, professional apparel technical drawing standard.
- Crisp, uniform outlines with slightly thicker exterior contour.
- Clear sans-serif font for all annotations and labels.
- Measurement text fully visible and not cut off.

Annotations & Measurements:
- Show ${features} construction, ${accessories} placement, ${stitching} details, ${decorativeStitching}.
- Include dimension arrows with measurement text in centimeters (cm) for *all garment parts*:
  - Shoulder width:
  - Chest width:
  - Front length: 
  - Back length: 
  - Sleeve length: 
  - Armhole depth:
  - Pocket width: 
  - Pocket height: 
  - Cuff width: 
  - Collar height:
  - Collar spread: 
  - Any other relevant measurements provided by the user
- Seam allowances (1.3 cm) shown as dashed lines with labels.
- Topstitching details shown in magnified circles, labeled with type (single, double) and stitch spacing in mm.
- Reinforcement points labeled with callouts (e.g., bartack length and more: mm).
- All arrows connect precisely to their measurement points.

Labeling Style:
- Labels positioned clearly with leader lines (callout lines) avoiding overlaps.
- Every major component of garment construction labeled in detail:
  - Stitch types and spacing
  - Fabric grainline
  - Accessory dimensions and placement
  - Functional openings (zippers, button plackets) with length
- All text in cm or mm as appropriate.

Output:
- White background, clean margins.
- Fully annotated, measurement-rich technical flat drawing ready for inclusion in a production tech pack.
- Black-and-white only, no shading or colors.
- Complete sheet layout with 10% margin border
''';

  print('Manufacturing prompt (${manufacturingPrompt.length} chars)');
  print('Technical prompt (${technicalFlatPrompt.length} chars)');

  return {
    'manufacturing_prompt': manufacturingPrompt,
    'technical_flat_prompt': technicalFlatPrompt,
  };
}

// ALTERNATIVE: Single detailed view if three views still cause cutting
static Map<String, String> getDetailedSingleViewPrompts(Map<String, dynamic> techPackDetails, Map<String, dynamic> creativeBrief) {
  final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  final accessories = techPackDetails['technical']?['accessories'] ?? 'zipper';
  final stitching = techPackDetails['technical']?['stitching'] ?? 'single stitch';
  final features = creativeBrief['features'] ?? 'collar';
  
  return {
    'manufacturing_prompt': 'Professional fashion tech pack specification sheet for ${garmentType}. Organized sections: materials, colors with swatches, sizes chart, technical details, production info. Clean grid layout, white background.',
    
    'technical_flat_prompt': 'Detailed technical flat drawing of ${garmentType}, large front view centered on white background. Black line art with comprehensive annotations: measurement arrows (A, B, C, D), seam allowances labeled, ${accessories} details, ${stitching} callouts, construction notes, dimension lines. Professional fashion industry flat with detailed labeling. Complete drawing visible with wide margins.',
  };
}

// ADVANCED: Detailed layout with explicit positioning
static Map<String, String> getAdvancedDetailedPrompts(Map<String, dynamic> techPackDetails, Map<String, dynamic> creativeBrief) {
  final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  final accessories = techPackDetails['technical']?['accessories'] ?? 'zipper';
  final stitching = techPackDetails['technical']?['stitching'] ?? 'single stitch';
  final decorativeStitching = techPackDetails['technical']?['decorativeStitching'] ?? 'contrast topstitch';
  final features = creativeBrief['features'] ?? 'collar';
  
  return {
    'manufacturing_prompt': 'Complete fashion tech pack layout for ${garmentType}. Grid format with sections: MATERIALS (fabric swatches), COLORS (color blocks with codes), SIZES (measurement table), TECHNICAL (${accessories}, ${stitching}), LABELS, PACKAGING, PRODUCTION. Professional format, white background, all content within frame.',
    
    'technical_flat_prompt': 'Technical flat drawing sheet for ${garmentType}. Layout: Front view (upper left), back view (upper right), detail callouts (bottom). Black lines on white. Show: ${features}, ${accessories}, ${stitching}, ${decorativeStitching}. Include: measurement points A-F with arrows, seam allowances, construction details, topstitching circles. Professional annotations. Complete sheet layout with 10% margin border.',
  };
}

// FALLBACK: Simplified but still detailed
static Map<String, String> getSimplifiedDetailedPrompts(Map<String, dynamic> techPackDetails, Map<String, dynamic> creativeBrief) {
  final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  final accessories = techPackDetails['technical']?['accessories'] ?? 'zipper';
  
  return {
    'manufacturing_prompt': 'Fashion tech pack for ${garmentType}: materials, colors, sizes, production details. Professional layout, white background, organized sections.',
    
    'technical_flat_prompt': 'Technical drawing ${garmentType} with detailed labels. Front view, black lines, measurement arrows, ${accessories} details, construction notes. Complete drawing with margins.',
  };
}
}
