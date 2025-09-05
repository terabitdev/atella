import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class EmailJSDebugService {
  static const String _serviceId = 'service_uwuy153';
  static const String _templateId = 'template_7zj5iof';
  static const String _publicKey = 'xQoXK58-R-NzOi3NG';
  static const String _openaiApiKey = 'YOUR_OPENAI_API_KEY';

  // Helper method to build PDF sections
  static pw.Widget _buildPDFSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 5),
        ...items.map(
          (item) => pw.Padding(
            padding: pw.EdgeInsets.only(left: 10, bottom: 3),
            child: pw.Text('• $item', style: pw.TextStyle(fontSize: 12)),
          ),
        ),
        pw.SizedBox(height: 10),
      ],
    );
  }

  // Clean template variables (simple cleanup without HTML escaping)
  static String cleanTemplateVariable(String input) {
    return input
        .replaceAll('\r\n', '\n') // Normalize line endings
        .replaceAll('\r', '\n')
        .replaceAll('\n\n\n', '\n\n') // Remove excessive line breaks
        .replaceAll(
          RegExp(r'\n{4,}'),
          '\n\n\n',
        ) // Limit to max 3 consecutive newlines
        .trim();
  }

  // Generate AI-powered email content
  static Future<String> generateEmailContent({
    required String manufacturerName,
    required String manufacturerLocation,
    required Map<String, dynamic> techPackData,
    required String userCompanyName,
  }) async {
    try {
      final prompt =
          '''
Generate professional email content for a fashion brand to send to a manufacturer. Use this information:

Manufacturer: $manufacturerName
Location: $manufacturerLocation
Brand: $userCompanyName

Tech Pack Details:
- Main Fabric: ${techPackData['mainFabric'] ?? 'Not specified'}
- Secondary Materials: ${techPackData['secondaryMaterials'] ?? 'Not specified'}
- Fabric Properties: ${techPackData['fabricProperties'] ?? 'Not specified'}
- Primary Color: ${techPackData['primaryColor'] ?? 'Not specified'}
- Size Range: ${techPackData['sizeRange'] ?? 'Not specified'}
- Cost per Piece: ${techPackData['costPerPiece'] ?? 'Not specified'}
- Quantity: ${techPackData['quantity'] ?? 'Not specified'}
- Delivery Date: ${techPackData['deliveryDate'] ?? 'Not specified'}
- Accessories: ${techPackData['accessories'] ?? 'Not specified'}
- Logo Placement: ${techPackData['logoPlacement'] ?? 'Not specified'}
- Packaging Type: ${techPackData['packagingType'] ?? 'Not specified'}

Generate a professional email that:
1. Has a compelling subject line
2. Introduces the brand professionally  
3. Clearly outlines the production requirements
4. Mentions that detailed tech pack PDF is attached
5. Requests a quote and production timeline
6. Maintains a professional yet friendly tone
7. Includes a clear call to action

Format as JSON with "subject" and "body" fields. The body should be plain text with proper formatting and line breaks.
''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional business communication expert specializing in fashion industry B2B emails.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        try {
          final emailData = jsonDecode(content);
          return jsonEncode(emailData);
        } catch (e) {
          return jsonEncode({
            'subject': 'Production Inquiry from $userCompanyName',
            'body': '''Dear $manufacturerName Team,

We hope this email finds you well. We are reaching out regarding a potential collaboration opportunity.

Please find attached our complete tech pack PDF with design specifications including:
• Selected Design Image
• Tech Pack Details & Specifications  
• Technical Drawings
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''',
          });
        }
      } else {
        throw Exception(
          'Failed to generate email content: ${response.statusCode}',
        );
      }
    } catch (e) {
      return jsonEncode({
        'subject': 'Production Inquiry from $userCompanyName',
        'body': '''Dear $manufacturerName Team,

We hope this email finds you well.

We are reaching out regarding a potential production opportunity.

Please find attached our complete tech pack PDF containing:
• Selected Design Image
• Tech Pack Details & Specifications
• Technical Drawings  
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''',
      });
    }
  }

  // Download network image
  static Future<String?> downloadNetworkImage(
    String imageUrl,
    String filename,
  ) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Failed to download image: ${response.statusCode}');
        }
        return null;
      }

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/$filename';
      await File(path).writeAsBytes(response.bodyBytes);
      if (kDebugMode) {
        print('Saved network image to: $path');
      }
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading image: $e');
      }
      return null;
    }
  }

  static Future<Uint8List?> getImageBytes(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('File does not exist: $imagePath');
        }
        return null;
      }
      if (kDebugMode) {
        print('Processing file: $imagePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image bytes: $e');
      }
      return null;
    }
  }

  // Create PDF with tech pack details and multiple images
  static Future<String?> createTechPackPDF(
    List<String> imagePaths, {
    Map<String, dynamic>? techPackData,
    String? userCompanyName,
  }) async {
    try {
      final pdf = pw.Document();

      // Page 1: Complete Tech Pack Details
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'COMPLETE TECH PACK SPECIFICATIONS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'From: ${userCompanyName ?? 'Atelia Fashion App'}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 15),

                // Materials Section
                _buildPDFSection('MATERIALS & FABRICS', [
                  'Main Fabric: ${techPackData?['mainFabric'] ?? 'Not specified'}',
                  'Secondary Materials: ${techPackData?['secondaryMaterials'] ?? 'Not specified'}',
                  'Fabric Properties: ${techPackData?['fabricProperties'] ?? 'Not specified'}',
                ]),

                // Colors Section
                _buildPDFSection('COLORS & DESIGN', [
                  'Primary Color: ${techPackData?['primaryColor'] ?? 'Not specified'}',
                  'Alternate Colorways: ${techPackData?['alternateColorways'] ?? 'Not specified'}',
                  'Pantone: ${techPackData?['pantone'] ?? 'Not specified'}',
                ]),

                // Sizing Section
                _buildPDFSection('SIZING & FIT', [
                  'Size Range: ${techPackData?['sizeRange'] ?? 'Not specified'}',
                  'Measurement Chart: ${techPackData?['measurementChart'] ?? 'Not specified'}',
                ]),

                // Technical Section
                _buildPDFSection('TECHNICAL SPECIFICATIONS', [
                  'Accessories: ${techPackData?['accessories'] ?? 'Not specified'}',
                  'Stitching: ${techPackData?['stitching'] ?? 'Not specified'}',
                  'Decorative Stitching: ${techPackData?['decorativeStitching'] ?? 'Not specified'}',
                  'Logo Placement: ${techPackData?['logoPlacement'] ?? 'Not specified'}',
                ]),

                // Production Requirements (highlighted)
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PRODUCTION REQUIREMENTS',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Quantity: ${techPackData?['quantity'] ?? 'Not specified'}',
                      ),
                      pw.Text(
                        'Cost per Piece: ${techPackData?['costPerPiece'] ?? 'Not specified'}',
                      ),
                      pw.Text(
                        'Delivery Date: ${techPackData?['deliveryDate'] ?? 'Not specified'}',
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Text(
                  'Generated by Atelia Fashion App - ${DateTime.now().toString().split(' ')[0]}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                  textAlign: pw.TextAlign.center,
                ),
              ],
            );
          },
        ),
      );

      // Pages 2-4: Images
      for (int i = 0; i < imagePaths.length && i < 3; i++) {
        // Include all 3 images
        final imagePath = imagePaths[i];

        if (imagePath.startsWith('/9j/') ||
            imagePath.startsWith('iVBORw0KGgo') ||
            imagePath.startsWith('data:image/')) {
          String cleanBase64 = imagePath;
          if (imagePath.startsWith('data:image/')) {
            final commaIndex = imagePath.indexOf(',');
            if (commaIndex != -1) {
              cleanBase64 = imagePath.substring(commaIndex + 1);
            }
          }

          try {
            final bytes = base64.decode(cleanBase64);

            // Balanced compression for PDF - better quality but manageable size
            Uint8List finalBytes;
            try {
              // High quality compression
              finalBytes = await FlutterImageCompress.compressWithList(
                Uint8List.fromList(bytes),
                minHeight: 600, // Higher dimensions for better quality
                minWidth: 600,
                quality: 75, // Higher quality
                format: CompressFormat.jpeg,
              );

              // If still too large, compress more but maintain good quality
              if (finalBytes.length > 12 * 1024) {
                // Slightly higher target for better quality
                finalBytes = await FlutterImageCompress.compressWithList(
                  Uint8List.fromList(bytes),
                  minHeight: 500,
                  minWidth: 500,
                  quality: 68,
                  format: CompressFormat.jpeg,
                );
              }

              // Final fallback if still too large
              if (finalBytes.length > 12 * 1024) {
                finalBytes = await FlutterImageCompress.compressWithList(
                  Uint8List.fromList(bytes),
                  minHeight: 450,
                  minWidth: 450,
                  quality: 62,
                  format: CompressFormat.jpeg,
                );
              }

              if (kDebugMode) {
                print(
                  '🗜️ Compressed image for PDF ${(bytes.length / 1024).toStringAsFixed(1)} KB → ${(finalBytes.length / 1024).toStringAsFixed(1)} KB',
                );
              }
            } catch (e) {
              // Fallback: reasonable compression instead of truncation
              try {
                finalBytes = await FlutterImageCompress.compressWithList(
                  Uint8List.fromList(bytes),
                  minHeight: 350,
                  minWidth: 350,
                  quality: 55,
                  format: CompressFormat.jpeg,
                );
              } catch (e2) {
                finalBytes = Uint8List.fromList(bytes.take(10 * 1024).toList());
              }
              if (kDebugMode) {
                print('Compression failed, using fallback: $e');
              }
            }

            // Create PDF page with image
            final imageTitle = i == 0
                ? 'PAGE ${i + 2}: SELECTED DESIGN IMAGE'
                : i == 1
                ? 'PAGE ${i + 2}: MANUFACTURING DESIGN'
                : 'PAGE ${i + 2}: TECHNICAL FLAT DRAWING';

            pdf.addPage(
              pw.Page(
                pageFormat: PdfPageFormat.a4,
                build: (pw.Context context) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        imageTitle,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Expanded(
                        child: pw.Center(
                          child: pw.Image(
                            pw.MemoryImage(finalBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Text(
                        'Generated by Atelia Fashion App - ${DateTime.now().toString().split('.')[0]}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            );

            if (kDebugMode) {
              print('✅ Added $imageTitle to PDF');
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ Failed to process image for PDF: $e');
            }
          }
        }
      }

      // Save PDF to temporary directory
      final directory = await getTemporaryDirectory();
      final pdfPath =
          '${directory.path}/techpack_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFile = File(pdfPath);
      final pdfBytes = await pdf.save();
      await pdfFile.writeAsBytes(pdfBytes);

      final fileSize = pdfBytes.length;

      if (kDebugMode) {
        print(
          '📄 Created PDF: $pdfPath (${(fileSize / 1024).toStringAsFixed(1)} KB)',
        );
      }

      // If PDF is still too large, recreate with compressed images
      if (fileSize > 60 * 1024) {
        // 60KB limit (since 53.9KB worked fine)
        if (kDebugMode) {
          print('⚠️ PDF too large, recreating with only first image');
        }

        // Delete the large PDF
        await pdfFile.delete();

        // Create new PDF with tech pack details page + all 3 images but more aggressive compression
        final smallPdf = pw.Document();

        // Add Page 1: Complete Tech Pack Details (same as original)
        smallPdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'COMPLETE TECH PACK SPECIFICATIONS',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'From: ${userCompanyName ?? 'Atelia Fashion App'}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 15),

                  // Materials Section
                  _buildPDFSection('MATERIALS & FABRICS', [
                    'Main Fabric: ${techPackData?['mainFabric'] ?? 'Not specified'}',
                    'Secondary Materials: ${techPackData?['secondaryMaterials'] ?? 'Not specified'}',
                    'Fabric Properties: ${techPackData?['fabricProperties'] ?? 'Not specified'}',
                  ]),

                  // Colors Section
                  _buildPDFSection('COLORS & DESIGN', [
                    'Primary Color: ${techPackData?['primaryColor'] ?? 'Not specified'}',
                    'Alternate Colorways: ${techPackData?['alternateColorways'] ?? 'Not specified'}',
                    'Pantone: ${techPackData?['pantone'] ?? 'Not specified'}',
                  ]),

                  // Sizing Section
                  _buildPDFSection('SIZING & FIT', [
                    'Size Range: ${techPackData?['sizeRange'] ?? 'Not specified'}',
                    'Measurement Chart: ${techPackData?['measurementChart'] ?? 'Not specified'}',
                  ]),

                  // Technical Section
                  _buildPDFSection('TECHNICAL SPECIFICATIONS', [
                    'Accessories: ${techPackData?['accessories'] ?? 'Not specified'}',
                    'Stitching: ${techPackData?['stitching'] ?? 'Not specified'}',
                    'Decorative Stitching: ${techPackData?['decorativeStitching'] ?? 'Not specified'}',
                    'Logo Placement: ${techPackData?['logoPlacement'] ?? 'Not specified'}',
                  ]),

                  // Production Requirements (highlighted)
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue),
                      borderRadius: pw.BorderRadius.circular(5),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PRODUCTION REQUIREMENTS',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Quantity: ${techPackData?['quantity'] ?? 'Not specified'}',
                        ),
                        pw.Text(
                          'Cost per Piece: ${techPackData?['costPerPiece'] ?? 'Not specified'}',
                        ),
                        pw.Text(
                          'Delivery Date: ${techPackData?['deliveryDate'] ?? 'Not specified'}',
                        ),
                      ],
                    ),
                  ),

                  pw.Spacer(),

                  // Footer
                  pw.Text(
                    'Generated by Atelia Fashion App - ${DateTime.now().toString().split(' ')[0]}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              );
            },
          ),
        );

        if (kDebugMode) {
          print('✅ Added PAGE 1: COMPLETE TECH PACK DETAILS to fallback PDF');
          print(
            '⚠️ PDF too large, recreating with compressed images and template parameters',
          );
        }

        // Add the image pages
        for (int i = 0; i < imagePaths.length && i < 3; i++) {
          // All 3 images for fallback
          final imagePath = imagePaths[i];
          if (imagePath.startsWith('/9j/') ||
              imagePath.startsWith('iVBORw0KGgo') ||
              imagePath.startsWith('data:image/')) {
            String cleanBase64 = imagePath;
            if (imagePath.startsWith('data:image/')) {
              final commaIndex = imagePath.indexOf(',');
              if (commaIndex != -1) {
                cleanBase64 = imagePath.substring(commaIndex + 1);
              }
            }

            try {
              final bytes = base64.decode(cleanBase64);
              final veryCompressed =
                  await FlutterImageCompress.compressWithList(
                    Uint8List.fromList(bytes),
                    minHeight: 450, // Higher resolution for better quality
                    minWidth: 450,
                    quality: 60, // Improved quality
                    format: CompressFormat.jpeg,
                  );

              final imageTitle = i == 0
                  ? 'PAGE ${i + 2}: SELECTED DESIGN IMAGE'
                  : i == 1
                  ? 'PAGE ${i + 2}: MANUFACTURING DESIGN'
                  : 'PAGE ${i + 2}: TECHNICAL FLAT DRAWING';

              smallPdf.addPage(
                pw.Page(
                  pageFormat: PdfPageFormat.a4,
                  build: (pw.Context context) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          imageTitle,
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Expanded(
                          child: pw.Center(
                            child: pw.Image(
                              pw.MemoryImage(veryCompressed),
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 20),
                        pw.Text(
                          'Page ${i + 1} of 3 - Optimized for email delivery',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    );
                  },
                ),
              );

              if (kDebugMode) {
                print('✅ Added $imageTitle to fallback PDF');
              }
            } catch (e) {
              if (kDebugMode) {
                print(
                  '❌ Failed to process image ${i + 1} for fallback PDF: $e',
                );
              }
            }
          }
        }

        final smallPdfBytes = await smallPdf.save();
        await pdfFile.writeAsBytes(smallPdfBytes);

        if (kDebugMode) {
          print(
            '📄 Created smaller PDF with 3 images: ${(smallPdfBytes.length / 1024).toStringAsFixed(1)} KB',
          );
        }

        // Add small compressed images as template parameters for the fallback
        try {
          for (int i = 0; i < imagePaths.length && i < 3; i++) {
            final imagePath = imagePaths[i];
            if (imagePath.startsWith('/9j/') ||
                imagePath.startsWith('iVBORw0KGgo') ||
                imagePath.startsWith('data:image/')) {
              String cleanBase64 = imagePath;
              if (imagePath.startsWith('data:image/')) {
                final commaIndex = imagePath.indexOf(',');
                if (commaIndex != -1) {
                  cleanBase64 = imagePath.substring(commaIndex + 1);
                }
              }

              try {
                final bytes = base64.decode(cleanBase64);
                // Very small images for template parameters (to fit within remaining space)
                final tinyCompressed =
                    await FlutterImageCompress.compressWithList(
                      Uint8List.fromList(bytes),
                      minHeight: 200, // Very small for template
                      minWidth: 200,
                      quality: 35, // Low quality but viewable
                      format: CompressFormat.jpeg,
                    );

                final tinyBase64 = base64Encode(tinyCompressed);
                // Only add if very small to avoid exceeding limits
                if (tinyBase64.length < 8 * 1024) {
                  // 8KB limit per template image
                  // Use attachment variables for template (this won't conflict with PDF attachment)
                  // templateParams['fallback_image_${i + 1}'] = tinyBase64;
                  if (kDebugMode) {
                    print(
                      '📎 Added tiny template image ${i + 1}: ${(tinyCompressed.length / 1024).toStringAsFixed(1)} KB',
                    );
                  }
                }
              } catch (e) {
                if (kDebugMode) {
                  print('❌ Failed to create tiny template image ${i + 1}: $e');
                }
              }
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Failed to add template parameters: $e');
          }
        }
      }

      return pdfPath;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating PDF: $e');
      }
      return null;
    }
  }

  static Future<Uint8List?> compressImage(String imagePath) async {
    try {
      final originalBytes = await getImageBytes(imagePath);
      if (originalBytes == null) {
        return null;
      }

      final originalSize = originalBytes.length;
      if (kDebugMode) {
        print(
          'Original image size: ${(originalSize / 1024).toStringAsFixed(1)} KB',
        );
      }

      if (originalSize < 100 * 1024) {
        return originalBytes;
      }

      // Aggressive compression for EmailJS 50KB limit (need ~15KB per image max)
      final targetSize =
          15 * 1024; // Target 15KB per image for 3 images under 50KB total

      // Try flutter_image_compress first
      try {
        final compressedBytes = await FlutterImageCompress.compressWithList(
          originalBytes,
          minHeight: 300, // Very small dimensions
          minWidth: 300,
          quality: 50, // Lower quality for smaller size
          format: CompressFormat.jpeg,
        );

        if (kDebugMode) {
          print(
            'FlutterImageCompress result: ${(compressedBytes.length / 1024).toStringAsFixed(1)} KB',
          );
        }

        if (compressedBytes.length <= targetSize) {
          return compressedBytes;
        }

        // If still too large, try again with even smaller dimensions
        final veryCompressed = await FlutterImageCompress.compressWithList(
          originalBytes,
          minHeight: 200,
          minWidth: 200,
          quality: 30,
          format: CompressFormat.jpeg,
        );

        if (kDebugMode) {
          print(
            'Very compressed result: ${(veryCompressed.length / 1024).toStringAsFixed(1)} KB',
          );
        }

        return veryCompressed;
      } catch (e) {
        if (kDebugMode) {
          print('FlutterImageCompress failed, using fallback: $e');
        }

        // Fallback: return much smaller portion of original
        if (originalSize > targetSize) {
          final smallerBytes = originalBytes.sublist(0, targetSize);
          if (kDebugMode) {
            print(
              'Fallback truncation: ${(smallerBytes.length / 1024).toStringAsFixed(1)} KB',
            );
          }
          return smallerBytes;
        }
      }

      return originalBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      return await getImageBytes(imagePath);
    }
  }

  static Future<bool> testMinimalEmail({
    required String toEmail,
    String? userMessage,
  }) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    // Fixed payload structure for EmailJS (with proper escaping)
    final payload = {
      'service_id': _serviceId,
      'template_id': _templateId,
      'user_id': _publicKey,
      'template_params': {
        // Match your EmailJS template configuration exactly
        'name': 'Atelia Fashion App',
        'time': DateTime.now().toString().split('.')[0],
        'message':
            userMessage ??
            'Simple test email from Atelia Fashion App - no attachments',
        'email': toEmail,
        'to_email': toEmail,
      },
    };

    if (kDebugMode) {
      print('🚀 Sending minimal test email');
      print('📧 Payload: ${jsonEncode(payload)}');
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred: $e');
      }
      return false;
    }
  }

  // Preview email content and PDF before sending
  static Future<Map<String, dynamic>> previewEmailWithPDF({
    required String toEmail,
    required String manufacturerName,
    required String manufacturerLocation,
    required Map<String, dynamic> techPackData,
    required String userCompanyName,
    List<String> imagePaths = const [],
  }) async {
    try {
      // Generate AI-powered email content
      final aiEmailJson = await generateEmailContent(
        manufacturerName: manufacturerName,
        manufacturerLocation: manufacturerLocation,
        techPackData: techPackData,
        userCompanyName: userCompanyName,
      );

      final aiEmailData = jsonDecode(aiEmailJson);
      final emailSubject =
          aiEmailData['subject']?.toString() ??
          'Production Inquiry from $userCompanyName';
      final emailBody =
          aiEmailData['body']?.toString() ?? 'Email content generation failed';

      // Create PDF preview
      String? pdfPath;
      int pdfSize = 0;
      if (imagePaths.isNotEmpty) {
        pdfPath = await createTechPackPDF(
          imagePaths,
          techPackData: techPackData,
          userCompanyName: userCompanyName,
        );
        if (pdfPath != null) {
          final pdfFile = File(pdfPath);
          pdfSize = (await pdfFile.readAsBytes()).length;
        }
      }

      return {
        'success': true,
        'emailPreview': {
          'to': toEmail,
          'subject': emailSubject,
          'from': userCompanyName,
          'timestamp': DateTime.now().toString().split('.')[0],
          'body': emailBody,
        },
        'pdfPreview': {
          'path': pdfPath,
          'size': pdfSize,
          'sizeKB': (pdfSize / 1024).toStringAsFixed(1),
          'imageCount': imagePaths.length,
        },
        'templateParams': {
          'name': userCompanyName,
          'time': DateTime.now().toString().split('.')[0],
          'message': emailBody,
        },
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error previewing email: $e');
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  // AI-powered professional email with PDF attachment
  static Future<bool> sendAIPoweredEmailWithPDF({
    required String toEmail,
    required String manufacturerName,
    required String manufacturerLocation,
    required Map<String, dynamic> techPackData,
    required String userCompanyName,
    String? userEmail,
    String? userName,
    List<String> imagePaths = const [],
  }) async {
    if (imagePaths.isEmpty) {
      if (kDebugMode) {
        print('No images provided for PDF creation');
      }
      return false;
    }

    try {
      // Generate AI-powered email content
      String emailSubject = 'Production Inquiry from $userCompanyName';
      String emailBody =
          '''Dear $manufacturerName Team,

We hope this email finds you well. We are reaching out from $userCompanyName regarding a potential collaboration opportunity.

Please find attached our complete tech pack PDF containing:
• Selected Design Image
• Tech Pack Details & Specifications  
• Technical Drawings
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''';

      if (kDebugMode) {
        print('🤖 Generating AI email content...');
      }

      try {
        final aiEmailJson = await generateEmailContent(
          manufacturerName: manufacturerName,
          manufacturerLocation: manufacturerLocation,
          techPackData: techPackData,
          userCompanyName: userCompanyName,
        );

        final aiEmailData = jsonDecode(aiEmailJson);
        emailSubject = aiEmailData['subject']?.toString() ?? emailSubject;
        emailBody = aiEmailData['body']?.toString() ?? emailBody;

        // Ensure emailBody is a proper string and not an object
        if (emailBody.contains('[object Object]') ||
            emailBody == 'null' ||
            emailBody.isEmpty) {
          if (kDebugMode) {
            print('⚠️ Fixing corrupted email body: $emailBody');
          }
          emailBody = '''Dear $manufacturerName Team,

We hope this email finds you well. We are reaching out regarding a potential production opportunity.

Please find attached our complete tech pack PDF with design specifications including:
• Selected Design Image
• Tech Pack Details & Specifications  
• Technical Drawings
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''';
        }

        if (kDebugMode) {
          print('✅ AI email content generated successfully');
          print('📧 Subject: $emailSubject');
          print(
            '📧 Body preview: ${emailBody.substring(0, emailBody.length > 100 ? 100 : emailBody.length)}...',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ AI generation failed, using fallback content: $e');
        }
      }

      // Create PDF with all images
      final pdfPath = await createTechPackPDF(
        imagePaths,
        techPackData: techPackData,
        userCompanyName: userCompanyName,
      );
      if (pdfPath == null) {
        if (kDebugMode) {
          print('❌ Failed to create PDF');
        }
        return false;
      }

      // Use sendForm multipart approach for PDF attachment
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send-form');
      final request = http.MultipartRequest('POST', url);

      // EmailJS authentication
      request.fields['service_id'] = _serviceId;
      request.fields['template_id'] = _templateId;
      request.fields['user_id'] = _publicKey;

      // Add recipient email separately (EmailJS needs this for routing)
      request.fields['to_email'] = toEmail;

      // Simple one-line message directing to PDF
      final cleanMessage =
          'Please see the attached PDF for complete design details and tech pack specifications. for further details contact or reply to this ${FirebaseAuth.instance.currentUser?.email}';

      // Add template parameters as individual fields (NOT JSON)
      request.fields['name'] = userCompanyName;
      request.fields['time'] = DateTime.now().toString().split('.')[0];
      request.fields['message'] = cleanMessage;
      request.fields['subject'] = emailSubject;
      request.fields['email'] = toEmail;
      
      // User information for reply-to functionality
      request.fields['user_email'] = userEmail ?? 'mdaniyalkhan783@gmail.com';
      request.fields['user_name'] = userName ?? userCompanyName;
      request.fields['reply_to'] = userEmail ?? 'terabititdeveloper@gmail.com';

      // Add PDF attachment (this doesn't count against 50KB template variable limit)
      final pdfFile = File(pdfPath);
      final pdfBytes = await pdfFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'techpack_pdf',
          pdfBytes,
          filename:
              'Atelia_TechPack_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      );

      if (kDebugMode) {
        print('🚀 Sending AI-powered email with sendForm approach');
        print('📧 Recipient (routing): ${request.fields['to_email']}');
        print('👤 Sender: ${request.fields['user_name']} <${request.fields['user_email']}>');
        print('↩️  Reply-to: ${request.fields['reply_to']}');
        print('📝 Template fields:');
        print('   name: ${request.fields['name']}');
        print('   time: ${request.fields['time']}');
        print(
          '   message: ${cleanMessage.substring(0, cleanMessage.length > 100 ? 100 : cleanMessage.length)}...',
        );
        print('   subject: ${request.fields['subject']}');
        print('   email: ${request.fields['email']}');
        print(
          '📎 PDF attachment: ${(pdfBytes.length / 1024).toStringAsFixed(1)} KB',
        );
        print('📋 All form fields: ${request.fields.keys.join(', ')}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
      }

      // Clean up temporary PDF file
      try {
        await File(pdfPath).delete();
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not delete temporary PDF file: $e');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred in AI-powered PDF email: $e');
      }
      return false;
    }
  }

  // Alternative: Send email with actual PDF attachment (requires EmailJS Professional plan)
  static Future<bool> sendAIPoweredEmailWithRealPDFAttachment({
    required String toEmail,
    required String manufacturerName,
    required String manufacturerLocation,
    required Map<String, dynamic> techPackData,
    required String userCompanyName,
    List<String> imagePaths = const [],
  }) async {
    if (imagePaths.isEmpty) {
      if (kDebugMode) {
        print('No images provided for PDF creation');
      }
      return false;
    }

    try {
      // Generate AI-powered email content
      String emailSubject = 'Production Inquiry from $userCompanyName';
      String emailBody = '''Dear $manufacturerName Team,

We hope this email finds you well. We are reaching out regarding a potential collaboration opportunity.

Please find attached our complete tech pack PDF with design specifications including:
• Selected Design Image
• Tech Pack Details & Specifications  
• Technical Drawings
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''';

      if (kDebugMode) {
        print('🤖 Generating AI email content...');
      }

      try {
        final aiEmailJson = await generateEmailContent(
          manufacturerName: manufacturerName,
          manufacturerLocation: manufacturerLocation,
          techPackData: techPackData,
          userCompanyName: userCompanyName,
        );

        final aiEmailData = jsonDecode(aiEmailJson);
        emailSubject = aiEmailData['subject']?.toString() ?? emailSubject;
        emailBody = aiEmailData['body']?.toString() ?? emailBody;

        // Ensure emailBody is a proper string and not an object
        if (emailBody.contains('[object Object]') ||
            emailBody == 'null' ||
            emailBody.isEmpty) {
          if (kDebugMode) {
            print('⚠️ Fixing corrupted email body: $emailBody');
          }
          emailBody = '''Dear $manufacturerName Team,

We hope this email finds you well. We are reaching out regarding a potential production opportunity.

Please find attached our complete tech pack PDF with design specifications including:
• Selected Design Image
• Tech Pack Details & Specifications  
• Technical Drawings
• Manufacturing Guidelines

We would love to discuss production possibilities and pricing with your team.

Best regards,
$userCompanyName Team''';
        }

        if (kDebugMode) {
          print('✅ AI email content generated successfully');
          print('📧 Subject: $emailSubject');
          print(
            '📧 Body preview: ${emailBody.substring(0, emailBody.length > 100 ? 100 : emailBody.length)}...',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ AI generation failed, using fallback content: $e');
        }
      }

      // Create PDF with all images
      final pdfPath = await createTechPackPDF(
        imagePaths,
        techPackData: techPackData,
        userCompanyName: userCompanyName,
      );
      if (pdfPath == null) {
        if (kDebugMode) {
          print('❌ Failed to create PDF');
        }
        return false;
      }

      // EmailJS sendForm endpoint for file attachments (Professional plan)
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send-form');
      final request = http.MultipartRequest('POST', url);

      // EmailJS authentication
      request.fields['service_id'] = _serviceId;
      request.fields['template_id'] = _templateId;
      request.fields['user_id'] = _publicKey;

      // Add recipient email directly
      request.fields['to_email'] = toEmail;

      // Add template parameters with proper prefix for multipart form
      request.fields['template_params[name]'] = userCompanyName;
      request.fields['template_params[time]'] = DateTime.now().toString().split(
        '.',
      )[0];
      request.fields['template_params[message]'] = cleanTemplateVariable(
        emailBody,
      );
      request.fields['template_params[to_email]'] = toEmail;
      request.fields['template_params[subject]'] = emailSubject;
      request.fields['template_params[email]'] = toEmail;

      // Add PDF attachment
      final pdfFile = File(pdfPath);
      final pdfBytes = await pdfFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'techpack_pdf',
          pdfBytes,
          filename:
              'Atelia_TechPack_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      );

      if (kDebugMode) {
        print(
          '🚀 Sending AI-powered email with REAL PDF attachment (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB)',
        );
        print(
          '📧 This requires EmailJS Professional plan for file attachments',
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
      }

      // Clean up temporary PDF file
      try {
        await pdfFile.delete();
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not delete temporary PDF file: $e');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred in AI-powered REAL PDF email: $e');
      }
      return false;
    }
  }

  // Professional plan method - PDF attachment with all images
  static Future<bool> testEmailJSWithPDFAttachment({
    required String toEmail,
    String? userMessage,
    List<String> imagePaths = const [],
  }) async {
    if (imagePaths.isEmpty) {
      if (kDebugMode) {
        print('No images provided for PDF creation');
      }
      return false;
    }

    try {
      // Create PDF with all images
      Map<String, dynamic>? techPackData;
      String? userCompanyName;
      final pdfPath = await createTechPackPDF(
        imagePaths,
        techPackData: techPackData,
        userCompanyName: userCompanyName,
      );
      if (pdfPath == null) {
        if (kDebugMode) {
          print('❌ Failed to create PDF');
        }
        return false;
      }

      // EmailJS sendForm endpoint for file attachments
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send-form');
      final request = http.MultipartRequest('POST', url);

      // EmailJS authentication
      request.fields['service_id'] = _serviceId;
      request.fields['template_id'] = _templateId;
      request.fields['user_id'] = _publicKey;

      // Add recipient email directly (not in template_params)
      request.fields['to_email'] =
          toEmail; // EmailJS expects this at root level

      // Add template parameters with proper prefix for multipart form
      request.fields['template_params[name]'] = 'Atelia Fashion App';
      request.fields['template_params[time]'] = DateTime.now().toString().split(
        '.',
      )[0];
      request.fields['template_params[message]'] = cleanTemplateVariable(
        userMessage ??
            'Please find attached our complete tech pack PDF with all design images and specifications.',
      );
      request.fields['template_params[email]'] = toEmail;
      request.fields['template_params[to_email]'] =
          toEmail; // Also in template for display
      request.fields['template_params[subject]'] =
          'Tech Pack from Atelia Fashion App';

      // Add PDF attachment as file for Professional plan
      final pdfFile = File(pdfPath);
      final pdfBytes = await pdfFile.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'techpack_pdf', // This should match the Parameter name in EmailJS template
          pdfBytes,
          filename:
              'Atelia_TechPack_${DateTime.now().millisecondsSinceEpoch}.pdf',
        ),
      );

      // Also add small template parameter images for inline display in email
      try {
        for (int i = 0; i < imagePaths.length && i < 2; i++) {
          // Only 2 to save space
          final imagePath = imagePaths[i];
          if (imagePath.startsWith('/9j/') ||
              imagePath.startsWith('iVBORw0KGgo') ||
              imagePath.startsWith('data:image/')) {
            String cleanBase64 = imagePath;
            if (imagePath.startsWith('data:image/')) {
              final commaIndex = imagePath.indexOf(',');
              if (commaIndex != -1) {
                cleanBase64 = imagePath.substring(commaIndex + 1);
              }
            }

            try {
              final bytes = base64.decode(cleanBase64);
              // Very tiny images for template parameters
              final miniCompressed =
                  await FlutterImageCompress.compressWithList(
                    Uint8List.fromList(bytes),
                    minHeight: 150, // Very small
                    minWidth: 150,
                    quality: 30, // Low quality for template
                    format: CompressFormat.jpeg,
                  );

              final miniBase64 = base64Encode(miniCompressed);
              // Only add if very small
              if (miniBase64.length < 5 * 1024) {
                // 5KB limit per template image
                request.fields['preview_image_${i + 1}'] = miniBase64;
                if (kDebugMode) {
                  print(
                    '📎 Added template preview ${i + 1}: ${(miniCompressed.length / 1024).toStringAsFixed(1)} KB',
                  );
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('❌ Failed to create preview image ${i + 1}: $e');
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Failed to add template previews: $e');
        }
      }

      if (kDebugMode) {
        print(
          '🚀 Sending EmailJS form with PDF attachment (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB)',
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('📤 Response Status: ${response.statusCode}');
        print('📤 Response Body: ${response.body}');
      }

      // Clean up temporary PDF file
      try {
        await pdfFile.delete();
      } catch (e) {
        if (kDebugMode) {
          print('Warning: Could not delete temporary PDF file: $e');
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception occurred in PDF email: $e');
      }
      return false;
    }
  }
}
