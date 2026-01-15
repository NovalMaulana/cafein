import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/cafe_service.dart';

class AddCafeDialog extends StatefulWidget {
  final LatLng point;
  final VoidCallback onSaved;

  const AddCafeDialog({super.key, required this.point, required this.onSaved});

  @override
  State<AddCafeDialog> createState() => _AddCafeDialogState();
}

class _AddCafeDialogState extends State<AddCafeDialog> {
  final _nameController = TextEditingController();
  final _service = CafeService();

  // Palet Warna (Konsisten dengan MapPage & EditPage)
  final Color _primaryColor = const Color(0xFF2C3E50); // Dark Slate
  final Color _accentColor = const Color(0xFFD35400); // Burnt Orange

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(
                      0.1,
                    ), // Background oranye muda
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_location_alt_rounded,
                    color: _accentColor,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "Tambah Baru",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. COORDINATES INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "KOORDINAT TERPILIH",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[500],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.my_location, size: 14, color: _primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        // Format angka agar tidak terlalu panjang (6 desimal)
                        "${widget.point.latitude.toStringAsFixed(6)}, ${widget.point.longitude.toStringAsFixed(6)}",
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. INPUT FIELD
            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "Nama Cafe",
                hintText: "Contoh: Kopi Kenangan",
                labelStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: _accentColor, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 4. ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    foregroundColor: Colors.grey[600],
                  ),
                  child: const Text("Batal"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty) {
                      // Tampilkan loading indicator kecil di tombol jika mau,
                      // tapi untuk operasi cepat ini langsung saja
                      await _service.createCafe(
                        _nameController.text,
                        widget.point.latitude,
                        widget.point.longitude,
                      );
                      widget.onSaved();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan Lokasi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
