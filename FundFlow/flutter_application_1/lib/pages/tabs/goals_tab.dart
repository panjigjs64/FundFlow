import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simulation_provider.dart';
import '../../theme/app_colors.dart';
import '../../data/target_icons.dart';
import '../../models/target_model.dart';
import '../setup_simulation_page.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

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

  Future<void> _openSetup(BuildContext context) async {
    context.read<SimulationProvider>().clearDraft();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SetupSimulationPage()),
    );
  }

  Future<void> _showNabungDialog(
      BuildContext context, TargetModel target) async {
    final sim = context.read<SimulationProvider>();
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: TargetIcons.getByKey(target.iconKey)
                    .color
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                TargetIcons.getByKey(target.iconKey).icon,
                color: TargetIcons.getByKey(target.iconKey).color,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Nabung ke ${target.nama}',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo tersedia: ${_formatRp(sim.state.saldo)}',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSub(context)),
            ),
            const SizedBox(height: 4),
            Text(
              'Target per hari: ${_formatRp(target.targetPerHari)}',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSub(context)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Jumlah',
                prefixText: 'Rp ',
                hintStyle: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSub(context)),
                isDense: true,
                filled: true,
                fillColor: AppColors.inputFill(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                      color: AppColors.primaryGreen),
                ),
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
            onPressed: () async {
              final jumlah = double.tryParse(controller.text) ?? 0;
              if (jumlah <= 0) return;
              final ok = await sim.nabungTarget(target.id, jumlah);
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok
                      ? 'Berhasil nabung ${_formatRp(jumlah)}'
                      : 'Saldo tidak cukup'),
                  backgroundColor: ok
                      ? AppColors.primaryGreen
                      : AppColors.dangerRed,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Nabung'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulationProvider>();
    final isDark = AppColors.isDark(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppColors.darkHeaderBlue, AppColors.darkBg]
              : [AppColors.headerBlueLight, Colors.white],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              if (sim.isOff)
                _modeOff(context)
              else
                _modeOn(context, sim),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: const [
          Icon(Icons.savings, color: AppColors.primaryGreen, size: 24),
          SizedBox(width: 6),
          Text(
            'FundFlow',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOff(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.flag,
                  size: 70, color: AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pegang Kendali Keuangan\nMahasiswa Bersama FundFlow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1.3,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Minimal uang saku tanpa drama finansial. Atur anggaran harian, '
            'simulasi bulanan, dan capai target impianmu secara realistis.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: AppColors.textSub(context)),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _openSetup(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 22, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              'START SIMULATION',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          _cardSection(
            context: context,
            title: 'Perencanaan & Alokasi Tujuan',
            child: Container(
              height: 130,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
            ),
          ),
          _cardSection(
            context: context,
            title: 'Grafik Data Tujuan',
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeOn(BuildContext context, SimulationProvider sim) {
    final targets = sim.state.targets;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _cardSection(
            context: context,
            title: 'Perencanaan & Alokasi Tujuan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (targets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Belum ada target.\nTambahkan dari setup simulasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSub(context)),
                      ),
                    ),
                  )
                else
                  ...targets.map((t) {
                    final ic = TargetIcons.getByKey(t.iconKey);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _targetCard(
                        context: context,
                        sim: sim,
                        icon: ic,
                        target: t,
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _achievementSection(context, sim),
        ],
      ),
    );
  }

  Widget _targetCard({
    required BuildContext context,
    required SimulationProvider sim,
    required TargetIcon icon,
    required TargetModel target,
  }) {
    final progress = target.progress;
    final isTercapai = progress >= 1.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTercapai ? icon.color : AppColors.border(context),
          width: isTercapai ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: icon.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon.icon, color: icon.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(target.nama,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.text(context))),
                        ),
                        if (isTercapai)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Tercapai',
                                style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatRp(target.jumlahTerkumpul)} / ${_formatRp(target.jumlahTarget)}',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSub(context)),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 9,
                            color: AppColors.textSub(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            target.labelPeriode,
                            style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textSub(context)),
                          ),
                        ),
                        if (!target.isKadaluarsa &&
                            target.sisaHari > 0)
                          Text(
                            '${target.sisaHari} hari lagi',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: target.sisaHari < 7
                                    ? AppColors.dangerRed
                                    : AppColors.primaryGreen),
                          ),
                        if (target.isKadaluarsa)
                          const Text(
                            'Kadaluarsa',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dangerRed),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border(context),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(icon.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNabungDialog(context, target),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Nabung',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(
                        color: AppColors.primaryGreen),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
              if (target.jumlahTerkumpul > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await sim.ambilDariTarget(
                          target.id, target.jumlahTerkumpul);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok
                              ? 'Dana ${_formatRp(target.jumlahTerkumpul)} diambil'
                              : 'Gagal mengambil dana'),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_downward, size: 14),
                    label: const Text('Ambil',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(
                          color: AppColors.primaryBlue),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _achievementSection(
      BuildContext context, SimulationProvider sim) {
    final achievements = sim.state.achievements;
    if (achievements.isEmpty) return const SizedBox();

    final unlockedCount =
        achievements.where((a) => a.unlocked).length;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pencapaian',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text(context))),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unlockedCount / ${achievements.length}',
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Selesaikan tantangan untuk membuka pencapaian',
            style: TextStyle(
                fontSize: 10, color: AppColors.textSub(context)),
          ),
          const SizedBox(height: 12),
          ...achievements.map((a) {
            final ic = TargetIcons.getByKey(a.iconKey);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: a.unlocked
                    ? AppColors.primaryGreen.withValues(alpha: 0.08)
                    : AppColors.inputFill(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: a.unlocked
                      ? AppColors.primaryGreen
                      : AppColors.border(context),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: a.unlocked
                          ? AppColors.primaryGreen
                          : AppColors.border(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      a.unlocked ? Icons.check : ic.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.judul,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: a.unlocked
                                    ? AppColors.primaryGreen
                                    : AppColors.text(context))),
                        const SizedBox(height: 2),
                        Text(a.deskripsi,
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSub(context))),
                      ],
                    ),
                  ),
                  if (a.unlocked)
                    const Icon(Icons.emoji_events,
                        color: AppColors.primaryGreen, size: 22),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _cardSection({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(context))),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}