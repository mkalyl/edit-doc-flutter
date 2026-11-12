import 'package:flutter/material.dart';

/// Seletor reutilizável de categorias usando ChoiceChips.
class SeletorCategoria extends StatelessWidget {
  final List<String> categorias;
  final String selecionada;
  final ValueChanged<String> aoSelecionar;
  final bool rolavelHorizontal;

  const SeletorCategoria({
    super.key,
    required this.categorias,
    required this.selecionada,
    required this.aoSelecionar,
    this.rolavelHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = categorias.map((String categoria) {
      return ChoiceChip(
        label: Text(categoria),
        selected: selecionada == categoria,
        onSelected: (_) => aoSelecionar(categoria),
      );
    }).toList();

    if (rolavelHorizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips
              .map(
                (Widget chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: chip,
                ),
              )
              .toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}
