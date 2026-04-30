import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

// TODO (back): importar o serviço de autenticação quando estiver pronto
// import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // 'morador' ou 'prestador'
  String _tipoConta = 'morador';
  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _erro;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    // TODO (back): substituir pelo serviço real de cadastro.
    // Quando a API estiver pronta, trocar o bloco abaixo por:
    //
    // try {
    //   await AuthService.register(
    //     nome: _nomeController.text.trim(),
    //     email: _emailController.text.trim(),
    //     senha: _senhaController.text,
    //     tipo: _tipoConta, // 'morador' ou 'prestador'
    //   );
    //   if (mounted) Navigator.pushReplacementNamed(context, '/home');
    // } on AuthException catch (e) {
    //   setState(() => _erro = e.message);
    // } finally {
    //   setState(() => _carregando = false);
    // }

    // SIMULAÇÃO TEMPORÁRIA — remover quando o back estiver pronto
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cadastro simulado ($_tipoConta) — integração com back pendente',
          ),
          backgroundColor: AppColors.verde,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.papel,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.preto),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (_, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Título
                const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.5,
                    color: AppColors.verde,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Escolha como quer usar o Buscaí',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.cinza,
                  ),
                ),

                const SizedBox(height: 32),

                // Seletor de tipo de conta
                const _FieldLabel('Tipo de conta'),
                const SizedBox(height: 12),
                _SeletorTipo(
                  selecionado: _tipoConta,
                  onChanged: (tipo) => setState(() => _tipoConta = tipo),
                ),

                const SizedBox(height: 28),

                const _FieldLabel('Nome completo'),
                const SizedBox(height: 8),
                _CampoTexto(
                  controller: _nomeController,
                  hint: 'Seu nome',
                  teclado: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Informe seu nome';
                    }
                    if (v.trim().split(' ').length < 2) {
                      return 'Informe nome e sobrenome';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const _FieldLabel('E-mail'),
                const SizedBox(height: 8),
                _CampoTexto(
                  controller: _emailController,
                  hint: 'seu@email.com',
                  teclado: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const _FieldLabel('Senha'),
                const SizedBox(height: 8),
                _CampoTexto(
                  controller: _senhaController,
                  hint: 'Mínimo 6 caracteres',
                  obscure: !_senhaVisivel,
                  sufixo: GestureDetector(
                    onTap: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                    child: Icon(
                      _senhaVisivel
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.cinza,
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe uma senha';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const _FieldLabel('Confirmar senha'),
                const SizedBox(height: 8),
                _CampoTexto(
                  controller: _confirmarSenhaController,
                  hint: 'Repita a senha',
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirme a senha';
                    if (v != _senhaController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),

                // Campos extras só para prestador
                if (_tipoConta == 'prestador') ...[
                  const SizedBox(height: 20),
                  const _FieldLabel('WhatsApp'),
                  const SizedBox(height: 8),
                  // TODO (back): esse número será usado para o deep link wa.me
                  _CampoTexto(
                    controller: TextEditingController(),
                    hint: '(00) 00000-0000',
                    teclado: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Informe o WhatsApp';
                      }
                      return null;
                    },
                  ),
                ],

                // Erro da API
                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.laranja.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AppColors.laranja),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _erro!,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              color: AppColors.laranja,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                _BotaoPrimario(
                  texto: 'Criar conta',
                  carregando: _carregando,
                  onTap: _cadastrar,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem conta? ',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 14,
                        color: AppColors.cinza,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.laranja,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Seletor morador / prestador ─────────────────────────────────────────────

class _SeletorTipo extends StatelessWidget {
  final String selecionado;
  final ValueChanged<String> onChanged;

  const _SeletorTipo({
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CardTipo(
            titulo: 'Morador',
            subtitulo: 'Quero encontrar serviços',
            icone: Icons.home_outlined,
            selecionado: selecionado == 'morador',
            onTap: () => onChanged('morador'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CardTipo(
            titulo: 'Prestador',
            subtitulo: 'Quero oferecer serviços',
            icone: Icons.handyman_outlined,
            selecionado: selecionado == 'prestador',
            onTap: () => onChanged('prestador'),
          ),
        ),
      ],
    );
  }
}

class _CardTipo extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icone;
  final bool selecionado;
  final VoidCallback onTap;

  const _CardTipo({
    required this.titulo,
    required this.subtitulo,
    required this.icone,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selecionado ? AppColors.verde : AppColors.branco,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selecionado ? AppColors.verde : AppColors.borda,
            width: selecionado ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icone,
              size: 22,
              color: selecionado ? AppColors.laranja : AppColors.cinza,
            ),
            const SizedBox(height: 10),
            Text(
              titulo,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selecionado ? Colors.white : AppColors.preto,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitulo,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: selecionado
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.cinza,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets reutilizáveis (mesmos do login) ─────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String texto;
  const _FieldLabel(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.preto,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType teclado;
  final Widget? sufixo;
  final String? Function(String?)? validator;

  const _CampoTexto({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.teclado = TextInputType.text,
    this.sufixo,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: teclado,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'DMSans',
        fontSize: 15,
        color: AppColors.preto,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 15,
          color: AppColors.cinza.withOpacity(0.6),
        ),
        suffixIcon: sufixo != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12),
                child: sufixo,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.branco,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borda, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borda, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.verde, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppColors.laranja.withOpacity(0.6), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.laranja, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12,
          color: AppColors.laranja,
        ),
      ),
    );
  }
}

class _BotaoPrimario extends StatelessWidget {
  final String texto;
  final bool carregando;
  final VoidCallback onTap;

  const _BotaoPrimario({
    required this.texto,
    required this.carregando,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: carregando ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: carregando
              ? AppColors.verde.withOpacity(0.7)
              : AppColors.verde,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: carregando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  texto,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
