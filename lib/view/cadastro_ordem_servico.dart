import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ordem_servico/database.dart';
import 'package:ordem_servico/models/ordem_servico_models.dart';

class CadastroOS extends StatefulWidget {
  @override
  _CadastroOSPageState createState() => _CadastroOSPageState();
}

class  _CadastroOSPageState extends State<CadastroOS> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _clienteController = TextEditingController();
  final _tecnicoController = TextEditingController();
  List<Map<String, dynamic>> _produtos = [];

  DateTime _dataAbertura = DateTime.now();

  // Função para salvar a ordem de serviço
  void _salvarOrdemServico() async {
    if (_formKey.currentState!.validate()) {
      try {
        final ordemServico = OrdemServico(
          clienteId: int.parse(_clienteController.text),
          tecnicoId: int.parse(_tecnicoController.text),
          descricao: _descricaoController.text,
          dataAbertura: DateFormat('yyyy-MM-dd').format(_dataAbertura),
          status: 'Aberto',
          valor: double.parse(_valorController.text),
        );

        final dbHelper = DatabaseHelper();
        final db = await dbHelper.database;

        // Insere a ordem de serviço no BDD
        final ordemId = await db.insert('ordens_de_servico', ordemServico.toMap());

        // Atualiza o estoque de produtos
        for (var produto in _produtos) {
          await db.update(
            'produtos',
            {'quantidade': produto['quantidade'] - produto['usado']},
            where: 'id = ?',
            whereArgs: [produto['id']],
          );

          // Relaciona os produtos à ordem
          await db.insert('ordem_produto', {
            'ordem_id': ordemId,
            'produto_id': produto['id'],
            'quantidade': produto['usado'],
          });
        }

        // Gera a conta a receber
        await db.insert('contas_receber', {
          'ordem_id': ordemId,
          'valor': ordemServico.valor,
          'vencimento': DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: 30))),
          'pago': 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ordem de serviço cadastrada com sucesso!')),
        );

        // Limpa os campos após o cadastro
        _formKey.currentState!.reset();
        _descricaoController.clear();
        _valorController.clear();
        _clienteController.clear();
        _tecnicoController.clear();
        setState(() {
          _produtos.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar a ordem de serviço. Verifique os dados.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro de Ordem de Serviço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _clienteController,
                  decoration: InputDecoration(labelText: 'Cliente ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o ID do cliente';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Insira um número válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tecnicoController,
                  decoration: InputDecoration(labelText: 'Técnico ID'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o ID do técnico';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Insira um número válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a descrição da ordem';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o valor';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Insira um valor numérico válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _salvarOrdemServico,
                  child: Text('Salvar Ordem de Serviço'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
