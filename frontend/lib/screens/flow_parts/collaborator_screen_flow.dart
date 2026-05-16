part of '../figma_flow.dart';

class CollaboratorScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const CollaboratorScreen({super.key, required this.user});

  @override
  ConsumerState<CollaboratorScreen> createState() => _CollaboratorScreenState();
}

class _CollaboratorScreenState extends ConsumerState<CollaboratorScreen> {
  bool editingYears = false;
  bool editingAbout = false;
  bool addingService = false;
  int? editingService;
  final yearsController = TextEditingController();
  final aboutController = TextEditingController();
  final serviceNameController = TextEditingController();
  final servicePriceController = TextEditingController();
  final serviceDurationController = TextEditingController();
  String? serviceNameError;
  String? servicePriceError;
  String? serviceDurationError;

  @override
  void dispose() {
    yearsController.dispose();
    aboutController.dispose();
    serviceNameController.dispose();
    servicePriceController.dispose();
    serviceDurationController.dispose();
    super.dispose();
  }

  void _startServiceEdit([int? index]) {
    setState(() {
      editingService = index;
      addingService = true;
      final service =
          index == null ? null : ref.read(collaboratorProvider).services[index];
      serviceNameController.text = service?.name ?? '';
      servicePriceController.text = service?.price ?? '';
      serviceDurationController.text =
          service?.duration.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      serviceNameError = null;
      servicePriceError = null;
      serviceDurationError = null;
    });
  }

  void _saveService() {
    final name = serviceNameController.text.trim();
    final priceValue = int.tryParse(
          servicePriceController.text.replaceAll(RegExp(r'\D'), ''),
        ) ??
        0;
    final hoursValue = int.tryParse(
          serviceDurationController.text.replaceAll(RegExp(r'\D'), ''),
        ) ??
        0;
    setState(() {
      serviceNameError = name.isEmpty ? 'Informe o nome do serviço' : null;
      servicePriceError =
          priceValue <= 0 ? 'Informe um valor maior que zero' : null;
      serviceDurationError =
          hoursValue <= 0 ? 'Informe a duração em horas' : null;
    });
    if (serviceNameError != null ||
        servicePriceError != null ||
        serviceDurationError != null) {
      return;
    }
    final service = ProviderServiceDraft(
      name: name,
      price: '$priceValue',
      duration: '${hoursValue}h',
    );
    // Futuro backend: criar/editar services do prestador via API.
    // Hoje mantemos em collaboratorProvider para prototipagem local.
    final index = editingService;
    if (index == null) {
      ref.read(collaboratorProvider.notifier).addService(service);
    } else {
      ref.read(collaboratorProvider.notifier).editService(index, service);
    }
    setState(() {
      addingService = false;
      editingService = null;
      serviceNameError = null;
      servicePriceError = null;
      serviceDurationError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final collab = ref.watch(collaboratorProvider);
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            _CollaboratorCover(image: collab.coverImage),
            Positioned(
              left: 20,
              bottom: -54,
              child: CircleAvatar(
                radius: 62,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  child: _UserAvatar(user: user, radius: 56),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 72, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(_displayProfileName(user.name),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700))),
                  CircleButton(
                    icon: Icons.settings_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              EditProviderProfileScreen(user: user)),
                    ),
                  ),
                ],
              ),
              Text(
                  collab.category.isEmpty
                      ? 'DEFINA SUA CATEGORIA'
                      : collab.category,
                  style: const TextStyle(
                      color: BColors.orange, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                            radius: 24,
                            backgroundColor: BColors.orange,
                            child:
                                Icon(Icons.star_rounded, color: Colors.white)),
                        SizedBox(height: 8),
                        Text('0.0',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('0 avaliações',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: BColors.gray, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const CircleAvatar(
                            radius: 24,
                            backgroundColor: BColors.green,
                            child: Icon(Icons.emoji_events_outlined,
                                color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('${collab.years} anos',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        const Text('Experiência',
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: BColors.gray, fontSize: 12)),
                        GestureDetector(
                          onTap: () => setState(() {
                            yearsController.text = '${collab.years}';
                            editingYears = true;
                          }),
                          child: const Text('Editar',
                              style: TextStyle(
                                  color: BColors.green, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (editingYears)
                _InlineEditor(
                  title: 'Editar anos de experiência',
                  children: [
                    TextInputLike(
                        icon: Icons.emoji_events_outlined,
                        hint: '10',
                        controller: yearsController,
                        keyboardType: TextInputType.number)
                  ],
                  onSave: () {
                    ref.read(collaboratorProvider.notifier).setYears(
                          int.tryParse(yearsController.text) ?? collab.years,
                        );
                    setState(() => editingYears = false);
                  },
                  onCancel: () => setState(() => editingYears = false),
                ),
              const Divider(height: 32),
              _EditableSectionTitle(
                title: 'Sobre',
                onEdit: () => setState(() {
                  aboutController.text = collab.about;
                  editingAbout = true;
                }),
              ),
              if (editingAbout)
                _InlineEditor(
                  title: '',
                  children: [
                    TextInputLike(
                        icon: Icons.info_outline_rounded,
                        hint: 'Sobre você',
                        controller: aboutController)
                  ],
                  onSave: () {
                    ref
                        .read(collaboratorProvider.notifier)
                        .setAbout(aboutController.text.trim());
                    setState(() => editingAbout = false);
                  },
                  onCancel: () => setState(() => editingAbout = false),
                )
              else
                collab.about.trim().isEmpty
                    ? const EmptyPanel(
                        icon: Icons.info_outline_rounded,
                        text: 'Preencha seu resumo profissional.')
                    : Text(collab.about, style: const TextStyle(height: 1.55)),
              const SizedBox(height: 26),
              _EditableSectionTitle(
                  title: 'Serviços',
                  action: '+ Cadastrar novo',
                  onEdit: () => _startServiceEdit()),
              if (addingService)
                _ServiceEditor(
                  title: editingService == null
                      ? 'Novo serviço'
                      : 'Editar serviço',
                  nameController: serviceNameController,
                  priceController: servicePriceController,
                  durationController: serviceDurationController,
                  nameError: serviceNameError,
                  priceError: servicePriceError,
                  durationError: serviceDurationError,
                  onNameChanged: (_) => setState(() => serviceNameError = null),
                  onPriceChanged: (_) =>
                      setState(() => servicePriceError = null),
                  onDurationChanged: (_) =>
                      setState(() => serviceDurationError = null),
                  onSave: _saveService,
                  onCancel: () => setState(() {
                    addingService = false;
                    serviceNameError = null;
                    servicePriceError = null;
                    serviceDurationError = null;
                  }),
                ),
              if (collab.services.isEmpty && !addingService)
                const EmptyPanel(
                    icon: Icons.work_outline_rounded,
                    text: 'Cadastre seus serviços para eles aparecerem aqui.')
              else
                ...List.generate(collab.services.length, (index) {
                  final service = collab.services[index];
                  return _CollaboratorServiceCard(
                    service: service,
                    onEdit: () => _startServiceEdit(index),
                    onDelete: () => ref
                        .read(collaboratorProvider.notifier)
                        .removeService(index),
                  );
                }),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Dias disponíveis',
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AvailabilityDaysScreen()),
                ),
              ),
              collab.days.isEmpty
                  ? const EmptyPanel(
                      icon: Icons.calendar_today_outlined,
                      text: 'Escolha seus dias de atendimento.')
                  : _Pills(values: collab.days.toList()),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Horários disponíveis',
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const AvailabilityHoursScreen()),
                ),
              ),
              collab.hours.isEmpty
                  ? const EmptyPanel(
                      icon: Icons.schedule_rounded,
                      text: 'Escolha seus horários de atendimento.')
                  : _Pills(values: collab.hours.toList()..sort()),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Portfólio',
                action: 'Gerenciar',
                onEdit: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const PortfolioManagerScreen()),
                ),
              ),
              if (collab.portfolio.isEmpty)
                const EmptyPanel(
                    icon: Icons.photo_library_outlined,
                    text: 'Adicione fotos para montar seu portfólio.')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: collab.portfolio.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12),
                  itemBuilder: (_, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image(
                        image: _imageProviderFromValue(collab.portfolio[index]),
                        fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 28),
              const SectionTitle('Avaliações (0)', size: 20),
              const SizedBox(height: 12),
              const EmptyPanel(
                  icon: Icons.star_border_rounded,
                  text:
                      'Suas avaliações aparecerão aqui depois dos atendimentos.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableSectionTitle extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onEdit;

  const _EditableSectionTitle(
      {required this.title, this.action = 'Editar', required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionTitle(title, size: 20)),
        TextButton.icon(
          onPressed: onEdit,
          icon: action.startsWith('+')
              ? const SizedBox.shrink()
              : const Icon(Icons.edit_outlined,
                  size: 16, color: BColors.orange),
          label: Text(action, style: const TextStyle(color: BColors.orange)),
        ),
      ],
    );
  }
}

class _CollaboratorCover extends StatelessWidget {
  final String image;

  const _CollaboratorCover({required this.image});

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return Container(
        height: 252,
        width: double.infinity,
        color: BColors.green,
        alignment: Alignment.center,
        child: const Icon(Icons.add_photo_alternate_outlined,
            color: Colors.white, size: 42),
      );
    }
    final provider = _imageProviderFromValue(image);
    return Image(
      image: provider,
      height: 252,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}

ImageProvider _imageProviderFromValue(String value) {
  if (value.startsWith('data:image')) {
    final commaIndex = value.indexOf(',');
    return MemoryImage(base64Decode(value.substring(commaIndex + 1)));
  }
  return NetworkImage(value);
}

class _InlineEditor extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _InlineEditor(
      {required this.title,
      required this.children,
      required this.onSave,
      required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BColors.green, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
          ],
          ...children,
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: PrimaryButton(
                      label: 'Salvar',
                      color: BColors.green,
                      onPressed: onSave)),
              const SizedBox(width: 10),
              Expanded(
                  child: PrimaryButton(
                      label: 'Cancelar',
                      color: BColors.border,
                      onPressed: onCancel)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceEditor extends StatelessWidget {
  final String title;
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController durationController;
  final String? nameError;
  final String? priceError;
  final String? durationError;
  final ValueChanged<String>? onNameChanged;
  final ValueChanged<String>? onPriceChanged;
  final ValueChanged<String>? onDurationChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ServiceEditor({
    required this.title,
    required this.nameController,
    required this.priceController,
    required this.durationController,
    this.nameError,
    this.priceError,
    this.durationError,
    this.onNameChanged,
    this.onPriceChanged,
    this.onDurationChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return _InlineEditor(
      title: title,
      onSave: onSave,
      onCancel: onCancel,
      children: [
        TextInputLike(
            icon: Icons.handyman_outlined,
            hint: 'Nome do serviço',
            controller: nameController,
            errorText: nameError,
            onChanged: onNameChanged),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: TextInputLike(
                    icon: Icons.attach_money_rounded,
                    hint: 'Valor em reais',
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    errorText: priceError,
                    onChanged: onPriceChanged)),
            const SizedBox(width: 10),
            Expanded(
                child: TextInputLike(
                    icon: Icons.schedule_rounded,
                    hint: 'Horas',
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    errorText: durationError,
                    onChanged: onDurationChanged)),
          ],
        ),
      ],
    );
  }
}

class _CollaboratorServiceCard extends StatelessWidget {
  final ProviderServiceDraft service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CollaboratorServiceCard(
      {required this.service, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                    'R\$ ${_formatServicePrice(service.price)} • ${service.duration}',
                    style: const TextStyle(
                        color: BColors.orange, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          CircleButton(icon: Icons.edit_outlined, onTap: onEdit),
          const SizedBox(width: 8),
          CircleButton(icon: Icons.delete_outline_rounded, onTap: onDelete),
        ],
      ),
    );
  }
}

String _formatServicePrice(String value) {
  final amount = int.tryParse(value.replaceAll(RegExp(r'\D'), '')) ?? 0;
  return '$amount,00';
}

class _Pills extends StatelessWidget {
  final List<String> values;

  const _Pills({required this.values});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map((value) => Chip(
                label: Text(value),
                backgroundColor: BColors.green,
                labelStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ))
          .toList(),
    );
  }
}
