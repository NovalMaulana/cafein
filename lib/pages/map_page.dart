import 'dart:ui' as ui; // Untuk ImageFilter (Glassmorphism)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/cafe_service.dart';
import '../services/auth_service.dart';
import '../dialogs/add_cafe_dialog.dart';
import '../dialogs/edit_cafe_dialog.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final service = CafeService();
  List<Map<String, dynamic>> cafes = [];
  LatLng? tappedPoint;
  final MapController _mapController = MapController();

  // Palet Warna Modern (Theme)
  final Color _primaryColor = const Color(0xFF2C3E50); // Dark Slate
  final Color _accentColor = const Color(0xFFD35400); // Burnt Orange

  Future load() async {
    final result = await service.getCafes();
    cafes = result.cast<Map<String, dynamic>>();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  void _handleTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      tappedPoint = point;
    });
    // Optional: Animate map to center slightly above the point so the marker isn't hidden by FAB
    // _mapController.move(point, _mapController.camera.zoom);
  }

  void _openAddDialog() {
    if (tappedPoint == null) return;
    showDialog(
      context: context,
      barrierDismissible: false, // User harus save/cancel eksplisit
      builder: (_) => BackdropFilter(
        filter: ui.ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ), // Blur background dialog
        child: AddCafeDialog(point: tappedPoint!, onSaved: load),
      ),
    );
  }

  void _openEditDialog(Map cafeData) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: EditCafeDialog(cafe: cafeData, onSaved: load),
      ),
    );
  }

  void _showCafeListDialog() {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _primaryColor.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.coffee_rounded,
                            color: _primaryColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Daftar Cafe",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: _primaryColor,
                                  ),
                                ),
                                Text(
                                  "${cafes.length} tempat tersimpan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            color: _primaryColor,
                          ),
                        ],
                      ),
                    ),
                    // List
                    Flexible(
                      child: cafes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.coffee_outlined,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Belum ada cafe tersimpan",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: cafes.length,
                              itemBuilder: (context, index) {
                                final cafe = cafes[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    _openEditDialog(cafe);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _accentColor.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.local_cafe,
                                            color: _accentColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cafe['name'] ?? 'Tanpa Nama',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: _primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                cafe['address'] ??
                                                    'Alamat tidak tersedia',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${cafe['lat'].toStringAsFixed(4)}, ${cafe['lng'].toStringAsFixed(4)}",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey[400],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // PENTING: Agar map full screen di belakang status bar
      body: Stack(
        children: [
          // 1. LAYER PETA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: LatLngBounds(
                  const LatLng(-7.30, 110.05),
                  const LatLng(-7.65, 110.35),
                ),
                padding: const EdgeInsets.only(
                  top: 100,
                  bottom: 100,
                  left: 20,
                  right: 20,
                ),
              ),
              onTap: _handleTap,
              interactionOptions: const InteractionOptions(
                flags:
                    InteractiveFlag.all &
                    ~InteractiveFlag
                        .rotate, // Disable rotasi agar label tetap lurus
              ),
            ),
            children: [
              TileLayer(
                // Menggunakan CartoDB Voyager untuk tampilan peta yang lebih bersih dan modern dibanding default OSM
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.app',
              ),

              // Marker Layer untuk Lokasi yang Dipilih (Baru)
              if (tappedPoint != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: tappedPoint!,
                      width: 60,
                      height: 60,
                      alignment: Alignment.topCenter,
                      child: _buildAnimatedSelectionMarker(),
                    ),
                  ],
                ),

              // Marker Layer untuk Kafe yang Sudah Ada
              MarkerLayer(
                markers: cafes.map((c) {
                  return Marker(
                    point: LatLng(c['lat'], c['lng']),
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _openEditDialog(c),
                      child: _buildCafeMarker(),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. LAYER HEADER (Floating Glassmorphism)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: _showCafeListDialog,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.coffee_rounded, color: _primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cafe Mapper",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _primaryColor,
                                ),
                              ),
                              Text(
                                "${cafes.length} tempat ditemukan",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.list_rounded,
                            size: 20,
                            color: _primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            // Show confirmation dialog
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text(
                                  'Apakah Anda yakin ingin keluar?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Logout'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await AuthService().logout();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 3. LAYER ACTION BUTTON (Bottom Center)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedOpacity(
                opacity: tappedPoint != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: tappedPoint == null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _openAddDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0, // Shadow ditangani oleh Container
                      ),
                      icon: const Icon(Icons.add_location_alt_outlined),
                      label: const Text(
                        "Tambah Cafe Disini",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Petunjuk jika belum tap apapun
          if (tappedPoint == null && cafes.isNotEmpty)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Text(
                    "Ketuk peta untuk menambah lokasi",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // WIDGET HELPER: Marker Cafe (Existing)
  Widget _buildCafeMarker() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: _primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.local_cafe, size: 20, color: _accentColor),
        ),
        // Segitiga kecil di bawah (Pointer)
        ClipPath(
          clipper: TriangleClipper(),
          child: Container(color: _primaryColor, height: 8, width: 10),
        ),
      ],
    );
  }

  // WIDGET HELPER: Marker Seleksi (New Location)
  Widget _buildAnimatedSelectionMarker() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, double val, child) {
        return Transform.translate(
          offset: Offset(0, -10 * (1 - val)), // Animasi turun dari atas
          child: Transform.scale(
            scale: val,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _accentColor.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, size: 24, color: Colors.white),
                ),
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(color: _accentColor, height: 8, width: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Clipper Sederhana untuk membuat ujung marker lancip
class TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    final path = ui.Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}
