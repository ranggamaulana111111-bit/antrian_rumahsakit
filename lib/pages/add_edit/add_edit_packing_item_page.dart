import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/categories.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/packing_repository.dart';

class AddEditPackingItemPage extends StatefulWidget {
  final int? itemId;

  const AddEditPackingItemPage({super.key, this.itemId});

  bool get isEditing => itemId != null;

  @override
  State<AddEditPackingItemPage> createState() =>
      _AddEditPackingItemPageState();
}

class _AddEditPackingItemPageState extends State<AddEditPackingItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = PackingRepository();
  final _namaCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  late final TextEditingController _dateCtrl;

  String? _kategori;
  String _prioritas = 'Sedang';
  DateTime _tanggalPerjalanan = DateTime.now();
  int _statusPacking = 0;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_tanggalPerjalanan),
    );
    if (widget.isEditing) {
      _loadItem();
    } else {
      _kategori = PackingCategories.categories.first;
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _catatanCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final item = await _repo.getById(widget.itemId!);
      if (item != null && mounted) {
        _namaCtrl.text = item.namaBarang;
        _catatanCtrl.text = item.catatan ?? '';
        _kategori = item.kategori;
        _prioritas = item.prioritas;
        _tanggalPerjalanan = DateTime.parse(item.tanggalPerjalanan);
        _dateCtrl.text =
            DateFormat('dd/MM/yyyy').format(_tanggalPerjalanan);
        _statusPacking = item.statusPacking;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPerjalanan,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih Tanggal Perjalanan',
    );
    if (picked != null) {
      setState(() {
        _tanggalPerjalanan = picked;
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_kategori == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih kategori terlebih dahulu'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);

    try {
      final tanggalStr =
          DateFormat('yyyy-MM-dd').format(_tanggalPerjalanan);

      if (widget.isEditing) {
        await _repo.updateItem(
          id: widget.itemId!,
          namaBarang: _namaCtrl.text,
          kategori: _kategori!,
          prioritas: _prioritas,
          tanggalPerjalanan: tanggalStr,
          statusPacking: _statusPacking,
          catatan: _catatanCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang berhasil diperbarui'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        await _repo.addItem(
          namaBarang: _namaCtrl.text,
          kategori: _kategori!,
          prioritas: _prioritas,
          tanggalPerjalanan: tanggalStr,
          statusPacking: _statusPacking,
          catatan: _catatanCtrl.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barang berhasil ditambahkan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Barang' : 'Tambah Barang';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'Informasi Barang',
                      Icons.inventory_2_rounded,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        hintText: 'Masukkan nama barang',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.inventory_2_rounded, size: 22),
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          Validators.notEmpty(v, 'Nama Barang'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _kategori,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.category_rounded, size: 22),
                        ),
                      ),
                      items: PackingCategories.categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                _iconForCategory(cat),
                                size: 18,
                                color: _colorForCategory(cat),
                              ),
                              const SizedBox(width: 10),
                              Text(cat),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _kategori = v),
                      validator: (v) =>
                          v == null ? 'Pilih kategori' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Detail Perjalanan',
                      Icons.flight_rounded,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      readOnly: true,
                      controller: _dateCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Perjalanan',
                        hintText: 'Pilih tanggal',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child:
                              Icon(Icons.calendar_month_rounded, size: 22),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      onTap: _pickDate,
                      validator: (_) => Validators.notEmpty(
                        DateFormat('dd/MM/yyyy').format(_tanggalPerjalanan),
                        'Tanggal',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Prioritas',
                      Icons.flag_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildPrioritasWidget(),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      'Status & Catatan',
                      Icons.notes_rounded,
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: CheckboxListTile(
                        title: Text(
                          'Sudah Dipacking',
                          style: AppTextStyles.bodyTextMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Tandai jika barang sudah siap',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        value: _statusPacking == 1,
                        onChanged: (v) => setState(
                            () => _statusPacking = v == true ? 1 : 0),
                        controlAffinity:
                            ListTileControlAffinity.leading,
                        activeColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _catatanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        hintText: 'Tambahkan catatan...',
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.notes_rounded, size: 22),
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Text(
                                widget.isEditing
                                    ? 'Simpan Perubahan'
                                    : 'Tambah Barang',
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.accent),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritasWidget() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: PackingCategories.priorities.map((p) {
              final selected = _prioritas == p;
              Color color;
              IconData icon;
              switch (p) {
                case 'Tinggi':
                  color = AppColors.priorityHigh;
                  icon = Icons.arrow_upward_rounded;
                  break;
                case 'Sedang':
                  color = AppColors.priorityMedium;
                  icon = Icons.remove_rounded;
                  break;
                case 'Rendah':
                  color = AppColors.priorityLow;
                  icon = Icons.arrow_downward_rounded;
                  break;
                default:
                  color = AppColors.textHint;
                  icon = Icons.remove_rounded;
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _prioritas = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                      right:
                          p != PackingCategories.priorities.last ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.1)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? color : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, color: selected ? color : AppColors.textHint, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          p,
                          style: AppTextStyles.captionBold.copyWith(
                            color: selected
                                ? color
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Dokumen':
        return Icons.description_rounded;
      case 'Pakaian':
        return Icons.checkroom_rounded;
      case 'Peralatan Mandi':
        return Icons.shower_rounded;
      case 'Elektronik':
        return Icons.bolt_rounded;
      case 'Obat-obatan':
        return Icons.medication_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Dokumen':
        return AppColors.categoryDokumen;
      case 'Pakaian':
        return AppColors.categoryPakaian;
      case 'Peralatan Mandi':
        return AppColors.categoryMandi;
      case 'Elektronik':
        return AppColors.categoryElektronik;
      case 'Obat-obatan':
        return AppColors.categoryObat;
      default:
        return AppColors.textHint;
    }
  }
}
