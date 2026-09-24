import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengelolaan Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ==================== MODEL ====================
enum PeriodeType { harian, mingguan, bulanan, custom }

class Transaksi {
  final String keterangan;
  final double jumlah;
  final bool isPemasukan;
  final DateTime tanggal;

  Transaksi({
    required this.keterangan,
    required this.jumlah,
    required this.isPemasukan,
    required this.tanggal,
  });
}

// ==================== HALAMAN UTAMA ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _saldoAwalController = TextEditingController();
  final TextEditingController _customPeriodeController = TextEditingController();

  PeriodeType _selectedPeriode = PeriodeType.bulanan;
  double _saldoAwal = 0;
  bool _isSetupDone = false;

  // Data transaksi
  final List<Transaksi> _transaksiList = [];

  // Dialog tambah transaksi
  final TextEditingController _ketController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  @override
  void dispose() {
    _saldoAwalController.dispose();
    _customPeriodeController.dispose();
    _ketController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  // ====== HITUNG TOTAL ======
  double get _totalPemasukan => _transaksiList
      .where((t) => t.isPemasukan)
      .fold(0.0, (sum, t) => sum + t.jumlah);

  double get _totalPengeluaran => _transaksiList
      .where((t) => !t.isPemasukan)
      .fold(0.0, (sum, t) => sum + t.jumlah);

  double get _saldoAkhir => _saldoAwal + _totalPemasukan - _totalPengeluaran;

  String get _labelPeriode {
    switch (_selectedPeriode) {
      case PeriodeType.harian:
        return 'Harian';
      case PeriodeType.mingguan:
        return 'Mingguan';
      case PeriodeType.bulanan:
        return 'Bulanan';
      case PeriodeType.custom:
        return _customPeriodeController.text.isEmpty
            ? 'Custom'
            : '${_customPeriodeController.text} hari';
    }
  }

  // ====== FORMAT RUPIAH ======
  String _formatRupiah(double angka) {
    final str = angka.toStringAsFixed(0);
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join()}';
  }

  // ====== SIMPAN SETUP AWAL ======
  void _simpanSetup() {
    if (_saldoAwalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan saldo awal terlebih dahulu!')),
      );
      return;
    }
    setState(() {
      _saldoAwal = double.tryParse(_saldoAwalController.text) ?? 0;
      _isSetupDone = true;
    });
  }

  // ====== DIALOG TAMBAH TRANSAKSI ======
  void _showTambahTransaksiDialog({required bool isPemasukan}) {
    _ketController.clear();
    _jumlahController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isPemasukan ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ketController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final ket = _ketController.text.trim();
                final jumlah = double.tryParse(_jumlahController.text) ?? 0;
                if (ket.isEmpty || jumlah <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Isi data dengan benar!')),
                  );
                  return;
                }
                setState(() {
                  _transaksiList.add(
                    Transaksi(
                      keterangan: ket,
                      jumlah: jumlah,
                      isPemasukan: isPemasukan,
                      tanggal: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // ====== RESET ======
  void _reset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Data'),
        content: const Text('Yakin ingin menghapus semua data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _transaksiList.clear();
                _saldoAwalController.clear();
                _isSetupDone = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Ya, Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengelolaan Keuangan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: _isSetupDone
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _reset,
                  tooltip: 'Reset',
                ),
              ]
            : null,
      ),
      body: _isSetupDone ? _buildDashboard() : _buildSetupScreen(),
    );
  }

  // ==================== SETUP SCREEN ====================
  Widget _buildSetupScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.account_balance_wallet,
              size: 80, color: Colors.teal),
          const SizedBox(height: 16),
          const Text(
            'Atur Keuanganmu',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan saldo awal dan periode pengelolaan',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Saldo awal
          TextField(
            controller: _saldoAwalController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah Awal / Saldo Awal',
              hintText: 'Contoh: 1000000',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.money),
            ),
          ),
          const SizedBox(height: 24),

          // Pilih periode
          const Text(
            'Pilih Periode Pengelolaan:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _periodeChip('Harian', PeriodeType.harian),
              _periodeChip('Mingguan', PeriodeType.mingguan),
              _periodeChip('Bulanan', PeriodeType.bulanan),
              _periodeChip('Custom', PeriodeType.custom),
            ],
          ),

          if (_selectedPeriode == PeriodeType.custom) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _customPeriodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah Hari',
                hintText: 'Contoh: 14',
                suffixText: 'hari',
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _simpanSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Mulai Kelola', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _periodeChip(String label, PeriodeType type) {
    final isSelected = _selectedPeriode == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedPeriode = type),
      selectedColor: Colors.teal.shade200,
    );
  }

  // ==================== DASHBOARD ====================
  Widget _buildDashboard() {
    return Column(
      children: [
        // ==== Kartu Saldo ====
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Saldo Saat Ini',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                _formatRupiah(_saldoAkhir),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 14, color: Colors.white70),
                  const SizedBox(width: 6),
                  Text(
                    'Periode: $_labelPeriode',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ==== Ringkasan ====
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Pemasukan',
                  _formatRupiah(_totalPemasukan),
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Pengeluaran',
                  _formatRupiah(_totalPengeluaran),
                  Colors.red,
                  Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ),

        // ==== Tombol Aksi ====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showTambahTransaksiDialog(isPemasukan: true),
                  icon: const Icon(Icons.add),
                  label: const Text('Pemasukan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showTambahTransaksiDialog(isPemasukan: false),
                  icon: const Icon(Icons.remove),
                  label: const Text('Pengeluaran'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Riwayat Transaksi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ==== List Transaksi ====
        Expanded(
          child: _transaksiList.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Belum ada transaksi',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _transaksiList.length,
                  itemBuilder: (context, index) {
                    // tampilkan dari yang terbaru
                    final t = _transaksiList[_transaksiList.length - 1 - index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.isPemasukan
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            t.isPemasukan
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: t.isPemasukan ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(t.keterangan),
                        subtitle: Text(
                          '${t.tanggal.day}/${t.tanggal.month}/${t.tanggal.year}',
                        ),
                        trailing: Text(
                          '${t.isPemasukan ? '+' : '-'} ${_formatRupiah(t.jumlah)}',
                          style: TextStyle(
                            color: t.isPemasukan ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(color: color, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}