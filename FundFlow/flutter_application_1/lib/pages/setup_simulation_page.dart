import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/simulation_state.dart';
import '../providers/simulation_provider.dart';
import '../theme/app_colors.dart';
import '../data/target_icons.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/gradient_background.dart';

class SetupSimulationPage extends StatefulWidget {
  const SetupSimulationPage({super.key});

  @override
  State<SetupSimulationPage> createState() => _SetupSimulationPageState();
}

class _SetupSimulationPageState extends State<SetupSimulationPage> {
  int _step = 0;

  // ===== LANGKAH 1 =====
  PeriodeType _periode = PeriodeType.bulanan;
  final _saldoController = TextEditingController();

  // ===== LANGKAH 2 =====
  final _bebanNamaController = TextEditingController();
  final _bebanJumlahController = TextEditingController();

  // ===== LANGKAH 3 =====
  final _targetNamaController = TextEditingController();
  final _targetJumlahController = TextEditingController();
  String _targetIconKey = 'shield';
  DateTime? _targetTanggalMulai;
  DateTime? _targetTanggalSelesai;

  @override
  void dispose() {
    _saldoController.dispose();
    _bebanNamaController.dispose();
    _bebanJumlahController.dispose();
    _targetNamaController.dispose();
    _targetJumlahController.dispose();
    super.dispose();
  }

  // ===== UTIL =====
  String _formatRp(double angka) {
    final str = angka.toStringAsFixed(0);
    final buf = StringBuffer();
    int c = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buf.write(str[i]);
      c++;
      if (c % 3 == 0 && i != 0) buf.write('.');
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${bulan[d.month - 1]} ${d.year}';
  }

  int _getPeriodeHari(PeriodeType p) {
    switch (p) {
      case PeriodeType.mingguan:
        return 7;
      case PeriodeType.bulanan:
        return 30;
      case PeriodeType.semester:
        return 180;
      case PeriodeType.tahunan:
        return 365;
    }
  }

  String _getPeriodeLabel(PeriodeType p) {
    switch (p) {
      case PeriodeType.mingguan:
        return 'Mingguan';
      case PeriodeType.bulanan:
        return 'Bulanan';
      case PeriodeType.semester:
        return 'Semester';
      case PeriodeType.tahunan:
        return 'Tahunan';
    }
  }

  void _nextStep() {
    if (_step == 0) {
      if (_saldoController.text.isEmpty) {
        _showSnack('Masukkan saldo utama terlebih dahulu');
        return;
      }
      final saldo = double.tryParse(_saldoController.text);
      if (saldo == null || saldo <= 0) {
        _showSnack('Saldo harus berupa angka positif');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      setState(() => _step = 2);
    }
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step -= 1);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // ===== KONFIRMASI =====
  Future<void> _showKonfirmasi() async {
    final sim = context.read<SimulationProvider>();
    final saldo = double.tryParse(_saldoController.text) ?? 0;
    final totalBeban =
        sim.draftBebanWajib.fold<double>(0, (s, b) => s + b.jumlah);

    if (sim.draftBebanWajib.isEmpty) {
      _showSnack('Beban wajib belum diisi. Minimal 1 item.');
      return;
    }
    if (sim.draftTargets.isEmpty) {
      _showSnack('Target belum diisi. Minimal 1 target.');
      return;
    }
    if (totalBeban > saldo) {
      _showSnack(
          'Total beban wajib (${_formatRp(totalBeban)}) melebihi saldo utama!');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Setup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _confirmRow('Periode', _getPeriodeLabel(_periode)),
            _confirmRow('Saldo Utama', _formatRp(saldo)),
            _confirmRow(
                'Beban Wajib',
                '${sim.draftBebanWajib.length} item (${_formatRp(totalBeban)})'),
            _confirmRow('Target', '${sim.draftTargets.length} item'),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            _confirmRow(
              'Saldo Awal Periode 1',
              _formatRp(saldo - totalBeban),
              bold: true,
            ),
            const SizedBox(height: 8),
            const Text(
              '⚠️ Beban wajib akan langsung dipotong dari saldo di awal periode.',
              style: TextStyle(
                  fontSize: 10, color: AppColors.dangerRed),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mulai Simulasi'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await sim.finishSetup(
        periode: _periode,
        periodeHari: _getPeriodeHari(_periode),
        saldoAwal: saldo,
      );
      if (!mounted) return;
      Navigator.pop(context);
      _showSnack('Simulasi dimulai! Beban wajib telah dipotong 🎉');
    }
  }

  Widget _confirmRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textGrey)),
          Text(value,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      bold ? FontWeight.bold : FontWeight.w600,
                  color: bold
                      ? AppColors.primaryGreen
                      : AppColors.darkNavy)),
        ],
      ),
    );
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildStepContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Langkah 1: Aturan Main',
      'Langkah 2: Beban Wajib',
      'Langkah 3: Tujuan Utama',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (_step == 0) {
                    Navigator.pop(context);
                  } else {
                    _prevStep();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back,
                      size: 18, color: AppColors.darkNavy),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                titles[_step],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) {
              final isActive = i <= _step;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  height: 5,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryGreen
                        : AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Langkah ${_step + 1} dari 3',
            style: const TextStyle(
                fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _step1AturanMain();
      case 1:
        return _step2BebanWajib();
      case 2:
        return _step3TujuanUtama();
      default:
        return const SizedBox();
    }
  }

  // ===== STEP 1 =====
  Widget _step1AturanMain() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilihan Periode',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PeriodeType.values.map((p) {
                  final isSelected = _periode == p;
                  return ChoiceChip(
                    label: Text(_getPeriodeLabel(p)),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _periode = p),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white
                          : AppColors.darkNavy,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    selectedColor: AppColors.primaryGreen,
                    backgroundColor: AppColors.offWhite,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.lightGrey,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              const Text(
                'Periode menentukan durasi 1 siklus. Setelah selesai, sisa saldo akan otomatis ditambahkan ke siklus berikutnya.',
                style: TextStyle(
                    fontSize: 10,
                    height: 1.4,
                    color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Input Saldo Utama',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Saldo Awal',
                hint: 'Contoh: 5000000',
                controller: _saldoController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 4),
              const Text(
                'Saldo ini akan menjadi modal awal simulasi kamu.',
                style:
                    TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== STEP 2 =====
  Widget _step2BebanWajib() {
    final sim = context.watch<SimulationProvider>();
    final list = sim.draftBebanWajib;
    final total = list.fold<double>(0, (s, b) => s + b.jumlah);
    final saldo = double.tryParse(_saldoController.text) ?? 0;

    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Daftar Pengeluaran Tetap',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 4),
              const Text(
                'Masukkan pengeluaran rutin (Kos, Makan, Transport, dll).',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: const Center(
                    child: Text('Belum ada beban wajib',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textGrey)),
                  ),
                )
              else
                ...list.map((b) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.offWhite,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(b.nama,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkNavy)),
                                const SizedBox(height: 2),
                                Text(_formatRp(b.jumlah),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textGrey)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => sim.removeDraftBeban(b.id),
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.dangerRed),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _bebanNamaController,
                      decoration: InputDecoration(
                        hintText: 'Nama (cth: Kos)',
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.lightGrey),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.offWhite,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primaryGreen),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _bebanJumlahController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Jumlah',
                        hintStyle: const TextStyle(
                            fontSize: 12, color: AppColors.lightGrey),
                        isDense: true,
                        filled: true,
                        fillColor: AppColors.offWhite,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.primaryGreen),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      final nama = _bebanNamaController.text.trim();
                      final jumlah =
                          double.tryParse(_bebanJumlahController.text) ?? 0;
                      if (nama.isEmpty || jumlah <= 0) {
                        _showSnack('Isi nama & jumlah dengan benar');
                        return;
                      }
                      sim.addDraftBeban(nama, jumlah);
                      _bebanNamaController.clear();
                      _bebanJumlahController.clear();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _card(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo Utama',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textGrey)),
                  Text(_formatRp(saldo),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Beban Wajib',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textGrey)),
                  Text(_formatRp(total),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dangerRed)),
                ],
              ),
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa untuk Harian',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textGrey)),
                  Text(_formatRp(saldo - total),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: (saldo - total) >= 0
                              ? AppColors.primaryGreen
                              : AppColors.dangerRed)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== STEP 3 =====
  Widget _step3TujuanUtama() {
    final sim = context.watch<SimulationProvider>();
    final targets = sim.draftTargets;

    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (targets.isNotEmpty) ...[
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target yang Sudah Ditambahkan',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy)),
                const SizedBox(height: 10),
                ...targets.map((t) {
                  final ic = TargetIcons.getByKey(t.iconKey);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: ic.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(ic.icon,
                              color: ic.color, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(t.nama,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy)),
                              const SizedBox(height: 2),
                              Text(
                                  '${t.labelPeriode} • ${_formatRp(t.jumlahTarget)}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => sim.removeDraftTarget(t.id),
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: AppColors.dangerRed),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Tujuan',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 4),
              const Text(
                'Tentukan tujuan finansialmu sendiri (contoh: Tabungan Darurat, Beli Laptop).',
                style: TextStyle(
                    fontSize: 10, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),

              // Pilih Ikon
              const Text('Pilih Ikon',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: TargetIcons.all.length,
                  itemBuilder: (context, i) {
                    final ic = TargetIcons.all[i];
                    final isSelected = _targetIconKey == ic.key;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _targetIconKey = ic.key),
                      child: Container(
                        width: 48,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ic.color.withValues(alpha: 0.2)
                              : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? ic.color
                                : AppColors.lightGrey,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(ic.icon,
                            color: ic.color, size: 22),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Nama Tujuan
              CustomTextField(
                label: 'Nama Tujuan',
                hint: 'Contoh: Tabungan Darurat',
                controller: _targetNamaController,
              ),
              const SizedBox(height: 12),

              // ===== PERIODE (DATE RANGE PICKER) =====
              const Text('Periode Target',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkNavy)),
              const SizedBox(height: 2),
              const Text('Pilih rentang tanggal mulai & selesai',
                  style: TextStyle(
                      fontSize: 9.5, color: AppColors.textGrey)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate:
                        DateTime(now.year, now.month, now.day),
                    lastDate: DateTime(now.year + 5),
                    initialDateRange:
                        _targetTanggalMulai != null &&
                                _targetTanggalSelesai != null
                            ? DateTimeRange(
                                start: _targetTanggalMulai!,
                                end: _targetTanggalSelesai!,
                              )
                            : null,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData(
                          colorScheme: ColorScheme.light(
                            primary: AppColors.primaryBlue,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: AppColors.darkNavy,
                          ),
                        ),
                        child: child!,
                      );
                    },
                    helpText: 'Pilih rentang tanggal target',
                    saveText: 'Simpan',
                    cancelText: 'Batal',
                  );

                  if (picked != null) {
                    setState(() {
                      _targetTanggalMulai = picked.start;
                      _targetTanggalSelesai = picked.end;
                    });
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _targetTanggalMulai != null
                          ? AppColors.primaryBlue
                          : AppColors.lightGrey,
                      width: _targetTanggalMulai != null ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: _targetTanggalMulai != null
                            ? AppColors.primaryBlue
                            : AppColors.textGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _targetTanggalMulai == null
                            ? const Text(
                                'Pilih tanggal mulai & selesai',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.lightGrey),
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_formatTanggal(_targetTanggalMulai!)} – ${_formatTanggal(_targetTanggalSelesai!)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_targetTanggalSelesai!.difference(_targetTanggalMulai!).inDays + 1} hari',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                      ),
                      if (_targetTanggalMulai != null)
                        InkWell(
                          onTap: () => setState(() {
                            _targetTanggalMulai = null;
                            _targetTanggalSelesai = null;
                          }),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.close,
                                size: 16, color: AppColors.textGrey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Jumlah Target
              CustomTextField(
                label: 'Jumlah Target',
                hint: 'Contoh: 1000000',
                controller: _targetJumlahController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),

              // Tombol Tambah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final nama = _targetNamaController.text.trim();
                    final jumlah =
                        double.tryParse(_targetJumlahController.text) ?? 0;

                    if (nama.isEmpty) {
                      _showSnack('Nama target tidak boleh kosong');
                      return;
                    }
                    if (jumlah <= 0) {
                      _showSnack('Jumlah target harus lebih dari 0');
                      return;
                    }
                    if (_targetTanggalMulai == null ||
                        _targetTanggalSelesai == null) {
                      _showSnack('Pilih periode target terlebih dahulu');
                      return;
                    }

                    sim.addDraftTarget(
                      nama: nama,
                      iconKey: _targetIconKey,
                      tanggalMulai: _targetTanggalMulai!,
                      tanggalSelesai: _targetTanggalSelesai!,
                      jumlahTarget: jumlah,
                    );

                    _targetNamaController.clear();
                    _targetJumlahController.clear();
                    setState(() {
                      _targetTanggalMulai = null;
                      _targetTanggalSelesai = null;
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambahkan Tujuan',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkNavy,
                  side: const BorderSide(color: AppColors.lightGrey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _step < 2
                ? CustomButton(
                    label: 'Lanjutkan',
                    onPressed: _nextStep,
                    color: AppColors.primaryGreen,
                  )
                : CustomButton(
                    label: 'Konfirmasi',
                    onPressed: _showKonfirmasi,
                    color: AppColors.primaryBlue,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
  return Builder(
    builder: (context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    ),
  );
}
}