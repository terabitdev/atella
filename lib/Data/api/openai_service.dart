import 'dart:convert';
import 'dart:io';
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
          throw Exception('OpenAI API Error: status ${response.statusCode}, empty response body');
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
        print('OpenAI: Added white background and front/back split requirement to prompt');
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
          throw Exception('OpenAI API Error: status ${response.statusCode}, empty response body');
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
    'lightweight (poplin, voile)': {'composition': '100% Cotton', 'type': 'Poplin', 'gsm': '90'},
    'poplin': {'composition': '100% Cotton', 'type': 'Poplin', 'gsm': '90'},
    'voile': {'composition': '100% Cotton', 'type': 'Voile', 'gsm': '70'},
    'medium (twill)': {'composition': '100% Cotton', 'type': 'Twill', 'gsm': '150'},
    'twill': {'composition': '100% Cotton', 'type': 'Twill', 'gsm': '150'},
    'heavy (denim, canvas)': {'composition': '100% Cotton', 'type': 'Denim', 'gsm': '320'},
    'denim': {'composition': '100% Cotton', 'type': 'Denim', 'gsm': '320'},
    'canvas': {'composition': '100% Cotton', 'type': 'Canvas', 'gsm': '350'},
    // Wool
    'wool': {'composition': '100% Wool', 'type': 'Woven', 'gsm': '300'},
    'merino': {'composition': '100% Merino Wool', 'type': 'Fine Knit', 'gsm': '200'},
    'cashmere': {'composition': '100% Cashmere', 'type': 'Fine Knit', 'gsm': '160'},
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
    'textured': {'composition': '100% Linen', 'type': 'Textured Weave', 'gsm': '160'},
    'blended': {'composition': '55% Linen 45% Cotton', 'type': 'Blended Weave', 'gsm': '150'},
    // Synthetic
    'polyester': {'composition': '100% Polyester', 'type': 'Woven', 'gsm': '120'},
    'nylon': {'composition': '100% Nylon', 'type': 'Plain Weave', 'gsm': '100'},
    'spandex': {'composition': '80% Polyester 20% Spandex', 'type': 'Stretch Woven', 'gsm': '180'},
    'neoprene': {'composition': '100% Neoprene', 'type': 'Scuba', 'gsm': '380'},
    // Eco
    'organic cotton': {'composition': '100% Organic Cotton', 'type': 'Jersey', 'gsm': '180'},
    'recycled polyester': {'composition': '100% Recycled Polyester', 'type': 'Woven', 'gsm': '120'},
    'bamboo': {'composition': '70% Bamboo 30% Cotton', 'type': 'Jersey', 'gsm': '160'},
    'hemp': {'composition': '100% Hemp', 'type': 'Plain Weave', 'gsm': '200'},
    // Leather
    'leather': {'composition': '100% Genuine Leather', 'type': 'Full Grain', 'gsm': '800'},
    'faux leather': {'composition': '100% Faux Leather (PU)', 'type': 'Backed Fabric', 'gsm': '600'},
    // Knitwear
    'jersey': {'composition': '100% Cotton', 'type': 'Jersey', 'gsm': '180'},
    'rib knit': {'composition': '95% Cotton 5% Elastane', 'type': 'Rib Knit', 'gsm': '220'},
    'interlock': {'composition': '100% Cotton', 'type': 'Interlock', 'gsm': '200'},
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

  static String resolveByGarmentType(String garmentType, Map<String, String> defaults, String fallback) {
    final key = garmentType.toLowerCase().trim();
    if (defaults.containsKey(key)) return defaults[key]!;
    for (final entry in defaults.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return fallback;
  }

  static String _resolveFabricLine(String compositionInput, String weightInput, String creativeBriefFabric) {
    final compositionKey = compositionInput.toLowerCase().trim();
    // Strip any "Category:" prefix from creative brief fabric (e.g. "Knitwear:Jersey" → "jersey")
    final fabricTypeKey = creativeBriefFabric.contains(':')
        ? creativeBriefFabric.split(':').last.trim().toLowerCase()
        : creativeBriefFabric.toLowerCase().trim();

    // Look up defaults: try composition input first, then creative brief fabric type
    final defaults = fabricDefaults[compositionKey] ?? fabricDefaults[fabricTypeKey];

    // If composition already has %, treat as complete — only fill missing weight
    if (compositionInput.contains('%')) {
      final resolvedType = defaults?['type'] ?? fabricTypeKey;
      final rawGsm = weightInput.replaceAll(RegExp(r'[^0-9]'), '');
      final resolvedGsm = rawGsm.isNotEmpty ? rawGsm : (defaults?['gsm'] ?? '180');
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
      return rawGsm.isNotEmpty ? '$compositionInput, $rawGsm GSM' : compositionInput;
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
      return rawGsm.isNotEmpty ? '$compositionInput, $rawGsm GSM' : compositionInput;
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

  static String _standardMeasurementRules(String measurementChart) {
    String section = '';
    if (measurementChart.isNotEmpty) {
      section += 'Measurement data: $measurementChart\n';
    }
    section += 'Render as a clean bordered grid table. Columns = each selected size (e.g. S, M, L, XL). Rows = standard measurements: Chest, Waist, Hip, Length, Sleeve. Fill in standard industry values for each size.\n'
        'Grading rules: Chest +3 cm, Length +2 cm, Shoulder +2 cm, Armhole +1 cm per size.\n'
        'Tolerance: ±1 cm for all measurements.\n';
    return section;
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
        .map((c) => '• $c — draw a small solid color swatch block (1.5cm x 1.5cm) filled with this color, with the text "$c" printed next to it')
        .join('\n') + '\n';
  }

  /// Calls gpt-4o vision with the garment image and returns dominant colors as a plain text list.
  /// Returns null if the image cannot be read or the API call fails.
  static Future<String?> extractColorsFromGarmentImage(String imagePathOrUrl) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) return null;

      List<Map<String, dynamic>> imageContent;
      if (imagePathOrUrl.startsWith('http://') || imagePathOrUrl.startsWith('https://')) {
        imageContent = [
          {'type': 'image_url', 'image_url': {'url': imagePathOrUrl}},
        ];
      } else if (imagePathOrUrl.startsWith('iVBOR') ||
          imagePathOrUrl.startsWith('/9j/') ||
          imagePathOrUrl.startsWith('R0lGOD')) {
        // Already base64 data — wrap directly as a data URI
        final mimeType = imagePathOrUrl.startsWith('/9j/') ? 'jpeg' : 'png';
        imageContent = [
          {'type': 'image_url', 'image_url': {'url': 'data:image/$mimeType;base64,$imagePathOrUrl'}},
        ];
      } else {
        final base64Image = await _convertImageToBase64(imagePathOrUrl);
        if (base64Image == null) return null;
        imageContent = [
          {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}},
        ];
      }

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
                  'text': 'Identify the dominant colors of this garment and match each one to its closest Pantone TPX color code. Return ONLY a short comma-separated list of Pantone codes in the exact format "Pantone 19-4052 TPX" (e.g. "Pantone 19-4052 TPX, Pantone 11-0601 TPX, Pantone 14-0952 TPX"). Maximum 5 colors. No color names, no explanations, no extra text.',
                },
                ...imageContent,
              ],
            },
          ],
          'max_tokens': 60,
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final colors = (data['choices'][0]['message']['content'] as String).trim();
        print('🎨 Extracted colors: $colors');
        return colors;
      } else {
        print('❌ Color extraction failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error extracting colors: $e');
      return null;
    }
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
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
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

  /// Returns garment-appropriate approximate measurements for the technical flat drawing.
  /// Values are for a size M garment; front, back, and summary table are pre-formatted strings.
  static Map<String, String> _techFlatMeasurements(String garmentType) {
    final key = garmentType.toLowerCase().trim();

    if (['t-shirt', 'tshirt', 't shirt', 'tank', 'polo', 'crop top'].any((k) => key.contains(k))) {
      return {
        'front': '  • Neck opening width: 20 cm — horizontal arrow across the neckline\n'
            '  • Chest width: 50 cm — horizontal arrow across the widest chest point\n'
            '  • Front length: 68 cm — vertical arrow along the left outer edge, top to hem\n'
            '  • Armhole depth: 22 cm — vertical arrow from shoulder seam to underarm\n'
            '  • Sleeve length: 22 cm — arrow along the outer sleeve edge from shoulder to cuff',
        'back': '  • Shoulder width: 42 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 70 cm — vertical arrow along the right outer edge, top to hem\n'
            '  • Sleeve opening width: 16 cm — horizontal arrow at the sleeve hem\n'
            '  • Waist width: 46 cm — horizontal arrow at waist level\n'
            '  • Hem width: 48 cm — horizontal arrow at the bottom hem',
        'table': '  Neck Opening: 20 cm        Shoulder Width: 42 cm\n'
            '  Chest Width: 50 cm         Back Length: 70 cm\n'
            '  Front Length: 68 cm        Sleeve Opening: 16 cm\n'
            '  Armhole Depth: 22 cm       Waist Width: 46 cm\n'
            '  Sleeve Length: 22 cm       Hem Width: 48 cm',
      };
    }

    if (['sweatshirt', 'hoodie', 'sweater', 'pullover', 'cardigan', 'knitwear'].any((k) => key.contains(k))) {
      return {
        'front': '  • Neck opening width: 22 cm — horizontal arrow across the neckline\n'
            '  • Chest width: 56 cm — horizontal arrow across the widest chest point\n'
            '  • Front length: 70 cm — vertical arrow along the left outer edge, top to hem\n'
            '  • Armhole depth: 25 cm — vertical arrow from shoulder seam to underarm\n'
            '  • Sleeve length: 60 cm — arrow along the outer sleeve edge from shoulder to cuff',
        'back': '  • Shoulder width: 46 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 72 cm — vertical arrow along the right outer edge, top to hem\n'
            '  • Cuff width: 18 cm — horizontal arrow across the cuff opening\n'
            '  • Hem width: 54 cm — horizontal arrow at the bottom hem\n'
            '  • Sleeve opening width: 18 cm — horizontal arrow at the sleeve hem',
        'table': '  Neck Opening: 22 cm        Shoulder Width: 46 cm\n'
            '  Chest Width: 56 cm         Back Length: 72 cm\n'
            '  Front Length: 70 cm        Cuff Width: 18 cm\n'
            '  Armhole Depth: 25 cm       Hem Width: 54 cm\n'
            '  Sleeve Length: 60 cm       Sleeve Opening: 18 cm',
      };
    }

    if (['shirt', 'blouse', 'button'].any((k) => key.contains(k))) {
      return {
        'front': '  • Neck opening width: 38 cm — horizontal arrow at the collar base\n'
            '  • Chest width: 54 cm — horizontal arrow across the widest chest point\n'
            '  • Front length: 78 cm — vertical arrow along the left outer edge, top to hem\n'
            '  • Armhole depth: 24 cm — vertical arrow from shoulder seam to underarm\n'
            '  • Sleeve length: 62 cm — arrow along the outer sleeve edge from shoulder to cuff',
        'back': '  • Shoulder width: 44 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 80 cm — vertical arrow along the right outer edge, top to hem\n'
            '  • Collar height: 4 cm — vertical arrow at the collar stand\n'
            '  • Cuff width: 11 cm — horizontal arrow across the cuff opening\n'
            '  • Sleeve opening width: 23 cm — horizontal arrow at the sleeve hem',
        'table': '  Neck Opening: 38 cm        Shoulder Width: 44 cm\n'
            '  Chest Width: 54 cm         Back Length: 80 cm\n'
            '  Front Length: 78 cm        Collar Height: 4 cm\n'
            '  Armhole Depth: 24 cm       Cuff Width: 11 cm\n'
            '  Sleeve Length: 62 cm       Sleeve Opening: 23 cm',
      };
    }

    if (['jacket', 'coat', 'blazer', 'overcoat', 'trench', 'parka', 'outerwear'].any((k) => key.contains(k))) {
      return {
        'front': '  • Neck opening width: 20 cm — horizontal arrow across the neckline\n'
            '  • Chest width: 58 cm — horizontal arrow across the widest chest point\n'
            '  • Front length: 82 cm — vertical arrow along the left outer edge, top to hem\n'
            '  • Armhole depth: 26 cm — vertical arrow from shoulder seam to underarm\n'
            '  • Sleeve length: 64 cm — arrow along the outer sleeve edge from shoulder to cuff',
        'back': '  • Shoulder width: 46 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 84 cm — vertical arrow along the right outer edge, top to hem\n'
            '  • Collar height: 6 cm — vertical arrow at the collar stand\n'
            '  • Cuff width: 13 cm — horizontal arrow across the cuff opening\n'
            '  • Sleeve opening width: 26 cm — horizontal arrow at the sleeve hem',
        'table': '  Neck Opening: 20 cm        Shoulder Width: 46 cm\n'
            '  Chest Width: 58 cm         Back Length: 84 cm\n'
            '  Front Length: 82 cm        Collar Height: 6 cm\n'
            '  Armhole Depth: 26 cm       Cuff Width: 13 cm\n'
            '  Sleeve Length: 64 cm       Sleeve Opening: 26 cm',
      };
    }

    if (['dress', 'gown', 'frock'].any((k) => key.contains(k))) {
      return {
        'front': '  • Bust width: 46 cm — horizontal arrow across the widest bust point\n'
            '  • Waist width: 36 cm — horizontal arrow at the narrowest waist point\n'
            '  • Hip width: 52 cm — horizontal arrow at the widest hip point\n'
            '  • Front length: 105 cm — vertical arrow from shoulder to hem\n'
            '  • Armhole depth: 20 cm — vertical arrow from shoulder seam to underarm',
        'back': '  • Shoulder width: 38 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 107 cm — vertical arrow along the right outer edge, top to hem\n'
            '  • Neck opening width: 16 cm — horizontal arrow across the back neckline\n'
            '  • Waist to hem: 70 cm — vertical arrow from waist to hem\n'
            '  • Hem width: 60 cm — horizontal arrow at the bottom hem',
        'table': '  Bust Width: 46 cm          Shoulder Width: 38 cm\n'
            '  Waist Width: 36 cm         Back Length: 107 cm\n'
            '  Hip Width: 52 cm           Neck Opening: 16 cm\n'
            '  Front Length: 105 cm       Waist to Hem: 70 cm\n'
            '  Armhole Depth: 20 cm       Hem Width: 60 cm',
      };
    }

    if (['skirt'].any((k) => key.contains(k))) {
      return {
        'front': '  • Waist width: 34 cm — horizontal arrow at the waistband top\n'
            '  • Hip width: 50 cm — horizontal arrow at the widest hip point\n'
            '  • Front length: 60 cm — vertical arrow from waistband to hem\n'
            '  • Hem width: 58 cm — horizontal arrow at the bottom hem\n'
            '  • Waistband height: 4 cm — vertical arrow at the waistband',
        'back': '  • Back waist width: 34 cm — horizontal arrow at the back waistband\n'
            '  • Back hip width: 50 cm — horizontal arrow at the widest back hip point\n'
            '  • Back length: 62 cm — vertical arrow from waistband to hem\n'
            '  • Back hem width: 58 cm — horizontal arrow at the back hem\n'
            '  • Side seam length: 58 cm — vertical arrow along the side seam',
        'table': '  Waist Width: 34 cm         Back Waist: 34 cm\n'
            '  Hip Width: 50 cm           Back Hip: 50 cm\n'
            '  Front Length: 60 cm        Back Length: 62 cm\n'
            '  Hem Width: 58 cm           Back Hem: 58 cm\n'
            '  Waistband Height: 4 cm     Side Seam: 58 cm',
      };
    }

    if (['trouser', 'pant', 'jean', 'chino', 'jogger', 'cargo'].any((k) => key.contains(k))) {
      return {
        'front': '  • Waist width: 36 cm — horizontal arrow at the waistband\n'
            '  • Hip width: 52 cm — horizontal arrow at the widest hip point\n'
            '  • Thigh width: 30 cm — horizontal arrow at the widest thigh\n'
            '  • Outseam length: 102 cm — vertical arrow from waistband to hem\n'
            '  • Inseam length: 80 cm — vertical arrow from crotch to hem',
        'back': '  • Back rise: 32 cm — vertical arrow from waistband to crotch\n'
            '  • Seat width: 54 cm — horizontal arrow at the seat level\n'
            '  • Knee width: 22 cm — horizontal arrow at the knee level\n'
            '  • Leg opening: 18 cm — horizontal arrow at the hem\n'
            '  • Waistband height: 4 cm — vertical arrow at the waistband',
        'table': '  Waist Width: 36 cm         Back Rise: 32 cm\n'
            '  Hip Width: 52 cm           Seat Width: 54 cm\n'
            '  Thigh Width: 30 cm         Knee Width: 22 cm\n'
            '  Outseam: 102 cm            Leg Opening: 18 cm\n'
            '  Inseam: 80 cm              Waistband Height: 4 cm',
      };
    }

    if (['short'].any((k) => key.contains(k))) {
      return {
        'front': '  • Waist width: 36 cm — horizontal arrow at the waistband\n'
            '  • Hip width: 52 cm — horizontal arrow at the widest hip point\n'
            '  • Thigh width: 30 cm — horizontal arrow at the widest thigh\n'
            '  • Outseam length: 42 cm — vertical arrow from waistband to hem\n'
            '  • Inseam length: 18 cm — vertical arrow from crotch to hem',
        'back': '  • Back rise: 28 cm — vertical arrow from waistband to crotch\n'
            '  • Seat width: 54 cm — horizontal arrow at the seat level\n'
            '  • Hem width: 26 cm — horizontal arrow at the bottom hem\n'
            '  • Side seam: 40 cm — vertical arrow along the side seam\n'
            '  • Waistband height: 4 cm — vertical arrow at the waistband',
        'table': '  Waist Width: 36 cm         Back Rise: 28 cm\n'
            '  Hip Width: 52 cm           Seat Width: 54 cm\n'
            '  Thigh Width: 30 cm         Hem Width: 26 cm\n'
            '  Outseam: 42 cm             Side Seam: 40 cm\n'
            '  Inseam: 18 cm              Waistband Height: 4 cm',
      };
    }

    if (['legging', 'tight', 'activewear', 'yoga'].any((k) => key.contains(k))) {
      return {
        'front': '  • Waist width: 28 cm — horizontal arrow at the waistband\n'
            '  • Hip width: 46 cm — horizontal arrow at the widest hip point\n'
            '  • Thigh width: 26 cm — horizontal arrow at the widest thigh\n'
            '  • Outseam length: 94 cm — vertical arrow from waistband to hem\n'
            '  • Inseam length: 72 cm — vertical arrow from crotch to hem',
        'back': '  • Back rise: 28 cm — vertical arrow from waistband to crotch\n'
            '  • Seat width: 48 cm — horizontal arrow at the seat level\n'
            '  • Knee width: 20 cm — horizontal arrow at the knee level\n'
            '  • Ankle width: 12 cm — horizontal arrow at the ankle/hem\n'
            '  • Calf width: 16 cm — horizontal arrow at the calf level',
        'table': '  Waist Width: 28 cm         Back Rise: 28 cm\n'
            '  Hip Width: 46 cm           Seat Width: 48 cm\n'
            '  Thigh Width: 26 cm         Knee Width: 20 cm\n'
            '  Outseam: 94 cm             Ankle Width: 12 cm\n'
            '  Inseam: 72 cm              Calf Width: 16 cm',
      };
    }

    if (['jumpsuit', 'romper', 'playsuit', 'overall'].any((k) => key.contains(k))) {
      return {
        'front': '  • Chest width: 50 cm — horizontal arrow across the widest chest point\n'
            '  • Waist width: 36 cm — horizontal arrow at the narrowest waist point\n'
            '  • Hip width: 52 cm — horizontal arrow at the widest hip point\n'
            '  • Total length: 130 cm — vertical arrow from shoulder to hem\n'
            '  • Inseam length: 78 cm — vertical arrow from crotch to hem',
        'back': '  • Shoulder width: 40 cm — horizontal arrow across the full shoulder seam\n'
            '  • Back length: 132 cm — vertical arrow from shoulder to hem\n'
            '  • Sleeve length: 60 cm — arrow along the outer sleeve edge\n'
            '  • Leg opening: 18 cm — horizontal arrow at the leg hem\n'
            '  • Armhole depth: 22 cm — vertical arrow from shoulder seam to underarm',
        'table': '  Chest Width: 50 cm         Shoulder Width: 40 cm\n'
            '  Waist Width: 36 cm         Back Length: 132 cm\n'
            '  Hip Width: 52 cm           Sleeve Length: 60 cm\n'
            '  Total Length: 130 cm       Leg Opening: 18 cm\n'
            '  Inseam: 78 cm              Armhole Depth: 22 cm',
      };
    }

    // Default fallback
    return {
      'front': '  • Neck opening width: 18 cm — horizontal arrow across the neckline opening at top\n'
          '  • Chest width: 48 cm — horizontal arrow across the widest chest point\n'
          '  • Front length: 65 cm — vertical arrow along the left outer edge, top to hem\n'
          '  • Armhole depth: 22 cm — vertical arrow on the side from shoulder seam to underarm\n'
          '  • Sleeve length: 60 cm — arrow along the outer sleeve edge from shoulder to cuff',
      'back': '  • Shoulder width: 38 cm — horizontal arrow across the full shoulder seam\n'
          '  • Back length: 67 cm — vertical arrow along the right outer edge, top to hem\n'
          '  • Collar height: 4 cm — vertical arrow at the collar stand\n'
          '  • Cuff width: 11 cm — horizontal arrow across the cuff opening\n'
          '  • Sleeve opening width: 12 cm — horizontal arrow at the sleeve hem/opening',
      'table': '  Neck Opening: 18 cm        Shoulder Width: 38 cm\n'
          '  Chest Width: 48 cm         Back Length: 67 cm\n'
          '  Front Length: 65 cm        Collar Height: 4 cm\n'
          '  Armhole Depth: 22 cm       Cuff Width: 11 cm\n'
          '  Sleeve Length: 60 cm       Sleeve Opening: 12 cm',
    };
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
    final rawGarmentType = (creativeBrief['garmentType'] ?? 'jacket').toString();
    // Strip category prefix: "Dresses:Cocktail dress" → "Cocktail dress"
    final garmentType = rawGarmentType.contains(':')
        ? rawGarmentType.split(':').last.trim()
        : rawGarmentType;
    final fabricComposition = _resolveField(techPackDetails['materials']?['fabricComposition'] ?? '', 'Standard fabric');
    final fabricWeight = _resolveField(techPackDetails['materials']?['fabricWeight'] ?? '', '180 GSM');
    final creativeBriefFabric = (creativeBrief['fabrics'] ?? '').toString();
    final bool isIndustryComposition = techPackDetails['materials']?['isIndustryStandardComposition'] == true;
    final bool isIndustryGSM = techPackDetails['materials']?['isIndustryStandardGSM'] == true;

    final String resolvedFabric = _buildFabricLine(
      fabricComposition, fabricWeight, creativeBriefFabric,
      isIndustryComposition: isIndustryComposition,
      isIndustryGSM: isIndustryGSM,
    );
    final secondaryMaterial = _resolveField(techPackDetails['materials']?['secondaryMaterials'] ?? '', 'No secondary material');
    final fabricProperties = _resolveField(techPackDetails['materials']?['fabricProperties'] ?? '', 'Standard');
    final sizeRange = techPackDetails['sizes']?['sizeRange'] ?? '';
    final measurementChart = techPackDetails['sizes']?['measurementChart'] ?? '';
    final stitching = _resolveField(techPackDetails['technical']?['stitching'] ?? '', 'Overlock stitch (4 threads)');
    final decorativeStitching = _resolveField(techPackDetails['technical']?['decorativeStitching'] ?? '', 'Single row, 1 mm spacing');
    final accessories = _resolveField(techPackDetails['technical']?['accessories'] ?? '', 'Bartack at stress points');
    final logoPlacement = _resolveField(techPackDetails['labeling']?['logoPlacement'] ?? '', 'Neck');
    final labelsNeeded = _resolveField(techPackDetails['labeling']?['labelsNeeded'] ?? '', 'No Label');
    final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';
    // Garment overview fields
    final fit = (refinedConcept['silhouette'] ?? '').toString();
    final gender = (creativeBrief['targetAudience'] ?? '').toString();
    final season = (refinedConcept['season'] ?? '').toString();
    print('🎨 DEBUG: Building manufacturing prompt...');
    print('   📷 labelImage.isNotEmpty: ${labelImage.isNotEmpty}');
    print('   📝 labelsNeeded.isNotEmpty: ${labelsNeeded.isNotEmpty}');

    // MEASUREMENT TABLE — grid table
    String measurementTableSection = '';
    if (sizeRange.isNotEmpty) {
      measurementTableSection += 'Selected sizes: $sizeRange\n';
    }

    if (measurementChartImagePath != null && measurementChartImagePath.isNotEmpty) {
      final extractedSizes = await extractSizesFromChartImage(measurementChartImagePath);
      if (extractedSizes != null && extractedSizes.isNotEmpty) {
        measurementTableSection +=
            'IMPORTANT: Use ONLY the following measurements extracted from the user\'s size chart. '
            'Do NOT apply standard industry grading rules or default values. '
            'Preserve the exact units as provided (cm, inches, mm — do NOT convert):\n$extractedSizes\n'
            'Render as a clean bordered grid table. Columns = each size. Rows = each measurement name from the chart.\n'
            'Tolerance: ±1 unit for all measurements.\n';
      } else {
        measurementTableSection += _standardMeasurementRules(measurementChart);
      }
    } else {
      measurementTableSection += _standardMeasurementRules(measurementChart);
    }

    // CONSTRUCTION DETAILS — always 4 mandatory items
    final String constructionSection =
        '-- Stitch type: $stitching\n'
        '-- Topstitch: $decorativeStitching\n'
        '-- Reinforcements: $accessories\n'
        '-- Seam allowance: 1 cm (all seams)\n';

    // FABRIC — dedicated section
    String fabricSection = '';
    if (resolvedFabric.isNotEmpty) fabricSection += '-- Fabric: $resolvedFabric\n';
    if (secondaryMaterial.isNotEmpty) fabricSection += '-- Secondary material: $secondaryMaterial\n';
    if (fabricProperties.isNotEmpty) fabricSection += '-- Fabric properties: $fabricProperties\n';

    // LOGO AND LABELS — combined section
    String logoAndLabelsSection = '• Logo placement: $logoPlacement\n• Labels: $labelsNeeded\n';

    // Garment overview — clean lines
    String garmentOverviewSection = '• Garment Type: $garmentType\n';
    if (fit.isNotEmpty) garmentOverviewSection += '• Fit: $fit\n';
    if (gender.isNotEmpty) garmentOverviewSection += '• Gender: $gender\n';
    if (season.isNotEmpty) garmentOverviewSection += '• Season: $season\n';

    // COLORS — dedicated section with drawn swatch blocks
    final bool hasColors = colorPalette != null && colorPalette.isNotEmpty;
    final String colorsSection = _buildColorSwatchSection(hasColors ? colorPalette : null);

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
    final String technicalLogoInstruction =
        '\n- Logo placeholder: Draw a dashed-border rectangle (5 cm W × 3 cm H) with the text "LOGO" centered inside it. Place this box exactly at the user-requested location: "$logoPlacement". If that location is on the back, draw it on the BACK VIEW (right half). If it is on a sleeve/bicep/arm, draw it on that sleeve of the matching view. If it is on the front/chest/neck, draw it on the FRONT VIEW (left half). Do not default to the chest. Do not place it 3 cm below the neckline unless the user asked for the neck. Add width (5 cm) and height (3 cm) dimension arrows outside the box. Do NOT draw any actual logo image or artwork inside the box.';

    final measurements = _techFlatMeasurements(garmentType);

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

  // ALTERNATIVE: Single detailed view if three views still cause cutting
  static Map<String, String> getDetailedSingleViewPrompts(
    Map<String, dynamic> techPackDetails,
    Map<String, dynamic> creativeBrief,
  ) {
    final garmentType = creativeBrief['garmentType'] ?? 'jacket';
    final accessories =
        techPackDetails['technical']?['accessories'] ?? 'zipper';
    final stitching =
        techPackDetails['technical']?['stitching'] ?? 'single stitch';
    final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
    final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
    final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';

    // Create label text for LABELS section
    String labelTextForSection = '';
    String technicalLogoInstruction = '';

    if (labelImage.isNotEmpty) {
      // User uploaded logo image - show actual logo
      technicalLogoInstruction =
          'Show logo from reference image on $logoPlacement with callout. ';
      if (labelsNeeded.isNotEmpty) {
        labelTextForSection = labelsNeeded;
      }
    } else if (labelsNeeded.isNotEmpty) {
      // User provided label text only - keep garment clean, show highlighted area on technical
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text, add callout annotation "Label: $labelsNeeded". ';
      labelTextForSection = labelsNeeded;
    } else if (logoPlacement.isNotEmpty) {
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
    }

    String labelsSection = '';
    if (labelTextForSection.isNotEmpty) {
      // Only show label text, not placement
      labelsSection = labelTextForSection;
    } else if (logoPlacement.isNotEmpty) {
      labelsSection = '$logoPlacement placement';
    }

    return {
      'manufacturing_prompt':
          'Professional fashion tech pack specification sheet for $garmentType. Organized sections: materials, colors with swatches, sizes chart, technical details, LABELS ($labelsSection), production info. Clean grid layout, white background.',

      'technical_flat_prompt':
          'Detailed technical flat drawing of $garmentType, large front view centered on white background. Black line art with comprehensive annotations: measurement arrows (A, B, C, D), seam allowances labeled, $accessories details, $stitching callouts, construction notes, dimension lines. ${technicalLogoInstruction}Professional fashion industry flat with detailed labeling. Complete drawing visible with wide margins.',
    };
  }

  // ADVANCED: Detailed layout with explicit positioning
  static Map<String, String> getAdvancedDetailedPrompts(
    Map<String, dynamic> techPackDetails,
    Map<String, dynamic> creativeBrief,
  ) {
    final garmentType = creativeBrief['garmentType'] ?? 'jacket';
    final accessories =
        techPackDetails['technical']?['accessories'] ?? 'zipper';
    final stitching =
        techPackDetails['technical']?['stitching'] ?? 'single stitch';
    final decorativeStitching =
        techPackDetails['technical']?['decorativeStitching'] ??
        'contrast topstitch';
    final features = creativeBrief['features'] ?? 'collar';
    final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
    final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
    final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';

    // Create label text for LABELS section
    String labelTextForSection = '';
    String technicalLogoInstruction = '';

    if (labelImage.isNotEmpty) {
      technicalLogoInstruction =
          'Show logo from reference image on $logoPlacement with callout. ';
      if (labelsNeeded.isNotEmpty) {
        labelTextForSection = labelsNeeded;
      }
    } else if (labelsNeeded.isNotEmpty) {
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text, add callout annotation "Label: $labelsNeeded". ';
      labelTextForSection = labelsNeeded;
    } else if (logoPlacement.isNotEmpty) {
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
    }

    String labelsSection = '';
    if (labelTextForSection.isNotEmpty) {
      labelsSection = labelTextForSection;
    } else if (logoPlacement.isNotEmpty) {
      labelsSection = '$logoPlacement placement';
    }

    return {
      'manufacturing_prompt':
          'Complete fashion tech pack layout for $garmentType. Grid format with sections: MATERIALS (fabric swatches), COLORS (color blocks with codes), SIZES (measurement table), TECHNICAL ($accessories, $stitching), LABELS ($labelsSection), PACKAGING, PRODUCTION. Professional format, white background, all content within frame.',

      'technical_flat_prompt':
          'Technical flat drawing sheet for $garmentType. Layout: Front view (upper left), back view (upper right), detail callouts (bottom). Black lines on white. Show: $features, $accessories, $stitching, $decorativeStitching. ${technicalLogoInstruction}Include: measurement points A-F with arrows, seam allowances, construction details, topstitching circles. Professional annotations. Complete sheet layout with 10% margin border.',
    };
  }

  // FALLBACK: Simplified but still detailed
  static Map<String, String> getSimplifiedDetailedPrompts(
    Map<String, dynamic> techPackDetails,
    Map<String, dynamic> creativeBrief,
  ) {
    final garmentType = creativeBrief['garmentType'] ?? 'jacket';
    final accessories =
        techPackDetails['technical']?['accessories'] ?? 'zipper';
    final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
    final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
    final labelImage = techPackDetails['labeling']?['labelImage'] ?? '';

    // Create label text for LABELS section
    String labelTextForSection = '';
    String technicalLogoInstruction = '';

    if (labelImage.isNotEmpty) {
      technicalLogoInstruction =
          'Show logo from reference on $logoPlacement with callout. ';
      if (labelsNeeded.isNotEmpty) {
        labelTextForSection = labelsNeeded;
      }
    } else if (labelsNeeded.isNotEmpty) {
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text, add annotation "Label: $labelsNeeded". ';
      labelTextForSection = labelsNeeded;
    } else if (logoPlacement.isNotEmpty) {
      technicalLogoInstruction =
          'Mark $logoPlacement area with highlighted box containing "LOGO" text. ';
    }

    String labelsSection = '';
    if (labelTextForSection.isNotEmpty) {
      labelsSection = labelTextForSection;
    } else if (logoPlacement.isNotEmpty) {
      labelsSection = '$logoPlacement placement';
    }

    return {
      'manufacturing_prompt':
          'Fashion tech pack for $garmentType: materials, colors, sizes, LABELS ($labelsSection), production details. Professional layout, white background, organized sections.',

      'technical_flat_prompt':
          'Technical drawing $garmentType with detailed labels. Front view, black lines, measurement arrows, $accessories details, construction notes. ${technicalLogoInstruction}Complete drawing with margins.',
    };
  }
}
