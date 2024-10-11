class OrdemServico {
  int tecnicoId;
  int clienteId;
  String status;
  String descricao;
  String dataAbertura;
  double valor;
  

  OrdemServico({
    required this.tecnicoId,
    required this.clienteId,
    required this.status,
    required this.descricao,
    required this.dataAbertura,
    required this.valor,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': tecnicoId,
      'cliente': clienteId,
      'status': status,
      'descricao': descricao,
      'data': dataAbertura,
      'valor': valor,
  };
}
}