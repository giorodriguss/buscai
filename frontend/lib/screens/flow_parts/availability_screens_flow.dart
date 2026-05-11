part of '../figma_flow.dart';

<<<<<<< HEAD
class AvailabilityDaysScreen extends ConsumerWidget {
  const AvailabilityDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
=======
class AvailabilityDaysScreen extends StatefulWidget {
  const AvailabilityDaysScreen({super.key});

  @override
  State<AvailabilityDaysScreen> createState() => _AvailabilityDaysScreenState();
}

class _AvailabilityDaysScreenState extends State<AvailabilityDaysScreen> {
  final days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
>>>>>>> origin/develop
    return _AvailabilityPicker(
      title: 'Dias Disponíveis',
      subtitle: 'Selecione os dias da semana em que você está disponível',
      values: days,
<<<<<<< HEAD
      initialSelected: ref.read(collaboratorProvider).days,
      button: 'Salvar dias',
      onSave: (selected) => ref.read(collaboratorProvider.notifier).setDays(selected),
=======
      selected: CollaboratorState.days,
      button: 'Salvar dias',
>>>>>>> origin/develop
    );
  }
}

<<<<<<< HEAD
class AvailabilityHoursScreen extends ConsumerWidget {
  const AvailabilityHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
=======
// Edicao local dos horarios de atendimento. O clique alterna selecionado/nao
// selecionado para permitir desmarcar horarios.
class AvailabilityHoursScreen extends StatelessWidget {
  const AvailabilityHoursScreen({super.key});

  @override
  Widget build(BuildContext context) {
>>>>>>> origin/develop
    return _AvailabilityPicker(
      title: 'Horários Disponíveis',
      subtitle: 'Selecione os horários em que você está disponível para atender',
      values: serviceHours,
<<<<<<< HEAD
      initialSelected: ref.read(collaboratorProvider).hours,
      button: 'Salvar horários',
      onSave: (selected) => ref.read(collaboratorProvider.notifier).setHours(selected),
=======
      selected: CollaboratorState.hours,
      button: 'Salvar horários',
>>>>>>> origin/develop
      grid: true,
    );
  }
}

class _AvailabilityPicker extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> values;
<<<<<<< HEAD
  final Set<String> initialSelected;
  final String button;
  final bool grid;
  final void Function(Set<String>)? onSave;
=======
  final Set<String> selected;
  final String button;
  final bool grid;
>>>>>>> origin/develop

  const _AvailabilityPicker({
    required this.title,
    required this.subtitle,
    required this.values,
<<<<<<< HEAD
    required this.initialSelected,
    required this.button,
    this.grid = false,
    this.onSave,
=======
    required this.selected,
    required this.button,
    this.grid = false,
>>>>>>> origin/develop
  });

  @override
  State<_AvailabilityPicker> createState() => _AvailabilityPickerState();
}

class _AvailabilityPickerState extends State<_AvailabilityPicker> {
<<<<<<< HEAD
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = {...widget.initialSelected};
  }

=======
>>>>>>> origin/develop
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: _GreenAppBar(title: widget.title),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text(widget.subtitle, style: const TextStyle(color: BColors.gray, height: 1.4)),
          const SizedBox(height: 20),
          if (widget.grid)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: widget.values.map((value) => _AvailabilityOption(
                    value: value,
<<<<<<< HEAD
                    active: _localSelected.contains(value),
                    width: 104,
                    centered: true,
                    onTap: () => setState(() {
                      _localSelected.contains(value)
                          ? _localSelected.remove(value)
                          : _localSelected.add(value);
=======
                    active: widget.selected.contains(value),
                    width: 104,
                    centered: true,
                    onTap: () => setState(() {
                      widget.selected.contains(value) ? widget.selected.remove(value) : widget.selected.add(value);
>>>>>>> origin/develop
                    }),
                  )).toList(),
            )
          else
            Column(
              children: widget.values.map((value) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AvailabilityOption(
                      value: value,
<<<<<<< HEAD
                      active: _localSelected.contains(value),
                      width: double.infinity,
                      onTap: () => setState(() {
                        _localSelected.contains(value)
                            ? _localSelected.remove(value)
                            : _localSelected.add(value);
=======
                      active: widget.selected.contains(value),
                      width: double.infinity,
                      onTap: () => setState(() {
                        widget.selected.contains(value) ? widget.selected.remove(value) : widget.selected.add(value);
>>>>>>> origin/develop
                      }),
                    ),
                  )).toList(),
            ),
          const SizedBox(height: 28),
<<<<<<< HEAD
          PrimaryButton(
            label: widget.button,
            onPressed: () {
              widget.onSave?.call({..._localSelected});
              Navigator.of(context).pop();
            },
          ),
=======
          PrimaryButton(label: widget.button, onPressed: () => Navigator.of(context).pop()),
>>>>>>> origin/develop
        ],
      ),
    );
  }
}

class _AvailabilityOption extends StatelessWidget {
  final String value;
  final bool active;
  final double? width;
  final bool centered;
  final VoidCallback onTap;

  const _AvailabilityOption({
    required this.value,
    required this.active,
    this.width,
    this.centered = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: active ? BColors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? BColors.green : BColors.border, width: 2),
        ),
        child: Text(
          value,
          textAlign: centered ? TextAlign.center : TextAlign.left,
          style: TextStyle(color: active ? Colors.white : BColors.black, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======

// Gerenciador de portfolio fake: adiciona/remove URLs de exemplo em memoria.
// Futuro backend: trocar por upload real de imagem e lista vinda da API.
>>>>>>> origin/develop
