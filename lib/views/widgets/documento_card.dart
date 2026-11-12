import 'package:flutter/material.dart';
import '../../models/documento.dart';

/// Cartão visual que apresenta os metadados e resumo de um documento.
class DocumentoCard extends StatelessWidget {
  final Documento documento;
  final VoidCallback aoTocar;
  final VoidCallback? aoEditar;
  final VoidCallback? aoExcluir;

  const DocumentoCard({
    super.key,
    required this.documento,
    required this.aoTocar,
    this.aoEditar,
    this.aoExcluir,
  });

  String _formatarData(DateTime data) {
    final String dia = data.day.toString().padLeft(2, '0');
    final String mes = data.month.toString().padLeft(2, '0');
    final String hora = data.hour.toString().padLeft(2, '0');
    final String minuto = data.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year} às $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;
    final TextTheme textos = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: aoTocar,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      documento.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textos.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cores.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      documento.categoria,
                      style: textos.labelSmall?.copyWith(
                        color: cores.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                documento.resumo,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textos.bodyMedium?.copyWith(
                  color: cores.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule, size: 14, color: cores.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${_formatarData(documento.atualizadoEm)} • '
                      '${documento.contagemPalavras} palavras',
                      style: textos.labelSmall?.copyWith(color: cores.outline),
                    ),
                  ),
                  if (aoEditar != null)
                    IconButton(
                      tooltip: 'Editar documento',
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: aoEditar,
                    ),
                  if (aoExcluir != null)
                    IconButton(
                      tooltip: 'Excluir documento',
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: cores.error,
                      ),
                      onPressed: aoExcluir,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
