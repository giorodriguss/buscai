import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'register_screen.dart';

// TODO (back): importar o serviço de autenticação quando estiver pronto
// import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    // TODO (back): substituir pelo serviço real de autenticação.
    // Quando a API estiver pronta, trocar o bloco abaixo por:
    //
    // try {
    //   final user = await AuthService.login(
    //     email: _emailController.text.trim(),
    //     senha: _senhaController.text,
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
        const SnackBar(
          content: Text('Login simulado — integração com back pendente'),
          backgroundColor: AppColors.verde,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.papel,
      body: AnimatedBuilder(
        animation: _animController,
        builder: (_, child) => Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // Logo
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'Busca',
                          style: TextStyle(color: AppColors.verde),
                        ),
                        TextSpan(
                          text: 'í',
                          style: TextStyle(color: AppColors.laranja),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Bem-vindo de volta',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.cinza,
                    ),
                  ),

                  const SizedBox(height: 48),

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
                    hint: '••••••••',
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
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO (back): implementar fluxo de recuperação de senha
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: AppColors.laranja,
                      ),
                      child: const Text(
                        'Esqueci a senha',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  // Mensagem de erro vinda da API
                  if (_erro != null) ...[
                    const SizedBox(height: 8),
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
                    texto: 'Entrar',
                    carregando: _carregando,
                    onTap: _entrar,
                  ),

                  const SizedBox(height: 24),

                  const _Divisor(texto: 'ou'),

                  const SizedBox(height: 24),

                  // TODO (back): implementar OAuth com Google
                  _BotaoSecundario(
                    texto: 'Continuar com Google',
                    icone: Icons.g_mobiledata_rounded,
                    onTap: () {
                      // TODO (back): chamar AuthService.loginGoogle()
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google OAuth — pendente no back'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem conta? ',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          color: AppColors.cinza,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        ),
                        child: const Text(
                          'Criar conta',
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

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

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

class _BotaoSecundario extends StatelessWidget {
  final String texto;
  final IconData icone;
  final VoidCallback onTap;

  const _BotaoSecundario({
    required this.texto,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borda, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 22, color: AppColors.cinza),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.preto,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divisor extends StatelessWidget {
  final String texto;
  const _Divisor({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.borda)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            texto,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: AppColors.cinza,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.borda)),
      ],
    );
  }
}
