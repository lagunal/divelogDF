import 'package:flutter/material.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:divelogtest/theme.dart';
import 'package:divelogtest/widgets/quick_action_card.dart';
import 'package:divelogtest/widgets/stat_card.dart';
import 'package:divelogtest/widgets/dive_card.dart';
import 'package:divelogtest/widgets/empty_state_card.dart';
import 'package:divelogtest/screens/dive_list_screen.dart';
import 'package:divelogtest/screens/add_edit_dive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DiveService _diveService = DiveService();
  List<DiveSession> _recentDives = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      await _diveService.initialize();
      await _diveService.loadSampleData('demo-user');
      final allDives = await _diveService.getAllDiveSessions();
      _stats = await _diveService.getStatistics('demo-user');
      setState(() {
        _recentDives = allDives.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                      // Quick Actions
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: QuickActionCard(
                                    icon: Icons.add_circle,
                                    title: 'Nueva Inmersión',
                                    color: colorScheme.primary,
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AddEditDiveScreen()),
                                      );
                                      if (result == true) _loadData();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: QuickActionCard(
                                    icon: Icons.list_alt,
                                    title: 'Ver Todas',
                                    color: colorScheme.secondary,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const DiveListScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Statistics Section
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Text(
                          'Estadísticas',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.water,
                                value: '${_stats['totalDives'] ?? 0}',
                                label: 'Inmersiones',
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.schedule,
                                value: '${(_stats['totalDiveTime'] ?? 0).toStringAsFixed(0)}m',
                                label: 'Tiempo Total',
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.arrow_downward,
                                value: '${(_stats['deepestDive'] ?? 0).toStringAsFixed(1)}m',
                                label: 'Profundidad Máx',
                                color: colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.water_drop,
                                value: '${(_stats['averageDepth'] ?? 0).toStringAsFixed(1)}m',
                                label: 'Prof. Promedio',
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recent Dives Section
                      Padding(
                        padding: AppSpacing.horizontalLg,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Inmersiones Recientes',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (_recentDives.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const DiveListScreen()),
                                  );
                                },
                                child: const Text('Ver todas'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_recentDives.isEmpty)
                        Padding(
                          padding: AppSpacing.paddingLg,
                          child: EmptyStateCard(
                            icon: Icons.scuba_diving,
                            title: 'No hay inmersiones',
                            subtitle: 'Registra tu primera inmersión para comenzar',
                            actionLabel: 'Agregar Inmersión',
                            onAction: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddEditDiveScreen()),
                              );
                              if (result == true) _loadData();
                            },
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: AppSpacing.horizontalLg,
                          itemCount: _recentDives.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final dive = _recentDives[index];
                            return DiveCard(
                              dive: dive,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditDiveScreen(existingDive: dive),
                                  ),
                                );
                                if (result == true) _loadData();
                              },
                            );
                          },
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
  }
}
