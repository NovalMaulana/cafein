import 'package:flutter/material.dart';
import '../services/cafe_service.dart';

class EditCafeDialog extends StatefulWidget {
  final Map cafe;
  final VoidCallback onSaved;

  const EditCafeDialog({super.key, required this.cafe, required this.onSaved});

  @override
  State<EditCafeDialog> createState() => _EditCafeDialogState();
}

class _EditCafeDialogState extends State<EditCafeDialog> {
  final service = CafeService();
  late TextEditingController _nameController;

  final Color _primaryColor = const Color(0xFF2C3E50); // Dark Slate
  final Color _accentColor = const Color(0xFFD35400); // Burnt Orange
  final Color _dangerColor = const Color(0xFFE74C3C); // Alizarin Red

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cafe['name']);
  }

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_location_alt_outlined,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  "Edit Lokasi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "${widget.cafe['lat'].toString().substring(0, 7)}, ${widget.cafe['lng'].toString().substring(0, 7)}",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: "Nama Cafe",
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

            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await service.deleteCafe(widget.cafe['id']);
                    widget.onSaved();
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: _dangerColor,
                    size: 20,
                  ),
                  label: Text("Hapus", style: TextStyle(color: _dangerColor)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty) {
                        await service.updateCafe(
                          widget.cafe['id'],
                          _nameController.text,
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
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
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
