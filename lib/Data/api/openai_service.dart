import 'dart:convert';
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
  
  static Future<List<String>> generateDesignImages({
    required String prompt,
    int numberOfImages = 3,
    String size = '1024x1024',
  }) async {
    try {
      print('OpenAI: Starting image generation...');
      print('OpenAI: Prompt for images: $prompt');
      print('OpenAI: Number of images requested: $numberOfImages');
      
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        print('OpenAI: ERROR - API key not found!');
        throw Exception('OpenAI API key not found');
      }
      
      // Truncate prompt to 1000 characters if necessary
      String safePrompt = prompt.length > 1000 ? prompt.substring(0, 1000) : prompt;
      if (prompt.length > 1000) {
        print('OpenAI: Prompt was too long (${prompt.length}), truncated to 1000 characters.');
      }

      print('OpenAI: API key found, making request to gpt-image-1...');

      final response = await http.post(
        Uri.parse('$_baseUrl/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-image-1',
          'prompt': safePrompt,
          'n': numberOfImages, // Generate multiple images from one prompt
          'size': size,
        }),
      );

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
  
  static Future<Map<String, String>> generateTechPackPrompts({
    required Map<String, dynamic> creativeBrief,
    required Map<String, dynamic> refinedConcept,
    required Map<String, dynamic> finalDetails,
    required Map<String, dynamic> techPackDetails,
    required String selectedDesignPrompt,
  }) async {
    try {
      final apiKey = await getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('OpenAI API key not found');
      }

      final systemPrompt = '''
You are a fashion tech pack expert. Based on user inputs from their questionnaire answers, selected design, and tech pack details, create two separate detailed prompts for generating tech pack images:

1. MANUFACTURING LAYOUT PROMPT - for a comprehensive tech pack layout with all specifications
2. TECHNICAL FLAT DRAWING PROMPT - for detailed technical flat drawings with annotations

Both prompts should be highly specific, professional, and suitable for DALL-E 3 image generation.
The images should be based on the selected design and incorporate all user-provided information.
''';

      final userMessage = '''
Please create two detailed prompts for tech pack image generation based on these inputs:

SELECTED DESIGN PROMPT: $selectedDesignPrompt

QUESTIONNAIRE DATA:
Creative Brief: ${jsonEncode(creativeBrief)}
Refined Concept: ${jsonEncode(refinedConcept)}
Final Details: ${jsonEncode(finalDetails)}

TECH PACK SPECIFICATIONS:
${jsonEncode(techPackDetails)}

Generate two separate prompts:
1. "manufacturing_prompt" - for a professional manufacturing tech pack layout image with all sections, color swatches, specifications, and organized information blocks
2. "technical_flat_prompt" - for technical flat drawings with detailed annotations, measurements, and construction details

Format your response as JSON with these two keys. Make sure both prompts reference the selected design and incorporate all the user's specifications for accurate, pixel-clear results.
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
          'max_tokens': 1500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        // Try to parse as JSON, fallback to manual extraction if needed
        try {
          final promptsJson = jsonDecode(content);
          return {
            'manufacturing_prompt': promptsJson['manufacturing_prompt'] ?? '',
            'technical_flat_prompt': promptsJson['technical_flat_prompt'] ?? '',
          };
        } catch (e) {
          // Fallback parsing if JSON parsing fails
          return _extractPromptsFromText(content);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('OpenAI API Error: ${errorData['error']['message']}');
      }
    } catch (e) {
      throw Exception('Failed to generate tech pack prompts: $e');
    }
  }
  
  static Map<String, String> _extractPromptsFromText(String text) {
    // Fallback method to extract prompts if JSON parsing fails
    final lines = text.split('\n');
    String manufacturingPrompt = '';
    String technicalFlatPrompt = '';
    
    bool inManufacturing = false;
    bool inTechnical = false;
    
    for (String line in lines) {
      if (line.toLowerCase().contains('manufacturing_prompt') || 
          line.toLowerCase().contains('manufacturing layout')) {
        inManufacturing = true;
        inTechnical = false;
        continue;
      } else if (line.toLowerCase().contains('technical_flat_prompt') || 
                 line.toLowerCase().contains('technical flat')) {
        inManufacturing = false;
        inTechnical = true;
        continue;
      }
      
      if (inManufacturing && line.trim().isNotEmpty) {
        manufacturingPrompt += line.trim() + ' ';
      } else if (inTechnical && line.trim().isNotEmpty) {
        technicalFlatPrompt += line.trim() + ' ';
      }
    }
    
    return {
      'manufacturing_prompt': manufacturingPrompt.trim(),
      'technical_flat_prompt': technicalFlatPrompt.trim(),
    };
  }
}