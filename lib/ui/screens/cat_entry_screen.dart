import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../grooming_view_model.dart';
import '../theme/theme.dart';
import '../common/cat_avatar.dart';
import '../../data/entity/cat.dart';
import '../../util/phone_number_utils.dart';

class CatEntryScreen extends StatefulWidget {
  final int? catId;

  const CatEntryScreen({super.key, this.catId});

  @override
  State<CatEntryScreen> createState() => _CatEntryScreenState();
}

class _CatEntryScreenState extends State<CatEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerPhoneCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _furColorCtrl = TextEditingController();
  final _eyeColorCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _alertCtrl = TextEditingController();

  String _gender = 'Male';
  bool _isSterile = false;
  String? _imagePath;
  Cat? _existingCat;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCat();
  }

  Future<void> _loadCat() async {
    if (widget.catId != null && widget.catId != 0) {
      final vm = context.read<GroomingViewModel>();
      final cat = await vm.getCat(widget.catId!);
      if (cat != null && mounted) {
        setState(() {
          _existingCat = cat;
          _catNameCtrl.text = cat.catName;
          _ownerNameCtrl.text = cat.ownerName;
          _ownerPhoneCtrl.text = cat.ownerPhone;
          _breedCtrl.text = cat.breed;
          _furColorCtrl.text = cat.furColor;
          _eyeColorCtrl.text = cat.eyeColor;
          _weightCtrl.text = cat.weight > 0 ? cat.weight.toString() : '';
          _alertCtrl.text = cat.permanentAlert;
          _gender = cat.gender;
          _isSterile = cat.isSterile;
          _imagePath = cat.imagePath;
        });
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Pilih Foto Profil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _executePickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _executePickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _executePickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (pickedFile != null && mounted) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<GroomingViewModel>();
    final cat = Cat(
      catId: _existingCat?.catId ?? 0,
      catName: _catNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      ownerPhone: PhoneNumberUtils.normalize(_ownerPhoneCtrl.text.trim()),
      breed: _breedCtrl.text.trim(),
      gender: _gender,
      dob: _existingCat?.dob ?? 0,
      profilePhotoPath: _existingCat?.profilePhotoPath ?? '',
      imagePath: _imagePath,
      permanentAlert: _alertCtrl.text.trim(),
      furColor: _furColorCtrl.text.trim(),
      eyeColor: _eyeColorCtrl.text.trim(),
      weight: double.tryParse(_weightCtrl.text) ?? 0.0,
      isSterile: _isSterile,
    );

    if (_existingCat != null) {
      await vm.updateCat(cat);
    } else {
      await vm.addCat(cat);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _catNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerPhoneCtrl.dispose();
    _breedCtrl.dispose();
    _furColorCtrl.dispose();
    _eyeColorCtrl.dispose();
    _weightCtrl.dispose();
    _alertCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.catId != null && widget.catId != 0;
    final vm = context.watch<GroomingViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kucing' : 'Tambah Kucing'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ─── Avatar ──────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            CatAvatar(imagePath: _imagePath, size: 100),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.accentBlue : AppColors.lightPrimary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? AppColors.darkBackground : Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Cat Info Section ────────────────────
                    _sectionTitle('Info Kucing', Icons.pets_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildTextField(_catNameCtrl, 'Nama Kucing', required: true),
                    const SizedBox(height: 12),
                    _buildTextField(_breedCtrl, 'Ras'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_furColorCtrl, 'Warna Bulu')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_eyeColorCtrl, 'Warna Mata')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _weightCtrl,
                      'Berat Badan (kg)',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    ),

                    const SizedBox(height: 16),
                    // ─── Gender ──────────────────────────────
                    Text('Jenis Kelamin', style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext,
                    )),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _choiceChip('Male', Icons.male_rounded, isDark),
                        const SizedBox(width: 12),
                        _choiceChip('Female', Icons.female_rounded, isDark),
                      ],
                    ),

                    const SizedBox(height: 16),
                    // ─── Sterilization ───────────────────────
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: SwitchListTile(
                        title: const Text('Sudah Steril'),
                        subtitle: Text(
                          _isSterile ? 'Ya, sudah steril' : 'Belum steril',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkSubtext : AppColors.lightSubtext),
                        ),
                        value: _isSterile,
                        onChanged: (v) => setState(() => _isSterile = v),
                        secondary: Icon(
                          Icons.medical_services_rounded,
                          color: _isSterile
                              ? (isDark ? AppColors.accentGreen : AppColors.lightPrimary)
                              : Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ─── Owner Info Section ──────────────────
                    _sectionTitle('Info Pemilik', Icons.person_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildOwnerAutocomplete(vm, isDark),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _ownerPhoneCtrl,
                      'No. Telepon Pemilik',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 24),
                    // ─── Alert Section ───────────────────────
                    _sectionTitle('Peringatan', Icons.warning_amber_rounded, isDark),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _alertCtrl,
                      'Catatan Peringatan Permanen',
                      maxLines: 2,
                      hint: 'Contoh: Galak, Jantung Lemah',
                    ),

                    const SizedBox(height: 32),

                    // ─── Starter Plan Limit ───────────────────
                    if (!isEdit && vm.userPlan == 'starter' && vm.allCats.length >= 15)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIMIT TERCAPAI (15 Ekor)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Anda menggunakan versi Gratis. Silakan upgrade ke PRO untuk menambah data tanpa batas.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // ─── Save Button ─────────────────────────
                    FilledButton.icon(
                      onPressed: (!isEdit && vm.userPlan == 'starter' && vm.allCats.length >= 15)
                          ? null
                          : _save,
                      icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded),
                      label: Text(isEdit ? 'Update Kucing' : 'Simpan Kucing'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _sectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isDark ? AppColors.accentBlue : AppColors.lightPrimary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null
              : null,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
            filled: true,
            // fillColor: Theme.of(context).cardColor, // Optional: customize fill color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerAutocomplete(GroomingViewModel vm, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Pemilik',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<OwnerInfo>(
          fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
            // Sync with our controller
            if (_ownerNameCtrl.text.isNotEmpty && textController.text.isEmpty) {
              textController.text = _ownerNameCtrl.text;
            }
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              onChanged: (v) => _ownerNameCtrl.text = v,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama Pemilik wajib diisi' : null,
              style: const TextStyle(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Cari atau masukkan nama pemilik',
                hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            );
          },
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable.empty();
        return vm.owners.where(
          (o) => o.name.toLowerCase().contains(textEditingValue.text.toLowerCase()),
        );
      },
      displayStringForOption: (o) => o.name,
      onSelected: (owner) {
        _ownerNameCtrl.text = owner.name;
        _ownerPhoneCtrl.text = owner.phone;
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final owner = options.elementAt(index);
                  return ListTile(
                    title: Text(owner.name),
                    subtitle: Text(owner.phone, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    onTap: () => onSelected(owner),
                  );
                },
              ),
            ),
          ),
        );
      },
        ),
      ],
    );
  }

  Widget _choiceChip(String value, IconData icon, bool isDark) {
    final isSelected = _gender == value;
    final color = isDark ? AppColors.accentBlue : AppColors.lightPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? color : Colors.grey),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
