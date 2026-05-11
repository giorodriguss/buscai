part of '../figma_flow.dart';

class AuthPage extends StatelessWidget {
  final bool showBack;
  final bool centered;
  final double logoSize;
  final String? appBarTitle;
  final String title;
  final String subtitle;
  final List<FieldSpec> fields;
  final Widget? forgot;
  final String primaryLabel;
  final Color primaryColor;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? footer;

  const AuthPage({
    super.key,
    this.showBack = false,
    this.centered = false,
    this.logoSize = 96,
    this.appBarTitle,
    required this.title,
    required this.subtitle,
    required this.fields,
    this.forgot,
    required this.primaryLabel,
    this.primaryColor = BColors.orange,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: showBack && appBarTitle != null ? _GreenAppBar(title: appBarTitle!) : null,
      body: SafeArea(
        top: appBarTitle == null,
        child: ListView(
          padding: EdgeInsets.fromLTRB(32, showBack && appBarTitle == null ? 22 : 86, 32, 28),
          children: [
            if (showBack && appBarTitle == null)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
            SizedBox(height: centered ? 28 : 10),
            Center(child: _LogoIcon(size: logoSize)),
            const SizedBox(height: 26),
            Text(
              title,
              textAlign: centered ? TextAlign.center : TextAlign.left,
              style: const TextStyle(
                color: BColors.black,
                fontFamily: 'Georgia',
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: centered ? TextAlign.center : TextAlign.left,
              style: const TextStyle(color: BColors.gray, height: 1.4),
            ),
            const SizedBox(height: 30),
            ...fields.map(
              (field) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextInputLike(
                  icon: field.icon,
                  hint: field.hint,
                  controller: field.controller,
                  keyboardType: field.keyboardType,
                  obscure: field.obscure,
                  errorText: field.errorText,
                  inputFormatters: field.inputFormatters,
                  onChanged: field.onChanged,
                  onEditingComplete: field.onEditingComplete,
                ),
              ),
            ),
            if (forgot != null) Align(alignment: Alignment.centerRight, child: forgot!),
            const SizedBox(height: 8),
            PrimaryButton(label: primaryLabel, color: primaryColor, onPressed: onPrimary),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onSecondary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BColors.green,
                    foregroundColor: BColors.paper,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700),
                  ),
                  child: Text(secondaryLabel!),
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 24),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

// Configuracao de um campo dentro do AuthPage. Se precisar ligar backend,
// mantenha o erro em errorText para continuar exibindo abaixo do campo.
class FieldSpec {
  final IconData icon;
  final String hint;
  final TextInputType keyboardType;
  final bool obscure;
  final TextEditingController? controller;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;

  const FieldSpec(
    this.icon,
    this.hint,
    this.keyboardType,
    this.obscure, {
    this.controller,
    this.errorText,
    this.inputFormatters,
    this.onEditingComplete,
    this.onChanged,
  });
}

class ProviderCard extends StatelessWidget {
  final Provider provider;
  final bool compact;

  const ProviderCard({super.key, required this.provider, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GestureDetector(
        onTap: () => openProvider(context, provider),
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(12),
          decoration: cardDecoration(radius: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(provider: provider, size: 52),
              const SizedBox(height: 10),
              Text(provider.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BColors.black)),
              const SizedBox(height: 3),
              Text(
                provider.category.toUpperCase(),
                style: const TextStyle(color: BColors.orange, fontSize: 11),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: BColors.orange),
                  const SizedBox(width: 4),
                  Text('${provider.rating}', style: const TextStyle(color: BColors.gray, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => openProvider(context, provider),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [BColors.green, BColors.greenDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(provider: provider, size: 54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    provider.category.toUpperCase(),
                    style: const TextStyle(color: BColors.orange, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: BColors.orange),
                      const SizedBox(width: 3),
                      Text('${provider.rating}', style: const TextStyle(color: Color(0xCCF7F4EF), fontSize: 12)),
                      const Text('  •  ', style: TextStyle(color: Color(0xCCF7F4EF), fontSize: 12)),
                      Text(provider.distance, style: const TextStyle(color: Color(0xCCF7F4EF), fontSize: 12)),
                      const Text('  •  ', style: TextStyle(color: Color(0xCCF7F4EF), fontSize: 12)),
                      Expanded(
                        child: Text(
                          provider.priceRange,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Color(0xCCF7F4EF), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: BColors.whatsapp, shape: BoxShape.circle),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCarousel extends StatefulWidget {
  final VoidCallback onCategory;

  const ServiceCarousel({super.key, required this.onCategory});

  @override
  State<ServiceCarousel> createState() => _ServiceCarouselState();
}

class _ServiceCarouselState extends State<ServiceCarousel> {
  int index = 0;
  Timer? timer;
  final services = const [
    (
      image: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800&h=400&fit=crop',
      title: 'Que tal fazer as unhas hoje?',
      subtitle: 'Manicures e pedicures perto de você',
    ),
    (
      image: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800&h=400&fit=crop',
      title: 'Problema elétrico?',
      subtitle: 'Eletricistas prontos para ajudar',
    ),
    (
      image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800&h=400&fit=crop',
      title: 'Casa brilhando em minutos',
      subtitle: 'Profissionais de limpeza confiáveis',
    ),
    (
      image: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800&h=400&fit=crop',
      title: 'Renove sua casa',
      subtitle: 'Pintores profissionais do seu bairro',
    ),
  ];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) setState(() => index = (index + 1) % services.length);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = services[index];
    return GestureDetector(
      onTap: widget.onCategory,
      child: Container(
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(service.image, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x22000000), Color(0xAA000000)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Georgia',
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(service.subtitle, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  services.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: i == index ? 24 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == index ? Colors.white : Colors.white.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  final int index;
  final bool showCollaborator;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.index,
    this.showCollaborator = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.home_rounded, 'Home'),
      (Icons.search_rounded, 'Buscar'),
      (Icons.favorite_border_rounded, 'Favoritos'),
      (Icons.person_outline_rounded, 'Perfil'),
      if (showCollaborator) (Icons.work_outline_rounded, 'Colaborador'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: BColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final active = i == index;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[i].$1, color: active ? BColors.orange : BColors.gray),
                const SizedBox(height: 3),
                Text(
                  items[i].$2,
                  style: TextStyle(
                    color: active ? BColors.orange : BColors.gray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final Provider provider;
  final double size;

  const Avatar({super.key, required this.provider, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size > 80 ? 4 : 0),
        image: DecorationImage(image: NetworkImage(provider.image), fit: BoxFit.cover),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.color = BColors.orange,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final String hint;
  final String? value;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchField({super.key, required this.hint, this.value, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      // Nao crie TextEditingController dentro do build para campos digitaveis:
      // isso recria selecao/cursor a cada letra e faz o texto entrar no começo.
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: 'Georgia'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Georgia'),
        prefixIcon: const Icon(Icons.search_rounded, color: BColors.orange),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.orange, width: 2),
        ),
      ),
    );
  }
}

// Campo padrao do app. Ele concentra mascara, erro, icone e fonte Georgia para
// os formularios ficarem consistentes entre login, cadastro e edicao.
class TextInputLike extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscure;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;

  const TextInputLike({
    super.key,
    required this.icon,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
    this.errorText,
    this.inputFormatters,
    this.onEditingComplete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      inputFormatters: inputFormatters,
      style: const TextStyle(fontFamily: 'Georgia'),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Georgia'),
        errorText: errorText,
        errorMaxLines: 2,
        prefixIcon: Icon(icon, color: BColors.gray),
        suffixIcon: suffixIcon == null ? null : Icon(suffixIcon, color: BColors.gray),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: BColors.orange, width: 2),
        ),
      ),
    );
  }
}

class HorizontalChips extends StatelessWidget {
  final List<String> values;
  final String? selected;
  final ValueChanged<String> onTap;

  const HorizontalChips({super.key, required this.values, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final value = values[index];
          final active = value == selected;
          return GestureDetector(
            onTap: () => onTap(value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: active ? BColors.green : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? BColors.green : BColors.border, width: 2),
              ),
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    color: active ? Colors.white : BColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: values.length,
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final double size;

  const SectionTitle(this.title, {super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: BColors.black,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _GreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PreferredSizeWidget? bottom;

  const _GreenAppBar({required this.title, this.bottom});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: BColors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      bottom: bottom,
    );
  }
}

class SimplePage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool bottomPadding;

  const SimplePage({super.key, required this.title, required this.child, this.bottomPadding = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding ? 110 : 28),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class CalendarPicker extends StatelessWidget {
  final List<String> hours;
  final String? selectedHour;
  final ValueChanged<String> onHour;

  const CalendarPicker({super.key, required this.hours, required this.selectedHour, required this.onHour});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Horários disponíveis', size: 18),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hours.map((hour) {
              final active = selectedHour == hour;
              return ChoiceChip(
                selected: active,
                label: Text(hour),
                selectedColor: BColors.green,
                labelStyle: TextStyle(color: active ? Colors.white : BColors.black),
                onSelected: (_) => onHour(hour),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Agenda exibida no detalhe do prestador. As datas ainda sao fixas para bater
// com o print; depois devem vir do calendario real/disponibilidade da API.
class BookingPicker extends StatelessWidget {
  final List<String> hours;
  final int selectedDate;
  final String? selectedHour;
  final ValueChanged<int> onDate;
  final ValueChanged<String> onHour;

  const BookingPicker({
    super.key,
    required this.hours,
    required this.selectedDate,
    required this.selectedHour,
    required this.onDate,
    required this.onHour,
  });

  static const _dates = [
    _BookingDate('Sáb.', '9', 'Hoje'),
    _BookingDate('Dom.', '10', ''),
    _BookingDate('Seg.', '11', ''),
    _BookingDate('Ter.', '12', ''),
    _BookingDate('Qua.', '13', ''),
    _BookingDate('Qui.', '14', ''),
    _BookingDate('Sex.', '15', ''),
    _BookingDate('Sáb.', '16', ''),
  ];

  @override
  Widget build(BuildContext context) {
    // Hoje esta fixo para bater com o prototipo. Backend/calendario real deve
    // gerar essa lista com datas disponiveis e bloquear dias sem atendimento.
    return Column(
      children: [
        _BookingCard(
          title: 'Escolha a data',
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 390 ? 5 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _dates.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: .66,
                ),
                itemBuilder: (_, index) {
                  final date = _dates[index];
                  final active = selectedDate == index;
                  return _DateChoice(
                    date: date,
                    active: active,
                    onTap: () => onDate(index),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _BookingCard(
          title: 'Escolha o horário',
          child: Wrap(
            spacing: 8,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: hours.map((hour) {
              final active = selectedHour == hour;
              return _HourChoice(
                hour: hour,
                active: active,
                onTap: () => onHour(hour),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _BookingDate {
  final String weekDay;
  final String day;
  final String caption;

  const _BookingDate(this.weekDay, this.day, this.caption);
}

class _BookingCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _BookingCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: cardDecoration(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title, size: 16),
          const SizedBox(height: 16),
          Center(child: child),
        ],
      ),
    );
  }
}

class _DateChoice extends StatelessWidget {
  final _BookingDate date;
  final bool active;
  final VoidCallback onTap;

  const _DateChoice({required this.date, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // A etiqueta "Hoje" fica fora do card, mas todos os itens reservam
          // essa altura. Isso impede que o card selecionado fique desalinhado.
          SizedBox(
            height: 18,
            child: date.caption.isEmpty
                ? null
                : Text(
                    date.caption,
                    style: const TextStyle(color: BColors.orange, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              decoration: BoxDecoration(
                color: active ? BColors.green : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: active ? BColors.green : BColors.border, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.weekDay,
                    style: TextStyle(color: active ? Colors.white : BColors.black, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    date.day,
                    style: TextStyle(color: active ? Colors.white : BColors.black, fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourChoice extends StatelessWidget {
  final String hour;
  final bool active;
  final VoidCallback onTap;

  const _HourChoice({required this.hour, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 100,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? BColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? BColors.green : BColors.border, width: 2),
        ),
        child: Text(
          hour,
          style: TextStyle(color: active ? Colors.white : BColors.black, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class ServiceOption extends StatelessWidget {
  final Service service;
  final bool selected;
  final VoidCallback onTap;

  const ServiceOption({super.key, required this.service, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? BColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? BColors.green : BColors.border, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                service.name,
                style: TextStyle(
                  color: selected ? Colors.white : BColors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              'R\$ ${service.price}',
              style: TextStyle(
                color: selected ? Colors.white : BColors.orange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const StatPill({super.key, required this.icon, required this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(color: BColors.gray, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(review.name, style: const TextStyle(fontWeight: FontWeight.w700))),
              ...List.generate(
                review.rating,
                (_) => const Icon(Icons.star_rounded, color: BColors.orange, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review.date, style: const TextStyle(color: BColors.gray, fontSize: 12)),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(height: 1.45)),
        ],
      ),
    );
  }
}

class EmptyPanel extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyPanel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 70),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(color: BColors.border, shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: BColors.gray),
            ),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: BColors.gray)),
          ],
        ),
      ),
    );
  }
}

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyPanel(
      icon: Icons.search_rounded,
      text: 'Nenhum prestador encontrado',
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ServiceHistoryItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = item.provider;
    final service = item.service;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          Avatar(provider: provider, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${provider.name} • ${provider.category}', style: const TextStyle(color: BColors.gray, fontSize: 12)),
                const SizedBox(height: 8),
                Text(item.date, style: const TextStyle(color: BColors.gray, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${service.price}', style: const TextStyle(color: BColors.green, fontWeight: FontWeight.w700)),
              const SizedBox(height: 28),
              const Text('☆ Avaliar', style: TextStyle(color: BColors.orange, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SettingsRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: BColors.paper,
              child: Icon(icon, color: BColors.green),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right_rounded, color: BColors.gray),
          ],
        ),
      ),
    );
  }
}

class AddressTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const AddressTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.selected = false,
    this.icon = Icons.location_on_outlined,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? BColors.green : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? BColors.green : BColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: selected ? BColors.green : BColors.paper,
              child: Icon(icon, color: selected ? Colors.white : BColors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? Colors.black : BColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: selected ? Colors.white70 : BColors.gray, fontSize: 14, height: 1.35),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Alterar endereço',
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_location_alt_outlined,
                color: selected ? Colors.white : BColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthFooter extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;

  const _AuthFooter({required this.text, required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$text ', style: const TextStyle(color: BColors.gray, fontFamily: 'Georgia')),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(color: BColors.orange, fontFamily: 'Georgia'),
          ),
        ),
      ],
    );
  }
}

class CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool white;

  const CircleButton({super.key, required this.icon, required this.onTap, this.white = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: white ? Colors.white : BColors.paper,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 10)],
        ),
        child: Icon(icon, color: BColors.black),
      ),
    );
  }
}

class _GreenGradient extends StatelessWidget {
  final Widget child;

  const _GreenGradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [BColors.green, BColors.green, BColors.greenDark],
        ),
      ),
      child: child,
    );
  }
}

class _LogoText extends StatelessWidget {
  final Color color;
  final double size;
  final bool dot;

  const _LogoText({required this.color, required this.size, this.dot = false});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: color,
          fontFamily: 'Georgia',
          fontSize: size,
          fontWeight: FontWeight.w700,
          shadows: const [Shadow(color: Color(0x55000000), blurRadius: 20, offset: Offset(0, 4))],
        ),
        children: [
          const TextSpan(text: 'Busca'),
          const TextSpan(text: 'í', style: TextStyle(color: BColors.orange)),
          if (dot) const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  final double size;

  const _LogoIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset('assets/images/buscai_icon_verde.png', fit: BoxFit.contain),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(color: BColors.orange, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class _FloatingDots extends StatelessWidget {
  const _FloatingDots();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        8,
        (index) => Positioned(
          left: (index * 47) % 360,
          top: 80.0 + (index * 73) % 620,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .04),
            ),
          ),
        ),
      ),
    );
  }
}

BoxDecoration cardDecoration({required double radius}) {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: BColors.border),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2)),
    ],
  );
}

void openProvider(BuildContext context, Provider provider) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => ProviderProfileScreen(provider: provider)),
  );
}
