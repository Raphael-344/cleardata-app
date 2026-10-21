import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

// Clé CARTO Basemaps (obligatoire depuis septembre 2026), fournie au build :
// flutter run --dart-define=CARTO_API_KEY=...  Sans clé, les tuiles portent un filigrane.
const String _cartoKey = String.fromEnvironment('CARTO_API_KEY');
const String _tileUrl = 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
    '${_cartoKey == '' ? '' : '?key=$_cartoKey'}';

// Coordonnées réelles des communes (city_coords.json du site) ; une ville absente
// du fichier n'est pas affichée plutôt que placée à une position inventée.
Map<String, List<double>> _cityCoords = {};

LatLng? _getCoords(String ville) {
  final c = _cityCoords[ville];
  return c == null ? null : LatLng(c[0], c[1]);
}

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});
  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  String sigle = 'CO2';
  List<dynamic> data = [];
  bool loading = false;
  dynamic selected;
  double minVal = 0, maxVal = 1;

  final List<String> gaz = ['CO2', 'CH4', 'N2O', 'O3', 'HFC', 'SF6', 'NH3'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; selected = null; });
    try {
      if (_cityCoords.isEmpty) _cityCoords = await ApiService.getCityCoords();
      final rows = await ApiService.getCarte(sigle: sigle);
      if (rows.isNotEmpty) {
        final vals = rows.map((r) => double.tryParse(r['concentration'].toString()) ?? 0.0).toList();
        minVal = vals.reduce((a, b) => a < b ? a : b);
        maxVal = vals.reduce((a, b) => a > b ? a : b);
      }
      setState(() { data = rows; loading = false; });
    } catch (_) {
      setState(() { loading = false; });
    }
  }

  Color _markerColor(double val) {
    final color = kGazColors[sigle] ?? kPrimary;
    final t = maxVal > minVal ? (val - minVal) / (maxVal - minVal) : 0.5;
    return color.withValues(alpha: 0.3 + t * 0.65);
  }

  double _markerSize(double val) {
    final t = maxVal > minVal ? (val - minVal) / (maxVal - minVal) : 0.5;
    return 2 + t * 5;
  }

  @override
  Widget build(BuildContext context) {
    final color = kGazColors[sigle] ?? kPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
        actions: [
          if (loading) const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2))),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur gaz
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: kBg,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: gaz.map((g) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GazChip(sigle: g, selected: sigle == g, onTap: () {
                    setState(() { sigle = g; });
                    _load();
                  }),
                )).toList(),
              ),
            ),
          ),

          // Carte
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(46.5, 2.5),
                    initialZoom: 5.5,
                    minZoom: 4,
                    maxZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: _tileUrl,
                      subdomains: const ['a', 'b', 'c', 'd'],
                      retinaMode: RetinaMode.isHighDensity(context),
                      userAgentPackageName: 'com.example.cleardata_app',
                    ),
                    CircleLayer(
                      circles: data.map((d) {
                        final coords = _getCoords(d['ville'] as String);
                        if (coords == null) return null;
                        final val = double.tryParse(d['concentration'].toString()) ?? 0.0;
                        return CircleMarker(
                          point: coords,
                          radius: _markerSize(val),
                          color: _markerColor(val),
                          borderColor: (kGazColors[sigle] ?? kPrimary).withValues(alpha: 0.5),
                          borderStrokeWidth: 0.5,
                          useRadiusInMeter: false,
                        );
                      }).whereType<CircleMarker>().toList(),
                    ),
                    MarkerLayer(
                      markers: data.map((d) {
                        final coords = _getCoords(d['ville'] as String);
                        if (coords == null) return null;
                        final val = double.tryParse(d['concentration'].toString()) ?? 0.0;
                        return Marker(
                          point: coords,
                          width: _markerSize(val) * 3,
                          height: _markerSize(val) * 3,
                          child: GestureDetector(
                            onTap: () => setState(() { selected = d; }),
                            child: const SizedBox.expand(),
                          ),
                        );
                      }).whereType<Marker>().toList(),
                    ),
                    // Attribution exigée par les conditions d'utilisation de CARTO Basemaps
                    const SimpleAttributionWidget(
                      source: Text('© OpenStreetMap contributors, © CARTO'),
                    ),
                  ],
                ),

                // Légende
                Positioned(
                  bottom: 16, left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kSurface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$sigle (ppm) — ${data.where((d) => _getCoords(d['ville'] as String) != null).length} villes',
                          style: const TextStyle(color: kTextMuted, fontSize: 10, fontFamily: 'monospace')),
                        const SizedBox(height: 6),
                        Container(
                          width: 140, height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(colors: [
                              color.withValues(alpha: 0.2), color,
                            ]),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(minVal.toStringAsFixed(3),
                              style: const TextStyle(color: kTextMuted, fontSize: 9, fontFamily: 'monospace')),
                            const SizedBox(width: 100),
                            Text(maxVal.toStringAsFixed(3),
                              style: const TextStyle(color: kTextMuted, fontSize: 9, fontFamily: 'monospace')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Popup ville sélectionnée
                if (selected != null)
                  Positioned(
                    top: 12, left: 12, right: 12,
                    child: GlassCard(
                      child: Row(
                        children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(selected['ville'] as String,
                                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16)),
                              Text(selected['region'] as String,
                                style: const TextStyle(color: kTextMuted, fontSize: 11)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Text(
                                  double.tryParse(selected['concentration'].toString())?.toStringAsFixed(3) ?? '—',
                                  style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(width: 4),
                                const Text('ppm', style: TextStyle(color: kTextMuted, fontSize: 12)),
                              ]),
                            ],
                          )),
                          IconButton(
                            icon: const Icon(Icons.close, color: kTextMuted),
                            onPressed: () => setState(() { selected = null; }),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}