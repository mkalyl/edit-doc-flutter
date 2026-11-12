import 'package:flutter/material.dart';

/// Campo de formulário padronizado para reutilização nas telas da aplicação.
class CampoTextoPadrao extends StatelessWidget {
  final TextEditingController controller;
  final String rotulo;
  final String? dica;
  final IconData icone;
  final String? Function(String?)? validador;
  final TextInputType tipoTeclado;
  final TextInputAction? acaoTeclado;
  final bool ocultarTexto;
  final Widget? iconeSufixo;
  final int? maximoLinhas;
  final void Function(String)? aoEnviar;

  const CampoTextoPadrao({
    super.key,
    required this.controller,
    required this.rotulo,
    required this.icone,
    this.dica,
    this.validador,
    this.tipoTeclado = TextInputType.text,
    this.acaoTeclado,
    this.ocultarTexto = false,
    this.iconeSufixo,
    this.maximoLinhas = 1,
    this.aoEnviar,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validador,
      keyboardType: tipoTeclado,
      textInputAction: acaoTeclado,
      obscureText: ocultarTexto,
      maxLines: ocultarTexto ? 1 : maximoLinhas,
      onFieldSubmitted: aoEnviar,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: dica,
        prefixIcon: Icon(icone),
        suffixIcon: iconeSufixo,
      ),
    );
  }
}
