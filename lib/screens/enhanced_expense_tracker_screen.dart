import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/tracking_models.dart';
import '../state/comprehensive_tracking_state.dart';

class EnhancedExpenseTrackerScreen extends ConsumerStatefulWidget {
  const EnhancedExpenseTrackerScreen({super.key});

  @override
  ConsumerState<EnhancedExpenseTrackerScreen> createState() => _EnhancedExpenseTrackerScreenState();
}

class _EnhancedExpenseTrackerScreenState extends ConsumerState<EnhancedExpenseTrackerScreen> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food & Drinks';
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFilter = 'All';

  String? _calendarFilterMode; // 'Date' | 'Month' | 'Year' | 'Week'
  DateTime? _calendarAnchorDate;

  // Category groups with emoji/3D-like icons
  final Map<String, List<Map<String, String>>> _categoryGroups = {
    '💳 Daily Living': [
      {'name': 'Groceries / Shopping', 'icon': '🛒'},
      {'name': 'Food & Drinks', 'icon': '🍔'},
      {'name': 'Transportation', 'icon': '🚌'},
      {'name': 'Rent / Housing', 'icon': '🏠'},
      {'name': 'Utilities', 'icon': '💡'},
      {'name': 'Internet & Mobile', 'icon': '📶'},
    ],
    '🎉 Entertainment & Lifestyle': [
      {'name': 'Movies / OTT', 'icon': '🎬'},
      {'name': 'Dining Out / Café', 'icon': '🍽️'},
      {'name': 'Gaming', 'icon': '🎮'},
      {'name': 'Sports / Fitness / Gym', 'icon': '🏋️‍♂️'},
      {'name': 'Travel / Trips', 'icon': '🧳'},
      {'name': 'Events / Concerts', 'icon': '🎤'},
    ],
    '👨‍👩‍👧 Personal & Family': [
      {'name': 'Education / Courses', 'icon': '🎓'},
      {'name': 'Medical / Health', 'icon': '🏥'},
      {'name': 'Insurance', 'icon': '🛡️'},
      {'name': 'Family & Kids', 'icon': '👨‍👩‍👧'},
      {'name': 'Gifts & Donations', 'icon': '🎁'},
    ],
    '💼 Work & Finance': [
      {'name': 'Office Supplies', 'icon': '🗂️'},
      {'name': 'Business Travel', 'icon': '✈️'},
      {'name': 'Investments / Stocks', 'icon': '📈'},
      {'name': 'Loans / EMIs', 'icon': '💳'},
      {'name': 'Savings / Deposits', 'icon': '💰'},
    ],
    '🛠️ Others / Misc': [
      {'name': 'Shopping (Clothes, Electronics)', 'icon': '🛍️'},
      {'name': 'Repairs & Maintenance', 'icon': '🧰'},
      {'name': 'Pets', 'icon': '🐾'},
      {'name': 'Subscriptions', 'icon': '📺'},
      {'name': 'Miscellaneous / Other', 'icon': '✨'},
    ],
  };

  final List<String> _types = ['Expense', 'Income'];
  final List<String> _filters = ['All', 'Today', 'This Week', 'This Month', 'This Year'];

  final List<String> _motivationalQuotes = [
    "💰 Every dollar saved is a dollar earned!",
    "🎯 Small consistent actions lead to big financial wins!",
    "💪 You're building wealth one transaction at a time!",
    "🌟 Financial freedom starts with tracking every penny!",
    "🚀 Your future self will thank you for today's discipline!",
    "💎 Smart money management is the key to success!",
    "🔥 Every expense tracked is a step toward your goals!",
    "⭐ You're not just spending money, you're investing in your future!",
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final expenses = ref.watch(expenseProvider);
    final expenseNotifier = ref.read(expenseProvider.notifier);

    final filteredExpenses = _applyEffectiveFilter(expenses);

    final totalExpenses = filteredExpenses
        .where((e) => e.type == 'Expense')
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalIncome = filteredExpenses
        .where((e) => e.type == 'Income')
        .fold(0.0, (sum, e) => sum + e.amount);

    final netAmount = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text('💵 Expense Tracker', style: TextStyle(color: scheme.onSurface)),
        backgroundColor: scheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: scheme.onSurface),
        actions: [
          IconButton(
            onPressed: () => _showAddExpenseDialog(expenseNotifier),
            icon: Icon(Icons.add, color: scheme.primary),
            tooltip: 'Add transaction',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.calendar_month, color: scheme.onSurface),
            tooltip: 'Filter by date/month/year/week',
            onSelected: (value) async {
              switch (value) {
                case 'date':
                  await _pickExactDate();
                  break;
                case 'month':
                  await _pickMonth();
                  break;
                case 'year':
                  await _pickYear();
                  break;
                case 'week':
                  await _pickWeek();
                  break;
                case 'clear':
                  setState(() {
                    _calendarFilterMode = null;
                    _calendarAnchorDate = null;
                  });
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'date', child: Text('Filter by date')),
              PopupMenuItem(value: 'month', child: Text('Filter by month')),
              PopupMenuItem(value: 'year', child: Text('Filter by year')),
              PopupMenuItem(value: 'week', child: Text('Filter by week')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'clear', child: Text('Clear filter')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMotivationalQuote(isLight),
          _buildFilterSection(scheme),
          _buildSummaryCard(totalIncome, totalExpenses, netAmount, scheme),
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState(scheme)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseCard(expense, expenseNotifier, scheme);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(expenseNotifier),
        backgroundColor: scheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMotivationalQuote(bool isLight) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? [const Color(0xFF93C5FD), const Color(0xFFA78BFA)]
              : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _motivationalQuotes[DateTime.now().millisecond % _motivationalQuotes.length],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter && _calendarFilterMode == null;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : scheme.onSurface.withOpacity(0.6))),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _calendarFilterMode = null;
                    _calendarAnchorDate = null;
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: scheme.surfaceVariant,
                selectedColor: scheme.primary,
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalIncome, double totalExpenses, double netAmount, ColorScheme scheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getEffectiveFilterTitle(),
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('Income', totalIncome, Colors.green, Icons.trending_up),
              _buildSummaryItem('Expenses', totalExpenses, Colors.red, Icons.trending_down),
              _buildSummaryItem('Net', netAmount, netAmount >= 0 ? Colors.green : Colors.red, Icons.account_balance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 60,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your ${_getEffectiveFilterTitle().toLowerCase()}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddExpenseDialog(ref.read(expenseProvider.notifier)),
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseEntry expense, ExpenseStateManager notifier, ColorScheme scheme) {
    final isIncome = expense.type == 'Income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = _iconForCategory(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditExpenseDialog(expense, notifier),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isIncome ? Colors.green : scheme.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (expense.description != null)
                        Text(
                          expense.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(expense.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showEditExpenseDialog(expense, notifier),
                          icon: const Icon(Icons.edit, size: 16),
                          color: scheme.onSurfaceVariant,
                        ),
                        IconButton(
                          onPressed: () => _showDeleteConfirmation(expense, notifier),
                          icon: const Icon(Icons.delete, size: 16),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddExpenseDialog(ExpenseStateManager notifier) {
    _amountController.clear();
    _descriptionController.clear();
    _selectedCategory = 'Food & Drinks';
    _selectedType = 'Expense';
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => _buildExpenseDialog(notifier, null),
    );
  }

  void _showEditExpenseDialog(ExpenseEntry expense, ExpenseStateManager notifier) {
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description ?? '';
    _selectedCategory = expense.category;
    _selectedType = expense.type;
    _selectedDate = expense.date;
    _selectedTime = TimeOfDay.fromDateTime(expense.date);

    showDialog(
      context: context,
      builder: (context) => _buildExpenseDialog(notifier, expense),
    );
  }

  Widget _buildExpenseDialog(ExpenseStateManager notifier, ExpenseEntry? expense) {
    final isEditing = expense != null;
    final scheme = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: scheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Transaction' : 'Add Transaction',
            style: TextStyle(color: scheme.onSurface),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type Selection
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: _types.map((type) {
                      final isSelected = _selectedType == type;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            setDialogState(() {
                              _selectedType = type;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? scheme.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                // Amount
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(color: scheme.onSurface),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Picker with icons and groups
                _buildCategoryPicker(setDialogState, scheme),
                const SizedBox(height: 16),
                // Description
                TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Date and Time
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text('Date', style: TextStyle(color: scheme.onSurface)),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        trailing: Icon(Icons.calendar_today, color: scheme.onSurfaceVariant),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setDialogState(() {
                              _selectedDate = date;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text('Time', style: TextStyle(color: scheme.onSurface)),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                        trailing: Icon(Icons.access_time, color: scheme.onSurfaceVariant),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setDialogState(() {
                              _selectedTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  final dateTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  final newExpense = ExpenseEntry(
                    id: isEditing ? expense.id : DateTime.now().millisecondsSinceEpoch.toString(),
                    date: dateTime,
                    amount: amount,
                    category: _selectedCategory,
                    type: _selectedType,
                    description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                  );

                  if (isEditing) {
                    notifier.update(newExpense);
                  } else {
                    notifier.add(newExpense);
                  }

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryPicker(void Function(void Function()) setDialogState, ColorScheme scheme) {
    final allItems = _categoryGroups.entries
        .expand((group) => group.value.map((item) => {'group': group.key, ...item}))
        .toList();

    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<Map<String, String>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: scheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            String query = '';
            return StatefulBuilder(
              builder: (context, setState) {
                final filtered = allItems.where((item) {
                  final name = (item['name'] ?? '').toLowerCase();
                  return query.isEmpty || name.contains(query);
                }).toList();
                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.category, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text('Choose Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          onChanged: (val) => setState(() { query = val.trim().toLowerCase(); }),
                          decoration: InputDecoration(
                            hintText: 'Search categories',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: scheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final name = item['name']!;
                              final icon = item['icon']!;
                              return ListTile(
                                leading: Text(icon, style: const TextStyle(fontSize: 24)),
                                title: Text(name),
                                subtitle: Text(item['group']!),
                                onTap: () => Navigator.of(context).pop({'name': name, 'icon': icon}),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
        if (selected != null) {
          setDialogState(() {
            _selectedCategory = selected['name']!;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Category',
          labelStyle: TextStyle(color: scheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        child: Row(
          children: [
            Text(_iconForCategory(_selectedCategory), style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(child: Text(_selectedCategory)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _iconForCategory(String category) {
    for (final group in _categoryGroups.values) {
      for (final item in group) {
        if (item['name'] == category) return item['icon'] ?? '💬';
      }
    }
    return '💬';
  }

  void _showDeleteConfirmation(ExpenseEntry expense, ExpenseStateManager notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.remove(expense.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Filtering
  List<ExpenseEntry> _applyEffectiveFilter(List<ExpenseEntry> expenses) {
    if (_calendarFilterMode != null && _calendarAnchorDate != null) {
      return _applyCalendarFilter(expenses, _calendarFilterMode!, _calendarAnchorDate!);
    }
    return _filterExpenses(expenses);
  }

  List<ExpenseEntry> _applyCalendarFilter(List<ExpenseEntry> expenses, String mode, DateTime anchor) {
    switch (mode) {
      case 'Date':
        return expenses.where((e) => _isSameDate(e.date, anchor)).toList();
      case 'Week':
        final start = _startOfWeek(anchor);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
        return expenses.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
      case 'Month':
        return expenses.where((e) => e.date.year == anchor.year && e.date.month == anchor.month).toList();
      case 'Year':
        return expenses.where((e) => e.date.year == anchor.year).toList();
      default:
        return expenses;
    }
  }

  List<ExpenseEntry> _filterExpenses(List<ExpenseEntry> expenses) {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'Today':
        return expenses.where((e) {
          return e.date.year == now.year && 
                 e.date.month == now.month && 
                 e.date.day == now.day;
        }).toList();
      case 'This Week':
        final startOfWeek = _startOfWeek(now);
        final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
        return expenses.where((e) {
          return !e.date.isBefore(startOfWeek) && !e.date.isAfter(endOfWeek);
        }).toList();
      case 'This Month':
        return expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();
      case 'This Year':
        return expenses.where((e) {
          return e.date.year == now.year;
        }).toList();
      default:
        return expenses;
    }
  }

  String _getEffectiveFilterTitle() {
    if (_calendarFilterMode != null && _calendarAnchorDate != null) {
      switch (_calendarFilterMode) {
        case 'Date':
          return DateFormat('MMM dd, yyyy').format(_calendarAnchorDate!);
        case 'Week':
          final start = _startOfWeek(_calendarAnchorDate!);
          final end = start.add(const Duration(days: 6));
          return 'Week: ${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';
        case 'Month':
          return DateFormat('MMMM yyyy').format(_calendarAnchorDate!);
        case 'Year':
          return DateFormat('yyyy').format(_calendarAnchorDate!);
      }
    }
    switch (_selectedFilter) {
      case 'Today':
        return 'Today\'s Summary';
      case 'This Week':
        return 'This Week\'s Summary';
      case 'This Month':
        return 'This Month\'s Summary';
      case 'This Year':
        return 'This Year\'s Summary';
      default:
        return 'All Time Summary';
    }
  }

  // Calendar pickers
  Future<void> _pickExactDate() async {
    final initial = _calendarAnchorDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _calendarFilterMode = 'Date';
        _calendarAnchorDate = picked;
      });
    }
  }

  Future<void> _pickMonth() async {
    final initial = _calendarAnchorDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _calendarFilterMode = 'Month';
        _calendarAnchorDate = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  Future<void> _pickYear() async {
    final initial = _calendarAnchorDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _calendarFilterMode = 'Year';
        _calendarAnchorDate = DateTime(picked.year, 1, 1);
      });
    }
  }

  Future<void> _pickWeek() async {
    final initial = _calendarAnchorDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _calendarFilterMode = 'Week';
        _calendarAnchorDate = picked;
      });
    }
  }

  // Utils
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _startOfWeek(DateTime date) {
    final int weekday = date.weekday; // 1..7 (Mon..Sun)
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }
}
