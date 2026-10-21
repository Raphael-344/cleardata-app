import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';

const _requetes = [
  {'id': '1', 'label': 'Liste des agences', 'desc': 'Toutes les agences régionales'},
  {'id': '2', 'label': 'Personnel Bordeaux', 'desc': 'Agents techniques de Bordeaux'},
  {'id': '3', 'label': 'Nombre de capteurs', 'desc': 'Comptage total des capteurs'},
  {'id': '4', 'label': 'Rapports 2018–2022', 'desc': 'Rapports sur la période'},
  {'id': '5', 'label': 'CH4 IdF/Bretagne/Occitanie', 'desc': 'Concentrations méthane mai-juin 2025'},
  {'id': '6', 'label': 'Agents GESI', 'desc': 'Techniciens capteurs industriels'},
  {'id': '7', 'label': 'Rapports CO2', 'desc': 'Dioxyde de carbone, ordre antichronologique'},
  {'id': '8', 'label': 'Minimum HFC', 'desc': 'Mois de concentration minimale'},
  {'id': '9', 'label': 'Moyennes IdF 2025', 'desc': 'Concentration par gaz'},
  {'id': '10', 'label': 'Productivité Toulouse', 'desc': 'Taux de production rapports'},
  {'id': '11', 'label': 'Rapports par gaz', 'desc': 'Procédure stockée', 'hasParam': true},
  {'id': '12', 'label': 'Régions sous-encadrées', 'desc': 'Plus capteurs que personnel'},
];

const _gazOptions = ['Méthane', 'Dioxyde de carbone', "Protoxyde d'azote", 'Ozone troposphérique', 'Hydrofluorocarbures', 'Hexafluorure de soufre', 'Ammoniac'];

class RequetesScreen extends StatefulWidget {
  const RequetesScreen({super.key});
  @override
  State<RequetesScreen> createState() => _RequetesScreenState();
}

class _RequetesScreenState extends State<RequetesScreen> {
  String? selectedId;
  bool loading = false;
  Map<String, dynamic>? result;
  String paramGaz = 'Méthane';

  Future<void> _run(String id) async {
    setState(() { selectedId = id; loading = true; result = null; });
    try {
      final param = id == '11' ? paramGaz : null;
      final data = await ApiService.getRequete(id, param: param);
      setState(() { result = data; loading = false; });
    } catch (e) {
      setState(() { loading = false; result = {'error': e.toString()}; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('12 Requêtes SQL')),
      body: Column(
        children: [
          // Liste requêtes
          Expanded(
            flex: 2,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _requetes.length,
              itemBuilder: (ctx, i) {
                final r = _requetes[i];
                final isSelected = selectedId == r['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: GestureDetector(
                    onTap: () => _run(r['id'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryDim : kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? kPrimary.withValues(alpha: 0.5) : kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('R${(i+1).toString().padLeft(2,'0')}',
                              style: const TextStyle(color: kPrimary, fontSize: 10, fontFamily: 'monospace')),
                            const Spacer(),
                            if (loading && isSelected)
                              const SizedBox(width: 12, height: 12,
                                child: CircularProgressIndicator(color: kPrimary, strokeWidth: 1.5))
                            else
                              const Icon(Icons.play_arrow, color: kPrimary, size: 14),
                          ]),
                          const SizedBox(height: 4),
                          Text(r['label'] as String,
                            style: const TextStyle(color: kText, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(r['desc'] as String,
                            style: const TextStyle(color: kTextMuted, fontSize: 11)),
                          if (r['hasParam'] == true) ...[
                            const SizedBox(height: 6),
                            DropdownButton<String>(
                              value: paramGaz,
                              isExpanded: true,
                              dropdownColor: kSurface,
                              underline: const SizedBox(),
                              style: const TextStyle(color: kText, fontSize: 11),
                              items: _gazOptions.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (v) { if (v != null) setState(() { paramGaz = v; }); },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Résultats
          if (result != null || loading)
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: kSurface,
                  border: Border(top: BorderSide(color: kBorder)),
                ),
                child: _ResultPanel(result: result, loading: loading),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final Map<String, dynamic>? result;
  final bool loading;
  const _ResultPanel({this.result, required this.loading});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator(color: kPrimary));
    if (result == null) {
      return const Center(
      child: Text('Sélectionnez une requête', style: TextStyle(color: kTextMuted)),
    );
    }
    if (result!['error'] != null) {
      return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(result!['error'].toString(), style: const TextStyle(color: Colors.red)),
      ),
    );
    }

    final rows = result!['rows'] as List? ?? [];
    if (rows.isEmpty) return const Center(child: Text('Aucun résultat', style: TextStyle(color: kTextMuted)));

    final cols = (rows.first as Map).keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text('${result!['label']} — ${rows.length} résultats',
            style: const TextStyle(color: kPrimary, fontSize: 12, fontFamily: 'monospace')),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(kBg),
                columns: cols.map((c) => DataColumn(
                  label: Text(c.toString(), style: const TextStyle(
                    color: kPrimary, fontSize: 10, fontFamily: 'monospace')),
                )).toList(),
                rows: rows.take(50).map((row) => DataRow(
                  cells: cols.map((c) => DataCell(
                    Text(row[c]?.toString() ?? '—',
                      style: const TextStyle(color: kText, fontSize: 10, fontFamily: 'monospace')),
                  )).toList(),
                )).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
