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
        request.fields['model'] = 'gpt-image-1.5';
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
            'model': 'gpt-image-1.5',
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

      // Ensure white background requirement is in the prompt
      String enhancedPrompt = prompt;
      if (!enhancedPrompt.toLowerCase().contains('white background')) {
        enhancedPrompt +=
            '. Professional product photography on clean white background, no mannequin, no people, ghost mannequin effect.';
        print('OpenAI: Added white background requirement to prompt');
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
        request.fields['model'] = 'gpt-image-1.5';
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
            'model': 'gpt-image-1.5',
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
"Isolated garment only, NO human, NO model, NO mannequin, NO body, NO torso, NO person wearing the clothing. Product-only shot, floating garment on pure white background, ghost mannequin invisible effect, professional e-commerce product photography."

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
10. START the prompt with: "Product-only fashion photography of a [garment type], no human, no model, no mannequin, no body visible, no logos, no text or writing, no patterns, prints, textures, or decorative graphics on the garment unless explicitly requested. The garment should be look realistic and according the the type of realistic world garment style, lenght and properties."
11. END the prompt with: "Isolated floating garment, pure white background, invisible ghost mannequin effect, e-commerce product shot, absolutely no people or body parts."

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

  static const Map<String, Map<String, String>> _fabricDefaults = {
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

  static String _resolveFabricLine(String compositionInput, String weightInput, String creativeBriefFabric) {
    final compositionKey = compositionInput.toLowerCase().trim();
    // Strip any "Category:" prefix from creative brief fabric (e.g. "Knitwear:Jersey" → "jersey")
    final fabricTypeKey = creativeBriefFabric.contains(':')
        ? creativeBriefFabric.split(':').last.trim().toLowerCase()
        : creativeBriefFabric.toLowerCase().trim();

    // Look up defaults: try composition input first, then creative brief fabric type
    final defaults = _fabricDefaults[compositionKey] ?? _fabricDefaults[fabricTypeKey];

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

  static Future<Map<String, String>> generateTechPackPrompts({
    required Map<String, dynamic> creativeBrief,
    required Map<String, dynamic> refinedConcept,
    required Map<String, dynamic> finalDetails,
    required Map<String, dynamic> techPackDetails,
    required String selectedDesignPrompt,
  }) async {
    // Extract key information directly - no GPT-4 API call needed
    final rawGarmentType = (creativeBrief['garmentType'] ?? 'jacket').toString();
    // Strip category prefix: "Dresses:Cocktail dress" → "Cocktail dress"
    final garmentType = rawGarmentType.contains(':')
        ? rawGarmentType.split(':').last.trim()
        : rawGarmentType;
    final fabricComposition = techPackDetails['materials']?['fabricComposition'] ?? '';
    final fabricWeight = techPackDetails['materials']?['fabricWeight'] ?? '';
    final creativeBriefFabric = (creativeBrief['fabrics'] ?? '').toString();
    final resolvedFabric = _resolveFabricLine(fabricComposition, fabricWeight, creativeBriefFabric);
    final secondaryMaterial = techPackDetails['materials']?['secondaryMaterials'] ?? '';
    final fabricProperties = techPackDetails['materials']?['fabricProperties'] ?? '';
    final sizeRange = techPackDetails['sizes']?['sizeRange'] ?? '';
    final measurementChart = techPackDetails['sizes']?['measurementChart'] ?? '';
    final accessories = techPackDetails['technical']?['accessories'] ?? '';
    final stitching = techPackDetails['technical']?['stitching'] ?? '';
    final decorativeStitching = techPackDetails['technical']?['decorativeStitching'] ?? '';
    final logoPlacement = techPackDetails['labeling']?['logoPlacement'] ?? '';
    final labelsNeeded = techPackDetails['labeling']?['labelsNeeded'] ?? '';
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
    if (measurementChart.isNotEmpty) {
      measurementTableSection += 'Measurement data: $measurementChart\n';
    }
    measurementTableSection += 'Render as a clean bordered grid table. Columns = each selected size (e.g. S, M, L, XL). Rows = standard measurements: Chest, Waist, Hip, Length, Sleeve. Fill in standard industry values for each size.\n';

    // CONSTRUCTION DETAILS — stitching and accessories only, no fabric fields
    String constructionSection = '';
    if (stitching.isNotEmpty) constructionSection += '-- Main seams: $stitching\n';
    if (decorativeStitching.isNotEmpty) constructionSection += '-- Decorative stitching: $decorativeStitching\n';
    if (accessories.isNotEmpty) constructionSection += '-- Accessories: $accessories\n';
    constructionSection += '-- Seam allowance: 1 cm (all seams)\n';

    // FABRIC — dedicated section
    String fabricSection = '';
    if (resolvedFabric.isNotEmpty) fabricSection += '-- Fabric: $resolvedFabric\n';
    if (secondaryMaterial.isNotEmpty) fabricSection += '-- Secondary material: $secondaryMaterial\n';
    if (fabricProperties.isNotEmpty) fabricSection += '-- Fabric properties: $fabricProperties\n';

    // LOGO PLACEMENT — standalone section
    String logoPlacementSection = '• Logo placement: $logoPlacement\n';

    // LABELS — standalone section
    String labelsSection = '• Labels: $labelsNeeded\n';

    // Garment overview — 4 clean lines only
    String garmentOverviewSection = '• Garment Type: $garmentType\n';
    if (fit.isNotEmpty) garmentOverviewSection += '• Fit: $fit\n';
    if (gender.isNotEmpty) garmentOverviewSection += '• Gender: $gender\n';
    if (season.isNotEmpty) garmentOverviewSection += '• Season: $season\n';

    final String garmentTitle = garmentType.toUpperCase();

    final String manufacturingPrompt =
        '''Generate a professional fashion tech pack specification sheet as a clean document image on a white background. Use clear section headers, professional typography, and organized layout.

CRITICAL GLOBAL RULE: Render each section header and its content EXACTLY ONCE. Do NOT repeat any section or heading anywhere in the image under any circumstance. There must be exactly 6 sections — no more, no fewer.

═══════════════════════════════════════════════
TECH PACK — $garmentTitle
═══════════════════════════════════════════════

GARMENT IMAGE (render at the top of the document, before all sections):
- Show the garment exactly as it appears in the reference design image provided
- The garment image must be clearly visible, proportional, and not cropped

SECTIONS (render each exactly once, in this exact order, no additional sections allowed):

──────────────────────────────────────
1. GARMENT OVERVIEW
──────────────────────────────────────
$garmentOverviewSection
──────────────────────────────────────
2. MEASUREMENT TABLE
──────────────────────────────────────
$measurementTableSection
──────────────────────────────────────
3. CONSTRUCTION DETAILS
──────────────────────────────────────
$constructionSection
──────────────────────────────────────
4. FABRIC
──────────────────────────────────────
$fabricSection
──────────────────────────────────────
5. LOGO PLACEMENT
──────────────────────────────────────
$logoPlacementSection
──────────────────────────────────────
6. LABELS
──────────────────────────────────────
$labelsSection

Style requirements:
- White background, clean margins, professional fashion industry layout
- Section headers in bold with divider lines
- Bullet points for list items; bordered grid table for MEASUREMENT TABLE section
- All text clearly readable, professional sans-serif typography
- Complete layout fully visible within image boundaries
- CRITICAL: All text must be spelled correctly with zero spelling mistakes
- CRITICAL: Do NOT add any sections beyond the 6 listed above
''';

    // Build technical flat prompt with correct logo behavior
    String technicalLogoInstruction = '';
    if (labelImage.isNotEmpty) {
      // User uploaded logo image - show actual logo on technical drawing
      technicalLogoInstruction =
          '\n- Show the logo/label from reference image clearly marked on the $logoPlacement area with a dashed outline box.'
          '\n- Add two dimension arrows on the logo box: width arrow (e.g. 5 cm) horizontally across the top, height arrow (e.g. 3 cm) vertically on the side.';
    } else if (labelsNeeded.isNotEmpty || logoPlacement.isNotEmpty) {
      // User provided label text or just placement - show highlighted area with "LOGO" text
      technicalLogoInstruction =
          '\n- Mark the $logoPlacement area with a dashed outline box containing the word "LOGO" in capital letters.';
      if (labelsNeeded.isNotEmpty) {
        technicalLogoInstruction +=
            '\n- Add a small callout label near the box showing: "$labelsNeeded"';
      }
      technicalLogoInstruction +=
          '\n- Add two dimension arrows on the logo box: width arrow (e.g. 5 cm) horizontally across the top, height arrow (e.g. 3 cm) vertically on the side.';
    }

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
  • Neck opening width: 18 cm — horizontal arrow across the neckline opening at top
  • Chest width: 48 cm — horizontal arrow across the widest chest point
  • Front length: 65 cm — vertical arrow along the left outer edge, top to hem
  • Armhole depth: 22 cm — vertical arrow on the side from shoulder seam to underarm
  • Sleeve length: 60 cm — arrow along the outer sleeve edge from shoulder to cuff

MEASUREMENTS — BACK VIEW (annotate on the right half):
Draw double-headed dimension arrows OUTSIDE the garment outline, each with a clear numeric cm value:
  • Shoulder width: 38 cm — horizontal arrow across the full shoulder seam
  • Back length: 67 cm — vertical arrow along the right outer edge, top to hem
  • Collar height: 4 cm — vertical arrow at the collar stand
  • Cuff width: 11 cm — horizontal arrow across the cuff opening
  • Sleeve opening width: 12 cm — horizontal arrow at the sleeve hem/opening$technicalLogoInstruction

MEASUREMENT SUMMARY TABLE — below the drawing:
After both garment views, add a clean text summary at the bottom of the image listing all measurements in two columns:
  Neck Opening: 18 cm        Shoulder Width: 38 cm
  Chest Width: 48 cm         Back Length: 67 cm
  Front Length: 65 cm        Collar Height: 4 cm
  Armhole Depth: 22 cm       Cuff Width: 11 cm
  Sleeve Length: 60 cm       Sleeve Opening: 12 cm

RULES:
- Every single measurement arrow MUST display its numeric cm value — no blank or missing values
- Arrows must sit outside the garment, never overlapping the garment outline
- Use small, clear, sans-serif font for all measurement text
- Do not add any extra labels, callouts, or garment feature annotations beyond measurements
- The measurement summary table at the bottom must include all 10 measurements

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
