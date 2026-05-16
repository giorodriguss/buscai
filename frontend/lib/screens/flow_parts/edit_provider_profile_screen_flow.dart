part of '../figma_flow.dart';

class EditProviderProfileScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const EditProviderProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProviderProfileScreen> createState() =>
      _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState
    extends ConsumerState<EditProviderProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController aboutController;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    final collab = ref.read(collaboratorProvider);
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
    aboutController = TextEditingController(text: collab.about);
    selectedCategory = collab.category;
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    aboutController.dispose();
    super.dispose();
  }

  Future<String?> _pickImageDataUrl() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    final mime = picked.mimeType ?? 'image/jpeg';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> _pickCover() async {
    final dataUrl = await _pickImageDataUrl();
    if (dataUrl == null) return;
    // Futuro backend: subir a capa para Storage e atualizar a foto/capa do post.
    ref.read(collaboratorProvider.notifier).setCoverImage(dataUrl);
  }

  Future<void> _pickProfilePhoto(AppUser user) async {
    final dataUrl = await _pickImageDataUrl();
    if (dataUrl == null) return;
    user.photoUrl = dataUrl;
    // Futuro backend: salvar a URL retornada pelo Storage em users.avatar_url.
    ref.read(sessionProvider.notifier).setUser(user);
    setState(() {});
  }

  Future<void> _pickCategory() async {
    final category = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
    );
    if (category != null) setState(() => selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionProvider).currentUser ?? widget.user;
    final collab = ref.watch(collaboratorProvider);
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Editar Perfil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        children: [
          const Text('Foto de capa',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickCover,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: 126,
                    width: double.infinity,
                    child: collab.coverImage.isEmpty
                        ? Container(
                            color: BColors.green,
                            alignment: Alignment.center,
                            child: const Icon(
                                Icons.add_photo_alternate_outlined,
                                color: Colors.white,
                                size: 34),
                          )
                        : Image(
                            image: _imageProviderFromValue(collab.coverImage),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const Positioned(
                  right: 12,
                  bottom: 12,
                  child: CircleAvatar(
                    backgroundColor: BColors.orange,
                    child: Icon(Icons.camera_alt_outlined, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Foto de perfil',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Center(
            child: _EditableUserAvatar(
              user: user,
              radius: 50,
              onCameraTap: () => _pickProfilePhoto(user),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Categoria',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.work_outline_rounded,
            hint: selectedCategory.isEmpty
                ? 'Selecionar categoria'
                : selectedCategory,
            readOnly: true,
            suffixIcon: Icons.keyboard_arrow_down_rounded,
            onTap: _pickCategory,
          ),
          const SizedBox(height: 18),
          _SwitchCard(
            icon: Icons.visibility_outlined,
            title: 'Perfil público do colaborador',
            subtitle:
                'Quando ativado, seu perfil aparece para moradores na Home e na busca.',
            value: ref.watch(sessionProvider).profileVisible,
            // Futuro backend: persistir em providers/posts como perfil_publico.
            onChanged: ref.read(sessionProvider.notifier).setProfileVisible,
          ),
          const SizedBox(height: 18),
          const Text('Nome', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
              icon: Icons.person_outline_rounded,
              hint: 'Nome',
              controller: nameController),
          const SizedBox(height: 18),
          const Text('Telefone', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
              icon: Icons.phone_outlined,
              hint: '00 90000-0000',
              controller: phoneController,
              inputFormatters: const [PhoneInputFormatter()]),
          const SizedBox(height: 18),
          const Text('Sobre você',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
              icon: Icons.info_outline_rounded,
              hint: 'Sobre você',
              controller: aboutController),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Salvar alterações',
            onPressed: () {
              user.name = nameController.text.trim().isEmpty
                  ? user.name
                  : nameController.text.trim();
              user.phone = phoneController.text.trim();
              ref.read(sessionProvider.notifier).setUser(user);
              ref
                  .read(collaboratorProvider.notifier)
                  .setAbout(aboutController.text.trim());
              if (selectedCategory.isNotEmpty) {
                ref
                    .read(collaboratorProvider.notifier)
                    .setCategory(selectedCategory);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
