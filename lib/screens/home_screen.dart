import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/categories.dart';
import '../utils/app_strings.dart';
import '../widgets/summary_card.dart';
import '../widgets/budget_progress_card.dart';
import 'add_expense_screen.dart';
import 'summary_screen.dart';
import 'month_expenses_screen.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../utils/csv_export.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _exportCsv(BuildContext context, ExpenseProvider provider) async {
    final expenses = provider.filteredExpenses;
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export yet - add some expenses first.')),
      );
      return;
    }
    try {
      await exportExpensesToCsv(expenses, fileLabel: 'expenses');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export expenses. Please try again.')),
        );
      }
    }
  }

  String _greetingName() {
    final name = AuthService().currentUser?.displayName;
    if (name == null || name.trim().isEmpty) return 'there';
    return name.trim().split(' ').first;
  }

  void _showLanguagePicker(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF12181F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langOption(ctx, langProvider, AppLanguage.english, 'English'),
              _langOption(ctx, langProvider, AppLanguage.tamil, 'தமிழ்'),
              _langOption(ctx, langProvider, AppLanguage.sinhala, 'සිංහල'),
            ],
          ),
        );
      },
    );
  }

  Widget _langOption(BuildContext ctx, LanguageProvider provider, AppLanguage lang, String label) {
    final isSelected = provider.language == lang;
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final defaultColor = isDark ? Colors.white : const Color(0xFF12181F);
    return ListTile(
      title: Text(label, style: TextStyle(color: isSelected ? const Color(0xFF34D399) : defaultColor)),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF34D399)) : null,
      onTap: () {
        provider.setLanguage(lang);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColors = isDark
        ? const [Color(0xFF14261E), Color(0xFF0B0F14)]
        : const [Color(0xFFDCF3E7), Color(0xFFF6F8F7)];
    final textColor = isDark ? Colors.white : const Color(0xFF12181F);
    final mutedIconColor = isDark ? Colors.white70 : Colors.black54;
    final fillColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.035);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    final hintColor = isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.35);
    final faintIconColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.6),
            radius: 1.4,
            colors: bgColors,
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.appTitle,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${strings.greeting}, ${_greetingName()} 👋',
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (provider.selectedCategory != null ||
                                provider.selectedDate != null ||
                                provider.searchQuery.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.clearFilters();
                                },
                                child: const Text('Clear filters', style: TextStyle(fontSize: 12)),
                              ),
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) => IconButton(
                                onPressed: themeProvider.toggleTheme,
                                icon: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.light_mode_outlined
                                      : Icons.dark_mode_outlined,
                                  color: mutedIconColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showLanguagePicker(context),
                              icon: Icon(Icons.language, color: mutedIconColor),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SummaryScreen()),
                                );
                              },
                              icon: Icon(Icons.insert_chart_outlined, color: mutedIconColor),
                            ),
                            IconButton(
                              tooltip: 'Export as CSV',
                              onPressed: () => _exportCsv(context, provider),
                              icon: Icon(Icons.ios_share, color: mutedIconColor),
                            ),
                            IconButton(
                              onPressed: () async {
                                await AuthService().signOut();
                              },
                              icon: Icon(Icons.logout, color: mutedIconColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        onChanged: provider.setSearchQuery,
                        decoration: InputDecoration(
                          hintText: strings.searchHint,
                          hintStyle: TextStyle(color: hintColor),
                          prefixIcon: Icon(Icons.search, color: faintIconColor, size: 20),
                          suffixIcon: provider.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close, color: faintIconColor, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SummaryCard(total: provider.currentMonthTotal, label: strings.totalSpent),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: BudgetProgressCard(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: provider.selectedCategory == null,
                          onTap: () => provider.setCategoryFilter(null),
                          color: textColor,
                        ),
                        const SizedBox(width: 8),
                        ...kCategories.map((cat) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(
                                label: cat.name,
                                selected: provider.selectedCategory == cat.name,
                                onTap: () => provider.setCategoryFilter(cat.name),
                                color: cat.color,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickFilterDate(context, provider),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: provider.selectedDate != null
                                    ? const Color(0xFF34D399).withOpacity(0.15)
                                    : fillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: provider.selectedDate != null
                                      ? const Color(0xFF34D399)
                                      : borderColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_month,
                                      size: 16,
                                      color: provider.selectedDate != null
                                          ? const Color(0xFF34D399)
                                          : faintIconColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    provider.selectedDate == null
                                        ? strings.filterByDate
                                        : '${provider.selectedDate!.day}/${provider.selectedDate!.month}/${provider.selectedDate!.year}',
                                    style: TextStyle(
                                      color: provider.selectedDate != null
                                          ? const Color(0xFF34D399)
                                          : faintIconColor,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (provider.selectedDate != null)
                          IconButton(
                            onPressed: () => provider.setDateFilter(null),
                            icon: Icon(Icons.close, size: 18, color: faintIconColor),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildBody(context, provider, strings)),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF34D399),
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ExpenseProvider provider, AppStrings strings) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF12181F);
    final mutedColor = isDark ? Colors.white70 : Colors.black54;
    final faintColor = isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.45);
    final veryFaintColor = isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF34D399)));
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text(provider.errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: mutedColor)),
            ],
          ),
        ),
      );
    }

    final expenses = provider.filteredExpenses;

    if (expenses.isEmpty) {
      final hasFilters = provider.selectedCategory != null ||
          provider.selectedDate != null ||
          provider.searchQuery.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasFilters ? Icons.search_off : Icons.receipt_long,
                color: veryFaintColor,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                hasFilters ? 'No matching expenses' : strings.noExpensesYet,
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                hasFilters
                    ? 'Try a different search or filter'
                    : strings.addFirstExpense,
                textAlign: TextAlign.center,
                style: TextStyle(color: faintColor, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    // Group the expenses by "Month Year" (e.g. "September 2026").
    final Map<String, List<dynamic>> grouped = {};
    for (final expense in expenses) {
      final key = DateFormat('MMMM yyyy').format(expense.date);
      grouped.putIfAbsent(key, () => []).add(expense);
    }

    // Sort the month keys with the most recent month first.
    final monthKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      itemCount: monthKeys.length,
      itemBuilder: (context, index) {
        final monthKey = monthKeys[index];
        final monthExpenses = grouped[monthKey]!;
        final monthTotal = monthExpenses.fold(0.0, (sum, e) => sum + e.amount as double);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MonthExpensesScreen(monthLabel: monthKey),
                ),
              );
            },
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.calendar_month, color: Color(0xFF34D399)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          monthKey,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${monthExpenses.length} expense${monthExpenses.length == 1 ? '' : 's'}',
                          style: TextStyle(color: faintColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rs. ${NumberFormat('#,##0').format(monthTotal)}',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.chevron_right, color: faintColor, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedFill = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.035);
    final unselectedBorder = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    final unselectedText = isDark ? Colors.white60 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : unselectedFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : unselectedBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : unselectedText,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

Future<void> _pickFilterDate(BuildContext context, ExpenseProvider provider) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final picked = await showDatePicker(
    context: context,
    initialDate: provider.selectedDate ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    builder: (context, child) {
      final base = isDark ? ThemeData.dark() : ThemeData.light();
      return Theme(
        data: base.copyWith(
          colorScheme: base.colorScheme.copyWith(
            primary: const Color(0xFF34D399),
            surface: isDark ? const Color(0xFF12181F) : Colors.white,
          ),
        ),
        child: child!,
      );
    },
  );
  if (picked != null) provider.setDateFilter(picked);
}