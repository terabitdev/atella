import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docx_template_fork/docx_template_fork.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class WordGeneratorScreen extends StatefulWidget {
  const WordGeneratorScreen({super.key});

  @override
  State<WordGeneratorScreen> createState() => _WordGeneratorScreenState();
}

class _WordGeneratorScreenState extends State<WordGeneratorScreen> {
  bool isGenerating = false;

  Future<void> generateAndShareWordFile() async {
    try {
      setState(() => isGenerating = true);

      // Load the Word template
      final data = await rootBundle.load('assets/template.docx');
      final bytes = data.buffer.asUint8List();
      final docx = await DocxTemplate.fromBytes(bytes);

      // Fill in dynamic data using a Map approach
      final content = Content();
      content
        ..add(TextContent("name", "Muhammad Daniyal Khan"))
        ..add(TextContent("score", "95"));

      print('📝 Content added - name: Muhammad Daniyal Khan, score: 95');
      print('📋 Template loaded from assets');

      // Generate the final document
      final generated = await docx.generate(content);
      print('✅ Document generated, size: ${generated?.length ?? 0} bytes');

      if (generated != null) {
        print('✅ Generation successful, preparing to save...');
      } else {
        print('❌ Generation returned null');
      }

      if (generated == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Failed to generate Word file")),
        );
        setState(() => isGenerating = false);
        return;
      }

      // Save temporarily in app's documents directory
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/generated_word.docx';
      final file = File(filePath);
      await file.writeAsBytes(generated);

      // Share or open the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📄 Here is your generated Word file!',
      );

      setState(() => isGenerating = false);
    } catch (e) {
      setState(() => isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Word File Generator"),
      ),
      body: Center(
        child: isGenerating
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: generateAndShareWordFile,
                icon: const Icon(Icons.file_download),
                label: const Text("Generate & Share Word File"),
              ),
      ),
    );
  }
}
