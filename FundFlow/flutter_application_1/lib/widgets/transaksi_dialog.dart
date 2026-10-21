import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransaksiDialog extends StatefulWidget {
  final bool isPemasukanDefault;
  final Function(String keterangan, double jumlah, bool isPemasukan, String kategori) onSubmit;

  const TransaksiDialog({
    super.key,
    required this.isPemasukanDefault,
    required this.onSubmit,
  });

  @override
  State<TransaksiDialog> createState() => _TransaksiDialogState();
}

class _TransaksiDialogState extends State<TransaksiDialog> {
  final _ketController = TextEditingController();
  final _jumlahController = TextEditingController();
  bool _isPemasukan = false;
  String _selectedKategori = 'Makanan';
  String? _error;

  final List<Map<String, dynamic>> _kategoriList = [
    {'name': 'Makanan', 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'icon': Icons.directions_bus},
    {'name': 'Belanja', 'icon': Icons.shopping_bag},
    {'name': 'Pendidikan', 'icon': Icons.school},
    {'name': 'Kesehatan', 'icon': Icons.favorite},
    {'name': 'Tagihan', 'icon': Icons.receipt},
    {'name': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _isPemasukan = widget.isPemasukanDefault;
  }

  void _submit() {
    final ket = _ketController.text.trim();
    final jumlah = double.tryParse(_jumlahController.text) ?? 0;

    if (ket.isEmpty || jumlah <= 0) {
      setState(() => _error = 'Isi keterangan dan jumlah dengan benar');
      return;
    }
    widget.onSubmit(ket, jumlah, _isPemasukan, _isPemasukan ? 'Pemasukan' : _selectedKategori);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle Pemasukan / Pengeluaran
            Container(
              decoration: BoxDecoration(
                color: AppColors.offWhite,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPemasukan = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isPemasukan ? AppColors.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('Pengeluaran', textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                            color: !_isPemasukan ? Colors.white : AppColors.textGrey)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPemasukan = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isPemasukan ? AppColors.primaryGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text('Pemasukan', textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold,
                            color: _isPemasukan ? Colors.white : AppColors.textGrey)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kategori (Hanya muncul jika pengeluaran)
            if (!_isPemasukan) ...[
              const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _kategoriList.length,
                  itemBuilder: (context, i) {
                    final cat = _kategoriList[i];
                    final isSel = _selectedKategori == cat['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedKategori = cat['name']),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primaryGreen : AppColors.offWhite,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat['icon'], color: isSel ? Colors.white : AppColors.textGrey),
                            ),
                            const SizedBox(height: 4),
                            Text(cat['name'], style: TextStyle(fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Nominal
            TextField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textGrey),
                hintText: '0',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Input Keterangan
            TextField(
              controller: _ketController,
              decoration: InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.dangerRed, fontSize: 12)),
            ],

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}