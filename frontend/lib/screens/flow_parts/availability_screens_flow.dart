part of '../figma_flow.dart';

class AvailabilityDaysScreen extends ConsumerWidget {
  const AvailabilityDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return _AvailabilityPicker(
      title: 'Dias Disponíveis',
      subtitle: 'Selecione os dias da semana em que você está disponível',
      values: days,
      initialSelected: ref.read(collaboratorProvider).days,
      button: 'Salvar dias',
      onSave: (selected) => ref.read(collaboratorProvider.notifier).setDays(selected),
    );
  }
}

class AvailabilityHoursScreen extends ConsumerWidget {
  const AvailabilityHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AvailabilityPicker(
      title: 'Horários Disponíveis',
      subtitle: 'Selecione os horários em que você está disponível para atender',
      values: serviceHours,
      initialSelected: ref.read(collaboratorProvider).hours,
      button: 'Salvar horários',
      onSave: (selected) => ref.read(collaboratorProvider.notifier).setHours(selected),
      grid: true,
    );
  }
}

class _AvailabilityPicker extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> values;
  final Set<String> initialSelected;
  final String button;
  final bool grid;
  final void Function(Set<String>)? onSave;

  const _AvailabilityPicker({
    required this.title,
    required this.subtitle,
    required this.values,
    required this.initialSelected,
    required this.button,
    this.grid = false,
    this.onSave,
  });

  @override
  State<_AvailabilityPicker> createState() => _AvailabilityPickerState();
}

class _AvailabilityPickerState extends State<_AvailabilityPicker> {
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = {...widget.initialSelected};
  }

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
                    active: _localSelected.contains(value),
                    width: 104,
                    centered: true,
                    onTap: () => setState(() {
                      _localSelected.contains(value)
                          ? _localSelected.remove(value)
                          : _localSelected.add(value);
                    }),
                  )).toList(),
            )
          else
            Column(
              children: widget.values.map((value) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AvailabilityOption(
                      value: value,
                      active: _localSelected.contains(value),
                      width: double.infinity,
                      onTap: () => setState(() {
                        _localSelected.contains(value)
                            ? _localSelected.remove(value)
                            : _localSelected.add(value);
                      }),
                    ),
                  )).toList(),
            ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: widget.button,
            onPressed: () {
              widget.onSave?.call({..._localSelected});
              Navigator.of(context).pop();
            },
          ),
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
