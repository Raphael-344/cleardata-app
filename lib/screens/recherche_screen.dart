import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class RechercheScreen extends StatefulWidget {
  const RechercheScreen({super.key});
  @override
  State<RechercheScreen> createState() => _RechercheScreenState();
}

class _RechercheScreenState extends State<RechercheScreen> {
  final _ctrl = TextEditingController();
  String sigle = 'Tous';
  List<dynamic> results = [];
  bool loading = false;
  Timer? _debounce;

  final List<String> gaz = ['Tous', 'CO2', 'CH4', 'N2O', 'O3', 'HFC', 'SF6', 'NH3'];

  void _search(String q) {
    _debounce?.cancel();
    if (q.length < 2) { setState(() { results = []; }); return; }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() { loading = true; });
      try {
        final s = sigle == 'Tous' ? null : sigle;
        final data = await ApiService.search(q, sigle: s);
        setState(() { results = data; loading = false; });
      } catch (_) {
        setState(() { loading = false; });
      }
    });
  }

  // Grouper par ville
  Map<String, List<dynamic>> _groupByVille() {
    final map = <String, List<dynamic>>{};
    for (final r in results) {
      final v = r['ville'] as String;
      map.putIfAbsent(v, () => []).add(r);
    }
    return map;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByVille();

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: kBg,
            child: Column(
              children: [
                TextField(
                  controller: _ctrl,
                  onChanged: _search,
                  autofocus: false,
                  style: const TextStyle(color: kText),
                  decoration: InputDecoration(
                    hintText: 'Nom de ville...',
                    hintStyle: const TextStyle(color: kTextMuted),
                    prefixIcon: const Icon(Icons.search, color: kTextMuted),
                    filled: true,
                    fillColor: kSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: gaz.map((g) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: g == 'Tous'
                          ? GestureDetector(
                              onTap: () { setState(() { sigle = g; }); _search(_ctrl.text); },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: sigle == 'Tous' ? kPrimary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: sigle == 'Tous' ? kPrimary : kBorder),
                                ),
                                child: Text('Tous', style: TextStyle(
                                  color: sigle == 'Tous' ? Colors.black : kTextMuted,
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                )),
                              ),
                            )
                          : GazChip(sigle: g, selected: sigle == g, onTap: () {
                              setState(() { sigle = g; });
                              _search(_ctrl.text);
                            }),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: kPrimary))
                : _ctrl.text.length < 2
                    ? Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.air, color: kTextMuted, size: 48),
                          const SizedBox(height: 12),
                          const Text('Tapez le nom d\'une ville', style: TextStyle(color: kTextMuted)),
                        ],
                      ))
                    : grouped.isEmpty
                        ? Center(child: Text('Aucune ville trouvée pour "${_ctrl.text}"',
                            style: const TextStyle(color: kTextMuted)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: grouped.length,
                            itemBuilder: (ctx, i) {
                              final ville = grouped.keys.elementAt(i);
                              final capteurs = grouped[ville]!;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                          width: 36, height: 36,
                                          decoration: BoxDecoration(
                                            color: kPrimaryDim,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.location_on, color: kPrimary, size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(ville, style: const TextStyle(
                                              color: kText, fontWeight: FontWeight.w700, fontSize: 16)),
                                            Text(capteurs.first['region'] as String,
                                              style: const TextStyle(color: kTextMuted, fontSize: 11)),
                                          ],
                                        )),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: kPrimaryDim,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: kBorder),
                                          ),
                                          child: Text('${capteurs.length} capteur${capteurs.length > 1 ? 's' : ''}',
                                            style: const TextStyle(color: kPrimary, fontSize: 10, fontFamily: 'monospace')),
                                        ),
                                      ]),
                                      const SizedBox(height: 12),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 4,
                                        crossAxisSpacing: 6,
                                        mainAxisSpacing: 6,
                                        childAspectRatio: 1.0,
                                        children: capteurs.take(7).map((c) {
                                          final color = kGazColors[c['sigle']] ?? kPrimary;
                                          final val = c['concentration_ppm'];
                                          return Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: color.withOpacity(0.2)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(c['sigle'] as String, style: TextStyle(
                                                  color: color, fontFamily: 'monospace',
                                                  fontWeight: FontWeight.w700, fontSize: 10,
                                                )),
                                                const Spacer(),
                                                if (val != null)
                                                  Text(
                                                    double.tryParse(val.toString())?.toStringAsFixed(2) ?? '—',
                                                    style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
                                                  )
                                                else
                                                  const Text('—', style: TextStyle(color: kTextMuted, fontSize: 12)),
                                                const Text('ppm', style: TextStyle(color: kTextMuted, fontSize: 8)),
                                              ],
                                            ),
                                          );
                                        }).toList(),
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
    );
  }
}
