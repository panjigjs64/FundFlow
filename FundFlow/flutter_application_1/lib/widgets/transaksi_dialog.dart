import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TransaksiDialog extends StatefulWidget {
  final bool isPemasukan;
  final Function(String keterangan, double jumlah) onSubmit;

  const TransaksiDialog({
    super.key,
    required this.isPemasukan,
    required this.onSubmit,
  });

  @override
  State<TransaksiDialog> createState() => _TransaksiDialogState();
}

class _TransaksiDialogState extends State<TransaksiDialog> {
  final _ketController = TextEditingController();
  final _jumlahController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ketController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _submit() {
    final ket = _ketController.text.trim();
    final jumlah = double.tryParse(_jumlahController.text) ?? 0;

    if (ket.isEmpty) {
      setState(() => _error = 'Keterangan tidak boleh kosong');
      return;
    }
    if (jumlah <= 0) {
      setState(() => _error = 'Jumlah harus lebih dari 0');
      return;
    }
    widget.onSubmit(ket, jumlah);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.isPemasukan ? AppColors.primaryGreen : AppColors.dangerRed;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.isPemasukan
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.isPemasukan ? 'Tambah Pemasukan' : 'Tambah Pengeluaran',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(
            controller: _ketController,
            label: 'Keterangan',
            hint: widget.isPemasukan
                ? 'cth: Uang saku bulanan'
                : 'cth: Makan siang',
          ),
          const SizedBox(height: 12),
          _field(
            controller: _jumlahController,
            label: 'Jumlah',
            hint: 'cth: 50000',
            keyboardType: TextInputType.number,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _error!,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.dangerRed),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkNavy,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(fontSize: 12, color: AppColors.lightGrey),
            isDense: true,
            filled: true,
            fillColor: AppColors.offWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}