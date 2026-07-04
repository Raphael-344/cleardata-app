import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme.dart';
import '../widgets/common.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? stats;
  List<dynamic> lastReleves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await ApiService.getStats();
      setState(() { stats = s; loading = false; });
    } catch (e) {
      setState(() { loading = false; });
    }
  }

  String _fmt(dynamic val) {
    if (val == null) return '—';
    final n = int.tryParse(val.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: kPrimary,
        backgroundColor: kSurface,
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF050A06), Color(0xFF0F2712)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryDim,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: kBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(
                                color: kPrimary, shape: BoxShape.circle,
                              )),
                              const SizedBox(width: 6),
                              const Text('MINISTÈRE DE LA TRANSITION ÉCOLOGIQUE',
                                style: TextStyle(color: kPrimary, fontSize: 9, fontFamily: 'monospace')),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text('Qualité de l\'air', style: TextStyle(
                          color: kText, fontSize: 28, fontWeight: FontWeight.w800,
                        )),
                        const Text('en France', style: TextStyle(
                          color: kPrimary, fontSize: 28, fontWeight: FontWeight.w800,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(delegate: SliverChildListDelegate([
                // Stats
                const SectionTitle('Vue d\'ensemble'),
                const SizedBox(height: 12),
                if (loading)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: List.generate(6, (_) => const ShimmerLoading()),
                  )
                else
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(value: _fmt(stats?['agences']), label: 'Agences', icon: Icons.location_city),
                      StatCard(value: _fmt(stats?['capteurs']), label: 'Capteurs', icon: Icons.sensors),
                      StatCard(value: _fmt(stats?['capteurs_actifs']), label: 'Actifs', icon: Icons.wifi_tethering),
                      StatCard(value: _fmt(stats?['releves']), label: 'Relevés', icon: Icons.air),
                      StatCard(value: _fmt(stats?['rapports']), label: 'Rapports', icon: Icons.description),
                      StatCard(value: _fmt(stats?['employes']), label: 'Agents', icon: Icons.people),
                    ],
                  ),

                const SizedBox(height: 24),

                // 7 gaz
                const SectionTitle('Gaz surveillés'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kGazColors.entries.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: e.value.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: e.value.withOpacity(0.3)),
                    ),
                    child: Text(e.key, style: TextStyle(
                      color: e.value, fontWeight: FontWeight.w700,
                      fontFamily: 'monospace', fontSize: 13,
                    )),
                  )).toList(),
                ),

                const SizedBox(height: 24),

                // Navigation rapide
                const SectionTitle('Explorer'),
                const SizedBox(height: 12),
                _NavCard(icon: Icons.map_outlined, title: 'Carte interactive',
                  desc: 'Visualisez les capteurs sur une carte de France',
                  onTap: () => _navigate(context, 1)),
                const SizedBox(height: 10),
                _NavCard(icon: Icons.bar_chart_outlined, title: 'Graphiques',
                  desc: 'Évolution et comparaisons inter-régions',
                  onTap: () => _navigate(context, 2)),
                const SizedBox(height: 10),
                _NavCard(icon: Icons.storage_outlined, title: '12 Requêtes SQL',
                  desc: 'Toutes les requêtes du cahier des charges',
                  onTap: () => _navigate(context, 3)),
                const SizedBox(height: 10),
                _NavCard(icon: Icons.search_outlined, title: 'Recherche',
                  desc: 'Trouvez les données d\'une ville',
                  onTap: () => _navigate(context, 4)),

                const SizedBox(height: 30),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    // On utilise le MainScreen pour changer d'onglet
    final scaffold = context.findAncestorStateOfType<_HomeScreenState>();
    // Navigation via callback du parent
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;

  const _NavCard({required this.icon, required this.title, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: kPrimaryDim,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Icon(icon, color: kPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                color: kText, fontWeight: FontWeight.w600, fontSize: 14,
              )),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: kTextMuted, fontSize: 12)),
            ],
          )),
          const Icon(Icons.arrow_forward_ios, color: kPrimary, size: 14),
        ],
      ),
    );
  }
}
