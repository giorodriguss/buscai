part of '../figma_flow.dart';

class EditProviderProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditProviderProfileScreen({super.key, required this.user});

  @override
  State<EditProviderProfileScreen> createState() => _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController aboutController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
    aboutController = TextEditingController(text: CollaboratorState.about);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Editar Perfil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        children: [
          const Text('Foto de capa', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() {
              CollaboratorState.coverImage = CollaboratorState.coverImage.contains('1581092160562')
                  ? 'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=900'
                  : 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900';
            }),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(CollaboratorState.coverImage, height: 126, width: double.infinity, fit: BoxFit.cover),
                ),
                const Positioned(right: 12, bottom: 12, child: CircleAvatar(backgroundColor: BColors.orange, child: Icon(Icons.camera_alt_outlined, color: Colors.white))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Foto de perfil', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Center(
            child: Stack(
              children: [
                CircleAvatar(radius: 44, backgroundColor: CollaboratorState.profileColor, child: Text(user.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 32))),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      CollaboratorState.profileColor =
                          CollaboratorState.profileColor == BColors.green ? BColors.orange : BColors.green;
                    }),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(color: BColors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Nome', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(icon: Icons.person_outline_rounded, hint: 'Nome', controller: nameController),
          const SizedBox(height: 18),
            const Text('Telefone', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(icon: Icons.phone_outlined, hint: '00 90000-0000', controller: phoneController, inputFormatters: const [PhoneInputFormatter()]),
          const SizedBox(height: 18),
          const Text('Sobre você', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(icon: Icons.info_outline_rounded, hint: 'Sobre você', controller: aboutController),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Salvar alterações',
            onPressed: () {
              user.name = nameController.text.trim().isEmpty ? user.name : nameController.text.trim();
              user.phone = phoneController.text.trim();
              CollaboratorState.about = aboutController.text.trim();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// Edicao local dos dias de atendimento do colaborador.
// Futuro backend: salvar esse conjunto no perfil profissional.
