import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

const List<String> _regions = [
  'Île-de-France', 'Auvergne-Rhône-Alpes', 'Nouvelle-Aquitaine',
  'Occitanie', 'Hauts-de-France', 'Grand Est', 'Bretagne',
  'Normandie', 'Pays de la Loire', 'Centre-Val de Loire',
  "Provence-Alpes-Côte d'Azur", 'Corse',
];

class GraphiquesScreen extends StatefulWidget {
  const GraphiquesScreen({super.key});
  @override
  State<GraphiquesScreen> createState() => _GraphiquesScreenState();
}

class _GraphiquesScreenState extends State<GraphiquesScreen> {
  String sigle = 'CO2';
  String region = 'Île-de-France';
  List<dynamic> evolution = [];
  List<dynamic> regions = [];
  List<dynamic> gaz = [];
  bool loading = false;

  final List<String> gazList = ['CO2', 'CH4', 'N2O', 'O3', 'HFC', 'SF6', 'NH3'];

  static const _mois = ['Jan','Fév','Mar','Avr','Mai','Jun','Jul','Aoû','Sep','Oct','Nov','Déc'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { loading = true; });
    try {
      final results = await Future.wait([
        ApiService.getGraphique(type: 'evolution', sigle: sigle, region: region),
        ApiService.getGraphique(type: 'regions', sigle: sigle, region: region),
        ApiService.getGraphique(type: 'gaz', sigle: sigle, region: region),
      ]);
      setState(() {
        evolution = results[0];
        regions = results[1];
        gaz = results[2];
        loading = false;
      });
    } catch (_) {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = kGazColors[sigle] ?? kPrimary;

    return Scaffold(
      appBar: AppBar(title: const Text('Graphiques & Tendances')),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtres gaz
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: gazList.map((g) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GazChip(sigle: g, selected: sigle == g, onTap: () {
                          setState(() { sigle = g; });
                          _load();
                        }),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Filtre région
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder),
                    ),
                    child: DropdownButton<String>(
                      value: region,
                      isExpanded: true,
                      dropdownColor: kSurface,
                      underline: const SizedBox(),
                      style: const TextStyle(color: kText, fontSize: 13),
                      items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                      onChanged: (v) { if (v != null) { setState(() { region = v; }); _load(); } },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Évolution
                  const SectionTitle('Évolution temporelle'),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$sigle en $region',
                          style: const TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: evolution.isEmpty
                              ? const Center(child: Text('Pas de données', style: TextStyle(color: kTextMuted)))
                              : LineChart(LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    getDrawingHorizontalLine: (_) => const FlLine(color: kBorder, strokeWidth: 1),
                                    getDrawingVerticalLine: (_) => const FlLine(color: kBorder, strokeWidth: 1),
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 40,
                                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                                        style: const TextStyle(color: kTextMuted, fontSize: 9)),
                                    )),
                                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                                      showTitles: true, reservedSize: 24,
                                      interval: (evolution.length / 6).ceilToDouble(),
                                      getTitlesWidget: (v, _) {
                                        final i = v.toInt();
                                        if (i < 0 || i >= evolution.length) return const SizedBox();
                                        final mois = (evolution[i]['mois'] as int?) ?? 1;
                                        return Text(_mois[mois - 1],
                                          style: const TextStyle(color: kTextMuted, fontSize: 9));
                                      },
                                    )),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [LineChartBarData(
                                    spots: evolution.asMap().entries.map((e) => FlSpot(
                                      e.key.toDouble(),
                                      double.tryParse(e.value['moyenne'].toString()) ?? 0,
                                    )).toList(),
                                    isCurved: true,
                                    color: color,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: color.withValues(alpha: 0.1),
                                    ),
                                  )],
                                )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Comparaison gaz
                  const SectionTitle('Tous les gaz'),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$region (2025–2026)',
                          style: const TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 16),
                        ...gaz.map((g) {
                          final val = double.tryParse(g['moyenne'].toString()) ?? 0.0;
                          final maxG = gaz.map((x) => double.tryParse(x['moyenne'].toString()) ?? 0.0)
                              .reduce((a, b) => a > b ? a : b);
                          final c = kGazColors[g['sigle']] ?? kPrimary;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(g['sigle'] as String,
                                      style: TextStyle(color: c, fontFamily: 'monospace',
                                        fontWeight: FontWeight.w700, fontSize: 12)),
                                    Text('${val.toStringAsFixed(4)} ppm',
                                      style: const TextStyle(color: kTextMuted, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: maxG > 0 ? val / maxG : 0,
                                    backgroundColor: c.withValues(alpha: 0.1),
                                    valueColor: AlwaysStoppedAnimation(c),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}
