class Cliente {
  int? id;
  String nome;
  String sexo;
  String? nascimento;
  String cpf;
  String endereco;
  String telefoneFixo;
  String telefoneCelular;
  String email;
  String dataCadastro;

  Cliente({
    this.id,
    required this.nome,
    required this.sexo,
    this.nascimento,
    required this.cpf,
    required this.endereco,
    required this.telefoneFixo,
    required this.telefoneCelular,
    required this.email,
    required this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sexo': sexo,
      'nascimento': nascimento,
      'cpf': cpf,
      'endereco': endereco,
      'telefoneFixo': telefoneFixo,
      'telefoneCelular': telefoneCelular,
      'email': email,
      'dataCadastro': dataCadastro,
    };
  }
}

