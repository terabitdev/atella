import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
      print(
        'OpenAI: Converted inspiration image to base64 (${bytes.length} bytes)',
      );
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
        if (primaryImagePath.startsWith('iVBOR') ||
            primaryImagePath.startsWith('/9j/') ||
            primaryImagePath.startsWith('R0lGOD')) {
          // It's already base64 data
          primaryImageBase64 = primaryImagePath;
          print(
            'OpenAI: Using selected design as primary reference (already base64)',
          );
        } else {
          // It's a file path, convert to base64
          primaryImageBase64 = await _convertImageToBase64(primaryImagePath);
          if (primaryImageBase64 != null) {
            print(
              'OpenAI: Using selected design as primary reference (converted from file)',
            );
          }
        }
      }

      // Truncate prompt to 1000 characters if necessary
      String safePrompt = prompt;

      // Enhance prompt with reference information
      if (referenceImages.containsKey('measurementChart')) {
        safePrompt +=
            '. Include detailed measurements and size specifications as shown in the reference chart.';
      }
      if (referenceImages.containsKey('labelReference')) {
        safePrompt +=
            '. Use the uploaded label examples for accurate label styling and placement.';
      }

      print('OpenAI: API key found, making request with enhanced prompt...');

      http.Response response;

      if (primaryImageBase64 != null) {
        // Use /v1/images/edits endpoint with form data when primary image is available
        print('OpenAI: Using /v1/images/edits endpoint with reference images');

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/images/edits'),
        );
        request.headers['Authorization'] = 'Bearer $apiKey';

        // Add form fields
        request.fields['model'] = 'gpt-image-2';
        request.fields['prompt'] = safePrompt;
        request.fields['size'] = size;
        request.fields['n'] = numberOfImages.toString();

        // Add the primary image as the main reference
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            base64Decode(primaryImageBase64),
            filename: 'primary_reference.png',
            contentType: MediaType('image', 'png'),
          ),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Use regular generation endpoint when no primary image
        print(
          'OpenAI: Using /v1/images/generations endpoint (no primary reference image)',
        );
        response = await http.post(
          Uri.parse('$_baseUrl/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-image-2',
            'prompt': safePrompt,
            'n': numberOfImages,
            'size': size,
          }),
        );
      }

      print('OpenAI: Response status code: ${response.statusCode}');
      print('OpenAI: Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        print('OpenAI: Tech pack image generation successful!');
        if (response.body.isEmpty) {
          throw Exception('OpenAI returned empty response body');
        }
        final data = jsonDecode(response.body);
        final List<dynamic> imageData = data['data'];

        List<String> base64Images = [];

        for (int i = 0; i < imageData.length; i++) {
          print('OpenAI: Adding tech pack image ${i + 1} base64 data.');
          base64Images.add(imageData[i]['b64_json']);
        }

        print(
          'OpenAI: Total tech pack images generated: ${base64Images.length}',
        );
        return base64Images;
      } else {
        print('OpenAI: Error response: ${response.body}');
        if (response.body.isEmpty) {
          throw Exception(
            'OpenAI API Error: status ${response.statusCode}, empty response body',
          );
        }
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
      print(
        'OpenAI: Inspiration image path: ${inspirationImagePath ?? 'none'}',
      );

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

      // Ensure white background and front/back split requirement is in the prompt
      String enhancedPrompt = prompt;
      if (!enhancedPrompt.toLowerCase().contains('white background')) {
        enhancedPrompt +=
            '. Two-panel split image: LEFT panel shows FRONT VIEW, RIGHT panel shows BACK VIEW of the same garment, side by side on a pure white background. No mannequin, no people, ghost mannequin effect, professional e-commerce product photography.';
        print(
          'OpenAI: Added white background and front/back split requirement to prompt',
        );
      }

      // Truncate prompt to 1000 characters if necessary
      String safePrompt = enhancedPrompt;

      print('OpenAI: API key found, making request to DALL-E 3...');

      http.Response response;

      if (inspirationBase64 != null) {
        // Use /v1/images/edits endpoint with form data when inspiration image is provided
        print('OpenAI: Using /v1/images/edits endpoint with inspiration image');

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/images/edits'),
        );
        request.headers['Authorization'] = 'Bearer $apiKey';

        // Add form fields
        request.fields['model'] = 'gpt-image-2';
        request.fields['prompt'] = safePrompt;
        request.fields['size'] = size;
        request.fields['n'] = numberOfImages.toString();

        // Add the base64 image as a file
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            base64Decode(inspirationBase64),
            filename: 'base64decoded.png',
            contentType: MediaType('image', 'png'),
          ),
        );

        final streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Use regular /v1/images/generations endpoint when no inspiration image
        print(
          'OpenAI: Using /v1/images/generations endpoint (no inspiration image)',
        );
        response = await http.post(
          Uri.parse('$_baseUrl/images/generations'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-image-2',
            'prompt': safePrompt,
            'n': numberOfImages,
            'size': size,
          }),
        );
      }

      print('OpenAI: Response status code: ${response.statusCode}');
      print('OpenAI: Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        print('OpenAI: Image generation successful!');
        if (response.body.isEmpty) {
          throw Exception('OpenAI returned empty response body');
        }
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
        if (response.body.isEmpty) {
          throw Exception(
            'OpenAI API Error: status ${response.statusCode}, empty response body',
          );
        }
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
    Map<String, dynamic>? finalDetails,
  }) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final systemPrompt = '''
You are a fashion design assistant. Based on user inputs from creative brief, refined concept, and final details, create a detailed visual prompt for generating fashion design images.

IMPORTANT REQUIREMENTS FOR IMAGE GENERATION:
- ALWAYS specify "clean white background" or "pure white background"
- NEVER include mannequins, models, or people
- Use "ghost mannequin effect" or "flat lay style" or "product photography style" (no people)
- The garment should be photographed as if floating or laid flat (no people)
- Professional product photography presentation
- ALWAYS generate a TWO-PANEL split image: LEFT PANEL shows the FRONT VIEW of the garment, RIGHT PANEL shows the BACK VIEW of the same garment. Both panels on a pure white background, side by side in a single image.

IMPORTANT: ABSOLUTE RULES (do not omit, paraphrase, or weaken):
1) DO NOT include any people, models, mannequins, partial bodies, torsos, heads, faces, arms, hands, legs, feet, or any human-like forms in the output image.
2) DO NOT show a model wearing the garment.
3) DO NOT mention or request a mannequin, dress form, torso, or human shadow.
4) If the generated image includes any human or mannequin, the generation must be considered INVALID and retried.
5) Do NOT add any logos, branding, brand names, text, lettering, numbers, symbols, or writing on the garment unless the user explicitly requests logos/text or provides a logo reference.
6) Do NOT add any patterns, prints, textures, or decorative graphics on the garment unless the user explicitly requests a pattern/print or provides a clear pattern reference.

PRINTS + TECHNIQUES MUST BE PROMINENT
You MUST apply the print pattern and technique very clearly and prominently on the garment.  
The print must be visible, bold, and placed across the correct surface area of the clothing.  
Techniques (like embroidery, ombré, tie-dye, applique, sequins, patchwork) must appear correctly applied to the fabric, not faint, not subtle, not missing.  
ALWAYS ensure the print and technique are integrated naturally with the fabric and silhouette.

CORRECT GARMENT LENGTH + PROPORTION
You MUST generate garments with **correct real-world proportions** for their category.  
Example: cocktail dresses must be knee-length or mid-thigh, not long gowns; crop tops must be short; tunics must be long.  
Always respect the standard fashion-length conventions when rendering the final design.

SPECIAL FEATURES MUST ALWAYS APPEAR
For all special features (neckline, sleeves, closures, lace, buttons, zippers, pleats, pockets, trims, straps, cutouts, etc):
- You MUST include **every selected feature** in the final design  
- Missing features are not allowed  
- Closure mechanisms must be placed accurately (front zipper, back zipper, side closure, button-up, hook fastener, etc)  
- Lace or trims must appear in the correct areas  
- Features must always be visible, clear, and stylistically consistent

MORE COLOR VARIETY
If the user does not specify exact solid colors:
- Avoid repeating the same color family

The prompt should be specific, descriptive, and suitable for DALL-E 3 image generation.

CRITICAL: You MUST extract and use ALL the following details from the data provided:
FROM CREATIVE BRIEF:
- Garment type (garmentType) - the main type of clothing
- Style preference (style) - the overall aesthetic
- Target audience (targetAudience) - who will wear this
- Occasion/use (occasion) - when it will be worn
- Solid colors (solidColors array) - specific hex colors to use
- Print pattern (print) - the pattern type (floral, abstract, etc)
- Technique (technique) - color technique (ombré, embroidery, etc)
- Fabric/material (fabrics) - the type of fabric

FROM REFINED CONCEPT:
- Silhouette/fit (silhouette) - how the garment should fit (slim, oversized, etc)
- Special features (features) - specific details like necklines, sleeves, closures, pockets, etc
- Season (season) - seasonal considerations
- Budget level (budget) - impacts quality and finish
- Values/functionality (values) - special properties like organic, quick-dry, etc

Create a comprehensive, visually descriptive prompt that incorporates ALL these elements. Be specific about colors (use hex codes if provided), materials, fit, and design details.

MANDATORY ENDING - You MUST end EVERY prompt with this EXACT phrase (do not modify or omit):
"Two-panel split image: LEFT panel shows the FRONT VIEW of the garment, RIGHT panel shows the BACK VIEW of the same garment. Both panels side by side on a pure white background. Isolated garment only, NO human, NO model, NO mannequin, NO body, NO torso, NO person wearing the clothing. Product-only shot, floating garment, ghost mannequin invisible effect, professional e-commerce product photography."

Make the prompt clear, detailed, and visually descriptive - include specific colors, textures, patterns, and construction details.
''';

      // Build user message - only include finalDetails if provided
      String userMessage =
          '''
Please create a detailed visual prompt for fashion design based on these inputs:

Creative Brief: ${jsonEncode(creativeBrief)}
Refined Concept: ${jsonEncode(refinedConcept)}''';

      // Only add Final Details if provided (not skipped)
      if (finalDetails != null && finalDetails.isNotEmpty) {
        userMessage += '''

Final Details: ${jsonEncode(finalDetails)}''';
      }

      userMessage += '''


CRITICAL INSTRUCTIONS:
1. Extract the garment type, style, colors, prints, techniques, and fabrics from Creative Brief
2. Extract the silhouette/fit, special features, season, budget, and values from Refined Concept
3. Combine ALL these elements into a single, comprehensive visual prompt
4. Be SPECIFIC about colors (mention hex codes if provided in solidColors array)
5. Include the print pattern and technique in the description
6. Describe the fit/silhouette clearly (from Refined Concept)
7. Mention any special features like necklines, sleeves, closures, pockets
8. Include material/fabric details and seasonal considerations
9. Use the budget level from Refined Concept to determine quality/finish
10. START the prompt with: "Two-panel split image showing FRONT VIEW on the left and BACK VIEW on the right of a [garment type]. Product-only fashion photography, no human, no model, no mannequin, no body visible, no logos, no text or writing, no patterns, prints, textures, or decorative graphics on the garment unless explicitly requested. The garment should look realistic and according to the type of realistic world garment style, length and properties."
11. END the prompt with: "Two-panel split image: LEFT panel = FRONT VIEW, RIGHT panel = BACK VIEW. Both side by side on a pure white background. Isolated floating garment, invisible ghost mannequin effect, e-commerce product shot, absolutely no people or body parts."

Generate a comprehensive visual prompt that captures ALL the design elements from the user's questionnaire answers.
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

  static const Map<String, Map<String, String>> fabricDefaults = {
    // Cotton subcategories
    'cotton': {'composition': '100% Cotton', 'type': 'Jersey', 'gsm': '180'},
    'lightweight (poplin, voile)': {
      'composition': '100% Cotton',
      'type': 'Poplin',
      'gsm': '90',
    },
    'poplin': {'composition': '100% Cotton', 'type': 'Poplin', 'gsm': '90'},
    'voile': {'composition': '100% Cotton', 'type': 'Voile', 'gsm': '70'},
    'medium (twill)': {
      'composition': '100% Cotton',
      'type': 'Twill',
      'gsm': '150',
    },
    'twill': {'composition': '100% Cotton', 'type': 'Twill', 'gsm': '150'},
    'heavy (denim, canvas)': {
      'composition': '100% Cotton',
      'type': 'Denim',
      'gsm': '320',
    },
    'denim': {'composition': '100% Cotton', 'type': 'Denim', 'gsm': '320'},
    'canvas': {'composition': '100% Cotton', 'type': 'Canvas', 'gsm': '350'},
    // Wool
    'wool': {'composition': '100% Wool', 'type': 'Woven', 'gsm': '300'},
    'merino': {
      'composition': '100% Merino Wool',
      'type': 'Fine Knit',
      'gsm': '200',
    },
    'cashmere': {
      'composition': '100% Cashmere',
      'type': 'Fine Knit',
      'gsm': '160',
    },
    'tweed': {'composition': '100% Wool', 'type': 'Tweed', 'gsm': '400'},
    'felt': {'composition': '100% Wool', 'type': 'Felt', 'gsm': '500'},
    // Silk
    'silk': {'composition': '100% Silk', 'type': 'Woven', 'gsm': '80'},
    'satin': {'composition': '100% Silk', 'type': 'Satin', 'gsm': '90'},
    'chiffon': {'composition': '100% Silk', 'type': 'Chiffon', 'gsm': '60'},
    'organza': {'composition': '100% Silk', 'type': 'Organza', 'gsm': '50'},
    // Linen
    'linen': {'composition': '100% Linen', 'type': 'Plain Weave', 'gsm': '140'},
    'plain': {'composition': '100% Linen', 'type': 'Plain Weave', 'gsm': '140'},
    'textured': {
      'composition': '100% Linen',
      'type': 'Textured Weave',
      'gsm': '160',
    },
    'blended': {
      'composition': '55% Linen 45% Cotton',
      'type': 'Blended Weave',
      'gsm': '150',
    },
    // Synthetic
    'polyester': {
      'composition': '100% Polyester',
      'type': 'Woven',
      'gsm': '120',
    },
    'nylon': {'composition': '100% Nylon', 'type': 'Plain Weave', 'gsm': '100'},
    'spandex': {
      'composition': '80% Polyester 20% Spandex',
      'type': 'Stretch Woven',
      'gsm': '180',
    },
    'neoprene': {'composition': '100% Neoprene', 'type': 'Scuba', 'gsm': '380'},
    // Eco
    'organic cotton': {
      'composition': '100% Organic Cotton',
      'type': 'Jersey',
      'gsm': '180',
    },
    'recycled polyester': {
      'composition': '100% Recycled Polyester',
      'type': 'Woven',
      'gsm': '120',
    },
    'bamboo': {
      'composition': '70% Bamboo 30% Cotton',
      'type': 'Jersey',
      'gsm': '160',
    },
    'hemp': {'composition': '100% Hemp', 'type': 'Plain Weave', 'gsm': '200'},
    // Leather
    'leather': {
      'composition': '100% Genuine Leather',
      'type': 'Full Grain',
      'gsm': '800',
    },
    'faux leather': {
      'composition': '100% Faux Leather (PU)',
      'type': 'Backed Fabric',
      'gsm': '600',
    },
    // Knitwear
    'jersey': {'composition': '100% Cotton', 'type': 'Jersey', 'gsm': '180'},
    'rib knit': {
      'composition': '95% Cotton 5% Elastane',
      'type': 'Rib Knit',
      'gsm': '220',
    },
    'interlock': {
      'composition': '100% Cotton',
      'type': 'Interlock',
      'gsm': '200',
    },
  };

  static const Map<String, String> technicalPropertiesDefaults = {
    't-shirt': 'Breathable, moisture-wicking',
    'shirt': 'Wrinkle-resistant, easy-care',
    'blouse': 'Lightweight, anti-static, drape-friendly',
    'jacket': 'Water-resistant, windproof',
    'coat': 'Insulating, water-resistant, windproof',
    'blazer': 'Wrinkle-resistant, shape-retaining',
    'dress': 'Breathable, anti-static',
    'skirt': 'Anti-static, shape-retaining',
    'trousers': 'Wrinkle-resistant, shape-retaining',
    'pants': 'Wrinkle-resistant, shape-retaining',
    'jeans': 'Abrasion-resistant, stretch',
    'shorts': 'Quick-dry, breathable',
    'sweater': 'Pilling-resistant, shape-retaining',
    'hoodie': 'Moisture-wicking, pilling-resistant',
    'sweatshirt': 'Moisture-wicking, pilling-resistant',
    'activewear': 'Moisture-wicking, four-way stretch, quick-dry',
    'leggings': 'Four-way stretch, moisture-wicking, opaque',
    'swimwear': 'Chlorine-resistant, UV protection, quick-dry',
    'outerwear': 'Water-resistant, windproof, breathable',
    'jumpsuit': 'Breathable, anti-static, stretch',
    'cardigan': 'Pilling-resistant, shape-retaining',
  };

  static const Map<String, String> stitchTypeDefaults = {
    't-shirt': 'Overlock stitch (4-thread)',
    'shirt': 'Lockstitch (ISO 301)',
    'blouse': 'Lockstitch (ISO 301)',
    'jacket': 'Lockstitch (ISO 301)',
    'coat': 'Lockstitch (ISO 301)',
    'blazer': 'Lockstitch (ISO 301)',
    'dress': 'Lockstitch (ISO 301)',
    'skirt': 'Lockstitch (ISO 301)',
    'trousers': 'Lockstitch (ISO 301)',
    'pants': 'Lockstitch (ISO 301)',
    'jeans': 'Chain stitch (ISO 401)',
    'shorts': 'Overlock stitch (4-thread)',
    'sweater': 'Overlock stitch (4-thread)',
    'hoodie': 'Overlock stitch (4-thread)',
    'sweatshirt': 'Overlock stitch (4-thread)',
    'activewear': 'Overlock stitch (4-thread)',
    'leggings': 'Flatlock stitch (ISO 605)',
    'swimwear': 'Flatlock stitch (ISO 605)',
    'outerwear': 'Lockstitch (ISO 301)',
    'jumpsuit': 'Overlock stitch (4-thread)',
    'cardigan': 'Overlock stitch (4-thread)',
  };

  static const Map<String, String> decorativeStitchingDefaults = {
    't-shirt': 'Single topstitch, 1 mm from seam',
    'shirt': 'Single topstitch, 2 mm from seam',
    'blouse': 'Single topstitch, 1 mm from seam',
    'jacket': 'Double topstitch, 6 mm spacing',
    'coat': 'Double topstitch, 6 mm spacing',
    'blazer': 'Single topstitch, 2 mm from seam',
    'dress': 'Single topstitch, 1 mm from seam',
    'skirt': 'Single topstitch, 1 mm from seam',
    'trousers': 'Single topstitch, 2 mm from seam',
    'pants': 'Single topstitch, 2 mm from seam',
    'jeans': 'Double topstitch, 6 mm spacing, contrast thread',
    'shorts': 'Single topstitch, 2 mm from seam',
    'sweater': 'No decorative stitching',
    'hoodie': 'Single topstitch, 2 mm from seam',
    'sweatshirt': 'Single topstitch, 2 mm from seam',
    'activewear': 'Flatlock seams, no topstitch',
    'leggings': 'Flatlock seams, no topstitch',
    'swimwear': 'Flatlock seams, no topstitch',
    'outerwear': 'Double topstitch, 6 mm spacing',
    'jumpsuit': 'Single topstitch, 2 mm from seam',
    'cardigan': 'No decorative stitching',
  };

  static String resolveByGarmentType(
    String garmentType,
    Map<String, String> defaults,
    String fallback,
  ) {
    final key = garmentType.toLowerCase().trim();
    if (defaults.containsKey(key)) return defaults[key]!;
    for (final entry in defaults.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return fallback;
  }

  static String _resolveFabricLine(
    String compositionInput,
    String weightInput,
    String creativeBriefFabric,
  ) {
    final compositionKey = compositionInput.toLowerCase().trim();
    // Strip any "Category:" prefix from creative brief fabric (e.g. "Knitwear:Jersey" → "jersey")
    final fabricTypeKey = creativeBriefFabric.contains(':')
        ? creativeBriefFabric.split(':').last.trim().toLowerCase()
        : creativeBriefFabric.toLowerCase().trim();

    // Look up defaults: try composition input first, then creative brief fabric type
    final defaults =
        fabricDefaults[compositionKey] ?? fabricDefaults[fabricTypeKey];

    // If composition already has %, treat as complete — only fill missing weight
    if (compositionInput.contains('%')) {
      final resolvedType = defaults?['type'] ?? fabricTypeKey;
      final rawGsm = weightInput.replaceAll(RegExp(r'[^0-9]'), '');
      final resolvedGsm = rawGsm.isNotEmpty
          ? rawGsm
          : (defaults?['gsm'] ?? '180');
      return resolvedType.isNotEmpty
          ? '$compositionInput, $resolvedType, $resolvedGsm GSM'
          : '$compositionInput, $resolvedGsm GSM';
    }

    // Simple fabric name — use full defaults
    if (defaults != null) {
      final resolvedComposition = defaults['composition']!;
      final resolvedType = defaults['type']!;
      final rawGsm = weightInput.replaceAll(RegExp(r'[^0-9]'), '');
      final resolvedGsm = rawGsm.isNotEmpty ? rawGsm : defaults['gsm']!;
      return '$resolvedComposition, $resolvedType, $resolvedGsm GSM';
    }

    // Fallback: pass through whatever user entered
    if (compositionInput.isNotEmpty) {
      final rawGsm = weightInput.replaceAll(RegExp(r'[^0-9]'), '');
      return rawGsm.isNotEmpty
          ? '$compositionInput, $rawGsm GSM'
          : compositionInput;
    }

    return '';
  }

  static String _buildFabricLine(
    String compositionInput,
    String weightInput,
    String creativeBriefFabric, {
    required bool isIndustryComposition,
    required bool isIndustryGSM,
  }) {
    final fabricKey = creativeBriefFabric.contains(':')
        ? creativeBriefFabric.split(':').last.trim().toLowerCase()
        : creativeBriefFabric.toLowerCase().trim();
    final mapEntry = fabricDefaults[fabricKey] ?? fabricDefaults['cotton']!;
    final rawGsm = weightInput.replaceAll(RegExp(r'[^0-9]'), '');

    if (isIndustryComposition && isIndustryGSM) {
      // Both from map
      return '${mapEntry['composition']}, ${mapEntry['type']}, ${mapEntry['gsm']} GSM';
    } else if (isIndustryComposition && !isIndustryGSM) {
      // Map composition, user GSM
      final gsm = rawGsm.isNotEmpty ? rawGsm : mapEntry['gsm']!;
      return '${mapEntry['composition']}, ${mapEntry['type']}, $gsm GSM';
    } else if (!isIndustryComposition && isIndustryGSM) {
      // User composition, map GSM
      return '$compositionInput, ${mapEntry['gsm']} GSM';
    } else {
      // Both manual — use raw values, skip map entirely
      return rawGsm.isNotEmpty
          ? '$compositionInput, $rawGsm GSM'
          : compositionInput;
    }
  }

  static String _resolveField(String value, String defaultValue) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty ||
        trimmed == 'no' ||
        trimmed == 'none' ||
        trimmed == 'n/a' ||
        trimmed == 'na' ||
        trimmed == 'not required' ||
        trimmed == 'not applicable' ||
        trimmed == '-') {
      return defaultValue;
    }
    return value.trim();
  }

  /// Checks the tech pack's free-text answers for any that essentially mean
  /// "none / not applicable" in a language other than English (e.g. French
  /// "non") so they can be routed to the same sensible defaults the English
  /// equivalents already trigger via _resolveField — instead of being
  /// printed literally in the document. This NEVER translates or rewrites
  /// real content: an answer with genuine meaning, in any language (e.g.
  /// French "milieux poitrine" or "cotton bio"), is left completely
  /// untouched and prints exactly as typed. Non-blocking — returns an empty
  /// set on any failure, so generation proceeds exactly as it does today.
  static Future<Set<String>> _detectEmptyMeaningFields(
    Map<String, String> fields,
  ) async {
    // Only worth asking about fields that actually have text in them.
    final candidates = Map<String, String>.fromEntries(
      fields.entries.where((e) => e.value.trim().isNotEmpty),
    );
    if (candidates.isEmpty) return {};

    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return {};

      final keysInOrder = candidates.keys.toList();
      final numbered = List.generate(
        keysInOrder.length,
        (i) => '${i + 1}. ${candidates[keysInOrder[i]]}',
      ).join('\n');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'These are answers from a tech pack form (the app supports English and French). '
                      'For each numbered answer below, decide if it essentially means "none / not applicable / nothing" '
                      '(in any language or wording — e.g. "non", "aucun", "n/a", "none") rather than real content. '
                      'Do NOT flag real content as empty, even short or unusual answers — only flag ones that genuinely mean nothing. '
                      'Return ONLY a comma-separated list of the numbers that mean "empty" (e.g. "2,5"). '
                      'If none of them mean empty, return exactly: NONE\n\n$numbered',
                },
              ],
              'max_tokens': 40,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('❌ Empty-meaning field check failed: ${response.body}');
        return {};
      }

      final data = jsonDecode(response.body);
      final content = (data['choices'][0]['message']['content'] as String)
          .trim();
      print('🌐 Empty-meaning field check result: $content');

      if (content.toUpperCase() == 'NONE') return {};

      final emptyKeys = <String>{};
      for (final part in content.split(',')) {
        final index = int.tryParse(part.trim());
        if (index != null && index >= 1 && index <= keysInOrder.length) {
          emptyKeys.add(keysInOrder[index - 1]);
        }
      }
      return emptyKeys;
    } catch (e) {
      print('❌ Error during empty-meaning field check: $e');
      return {};
    }
  }

  // Replaced by _classifyLogoPlacement + _visualSideForView below — this
  // only translated the words, it never told the drawing AI which side of
  // the WEARER's body was meant vs. which half of the image, which is what
  // caused unreliable/duplicate placement even on clear English input like
  // "chest". Kept here, disabled, for reference / possible rollback.
  //
  // static Future<String> _translateLogoPlacementForDrawing(
  //   String logoPlacement,
  // ) async {
  //   if (logoPlacement.trim().isEmpty) return logoPlacement;
  //
  //   try {
  //     final apiKey = await getApiKey();
  //     if (apiKey == null || apiKey.isEmpty) return logoPlacement;
  //
  //     final response = await http
  //         .post(
  //           Uri.parse('$_baseUrl/chat/completions'),
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Authorization': 'Bearer $apiKey',
  //           },
  //           body: jsonEncode({
  //             'model': 'gpt-4o',
  //             'messages': [
  //               {
  //                 'role': 'user',
  //                 'content':
  //                     'Translate this garment logo placement answer into a short, clear English location phrase suitable for a technical fashion drawing (e.g. "right shoulder", "mid-chest", "left sleeve", "center back"). '
  //                     'If it is already in English, return it unchanged (just cleaned up if needed). '
  //                     'Return ONLY the short phrase, no explanation, no quotes.\n\n"$logoPlacement"',
  //               },
  //             ],
  //             'max_tokens': 20,
  //           }),
  //         )
  //         .timeout(const Duration(seconds: 15));
  //
  //     if (response.statusCode != 200) {
  //       print('❌ Logo placement translation failed: ${response.body}');
  //       return logoPlacement;
  //     }
  //
  //     final data = jsonDecode(response.body);
  //     final translated =
  //         (data['choices'][0]['message']['content'] as String).trim();
  //     print(
  //       '🌐 Logo placement translated for drawing: "$logoPlacement" -> "$translated"',
  //     );
  //     return translated.isEmpty ? logoPlacement : translated;
  //   } catch (e) {
  //     print('❌ Error translating logo placement: $e');
  //     return logoPlacement;
  //   }
  // }

  /// Classifies a logo placement description into three simple facts a
  /// drawing AI can act on reliably: which view (front/back), which side
  /// of the WEARER's body (left/right/center — not the image's left/right),
  /// and a short zone description appropriate for the garment type (chest,
  /// shoulder, quad, waistband, back pocket, etc.). Works for any garment
  /// type, including bottoms and custom garments — no fixed word list.
  /// Layer 2 safety net: an incomplete/malformed response is never trusted,
  /// falls back to front/center instead. Non-blocking on any failure.
  static Future<Map<String, String>> _classifyLogoPlacement(
    String logoPlacement,
    String garmentType,
  ) async {
    const fallback = {'view': 'front', 'side': 'center', 'zone': 'as specified'};

    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return fallback;

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'A logo/embellishment placement was requested for a "$garmentType": "$logoPlacement". '
                      'Classify it into exactly three answers:\n'
                      'VIEW: front or back (visible from the front of the garment, or the back?)\n'
                      'SIDE: left, right, or center (the WEARER\'s own left/right, as if you were the person '
                      'wearing the garment — NOT the viewer\'s left/right)\n'
                      'ZONE: a short 1-3 word description of the specific area, appropriate for this garment '
                      'type (e.g. chest, shoulder, quad, waistband, back pocket, ankle)\n\n'
                      'Return ONLY these three lines, in this exact format, no explanation:\n'
                      'VIEW: front\n'
                      'SIDE: center\n'
                      'ZONE: chest',
                },
              ],
              'max_tokens': 30,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('❌ Logo placement classification failed: ${response.body}');
        return fallback;
      }

      final data = jsonDecode(response.body);
      final content = (data['choices'][0]['message']['content'] as String).trim();
      print('🌐 Logo placement classified: $content');

      String? view;
      String? side;
      String? zone;
      for (final line in content.split('\n')) {
        final parts = line.split(':');
        if (parts.length < 2) continue;
        final key = parts[0].trim().toUpperCase();
        final value = parts.sublist(1).join(':').trim().toLowerCase();
        if (key == 'VIEW' && (value == 'front' || value == 'back')) view = value;
        if (key == 'SIDE' && ['left', 'right', 'center'].contains(value)) side = value;
        if (key == 'ZONE' && value.isNotEmpty) zone = value;
      }

      // Layer 2 backstop: an incomplete/malformed reply is never trusted.
      if (view == null || side == null || zone == null) return fallback;
      return {'view': view, 'side': side, 'zone': zone};
    } catch (e) {
      print('❌ Error classifying logo placement: $e');
      return fallback;
    }
  }

  /// Converts the WEARER's side into the side it actually appears on
  /// within a given view — a fixed, deterministic rule, not an AI guess.
  /// Looking at someone's FRONT is a mirror (their right shows up on the
  /// left); looking at their BACK is not (their right stays on the right).
  static String _visualSideForView(String view, String wearerSide) {
    if (wearerSide == 'center') return 'center';
    final isRight = wearerSide == 'right';
    if (view == 'front') {
      return isRight ? 'left' : 'right';
    } else {
      return isRight ? 'right' : 'left';
    }
  }

  // Replaced by _buildMeasurementTableSection, which uses garment-aware
  // labels and real computed/chart-derived numbers instead of always
  // hardcoding "Chest, Waist, Hip, Length, Sleeve" for every garment type
  // (this is what caused jeans to show a nonsensical "Chest" row). Kept
  // here, disabled, for reference / possible rollback.
  //
  // static String _standardMeasurementRules(String measurementChart) {
  //   String section = '';
  //   if (measurementChart.isNotEmpty) {
  //     section += 'Measurement data: $measurementChart\n';
  //   }
  //   section +=
  //       'Render as a clean bordered grid table. Columns = each selected size (e.g. S, M, L, XL). Rows = standard measurements: Chest, Waist, Hip, Length, Sleeve. Fill in standard industry values for each size.\n'
  //       'Grading rules: Chest +3 cm, Length +2 cm, Shoulder +2 cm, Armhole +1 cm per size.\n'
  //       'Tolerance: ±1 cm for all measurements.\n';
  //   return section;
  // }

  /// A small, safe set used only if the AI measurement call fails entirely
  /// or returns unusable data — never shown to a user as a "final" result,
  /// just enough to keep generation from breaking outright.
  static List<Map<String, dynamic>> _fallbackMeasurementFields() => [
    _f('Chest Width', 'front', 50, 3, 'horizontal arrow across the widest chest point'),
    _f('Waist Width', 'front', 40, 3, 'horizontal arrow at waist level'),
    _f('Length', 'front', 65, 2, 'vertical arrow along the outer edge, top to hem'),
    _f('Shoulder Width', 'back', 40, 1.5, 'horizontal arrow across the full shoulder seam'),
  ];

  /// Asks AI to determine the standard, essential measurements for a given
  /// garment — works for ANY garment type, including "Custom" or anything
  /// not on a predefined list, since it reasons directly about the garment
  /// description rather than matching it against a fixed category list.
  ///
  /// Layer 1 (the ask): explicitly bounded to 6-10 NECESSARY measurements
  /// only, with reference examples so the AI calibrates to a normal,
  /// standard level of detail instead of returning something arbitrary.
  /// Layer 2 (the check): the response is parsed and hard-capped in code
  /// regardless of what the AI actually returned — never trusted blindly.
  /// Falls back to a small generic set on any failure (non-blocking).
  static Future<List<Map<String, dynamic>>> _generateMeasurementFields(
    String garmentType,
  ) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return _fallbackMeasurementFields();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'user',
                  'content':
                      'List the standard measurements needed for a technical spec sheet for this garment: "$garmentType". '
                      'Give between 6 and 10 measurements total — ONLY the standard, essential sizing points a manufacturer '
                      'would actually need to produce this garment. Do NOT include decorative, cosmetic, or overly specific '
                      'measurements. For reference: a t-shirt typically needs neck opening, chest width, front length, armhole '
                      'depth, sleeve length, shoulder width, back length, sleeve opening, waist width, hem width. Jeans typically '
                      'need waist width, hip width, thigh width, outseam, inseam, back rise, seat width, knee width, leg opening, '
                      'waistband height. Use this as a guide for the right LEVEL of detail for any garment type, including unusual '
                      'or custom ones.\n\n'
                      'For each measurement give: a short label, which view it belongs on (front or back), whether it is drawn as '
                      'a horizontal or vertical arrow, a realistic value in centimeters for a size M, and how many centimeters it '
                      'should grow or shrink per size step (grading).\n\n'
                      'Return ONLY plain lines in this exact format, one measurement per line, no headers, no explanation:\n'
                      'Label | View | Orientation | BaseAtM | GradingPerSize\n'
                      'Example: Chest Width | front | horizontal | 50 | 3',
                },
              ],
              'max_tokens': 400,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        print('❌ Measurement field generation failed: ${response.body}');
        return _fallbackMeasurementFields();
      }

      final data = jsonDecode(response.body);
      final content = (data['choices'][0]['message']['content'] as String).trim();
      print('📐 AI-generated measurement fields:\n$content');

      final parsed = <Map<String, dynamic>>[];
      for (final line in content.split('\n')) {
        final parts = line.split('|').map((p) => p.trim()).toList();
        if (parts.length != 5) continue;
        final base = double.tryParse(parts[3]);
        final grading = double.tryParse(parts[4]);
        final view = parts[1].toLowerCase();
        if (base == null || grading == null) continue;
        if (view != 'front' && view != 'back') continue;
        final isVertical = parts[2].toLowerCase().contains('vertical');
        final desc = isVertical
            ? 'vertical arrow along the ${parts[0]}'
            : 'horizontal arrow across the ${parts[0]}';
        parsed.add(_f(parts[0], view, base, grading, desc));
        // Layer 2 backstop: hard cap regardless of what the AI returned.
        if (parsed.length >= 10) break;
      }

      // Too little usable data came back — safer to fall back than build
      // an incomplete spec sheet from a mostly-failed parse.
      if (parsed.length < 4) return _fallbackMeasurementFields();
      return parsed;
    } catch (e) {
      print('❌ Error generating measurement fields: $e');
      return _fallbackMeasurementFields();
    }
  }

  /// Builds the COLORS section body. If real extracted Pantone codes are available,
  /// each gets its own bullet with an explicit instruction to draw a small solid
  /// swatch block filled with that color next to its Pantone code. Falls back to a
  /// plain instruction to reference the garment image when extraction produced nothing.
  static String _buildColorSwatchSection(String? colorPalette) {
    if (colorPalette == null || colorPalette.isEmpty) {
      return '• Primary colors: match the garment shown in the reference image above — draw one small solid color swatch block (1.5cm x 1.5cm) for each distinct color visible on the garment, with its Pantone code as text next to it\n';
    }
    final colors = colorPalette
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (colors.isEmpty) {
      return '• Primary colors: match the garment shown in the reference image above — draw one small solid color swatch block (1.5cm x 1.5cm) for each distinct color visible on the garment, with its Pantone code as text next to it\n';
    }
    return colors
            .map(
              (c) =>
                  '• $c — draw a small solid color swatch block (1.5cm x 1.5cm) filled with this color, with the text "$c" printed next to it',
            )
            .join('\n') +
        '\n';
  }

  /// Calls gpt-4o vision with the garment image and returns dominant colors as a plain text list.
  /// Returns null if the image cannot be read or the API call fails.
  static Future<String?> extractColorsFromGarmentImage(
    String imagePathOrUrl,
  ) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return null;

      List<Map<String, dynamic>> imageContent;
      if (imagePathOrUrl.startsWith('http://') ||
          imagePathOrUrl.startsWith('https://')) {
        imageContent = [
          {
            'type': 'image_url',
            'image_url': {'url': imagePathOrUrl},
          },
        ];
      } else if (imagePathOrUrl.startsWith('iVBOR') ||
          imagePathOrUrl.startsWith('/9j/') ||
          imagePathOrUrl.startsWith('R0lGOD')) {
        // Already base64 data — wrap directly as a data URI
        final mimeType = imagePathOrUrl.startsWith('/9j/') ? 'jpeg' : 'png';
        imageContent = [
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/$mimeType;base64,$imagePathOrUrl'},
          },
        ];
      } else {
        final base64Image = await _convertImageToBase64(imagePathOrUrl);
        if (base64Image == null) return null;
        imageContent = [
          {
            'type': 'image_url',
            'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
          },
        ];
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode({
              'model': 'gpt-4o',
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {
                      'type': 'text',
                      'text':
                          'Identify the truly distinct fabric colors of this garment — ignore shadows, highlights, folds, and ordinary lighting variation on the same fabric. If the garment is a single solid color, identify only ONE color even if the photo shows some shading. Only list additional colors if there are genuinely different colored components (e.g. a contrast panel, a different-colored trim or hood). For each distinct color, give its closest Pantone TPX code AND its approximate hex value. Return ONLY a comma-separated list in the exact format "Pantone 19-4052 TPX #2F4F3E" (e.g. "Pantone 19-4052 TPX #2F4F3E, Pantone 11-0601 TPX #1A2B1C"). Maximum 5 colors. No color names, no explanations, no extra text.',
                    },
                    ...imageContent,
                  ],
                },
              ],
              'max_tokens': 60,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawColors = (data['choices'][0]['message']['content'] as String)
            .trim();
        print('🎨 Extracted colors (raw): $rawColors');

        final dedupedColors = _dedupeSimilarColors(rawColors);
        print('🎨 Extracted colors (after merging near-identical shades): $dedupedColors');
        return dedupedColors;
      } else {
        print('❌ Color extraction failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error extracting colors: $e');
      return null;
    }
  }

  /// Merges Pantone/hex entries that are close enough in color to be
  /// shadow or lighting variation on the same fabric, rather than a
  /// genuinely distinct second color (fixes solid-color garments getting
  /// multiple fake Pantone matches). Expects entries in the format
  /// "Pantone 19-4052 TPX #2F4F3E". If any entry doesn't include a
  /// parseable hex value, dedup is skipped and the original list is
  /// returned as-is (no hex values means no safe way to compare colors).
  static String _dedupeSimilarColors(String rawColorList) {
    final entries = rawColorList
        .split(',')
        .map((c) => c.trim())
        .where((c) => c.isNotEmpty)
        .toList();
    if (entries.isEmpty) return rawColorList;

    final hexPattern = RegExp(r'^(.*?)\s*#([0-9A-Fa-f]{6})$');
    final parsed = <MapEntry<String, List<int>>>[];

    for (final entry in entries) {
      final match = hexPattern.firstMatch(entry);
      if (match == null) {
        // Couldn't parse a hex value from this entry — can't safely compare
        // colors, so skip deduping entirely and return the original list.
        return entries.join(', ');
      }
      final code = match.group(1)!.trim();
      final hex = match.group(2)!;
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      parsed.add(MapEntry(code, [r, g, b]));
    }

    // Two colors closer than this in RGB space are treated as the same
    // fabric color (shadow/highlight/lighting variation), not a real
    // second color. Max possible distance is ~441 (pure black vs white).
    const double similarityThreshold = 60.0;

    final kept = <MapEntry<String, List<int>>>[];
    for (final candidate in parsed) {
      final isDuplicate = kept.any((existing) {
        final dr = candidate.value[0] - existing.value[0];
        final dg = candidate.value[1] - existing.value[1];
        final db = candidate.value[2] - existing.value[2];
        final distance = sqrt((dr * dr + dg * dg + db * db).toDouble());
        return distance < similarityThreshold;
      });
      if (!isDuplicate) kept.add(candidate);
    }

    return kept.map((e) => e.key).join(', ');
  }

  /// Calls gpt-4o with the size chart image and returns extracted measurements as plain text.
  /// Returns null if the image cannot be read or the API call fails.
  static Future<String?> extractSizesFromChartImage(String imagePath) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return null;

      final base64Image = await _convertImageToBase64(imagePath);
      if (base64Image == null) return null;

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text':
                      'This is a garment size chart. Extract every measurement from it and return them as plain text only, in this exact format:\n'
                      'Size | Measurement Name | Value\n'
                      'Example:\nS | Chest | 36 cm\nM | Chest | 38 cm\n'
                      'IMPORTANT: Preserve the exact units as shown in the chart (e.g. cm, inches, mm). Do NOT convert units. If the chart uses inches, keep inches. If it uses cm, keep cm.\n'
                      'Return ONLY the extracted data rows, nothing else. No headings, no explanation.',
                },
                {
                  'type': 'image_url',
                  'image_url': {'url': 'data:image/jpeg;base64,$base64Image'},
                },
              ],
            },
          ],
          'max_tokens': 600,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final extracted = data['choices'][0]['message']['content'] as String;
        print('📐 Extracted measurements from chart:\n$extracted');
        return extracted;
      } else {
        print('❌ gpt-4o chart extraction failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error extracting sizes from chart image: $e');
      return null;
    }
  }

  // ============================================================================
  // SHARED MEASUREMENT SYSTEM — single source of truth for both Page 2's
  // measurement table and Page 3's technical flat drawing. Every field has a
  // base value at size M plus a per-size grading amount, so any selected
  // size can be computed (not just a fixed M), and both pages read from the
  // exact same category + field data so they can never disagree with each
  // other. An uploaded measurement chart's real values take priority over
  // these computed defaults wherever the chart actually provides them.
  // ============================================================================

  static const List<String> _sizeOrder = ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'];

  /// How many size steps `size` is away from M (negative = smaller, positive
  /// = larger). Unrecognized size labels are treated as M (no adjustment).
  static int _sizeStepFromM(String size) {
    final normalized = size.trim().toUpperCase();
    final idx = _sizeOrder.indexOf(normalized);
    if (idx == -1) return 0;
    return idx - _sizeOrder.indexOf('M');
  }

  static String _fmtCm(double value) => '${value.round()} cm';

  static Map<String, dynamic> _f(
    String label,
    String view,
    double base,
    double grading,
    String desc,
  ) => {
    'label': label,
    'view': view,
    'base': base,
    'grading': grading,
    'desc': desc,
  };


  /// Finds a chart-provided value for `label` at `size`, matching loosely
  /// (case-insensitive, either name containing the other) since an uploaded
  /// chart's wording won't exactly match our field labels. Returns null if
  /// the chart doesn't cover this field for this size.
  static String? _chartValueFor(
    Map<String, Map<String, String>>? chartData,
    String size,
    String label,
  ) {
    final sizeData = chartData?[size.trim().toUpperCase()];
    if (sizeData == null) return null;
    final target = label.toLowerCase();
    for (final entry in sizeData.entries) {
      final chartLabel = entry.key.toLowerCase();
      if (chartLabel.contains(target) || target.contains(chartLabel)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Parses "Size | Measurement Name | Value" lines (the exact format
  /// extractSizesFromChartImage's prompt asks the AI to return) into
  /// size -> field name -> value-with-unit. Malformed lines are skipped.
  static Map<String, Map<String, String>> _parseChartMeasurements(String rawChartText) {
    final result = <String, Map<String, String>>{};
    for (final line in rawChartText.split('\n')) {
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length != 3 || parts.any((p) => p.isEmpty)) continue;
      final size = parts[0].toUpperCase();
      result.putIfAbsent(size, () => {})[parts[1]] = parts[2];
    }
    return result;
  }

  /// Returns size-appropriate measurements for the technical flat drawing
  /// (ONE reference size only — a flat drawing can't legibly show arrows
  /// for multiple sizes at once), from the `fields` already produced by
  /// _generateMeasurementFields — the exact same fields Page 2's table
  /// uses, so the two pages can never disagree. Uses real chart values
  /// first where the chart covers a field, computed base+grading otherwise.
  static Map<String, String> _techFlatMeasurements(
    List<Map<String, dynamic>> fields,
    String referenceSize, {
    Map<String, Map<String, String>>? chartData,
  }) {
    String valueFor(Map<String, dynamic> field) {
      final chartValue = _chartValueFor(chartData, referenceSize, field['label'] as String);
      if (chartValue != null && chartValue.isNotEmpty) return chartValue;
      final steps = _sizeStepFromM(referenceSize);
      final computed = (field['base'] as double) + (field['grading'] as double) * steps;
      return _fmtCm(computed);
    }

    final frontFields =
        fields.where((f) => (f['view'] as String) == 'front').toList();
    final backFields =
        fields.where((f) => (f['view'] as String) == 'back').toList();

    String bulletsFor(List<Map<String, dynamic>> group) => group
        .map((f) => '  • ${f['label']}: ${valueFor(f)} — ${f['desc']}')
        .join('\n');

    final tableLines = <String>[];
    for (int i = 0; i < frontFields.length; i++) {
      final left = '${frontFields[i]['label']}: ${valueFor(frontFields[i])}';
      final right = i < backFields.length
          ? '${backFields[i]['label']}: ${valueFor(backFields[i])}'
          : '';
      tableLines.add('  ${left.padRight(28)}$right');
    }

    return {
      'front': bulletsFor(frontFields),
      'back': bulletsFor(backFields),
      'table': tableLines.join('\n'),
    };
  }

  /// Picks the one reference size the flat drawing displays: M if it was
  /// selected, otherwise the first selected size, otherwise M as a final
  /// fallback (no sizes selected at all).
  static String _referenceSizeFor(List<String> selectedSizes) {
    if (selectedSizes.contains('M')) return 'M';
    if (selectedSizes.isNotEmpty) return selectedSizes.first;
    return 'M';
  }

  /// Builds Page 2's MEASUREMENT TABLE section — every measurement in
  /// `fields` (already the AI-curated, necessary-only set produced by
  /// _generateMeasurementFields), across every selected size, using real
  /// chart values first and computed base+grading values otherwise. This
  /// is the exact same field data _techFlatMeasurements uses, so the two
  /// pages can never show different numbers for the same size.
  static String _buildMeasurementTableSection(
    List<Map<String, dynamic>> fields,
    List<String> selectedSizes, {
    Map<String, Map<String, String>>? chartData,
  }) {
    final sizes = selectedSizes.isEmpty ? ['S', 'M', 'L'] : selectedSizes;

    String valueFor(Map<String, dynamic> field, String size) {
      final chartValue = _chartValueFor(chartData, size, field['label'] as String);
      if (chartValue != null && chartValue.isNotEmpty) return chartValue;
      final steps = _sizeStepFromM(size);
      final computed = (field['base'] as double) + (field['grading'] as double) * steps;
      return _fmtCm(computed);
    }

    final rows = fields
        .map((f) => '${f['label']} | ${sizes.map((s) => valueFor(f, s)).join(' | ')}')
        .join('\n');

    return 'Render as a clean bordered grid table. Columns = ${sizes.join(', ')}. '
        'Rows = exactly these measurements, with exactly these values — do NOT invent different numbers, do NOT add or remove rows:\n'
        'Measurement (cm) | ${sizes.join(' | ')}\n'
        '$rows\n'
        'Tolerance: ±1 cm for all measurements.\n';
  }

  static Future<Map<String, String>> generateTechPackPrompts({
    required Map<String, dynamic> creativeBrief,
    required Map<String, dynamic> refinedConcept,
    required Map<String, dynamic> finalDetails,
    required Map<String, dynamic> techPackDetails,
    required String selectedDesignPrompt,
    String? measurementChartImagePath,
    String? colorPalette,
  }) async {
    // Extract key information directly - no GPT-4 API call needed
    final rawGarmentType = (creativeBrief['garmentType'] ?? 'jacket')
        .toString();
    // Strip category prefix: "Dresses:Cocktail dress" → "Cocktail dress"
    final garmentType = rawGarmentType.contains(':')
        ? rawGarmentType.split(':').last.trim()
        : rawGarmentType;

    // Check every free-text tech pack answer for ones that mean "none/not
    // applicable" in a language other than English (e.g. French "non")
    // BEFORE resolving defaults below. Real content — in English, French, or
    // any wording — is left completely untouched and prints exactly as
    // typed; only genuinely empty-meaning answers get routed to the same
    // defaults English "none" already triggers. See Problem 2/3 discussion.
    final rawFreeTextFields = <String, String>{
      'fabricComposition':
          (techPackDetails['materials']?['fabricComposition'] ?? '')
              .toString(),
      'fabricWeight':
          (techPackDetails['materials']?['fabricWeight'] ?? '').toString(),
      'secondaryMaterials':
          (techPackDetails['materials']?['secondaryMaterials'] ?? '')
              .toString(),
      'fabricProperties':
          (techPackDetails['materials']?['fabricProperties'] ?? '')
              .toString(),
      'stitching':
          (techPackDetails['technical']?['stitching'] ?? '').toString(),
      'decorativeStitching':
          (techPackDetails['technical']?['decorativeStitching'] ?? '')
              .toString(),
      'accessories':
          (techPackDetails['technical']?['accessories'] ?? '').toString(),
      'logoPlacement':
          (techPackDetails['labeling']?['logoPlacement'] ?? '').toString(),
      'logoShape':
          (techPackDetails['labeling']?['logoShape'] ?? '').toString(),
      'logoWidth':
          (techPackDetails['labeling']?['logoWidth'] ?? '').toString(),
      'logoHeight':
          (techPackDetails['labeling']?['logoHeight'] ?? '').toString(),
      'labelsNeeded':
          (techPackDetails['labeling']?['labelsNeeded'] ?? '').toString(),
      'embroideryThreadPantone':
          (techPackDetails['labeling']?['embroideryThreadPantone'] ?? '')
              .toString(),
    };
    final emptyMeaningFields = await _detectEmptyMeaningFields(
      rawFreeTextFields,
    );
    String rawOrEmpty(String key) =>
        emptyMeaningFields.contains(key) ? '' : rawFreeTextFields[key]!;

    final fabricComposition = _resolveField(
      rawOrEmpty('fabricComposition'),
      'Standard fabric',
    );
    final fabricWeight = _resolveField(
      rawOrEmpty('fabricWeight'),
      '180 GSM',
    );
    final creativeBriefFabric = (creativeBrief['fabrics'] ?? '').toString();
    final bool isIndustryComposition =
        techPackDetails['materials']?['isIndustryStandardComposition'] == true;
    final bool isIndustryGSM =
        techPackDetails['materials']?['isIndustryStandardGSM'] == true;

    final String resolvedFabric = _buildFabricLine(
      fabricComposition,
      fabricWeight,
      creativeBriefFabric,
      isIndustryComposition: isIndustryComposition,
      isIndustryGSM: isIndustryGSM,
    );
    final secondaryMaterial = _resolveField(
      rawOrEmpty('secondaryMaterials'),
      'No secondary material',
    );
    final fabricProperties = _resolveField(
      rawOrEmpty('fabricProperties'),
      'Standard',
    );
    final String sizeRange =
        (techPackDetails['sizes']?['sizeRange'] ?? '').toString();
    final measurementChart =
        techPackDetails['sizes']?['measurementChart'] ?? '';
    final stitching = _resolveField(
      rawOrEmpty('stitching'),
      'Overlock stitch (4 threads)',
    );
    final decorativeStitching = _resolveField(
      rawOrEmpty('decorativeStitching'),
      'Single row, 1 mm spacing',
    );
    final accessories = _resolveField(
      rawOrEmpty('accessories'),
      'Bartack at stress points',
    );
    final logoPlacement = rawOrEmpty('logoPlacement').trim();
    // Optional — left blank (not defaulted) so the corresponding line in the
    // document is simply omitted when not provided, rather than printing a
    // filler value. See Accurate Logo Placement / Embroidery Thread Colors.
    final logoShape = rawOrEmpty('logoShape').trim();
    final logoWidth = rawOrEmpty('logoWidth').trim();
    final logoHeight = rawOrEmpty('logoHeight').trim();
    final embroideryThreadPantone = rawOrEmpty('embroideryThreadPantone')
        .trim();
    final labelsNeeded = _resolveField(
      rawOrEmpty('labelsNeeded'),
      'No Label',
    );
    final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';
    // Garment overview fields
    final fit = (refinedConcept['silhouette'] ?? '').toString();
    final gender = (creativeBrief['targetAudience'] ?? '').toString();
    final season = (refinedConcept['season'] ?? '').toString();
    print('🎨 DEBUG: Building manufacturing prompt...');
    print('   📷 labelImage.isNotEmpty: ${labelImage.isNotEmpty}');
    print('   📝 labelsNeeded.isNotEmpty: ${labelsNeeded.isNotEmpty}');

    // MEASUREMENT TABLE — grid table
    // Selected sizes as a list — drives both pages' per-size calculations.
    final List<String> selectedSizesList = sizeRange
        .split(',')
        .map((s) => s.trim().toUpperCase())
        .where((s) => s.isNotEmpty)
        .toList();

    // If a real chart was uploaded and successfully read, its numbers take
    // priority (for whichever fields/sizes it actually covers) on BOTH
    // pages — computed defaults only fill in whatever the chart doesn't.
    Map<String, Map<String, String>>? chartData;
    if (measurementChartImagePath != null &&
        measurementChartImagePath.isNotEmpty) {
      final extractedSizes = await extractSizesFromChartImage(
        measurementChartImagePath,
      );
      if (extractedSizes != null && extractedSizes.isNotEmpty) {
        chartData = _parseChartMeasurements(extractedSizes);
      }
    }

    // Ask AI once for the standard, necessary measurements for this garment
    // (works for any garment type, including "Custom" — no fixed category
    // list). This SAME set is reused for the flat drawing below, so the two
    // pages can never disagree.
    final measurementFields = await _generateMeasurementFields(garmentType);

    String measurementTableSection = '';
    if (sizeRange.isNotEmpty) {
      measurementTableSection += 'Selected sizes: $sizeRange\n';
    }
    // Supplementary free-text measurement notes, if the user provided any —
    // shown alongside the computed table, not in place of it.
    if (measurementChart.isNotEmpty) {
      measurementTableSection += 'Additional measurement notes: $measurementChart\n';
    }
    measurementTableSection += _buildMeasurementTableSection(
      measurementFields,
      selectedSizesList,
      chartData: chartData,
    );

    // CONSTRUCTION DETAILS — always 4 mandatory items
    final String constructionSection =
        '-- Stitch type: $stitching\n'
        '-- Topstitch: $decorativeStitching\n'
        '-- Reinforcements: $accessories\n'
        '-- Seam allowance: 1 cm (all seams)\n';

    // FABRIC — dedicated section
    String fabricSection = '';
    if (resolvedFabric.isNotEmpty)
      fabricSection += '-- Fabric: $resolvedFabric\n';
    if (secondaryMaterial.isNotEmpty)
      fabricSection += '-- Secondary material: $secondaryMaterial\n';
    if (fabricProperties.isNotEmpty)
      fabricSection += '-- Fabric properties: $fabricProperties\n';

    // LOGO AND LABELS — combined section
    String logoAndLabelsSection = '• Logo placement: $logoPlacement\n';
    if (logoShape.isNotEmpty) {
      logoAndLabelsSection += '• Logo shape: $logoShape\n';
    }
    // Only shown when BOTH width and height are provided — a dimension line
    // with one side missing isn't meaningful, so it's omitted entirely.
    if (logoWidth.isNotEmpty && logoHeight.isNotEmpty) {
      logoAndLabelsSection +=
          '• Logo dimensions: ${logoWidth}cm x ${logoHeight}cm (Width x Height)\n';
    }
    logoAndLabelsSection += '• Labels: $labelsNeeded\n';

    // Garment overview — clean lines
    String garmentOverviewSection = '• Garment Type: $garmentType\n';
    if (fit.isNotEmpty) garmentOverviewSection += '• Fit: $fit\n';
    if (gender.isNotEmpty) garmentOverviewSection += '• Gender: $gender\n';
    if (season.isNotEmpty) garmentOverviewSection += '• Season: $season\n';

    // COLORS — dedicated section with drawn swatch blocks
    final bool hasColors = colorPalette != null && colorPalette.isNotEmpty;
    String colorsSection = _buildColorSwatchSection(
      hasColors ? colorPalette : null,
    );
    // User-specified thread color — manually entered, no AI detection.
    // Shown alongside the garment color(s) above, clearly labeled as thread
    // rather than fabric, so the two are never confused with one another.
    if (embroideryThreadPantone.isNotEmpty) {
      colorsSection +=
          '• Embroidery thread pantone: $embroideryThreadPantone — draw a small solid color swatch block (1.5cm x 1.5cm) filled with this color, with the text "Embroidery Thread: $embroideryThreadPantone" printed next to it (the words "Embroidery Thread:" MUST be printed as part of this label, so it is never mistaken for a garment/fabric color)\n';
    }

    final String garmentTitle = garmentType.toUpperCase();

    final String manufacturingPrompt =
        '''Generate a professional fashion tech pack specification sheet as a clean document image on a white background. Use clear section headers, professional typography, and organized layout.

CRITICAL GLOBAL RULE: Render each section header and its content EXACTLY ONCE. Do NOT repeat any section or heading anywhere in the image under any circumstance. There must be exactly 6 sections — no more, no fewer.

IMAGE RULE — STRICTLY ENFORCE:
- The ONLY visual elements allowed in the entire document are: (1) the single garment design image shown at the top, and (2) small solid color swatch blocks inside the COLORS section only.
- Do NOT include any fabric swatches, texture thumbnails, logo images, label images, garment cutouts, icons, or any other visual elements anywhere else in the document.
- Sections other than COLORS must contain TEXT ONLY. No images, no graphics, no illustrations of any kind within those sections.

═══════════════════════════════════════════════
TECH PACK — $garmentTitle
═══════════════════════════════════════════════

GARMENT IMAGE:
- Show the garment exactly as it appears in the reference design image provided
- The garment image must be clearly visible, proportional, and not cropped
- This is the only full garment image in the document (small color swatch blocks in the COLORS section are the sole exception)

SECTIONS (render each exactly once, in this exact order, no additional sections allowed):

──────────────────────────────────────
1. GARMENT OVERVIEW
──────────────────────────────────────
$garmentOverviewSection
──────────────────────────────────────
2. COLORS — MUST include a drawn solid color swatch block for each color listed below, plus its name
──────────────────────────────────────
$colorsSection
──────────────────────────────────────
3. MEASUREMENT TABLE
──────────────────────────────────────
$measurementTableSection
──────────────────────────────────────
4. CONSTRUCTION DETAILS
──────────────────────────────────────
$constructionSection
──────────────────────────────────────
5. FABRIC
──────────────────────────────────────
$fabricSection
──────────────────────────────────────
6. LOGO AND LABELS
──────────────────────────────────────
$logoAndLabelsSection

Style requirements:
- White background, clean margins, professional fashion industry layout
- Section headers in bold with divider lines
- Bullet points for list items; bordered grid table for MEASUREMENT TABLE section; small solid color blocks for the COLORS section
- All text clearly readable, professional sans-serif typography
- Complete layout fully visible within image boundaries
- CRITICAL: All text must be spelled correctly with zero spelling mistakes
- CRITICAL: Do NOT add any sections beyond the 6 listed above
- CRITICAL: Sections 1, 3, 4, 5, 6 are TEXT ONLY. Zero images or graphics inside those sections. Section 2 (COLORS) is the only section allowed to contain drawn color swatch blocks.
''';

    // Dashed LOGO box at the user's requested location (not hardcoded to chest/neck)
    // final String technicalLogoInstruction =
    //     '\n- Logo placeholder: Draw a dashed-border rectangle (5 cm W × 3 cm H) with the text "LOGO" centered inside it. Place this box exactly at the user-requested location: "$logoPlacement". If that location is on the back, draw it on the BACK VIEW (right half). If it is on a sleeve/bicep/arm, draw it on that sleeve of the matching view. If it is on the front/chest/neck, draw it on the FRONT VIEW (left half). Do not default to the chest. Do not place it 3 cm below the neckline unless the user asked for the neck. Add width (5 cm) and height (3 cm) dimension arrows outside the box. Do NOT draw any actual logo image or artwork inside the box.';

    final lp = logoPlacement.toLowerCase();
    final bool wantsNoLogo =
        lp.contains('no logo') ||
        lp.contains('without logo') ||
        lp.contains('no branding') ||
        lp == 'none' ||
        lp == 'no' ||
        lp == 'nope' ||
        lp == 'n/a' ||
        lp == 'na';

    // Classified ONLY for this drawing instruction — never shown anywhere.
    // The visible spec sheet (logoAndLabelsSection, above) still uses the
    // original, untranslated $logoPlacement exactly as the user typed it.
    String technicalLogoPlacementText = '';
    if (!wantsNoLogo) {
      final classified = await _classifyLogoPlacement(logoPlacement, garmentType);
      final view = classified['view']!;
      final wearerSide = classified['side']!;
      final zone = classified['zone']!;
      final visualSide = _visualSideForView(view, wearerSide);
      technicalLogoPlacementText = visualSide == 'center'
          ? 'on the $view view, centered, in the $zone area'
          : 'on the $view view, on the $visualSide side of that view, in the $zone area';
    }

    final String technicalLogoInstruction = wantsNoLogo
        ? '\n- Logo placeholder: Do NOT draw any dashed LOGO box, logo mark, placeholder, or branding graphic on the FRONT VIEW or BACK VIEW. The garment must have zero logo boxes.'
        : '\n- Logo placeholder: Draw a dashed-border rectangle (5 cm W × 3 cm H) with the text "LOGO" centered inside it, and nothing else drawn on or around the box — no dimension arrows, no measurement labels, no size text of any kind. Place it $technicalLogoPlacementText. Do NOT draw any actual logo image or artwork inside the box.';

    // Same AI-generated fields, same reference size, and the same chart (if
    // any) that Page 2's table used above — guarantees this drawing's
    // numbers can never disagree with the measurement table.
    final String referenceSize = _referenceSizeFor(selectedSizesList);
    final measurements = _techFlatMeasurements(
      measurementFields,
      referenceSize,
      chartData: chartData,
    );

    final technicalFlatPrompt =
        '''Technical flat drawing of a $garmentType. White background. Black line art only, no colors, no shading, no fill.

LAYOUT:
- Left half of image: FRONT VIEW of the $garmentType
- Right half of image: BACK VIEW of the $garmentType
- Leave generous empty margin space around each view specifically for measurement annotations
- Both views fully visible, not cropped or cut off

DRAWING STYLE:
- Clean precise black outlines, slightly thicker on exterior silhouette
- Professional apparel technical drawing, vector-quality
- No text, labels, or callouts drawn on or inside the garment itself
- No shading, no color fills, black and white only

MEASUREMENTS — FRONT VIEW (annotate on the left half):
Draw double-headed dimension arrows OUTSIDE the garment outline, each with a clear numeric cm value:
${measurements['front']}

MEASUREMENTS — BACK VIEW (annotate on the right half):
Draw double-headed dimension arrows OUTSIDE the garment outline, each with a clear numeric cm value:
${measurements['back']}$technicalLogoInstruction

MEASUREMENT SUMMARY TABLE — below the drawing:
After both garment views, add a clean text summary at the bottom of the image listing all measurements in two columns:
${measurements['table']}

RULES:
- Every single measurement arrow MUST display its numeric cm value — no blank or missing values
- Arrows must sit outside the garment, never overlapping the garment outline
- Use small, clear, sans-serif font for all measurement text
- Do not add any extra labels, callouts, or garment feature annotations beyond measurements
- The measurement summary table at the bottom must include all 10 measurements
- Draw ONLY the measurement arrows listed above — do NOT add any additional arrows, lines, or callouts not listed
- Each arrow must be placed at the exact anatomical position described — do NOT place arrows arbitrarily or in the wrong location
- Do NOT add inaccurate measurement arrows — if a measurement position is unclear, omit the arrow entirely rather than placing it incorrectly

CRITICAL: All text and numbers must be spelled and written correctly with no mistakes.
''';

    print('Manufacturing prompt (${manufacturingPrompt.length} chars)');
    print('Technical prompt (${technicalFlatPrompt.length} chars)');

    return {
      'manufacturing_prompt': manufacturingPrompt,
      'technical_flat_prompt': technicalFlatPrompt,
    };
  }

  // ============================================================================
  // COMMENTED OUT (Problem 5 fix) — DO NOT re-enable without fixing the bug below.
  //
  // These 3 backup prompt-builders used hardcoded placeholder defaults
  // ('jacket' for garment type, 'collar' for features, 'zipper' for
  // accessories) whenever real data wasn't found. They were called as a
  // silent safety net when the main method (generateTechPackPrompts) failed —
  // which is exactly what caused a hoodie to be drawn as a collared, zipped
  // jacket for a real client, with no error ever shown to the user.
  //
  // On top of the hardcoded defaults, 'features' was read from
  // creativeBrief['features'], but that value is actually stored under
  // finalDetailsData['features'] / refinedConceptData['features'] instead —
  // so it was NEVER found, meaning the 'collar' default fired on every
  // single call to these methods, for every garment type, guaranteed.
  //
  // All call sites (main generation flow + the unused testTechnicalDrawingPrompts
  // debug helper in tech_pack_details_controller.dart) have been disabled too.
  // Kept here, disabled, only for reference / possible rollback.
  // ============================================================================
  //
  // // ALTERNATIVE: Single detailed view if three views still cause cutting
  // static Map<String, String> getDetailedSingleViewPrompts(
  //   Map<String, dynamic> techPackDetails,
  //   Map<String, dynamic> creativeBrief,
  // ) {
  //   final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  //   final accessories =
  //       techPackDetails['technical']?['accessories'] ?? 'zipper';
  //   final stitching =
  //       techPackDetails['technical']?['stitching'] ?? 'single stitch';
  //   final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
  //   final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
  //   final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';
  //
  //   // Create label text for LABELS section
  //   String labelTextForSection = '';
  //   String technicalLogoInstruction = '';
  //
  //   if (labelImage.isNotEmpty) {
  //     // User uploaded logo image - show actual logo
  //     technicalLogoInstruction =
  //         'Show logo from reference image on $logoPlacement with callout. ';
  //     if (labelsNeeded.isNotEmpty) {
  //       labelTextForSection = labelsNeeded;
  //     }
  //   } else if (labelsNeeded.isNotEmpty) {
  //     // User provided label text only - keep garment clean, show highlighted area on technical
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text, add callout annotation "Label: $labelsNeeded". ';
  //     labelTextForSection = labelsNeeded;
  //   } else if (logoPlacement.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
  //   }
  //
  //   String labelsSection = '';
  //   if (labelTextForSection.isNotEmpty) {
  //     // Only show label text, not placement
  //     labelsSection = labelTextForSection;
  //   } else if (logoPlacement.isNotEmpty) {
  //     labelsSection = '$logoPlacement placement';
  //   }
  //
  //   return {
  //     'manufacturing_prompt':
  //         'Professional fashion tech pack specification sheet for $garmentType. Organized sections: materials, colors with swatches, sizes chart, technical details, LABELS ($labelsSection), production info. Clean grid layout, white background.',
  //
  //     'technical_flat_prompt':
  //         'Detailed technical flat drawing of $garmentType, large front view centered on white background. Black line art with comprehensive annotations: measurement arrows (A, B, C, D), seam allowances labeled, $accessories details, $stitching callouts, construction notes, dimension lines. ${technicalLogoInstruction}Professional fashion industry flat with detailed labeling. Complete drawing visible with wide margins.',
  //   };
  // }
  //
  // // ADVANCED: Detailed layout with explicit positioning
  // static Map<String, String> getAdvancedDetailedPrompts(
  //   Map<String, dynamic> techPackDetails,
  //   Map<String, dynamic> creativeBrief,
  // ) {
  //   final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  //   final accessories =
  //       techPackDetails['technical']?['accessories'] ?? 'zipper';
  //   final stitching =
  //       techPackDetails['technical']?['stitching'] ?? 'single stitch';
  //   final decorativeStitching =
  //       techPackDetails['technical']?['decorativeStitching'] ??
  //       'contrast topstitch';
  //   final features = creativeBrief['features'] ?? 'collar';
  //   final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
  //   final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
  //   final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';
  //
  //   // Create label text for LABELS section
  //   String labelTextForSection = '';
  //   String technicalLogoInstruction = '';
  //
  //   if (labelImage.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Show logo from reference image on $logoPlacement with callout. ';
  //     if (labelsNeeded.isNotEmpty) {
  //       labelTextForSection = labelsNeeded;
  //     }
  //   } else if (labelsNeeded.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text, add callout annotation "Label: $labelsNeeded". ';
  //     labelTextForSection = labelsNeeded;
  //   } else if (logoPlacement.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
  //   }
  //
  //   String labelsSection = '';
  //   if (labelTextForSection.isNotEmpty) {
  //     labelsSection = labelTextForSection;
  //   } else if (logoPlacement.isNotEmpty) {
  //     labelsSection = '$logoPlacement placement';
  //   }
  //
  //   return {
  //     'manufacturing_prompt':
  //         'Complete fashion tech pack layout for $garmentType. Grid format with sections: MATERIALS (fabric swatches), COLORS (color blocks with codes), SIZES (measurement table), TECHNICAL ($accessories, $stitching), LABELS ($labelsSection), PACKAGING, PRODUCTION. Professional format, white background, all content within frame.',
  //
  //     'technical_flat_prompt':
  //         'Technical flat drawing sheet for $garmentType. Layout: Front view (upper left), back view (upper right), detail callouts (bottom). Black lines on white. Show: $features, $accessories, $stitching, $decorativeStitching. ${technicalLogoInstruction}Include: measurement points A-F with arrows, seam allowances, construction details, topstitching circles. Professional annotations. Complete sheet layout with 10% margin border.',
  //   };
  // }
  //
  // // FALLBACK: Simplified but still detailed
  // static Map<String, String> getSimplifiedDetailedPrompts(
  //   Map<String, dynamic> techPackDetails,
  //   Map<String, dynamic> creativeBrief,
  // ) {
  //   final garmentType = creativeBrief['garmentType'] ?? 'jacket';
  //   final accessories =
  //       techPackDetails['technical']?['accessories'] ?? 'zipper';
  //   final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
  //   final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
  //   final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';
  //
  //   // Create label text for LABELS section
  //   String labelTextForSection = '';
  //   String technicalLogoInstruction = '';
  //
  //   if (labelImage.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Show logo from reference on $logoPlacement with callout. ';
  //     if (labelsNeeded.isNotEmpty) {
  //       labelTextForSection = labelsNeeded;
  //     }
  //   } else if (labelsNeeded.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text, add annotation "Label: $labelsNeeded". ';
  //     labelTextForSection = labelsNeeded;
  //   } else if (logoPlacement.isNotEmpty) {
  //     technicalLogoInstruction =
  //         'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
  //   }
  //
  //   String labelsSection = '';
  //   if (labelTextForSection.isNotEmpty) {
  //     labelsSection = labelTextForSection;
  //   } else if (logoPlacement.isNotEmpty) {
  //     labelsSection = '$logoPlacement placement';
  //   }
  //
  //   return {
  //     'manufacturing_prompt':
  //         'Fashion tech pack for $garmentType: materials, colors, sizes, LABELS ($labelsSection), production details. Professional layout, white background, organized sections.',
  //
  //     'technical_flat_prompt':
  //         'Technical drawing $garmentType with detailed labels. Front view, black lines, measurement arrows, $accessories details, construction notes. ${technicalLogoInstruction}Complete drawing with margins.',
  //   };
  // }
}
