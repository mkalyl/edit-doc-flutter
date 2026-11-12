import 'package:flutter/material.dart';
import '../../models/documento.dart';

/// Exibe um diálogo de confirmação reutilizável antes de excluir um documento.
Future<bool> confirmarExclusaoDocumento(
  BuildContext context,
  Documento documento,
) async {
  final bool? confirmado = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Excluir documento'),
        content: Text(
          'Deseja excluir "${documento.titulo}"? Esta ação não pode ser desfeita.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return confirmado ?? false;
}
