import 'package:flutter/material.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD4F1D4), Color(0xFFFFFFFF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Header =====
              Row(
                children: const [
                  Icon(Icons.account_balance_wallet,
                      color: Color(0xFF4CAF50), size: 28),
                  SizedBox(width: 8),
                  Text(
                    'FundFlow',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ===== Ilustrasi Hero =====
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.savings,
                      size: 80, color: Color(0xFF4CAF50)),
                ),
              ),
              const SizedBox(height: 16),

              // ===== Judul =====
              const Text(
                'Pegang Kendali Keuangan Mahasiswa Bersama FundFlow',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kelola uang saku bulanan dengan lebih terencana. Atur anggaran harian, pantau pengeluaran, dan capai tujuan finansialmu tanpa drama.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('START SIMULATION',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(height: 20),

              // ===== Saldo Card =====
              _card(
                child: Column(
                  children: [
                    const Text(
                      'Saldo Saat Ini',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rp 0,00',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _miniBox('Penghasilan', 'Rp 0,00'),
                        const SizedBox(width: 8),
                        _miniBox('Pengeluaran', 'Rp 0,00'),
                        const SizedBox(width: 8),
                        _miniBox('Hemat', 'Rp 0,00'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _placeholder('Grafik Pengeluaran'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _placeholder('Status Keuangan'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ===== Batas Anggaran =====
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'BATAS ANGGARAN HARIAN: TERSISA Rp0,00',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Kebutuhan Bulanan',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _inputRow('1', 'Rp0,00'),
                    const SizedBox(height: 6),
                    _inputRow('2', 'Rp0,00'),
                    const SizedBox(height: 6),
                    _inputRow('3', 'Rp0,00'),
                    const SizedBox(height: 16),
                    const Text('Keinginan Pribadi',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _inputRow('•', 'Rp0,00'),
                    const SizedBox(height: 6),
                    _inputRow('•', 'Rp0,00'),
                    const SizedBox(height: 6),
                    _inputRow('•', 'Rp0,00'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _miniBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String label) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(label,
            style:
                const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
      ),
    );
  }

  Widget _inputRow(String prefix, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Text(prefix, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: const Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}