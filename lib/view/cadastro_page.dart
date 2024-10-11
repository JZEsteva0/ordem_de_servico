import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; 
import 'package:ordem_servico/database.dart';
import 'package:ordem_servico/models/cliente_models.dart';
import 'package:intl/intl.dart'; 

class CadastroClientePage extends StatefulWidget {
  @override
  _CadastroClientePageState createState() => _CadastroClientePageState();
}
  // Classe onde define os parâmetros da Model
class _CadastroClientePageState extends State<CadastroClientePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = MaskedTextController(mask: '000.000.000-00');
  final _telefoneFixoController = MaskedTextController(mask: '(00)0000-0000');
  final _telefoneCelularController = MaskedTextController(mask: '(00)00000-0000');
  final _emailController = TextEditingController();
  String _sexo = 'Masculino';
  DateTime _dataCadastro = DateTime.now();
  DateTime? _dataNascimento;

  // Método para selecionar a data de nascimento
  Future<void> _selecionarDataNascimento(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dataNascimento) {
      setState(() {
        _dataNascimento = picked;
      });
    }
  }
  // Função para salvar o cadastro do cliente
  void _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      final cliente = Cliente(
        nome: _nomeController.text,
        sexo: _sexo,
        nascimento: _dataNascimento != null
            ? DateFormat('yyyy-MM-dd').format(_dataNascimento!)
            : null,
        cpf: _cpfController.text,
        endereco: 'Rua Exemplo, Bairro, Número, CEP',
        telefoneFixo: _telefoneFixoController.text,
        telefoneCelular: _telefoneCelularController.text,
        email: _emailController.text,
        dataCadastro: DateFormat('yyyy-MM-dd').format(_dataCadastro),
      );

  // Insere o cliente no BDD
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      await db.insert('clientes', cliente.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cliente cadastrado com sucesso!')),
      );
      // Limpa os campos após o cadastro
      _formKey.currentState!.reset();
    }
  }

  // Aqui é a formatação dos elementos que serão exibidos na tela do usuário
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Cliente'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo de Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                
                // Campo de CPF
                TextFormField(
                  controller: _cpfController,
                  decoration: InputDecoration(labelText: 'CPF'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 14) {
                      return 'Por favor, insira um CPF válido';
                    }
                    return null;
                  },
                ),

                // Campo de Sexo
                DropdownButtonFormField<String>(
                  value: _sexo,
                  onChanged: (value) {
                    setState(() {
                      _sexo = value!;
                    });
                  },
                  items: ['Masculino', 'Feminino'].map((String sexo) {
                    return DropdownMenuItem(
                      value: sexo,
                      child: Text(sexo),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Sexo'),
                ),

                // Campo de Data de Nascimento
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dataNascimento == null
                            ? 'Data de Nascimento não selecionada'
                            : DateFormat('dd/MM/yyyy').format(_dataNascimento!),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _selecionarDataNascimento(context),
                      child: Text('Selecionar Data'),
                    ),
                  ],
                ),

                // Campo de Telefone Fixo
                TextFormField(
                  controller: _telefoneFixoController,
                  decoration: InputDecoration(labelText: 'Telefone Fixo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o telefone fixo';
                    }
                    return null;
                  },
                ),

                // Campo de Telefone Celular
                TextFormField(
                  controller: _telefoneCelularController,
                  decoration: InputDecoration(labelText: 'Telefone Celular'),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 15) {
                      return 'Por favor, insira um celular válido';
                    }
                    return null;
                  },
                ),

                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),

                // Botão de Salvar
                ElevatedButton(
                  onPressed: _salvarCliente,
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
