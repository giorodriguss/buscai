part of '../figma_flow.dart';

class CollaboratorScreen extends StatefulWidget {
  final AppUser user;

  const CollaboratorScreen({super.key, required this.user});

  @override
  State<CollaboratorScreen> createState() => _CollaboratorScreenState();
}

class _CollaboratorScreenState extends State<CollaboratorScreen> {
  bool editingYears = false;
  bool editingAbout = false;
  bool addingService = false;
  int? editingService;
  final yearsController = TextEditingController();
  final aboutController = TextEditingController();
  final serviceNameController = TextEditingController();
  final servicePriceController = TextEditingController();
  final serviceDurationController = TextEditingController();

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
      final service = index == null ? null : CollaboratorState.services[index];
      serviceNameController.text = service?.name ?? '';
      servicePriceController.text = service?.price ?? '';
      serviceDurationController.text = service?.duration ?? '';
    });
  }

  void _saveService() {
    final service = ProviderServiceDraft(
      name: serviceNameController.text.trim().isEmpty ? 'Novo serviço' : serviceNameController.text.trim(),
      price: servicePriceController.text.trim().isEmpty ? '0' : servicePriceController.text.trim(),
      duration: serviceDurationController.text.trim().isEmpty ? '1h' : serviceDurationController.text.trim(),
    );
    setState(() {
      if (editingService == null) {
        CollaboratorState.services.insert(0, service);
      } else {
        CollaboratorState.services[editingService!] = service;
      }
      addingService = false;
      editingService = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Image.network(
              CollaboratorState.coverImage,
              height: 252,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Positioned(
              left: 20,
              bottom: -54,
              child: CircleAvatar(
                radius: 62,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: CollaboratorState.profileColor,
                  child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 42)),
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
                  Expanded(child: Text(user.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))),
                  CircleButton(
                    icon: Icons.settings_outlined,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditProviderProfileScreen(user: user)),
                      );
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
              Text(CollaboratorState.category, style: const TextStyle(color: BColors.orange, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(radius: 24, backgroundColor: BColors.orange, child: Icon(Icons.star_rounded, color: Colors.white)),
                        SizedBox(height: 8),
                        Text('0.0', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        Text('0 avaliações', textAlign: TextAlign.center, style: TextStyle(color: BColors.gray, fontSize: 12)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const CircleAvatar(radius: 24, backgroundColor: BColors.green, child: Icon(Icons.emoji_events_outlined, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('${CollaboratorState.years} anos', textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const Text('Experiência', textAlign: TextAlign.center, style: TextStyle(color: BColors.gray, fontSize: 12)),
                        GestureDetector(
                          onTap: () => setState(() {
                            yearsController.text = '${CollaboratorState.years}';
                            editingYears = true;
                          }),
                          child: const Text('Editar', style: TextStyle(color: BColors.green, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (editingYears)
                _InlineEditor(
                  title: 'Editar anos de experiência',
                  children: [TextInputLike(icon: Icons.emoji_events_outlined, hint: '10', controller: yearsController, keyboardType: TextInputType.number)],
                  onSave: () => setState(() {
                    CollaboratorState.years = int.tryParse(yearsController.text) ?? CollaboratorState.years;
                    editingYears = false;
                  }),
                  onCancel: () => setState(() => editingYears = false),
                ),
              const Divider(height: 32),
              _EditableSectionTitle(
                title: 'Sobre',
                onEdit: () => setState(() {
                  aboutController.text = CollaboratorState.about;
                  editingAbout = true;
                }),
              ),
              if (editingAbout)
                _InlineEditor(
                  title: '',
                  children: [TextInputLike(icon: Icons.info_outline_rounded, hint: 'Sobre você', controller: aboutController)],
                  onSave: () => setState(() {
                    CollaboratorState.about = aboutController.text.trim();
                    editingAbout = false;
                  }),
                  onCancel: () => setState(() => editingAbout = false),
                )
              else
                CollaboratorState.about.trim().isEmpty
                    ? const EmptyPanel(icon: Icons.info_outline_rounded, text: 'Preencha seu resumo profissional.')
                    : Text(CollaboratorState.about, style: const TextStyle(height: 1.55)),
              const SizedBox(height: 26),
              _EditableSectionTitle(title: 'Serviços', action: '+ Cadastrar novo', onEdit: () => _startServiceEdit()),
              if (addingService)
                _ServiceEditor(
                  title: editingService == null ? 'Novo serviço' : 'Editar serviço',
                  nameController: serviceNameController,
                  priceController: servicePriceController,
                  durationController: serviceDurationController,
                  onSave: _saveService,
                  onCancel: () => setState(() => addingService = false),
                ),
              if (CollaboratorState.services.isEmpty && !addingService)
                const EmptyPanel(icon: Icons.work_outline_rounded, text: 'Cadastre seus serviços para eles aparecerem aqui.')
              else
                ...List.generate(CollaboratorState.services.length, (index) {
                  final service = CollaboratorState.services[index];
                  return _CollaboratorServiceCard(
                    service: service,
                    onEdit: () => _startServiceEdit(index),
                    onDelete: () => setState(() => CollaboratorState.services.removeAt(index)),
                  );
                }),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Dias disponíveis',
                onEdit: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AvailabilityDaysScreen()));
                  if (mounted) setState(() {});
                },
              ),
              CollaboratorState.days.isEmpty
                  ? const EmptyPanel(icon: Icons.calendar_today_outlined, text: 'Escolha seus dias de atendimento.')
                  : _Pills(values: CollaboratorState.days.toList()),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Horários disponíveis',
                onEdit: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AvailabilityHoursScreen()));
                  if (mounted) setState(() {});
                },
              ),
              CollaboratorState.hours.isEmpty
                  ? const EmptyPanel(icon: Icons.schedule_rounded, text: 'Escolha seus horários de atendimento.')
                  : _Pills(values: CollaboratorState.hours.toList()..sort()),
              const SizedBox(height: 24),
              _EditableSectionTitle(
                title: 'Portfólio',
                action: 'Gerenciar',
                onEdit: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PortfolioManagerScreen()));
                  if (mounted) setState(() {});
                },
              ),
              if (CollaboratorState.portfolio.isEmpty)
                const EmptyPanel(icon: Icons.photo_library_outlined, text: 'Adicione fotos para montar seu portfólio.')
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: CollaboratorState.portfolio.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemBuilder: (_, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(CollaboratorState.portfolio[index], fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 28),
              const SectionTitle('Avaliações (0)', size: 20),
              const SizedBox(height: 12),
              const EmptyPanel(icon: Icons.star_border_rounded, text: 'Suas avaliações aparecerão aqui depois dos atendimentos.'),
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

  const _EditableSectionTitle({required this.title, this.action = 'Editar', required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SectionTitle(title, size: 20)),
        TextButton.icon(
          onPressed: onEdit,
          icon: action.startsWith('+')
              ? const SizedBox.shrink()
              : const Icon(Icons.edit_outlined, size: 16, color: BColors.orange),
          label: Text(action, style: const TextStyle(color: BColors.orange)),
        ),
      ],
    );
  }
}

class _InlineEditor extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _InlineEditor({required this.title, required this.children, required this.onSave, required this.onCancel});

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
              Expanded(child: PrimaryButton(label: 'Salvar', color: BColors.green, onPressed: onSave)),
              const SizedBox(width: 10),
              Expanded(child: PrimaryButton(label: 'Cancelar', color: BColors.border, onPressed: onCancel)),
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
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _ServiceEditor({
    required this.title,
    required this.nameController,
    required this.priceController,
    required this.durationController,
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
        TextInputLike(icon: Icons.handyman_outlined, hint: 'Nome do serviço', controller: nameController),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextInputLike(icon: Icons.attach_money_rounded, hint: 'Preço (R\$)', controller: priceController, keyboardType: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: TextInputLike(icon: Icons.schedule_rounded, hint: 'Duração (ex: 1h)', controller: durationController)),
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

  const _CollaboratorServiceCard({required this.service, required this.onEdit, required this.onDelete});

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
                Text(service.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('R\$ ${service.price} • ${service.duration}', style: const TextStyle(color: BColors.orange, fontWeight: FontWeight.w700)),
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
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ))
          .toList(),
    );
  }
}
