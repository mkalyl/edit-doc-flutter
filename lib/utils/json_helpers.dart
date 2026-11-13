import 'dart:convert';

/// Decodifica uma string JSON de lista para mapas compatíveis com Web e VM.
List<Map<String, dynamic>> decodificarListaJson(String? jsonBruto) {
  if (jsonBruto == null || jsonBruto.trim().isEmpty) {
    return <Map<String, dynamic>>[];
  }
  try {
    final Object? decodificado = jsonDecode(jsonBruto);
    if (decodificado is! List) {
      return <Map<String, dynamic>>[];
    }
    return decodificado
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item),
        )
        .toList();
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
}

/// Decodifica uma string JSON de objeto único para mapa tipado.
Map<String, dynamic> decodificarMapaJson(String jsonBruto) {
  final Object? decodificado = jsonDecode(jsonBruto);
  if (decodificado is! Map<dynamic, dynamic>) {
    throw const FormatException('JSON esperado no formato de objeto.');
  }
  return Map<String, dynamic>.from(decodificado);
}
