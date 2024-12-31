import 'package:flutter/material.dart';

class BackgroundPermissionHelper extends StatelessWidget {

  const BackgroundPermissionHelper({
    Key? key,
  }) : super(key: key);


  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackgroundPermissionHelper();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
          'Atenção'
      ),
      content: Text('Para o rastreamento funcionar corretamente em segundo plano, selecione a opção'
          ' "Permitir o tempo todo". Permitir apenas "Durante o uso do app" '
          'pode causar falhas quando o app estiver em segundo plano.'
          ' Para alterar manualmente, vá em Configurações -> aplicativos -> EasyWay -> Permissões -> Localização'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Entendi'),
        ),
      ],
    );
  }
}
