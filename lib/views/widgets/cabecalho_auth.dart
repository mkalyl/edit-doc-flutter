import 'package:flutter/material.dart';

/// Cabeçalho visual compartilhado pelas telas de Login e Cadastro.
class CabecalhoAuth extends StatelessWidget {
  final String titulo;
  final String subtitulo;

  const CabecalhoAuth({
    super.key,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme textos = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: cores.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.description_outlined,
            size: 36,
            color: cores.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          titulo,
          textAlign: TextAlign.center,
          style: textos.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitulo,
          textAlign: TextAlign.center,
          style: textos.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
      ],
    );
  }
}
