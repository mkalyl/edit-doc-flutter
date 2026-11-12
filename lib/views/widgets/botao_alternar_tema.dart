import 'package:flutter/material.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Botão reutilizável na AppBar para alternar entre tema claro e escuro.
class BotaoAlternarTema extends StatelessWidget {
  final AuthViewModel authViewModel;

  const BotaoAlternarTema({
    super.key,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: authViewModel.temaEscuro
          ? 'Mudar para tema claro'
          : 'Mudar para tema escuro',
      icon: Icon(
        authViewModel.temaEscuro
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
      ),
      onPressed: authViewModel.alternarTema,
    );
  }
}
