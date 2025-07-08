import 'package:flutter/material.dart';

class InfographicPage extends StatelessWidget {
  const InfographicPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final maxContentWidth = 900.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM Infografik'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildZoomableImageCard(
                  context,
                  imagePath: 'assets/MVVM.png',
                  caption: 'MVVM-arkitektur: Simpelt overblik',
                ),
                const SizedBox(height: 32),
                _buildZoomableImageCard(
                  context,
                  imagePath: 'assets/MVVM-Detailed.png',
                  caption: 'MVVM-arkitektur: Detaljeret flow',
                ),
                const SizedBox(height: 40),
                _buildTextContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomableImageCard(BuildContext context, {required String imagePath, required String caption}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: Colors.grey[100],
            constraints: const BoxConstraints(
              minHeight: 200,
              maxHeight: 500,
              minWidth: 200,
              maxWidth: 800,
            ),
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              panEnabled: true,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.zoom_in, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$caption  (Zoom & pan)',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 700),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'MVVM (Model-View-ViewModel) er et arkitekturmønster, der adskiller UI (View), forretningslogik (ViewModel) og data (Model).',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 20, height: 1.5),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 32),
          _buildSection(
            title: 'Model',
            description: 'Repræsenterer data og forretningslogik. Modellerne er uafhængige af UI og håndterer data fra fx API eller database.',
          ),
          _buildSection(
            title: 'View',
            description: 'UI-laget, der viser data til brugeren og sender brugerinteraktioner videre til ViewModel.',
          ),
          _buildSection(
            title: 'ViewModel',
            description: 'Binder Model og View sammen. Indeholder præsentationslogik og eksponerer data til View via fx Provider.',
          ),
          const SizedBox(height: 32),
          Text(
            'Fordele ved MVVM:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              '- Bedre testbarhed\n- Genbrug af kode\n- Klar separation af ansvar\n- Lettere at vedligeholde og udvide',
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
} 