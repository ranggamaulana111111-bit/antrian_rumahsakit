import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/categories.dart';
import '../../data/models/packing_item.dart';
import '../../data/repositories/packing_repository.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/packing_item_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';

class PackingListPage extends StatefulWidget {
  const PackingListPage({super.key});

  @override
  State<PackingListPage> createState() => _PackingListPageState();
}

class _PackingListPageState extends State<PackingListPage> {
  final _repo = PackingRepository();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  List<PackingItem> _allItems = [];
  List<PackingItem> _filteredItems = [];
  bool _loading = true;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final items = await _repo.getAll();
      if (mounted) {
        setState(() {
          _allItems = items;
          _loading = false;
          _applyFilters();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    var result = _allItems.toList();

    if (_selectedCategory != 'Semua') {
      result = result.where((i) => i.kategori == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((i) {
        return i.namaBarang.toLowerCase().contains(q) ||
            i.kategori.toLowerCase().contains(q) ||
            (i.catatan?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    setState(() => _filteredItems = result);
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _applyFilters();
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  Future<void> _toggleStatus(PackingItem item) async {
    await _repo.toggleStatus(item.id!, item.statusPacking);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Packing List')),
      drawer: const AppDrawer(),
      body: _loading
          ? const LoadingWidget(message: 'Memuat...')
          : Column(
              children: [
                _buildSearchBar(),
                _buildCategoryFilter(),
                const Divider(height: 1),
                Expanded(child: _buildItemList()),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: TextField(
        controller: _searchCtrl,
        focusNode: _searchFocus,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cari barang...',
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(Icons.search_rounded, size: 22),
          ),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearchChanged('');
                      _searchFocus.unfocus();
                    },
                  ),
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Semua', ...PackingCategories.categories];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (ctx, i) {
          final cat = categories[i];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onCategoryChanged(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  cat,
                  style: AppTextStyles.captionBold.copyWith(
                    color:
                        isSelected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemList() {
    if (_filteredItems.isEmpty) {
      final hasQuery =
          _searchQuery.isNotEmpty || _selectedCategory != 'Semua';

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: EmptyState(
            icon: hasQuery ? Icons.search_off_rounded : Icons.checklist_rounded,
            title: hasQuery ? 'Tidak ditemukan' : 'Belum ada barang',
            message: hasQuery
                ? 'Coba ubah kata kunci atau filter kategori'
                : 'Tambahkan barang dari halaman utama',
            actionLabel: hasQuery ? null : 'Ke Home',
            onAction: hasQuery
                ? null
                : () => Navigator.pushReplacementNamed(context, '/home'),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        itemCount: _filteredItems.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                '${_filteredItems.length} barang ditemukan',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            );
          }
          final item = _filteredItems[i - 1];
          return PackingItemCard(
            item: item,
            onTap: () => Navigator.pushNamed(context, '/detail',
                    arguments: item.id)
                .then((_) => _loadData()),
            onToggle: () => _toggleStatus(item),
          );
        },
      ),
    );
  }
}
