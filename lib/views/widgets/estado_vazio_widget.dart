import 'package:flutter/material.dart';

/// Componente reutilizável para exibir estados vazios ou sem resultados.
class EstadoVazioWidget extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String mensagem;
  final Widget? acao;

  const EstadoVazioWidget({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme textos = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icone, size: 56, color: cores.outline),
            const SizedBox(height: 12),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: textos.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
            ),
            if (acao != null) ...<Widget>[
              const SizedBox(height: 16),
              acao!,
            ],
          ],
        ),
      ),
    );
  }
}
