import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

// Coordonnées approximatives des préfectures
const Map<String, List<double>> _prefCoords = {
  'Paris': [48.8566, 2.3522], 'Lyon': [45.764, 4.8357], 'Marseille': [43.2965, 5.3698],
  'Toulouse': [43.6047, 1.4442], 'Nice': [43.7102, 7.262], 'Nantes': [47.2184, -1.5536],
  'Strasbourg': [48.5734, 7.7521], 'Montpellier': [43.6108, 3.8767], 'Bordeaux': [44.8378, -0.5792],
  'Lille': [50.6292, 3.0573], 'Rennes': [48.1173, -1.6778], 'Reims': [49.2583, 4.0317],
  'Grenoble': [45.1885, 5.7245], 'Dijon': [47.322, 5.0415], 'Nîmes': [43.8367, 4.3601],
  'Angers': [47.4784, -0.5632], 'Clermont-Ferrand': [45.7797, 3.0863], 'Brest': [48.3905, -4.486],
  'Tours': [47.3941, 0.6848], 'Amiens': [49.8941, 2.2958], 'Limoges': [45.8336, 1.2611],
  'Metz': [49.1193, 6.1757], 'Caen': [49.1829, -0.3707], 'Nancy': [48.6921, 6.1844],
  'Perpignan': [42.6887, 2.8948], 'Besançon': [47.2378, 6.0241], 'Orléans': [47.9029, 1.909],
  'Rouen': [49.4432, 1.0993], 'Toulon': [43.1242, 5.928], 'Avignon': [43.9493, 4.8059],
};

LatLng? _getCoords(String ville) {
  final c = _prefCoords[ville];
  if (c != null) return LatLng(c[0], c[1]);
  // Hash simple pour placer les villes inconnues en France
  int hash = 0;
  for (var ch in ville.codeUnits) { hash = ((hash << 5) - hash) + ch; hash &= hash; }
  final lat = 43.5 + (hash.abs() % 1000) / 1000 * 7.5;
  final lng = -4.5 + ((hash.abs() >> 10) % 1000) / 1000 * 13;
  if (lat < 41 || lat > 51 || lng < -5 || lng > 10) return null;
  return LatLng(lat, lng);
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
    return color.withOpacity(0.3 + t * 0.65);
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
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
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
                          borderColor: (kGazColors[sigle] ?? kPrimary).withOpacity(0.5),
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
                  ],
                ),

                // Légende
                Positioned(
                  bottom: 16, left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kSurface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$sigle (ppm) — ${data.length} villes',
                          style: const TextStyle(color: kTextMuted, fontSize: 10, fontFamily: 'monospace')),
                        const SizedBox(height: 6),
                        Container(
                          width: 140, height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(colors: [
                              color.withOpacity(0.2), color,
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