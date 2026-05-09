part of '../figma_flow.dart';

class _SavedAddress {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;

  const _SavedAddress({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

IconData _addressIconFor(String type) {
  if (type == 'Trabalho') return Icons.work_outline_rounded;
  if (type == 'Outro') return Icons.location_on_outlined;
  return Icons.home_outlined;
}

// Enderecos salvos do usuario. Hoje salva localmente na AppSession; depois deve
// chamar API de enderecos e preencher rua/cidade/estado via CEP.
class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  bool adding = false;
  int? editingAddressIndex;

  void _openNewAddress() {
    setState(() {
      editingAddressIndex = null;
      adding = true;
    });
  }

  void _editAddress(int index) {
    setState(() {
      editingAddressIndex = index;
      adding = true;
    });
  }

  void _closeForm() {
    setState(() {
      adding = false;
      editingAddressIndex = null;
    });
  }

  void _saveAddress(_SavedAddress address) {
    // Futuro backend: salvar/editar endereço deve persistir no usuário logado.
    // CEP deve preencher rua/cidade/estado via serviço de CEP antes de salvar.
    setState(() {
      final index = editingAddressIndex;
      if (index == null) {
        AppSession.savedAddresses.add(address);
        AppSession.selectedAddress = AppSession.savedAddresses.length - 1;
      } else {
        AppSession.savedAddresses[index] = address;
        AppSession.selectedAddress = index;
      }
      adding = false;
      editingAddressIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Endereço de atendimento'),
      body: SafeArea(
        top: false,
        child: adding
            ? _AddressForm(
                initialAddress: editingAddressIndex == null ? null : AppSession.savedAddresses[editingAddressIndex!],
                onCancel: _closeForm,
                onSave: _saveAddress,
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                      children: [
                        const Text('Endereços salvos', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 18),
                        ...List.generate(AppSession.savedAddresses.length, (index) {
                          final address = AppSession.savedAddresses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AddressTile(
                              title: address.title,
                              subtitle: address.subtitle,
                              selected: AppSession.selectedAddress == index,
                              icon: address.icon,
                              onTap: () => setState(() => AppSession.selectedAddress = index),
                              onEdit: () => _editAddress(index),
                            ),
                          );
                        }),
                        const SizedBox(height: 26),
                        GestureDetector(
                          onTap: _openNewAddress,
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: BColors.green, width: 2),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_rounded, color: BColors.green),
                                  SizedBox(width: 10),
                                  Text('Adicionar novo endereço', style: TextStyle(color: BColors.green, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: PrimaryButton(label: 'Confirmar endereço', onPressed: () => Navigator.of(context).pop()),
                  ),
                ],
              ),
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final _SavedAddress? initialAddress;
  final VoidCallback onCancel;
  final ValueChanged<_SavedAddress> onSave;

  const _AddressForm({
    this.initialAddress,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  late String selectedType;
  final cepController = TextEditingController();
  final streetController = TextEditingController();
  final numberController = TextEditingController();
  final complementController = TextEditingController();
  final districtController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController(text: 'SP');

  @override
  void initState() {
    super.initState();
    selectedType = widget.initialAddress?.type ?? 'Casa';
    if (widget.initialAddress != null) {
      cityController.text = 'São Paulo';
    }
  }

  @override
  void dispose() {
    cepController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    districtController.dispose();
    cityController.dispose();
    stateController.dispose();
    super.dispose();
  }

  void _save() {
    final street = streetController.text.trim();
    final number = numberController.text.trim();
    final district = districtController.text.trim();
    final city = cityController.text.trim().isEmpty ? 'São Paulo' : cityController.text.trim();
    final state = stateController.text.trim().isEmpty ? 'SP' : stateController.text.trim();
    final firstLine = [
      if (street.isNotEmpty) street else 'Endereço sem rua',
      if (number.isNotEmpty) number,
      if (district.isNotEmpty) district,
    ].join(', ');
    widget.onSave(
      _SavedAddress(
        type: selectedType,
        title: selectedType,
        subtitle: '$firstLine\n$city - $state',
        icon: _addressIconFor(selectedType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Novo endereço', style: TextStyle(fontWeight: FontWeight.w700)),
            TextButton(onPressed: widget.onCancel, child: const Text('Cancelar')),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Tipo de endereço', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _AddressType(
                icon: Icons.home_outlined,
                label: 'Casa',
                selected: selectedType == 'Casa',
                onTap: () => setState(() => selectedType = 'Casa'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AddressType(
                icon: Icons.work_outline_rounded,
                label: 'Trabalho',
                selected: selectedType == 'Trabalho',
                onTap: () => setState(() => selectedType = 'Trabalho'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AddressType(
                icon: Icons.location_on_outlined,
                label: 'Outro',
                selected: selectedType == 'Outro',
                onTap: () => setState(() => selectedType = 'Outro'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _FieldLabel('CEP'),
        TextInputLike(icon: Icons.pin_drop_outlined, hint: '00000-000', controller: cepController),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel('Rua'), TextInputLike(icon: Icons.route_outlined, hint: 'Nome da rua', controller: streetController)])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel('Número'), TextInputLike(icon: Icons.numbers_rounded, hint: '123', controller: numberController)])),
          ],
        ),
        const SizedBox(height: 18),
        const _FieldLabel('Complemento (opcional)'),
        TextInputLike(icon: Icons.apartment_rounded, hint: 'Apto, bloco, etc.', controller: complementController),
        const SizedBox(height: 18),
        const _FieldLabel('Bairro'),
        TextInputLike(icon: Icons.location_city_outlined, hint: 'Nome do bairro', controller: districtController),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel('Cidade'), TextInputLike(icon: Icons.location_city_rounded, hint: 'Cidade', controller: cityController)])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_FieldLabel('Estado'), TextInputLike(icon: Icons.map_outlined, hint: 'SP', controller: stateController)])),
          ],
        ),
        const SizedBox(height: 28),
        PrimaryButton(label: 'Salvar endereço', onPressed: _save),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _AddressType extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AddressType({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: selected ? BColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? BColors.green : BColors.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : BColors.black),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : BColors.black, fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// Layout compartilhado pelas telas de login, recuperar senha e cadastro.
// FieldSpec abaixo permite montar formularios sem duplicar a estrutura visual.
