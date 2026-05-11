import 'package:buscai/screens/figma_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  ProviderServiceDraft _draft({String name = 'Serviço', String price = '100', String duration = '1h'}) =>
      ProviderServiceDraft(name: name, price: price, duration: duration);

  group('estado inicial', () {
    test('começa com 3 serviços cadastrados', () {
      expect(container.read(collaboratorProvider).services.length, equals(3));
    });

    test('começa com 5 dias disponíveis (segunda a sexta)', () {
      expect(container.read(collaboratorProvider).days.length, equals(5));
    });

    test('começa com 7 horários disponíveis', () {
      expect(container.read(collaboratorProvider).hours.length, equals(7));
    });

    test('começa com 4 fotos no portfólio', () {
      expect(container.read(collaboratorProvider).portfolio.length, equals(4));
    });

    test('começa com categoria ENCANADOR', () {
      expect(container.read(collaboratorProvider).category, equals('ENCANADOR'));
    });

    test('começa com 10 anos de experiência', () {
      expect(container.read(collaboratorProvider).years, equals(10));
    });

    test('começa com dias Segunda a Sexta', () {
      final days = container.read(collaboratorProvider).days;
      expect(days, containsAll(['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta']));
    });
  });

  group('setYears', () {
    test('atualiza os anos de experiência', () {
      container.read(collaboratorProvider.notifier).setYears(15);
      expect(container.read(collaboratorProvider).years, equals(15));
    });

    test('aceita 0 anos', () {
      container.read(collaboratorProvider.notifier).setYears(0);
      expect(container.read(collaboratorProvider).years, equals(0));
    });

    test('não altera outros campos do estado', () {
      final categoriaAntes = container.read(collaboratorProvider).category;
      container.read(collaboratorProvider.notifier).setYears(5);
      expect(container.read(collaboratorProvider).category, equals(categoriaAntes));
    });
  });

  group('setCoverImage', () {
    test('atualiza a URL da imagem de capa', () {
      const url = 'https://example.com/nova-capa.jpg';
      container.read(collaboratorProvider.notifier).setCoverImage(url);
      expect(container.read(collaboratorProvider).coverImage, equals(url));
    });

    test('substitui a capa anterior ao chamar novamente', () {
      container.read(collaboratorProvider.notifier).setCoverImage('https://first.jpg');
      container.read(collaboratorProvider.notifier).setCoverImage('https://second.jpg');
      expect(container.read(collaboratorProvider).coverImage, equals('https://second.jpg'));
    });
  });

  group('setProfileColor', () {
    test('atualiza a cor do perfil para laranja', () {
      container.read(collaboratorProvider.notifier).setProfileColor(Colors.orange);
      expect(container.read(collaboratorProvider).profileColor, equals(Colors.orange));
    });

    test('atualiza a cor do perfil para verde', () {
      container.read(collaboratorProvider.notifier).setProfileColor(Colors.green);
      expect(container.read(collaboratorProvider).profileColor, equals(Colors.green));
    });
  });

  group('setAbout', () {
    test('atualiza o texto sobre o colaborador', () {
      const bio = 'Especialista em hidráulica com 15 anos de experiência.';
      container.read(collaboratorProvider.notifier).setAbout(bio);
      expect(container.read(collaboratorProvider).about, equals(bio));
    });

    test('aceita string vazia', () {
      container.read(collaboratorProvider.notifier).setAbout('');
      expect(container.read(collaboratorProvider).about, equals(''));
    });

    test('não altera os serviços ao atualizar bio', () {
      final totalAntes = container.read(collaboratorProvider).services.length;
      container.read(collaboratorProvider.notifier).setAbout('Nova bio');
      expect(container.read(collaboratorProvider).services.length, equals(totalAntes));
    });
  });

  group('addService', () {
    test('incrementa a contagem de serviços em 1', () {
      final antes = container.read(collaboratorProvider).services.length;
      container.read(collaboratorProvider.notifier).addService(_draft(name: 'Novo'));
      expect(container.read(collaboratorProvider).services.length, equals(antes + 1));
    });

    test('insere o novo serviço no início da lista', () {
      container.read(collaboratorProvider.notifier).addService(_draft(name: 'Primeiro adicionado'));
      expect(container.read(collaboratorProvider).services.first.name, equals('Primeiro adicionado'));
    });

    test('preserva os serviços existentes após adição', () {
      final nomeAntes = container.read(collaboratorProvider).services.first.name;
      container.read(collaboratorProvider.notifier).addService(_draft(name: 'Extra'));
      expect(container.read(collaboratorProvider).services[1].name, equals(nomeAntes));
    });

    test('armazena price e duration corretamente', () {
      container.read(collaboratorProvider.notifier).addService(_draft(name: 'Pintura', price: '250', duration: '3h'));
      final added = container.read(collaboratorProvider).services.first;
      expect(added.price, equals('250'));
      expect(added.duration, equals('3h'));
    });
  });

  group('editService', () {
    test('substitui o serviço no índice 0', () {
      container.read(collaboratorProvider.notifier).editService(0, _draft(name: 'Serviço Editado'));
      expect(container.read(collaboratorProvider).services[0].name, equals('Serviço Editado'));
    });

    test('não altera a quantidade de serviços', () {
      final antes = container.read(collaboratorProvider).services.length;
      container.read(collaboratorProvider.notifier).editService(0, _draft());
      expect(container.read(collaboratorProvider).services.length, equals(antes));
    });

    test('não altera o serviço no índice 1 ao editar o índice 0', () {
      final nomeIndex1 = container.read(collaboratorProvider).services[1].name;
      container.read(collaboratorProvider.notifier).editService(0, _draft(name: 'Alterado'));
      expect(container.read(collaboratorProvider).services[1].name, equals(nomeIndex1));
    });

    test('edita o serviço no índice 2 corretamente', () {
      container.read(collaboratorProvider.notifier).editService(2, _draft(name: 'Último editado'));
      expect(container.read(collaboratorProvider).services[2].name, equals('Último editado'));
    });
  });

  group('removeService', () {
    test('decrementa a contagem de serviços em 1', () {
      final antes = container.read(collaboratorProvider).services.length;
      container.read(collaboratorProvider.notifier).removeService(0);
      expect(container.read(collaboratorProvider).services.length, equals(antes - 1));
    });

    test('remove o serviço correto: índice 1 é substituído pelo que era índice 2', () {
      final nomeIndex2 = container.read(collaboratorProvider).services[2].name;
      container.read(collaboratorProvider.notifier).removeService(1);
      expect(container.read(collaboratorProvider).services[1].name, equals(nomeIndex2));
    });

    test('pode remover o último serviço restante', () {
      container.read(collaboratorProvider.notifier).removeService(2);
      container.read(collaboratorProvider.notifier).removeService(1);
      container.read(collaboratorProvider.notifier).removeService(0);
      expect(container.read(collaboratorProvider).services, isEmpty);
    });
  });

  group('setDays', () {
    test('substitui completamente os dias disponíveis', () {
      container.read(collaboratorProvider.notifier).setDays({'Sábado', 'Domingo'});
      expect(container.read(collaboratorProvider).days, equals({'Sábado', 'Domingo'}));
    });

    test('aceita conjunto vazio (sem disponibilidade)', () {
      container.read(collaboratorProvider.notifier).setDays({});
      expect(container.read(collaboratorProvider).days, isEmpty);
    });

    test('não inclui dias anteriores após substituição', () {
      container.read(collaboratorProvider.notifier).setDays({'Sábado'});
      expect(container.read(collaboratorProvider).days, isNot(contains('Segunda')));
    });
  });

  group('setHours', () {
    test('substitui completamente os horários disponíveis', () {
      container.read(collaboratorProvider.notifier).setHours({'08:00', '09:00', '10:00'});
      expect(container.read(collaboratorProvider).hours, equals({'08:00', '09:00', '10:00'}));
    });

    test('aceita conjunto vazio (sem disponibilidade)', () {
      container.read(collaboratorProvider.notifier).setHours({});
      expect(container.read(collaboratorProvider).hours, isEmpty);
    });

    test('não inclui horários anteriores após substituição', () {
      container.read(collaboratorProvider.notifier).setHours({'20:00'});
      expect(container.read(collaboratorProvider).hours, isNot(contains('08:00')));
    });
  });

  group('addPortfolioPhoto', () {
    test('incrementa a contagem do portfólio em 1', () {
      final antes = container.read(collaboratorProvider).portfolio.length;
      container.read(collaboratorProvider.notifier).addPortfolioPhoto('https://example.com/foto.jpg');
      expect(container.read(collaboratorProvider).portfolio.length, equals(antes + 1));
    });

    test('insere a nova foto no início do portfólio', () {
      const url = 'https://example.com/nova-foto.jpg';
      container.read(collaboratorProvider.notifier).addPortfolioPhoto(url);
      expect(container.read(collaboratorProvider).portfolio.first, equals(url));
    });

    test('preserva as fotos existentes', () {
      final primeiraAntes = container.read(collaboratorProvider).portfolio.first;
      container.read(collaboratorProvider.notifier).addPortfolioPhoto('https://nova.jpg');
      expect(container.read(collaboratorProvider).portfolio[1], equals(primeiraAntes));
    });
  });

  group('removePortfolioPhoto', () {
    test('decrementa a contagem do portfólio em 1', () {
      final antes = container.read(collaboratorProvider).portfolio.length;
      container.read(collaboratorProvider.notifier).removePortfolioPhoto(0);
      expect(container.read(collaboratorProvider).portfolio.length, equals(antes - 1));
    });

    test('remove a foto correta: índice 1 é substituído pelo que era índice 2', () {
      final urlIndex2 = container.read(collaboratorProvider).portfolio[2];
      container.read(collaboratorProvider.notifier).removePortfolioPhoto(1);
      expect(container.read(collaboratorProvider).portfolio[1], equals(urlIndex2));
    });
  });

  group('reset', () {
    test('limpa todos os serviços', () {
      container.read(collaboratorProvider.notifier).reset('Pintor');
      expect(container.read(collaboratorProvider).services, isEmpty);
    });

    test('limpa todos os dias disponíveis', () {
      container.read(collaboratorProvider.notifier).reset('Pintor');
      expect(container.read(collaboratorProvider).days, isEmpty);
    });

    test('limpa todos os horários disponíveis', () {
      container.read(collaboratorProvider.notifier).reset('Pintor');
      expect(container.read(collaboratorProvider).hours, isEmpty);
    });

    test('limpa todo o portfólio', () {
      container.read(collaboratorProvider.notifier).reset('Pintor');
      expect(container.read(collaboratorProvider).portfolio, isEmpty);
    });

    test('define a categoria em maiúsculas a partir do argumento', () {
      container.read(collaboratorProvider.notifier).reset('Pintor');
      expect(container.read(collaboratorProvider).category, equals('PINTOR'));
    });

    test('zera os anos de experiência', () {
      container.read(collaboratorProvider.notifier).setYears(20);
      container.read(collaboratorProvider.notifier).reset('Eletricista');
      expect(container.read(collaboratorProvider).years, equals(0));
    });

    test('limpa o texto sobre o colaborador', () {
      container.read(collaboratorProvider.notifier).setAbout('Bio antiga');
      container.read(collaboratorProvider.notifier).reset('Eletricista');
      expect(container.read(collaboratorProvider).about, equals(''));
    });

    test('diferentes categorias são convertidas para maiúsculas corretamente', () {
      container.read(collaboratorProvider.notifier).reset('Diarista');
      expect(container.read(collaboratorProvider).category, equals('DIARISTA'));
    });
  });
}
