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
  String _selectedCategory = 'Food';
  String _selectedType = 'Expense';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedFilter = 'All';

  // Calendar override filter (takes precedence over _selectedFilter chips when set)
  String? _calendarFilterMode; // 'Date' | 'Month' | 'Year' | 'Week'
  DateTime? _calendarAnchorDate;

  final List<String> _expenseCategories = [
    'Food',
    'Transport',
    'Entertainment',
    'Shopping',
    'Bills',
    'Healthcare',
    'Education',
    'Travel',
    'Salary',
    'Freelance',
    'Investment',
    'Other',
  ];

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
    final expenses = ref.watch(expenseProvider);
    final expenseNotifier = ref.read(expenseProvider.notifier);

    // Apply calendar override filter if set; otherwise, use chip-based filter
    final filteredExpenses = _applyEffectiveFilter(expenses);

    // Calculate totals for filtered data
    final totalExpenses = filteredExpenses
        .where((e) => e.type == 'Expense')
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalIncome = filteredExpenses
        .where((e) => e.type == 'Income')
        .fold(0.0, (sum, e) => sum + e.amount);

    final netAmount = totalIncome - totalExpenses;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('💵 Expense Tracker', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => _showAddExpenseDialog(expenseNotifier),
            icon: const Icon(Icons.add, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
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
          // Motivational Quote
          _buildMotivationalQuote(),
          // Filter Section
          _buildFilterSection(),
          // Summary Card
          _buildSummaryCard(totalIncome, totalExpenses, netAmount),
          // Expense List
          Expanded(
            child: filteredExpenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseCard(expense, expenseNotifier);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(expenseNotifier),
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    final randomQuote = _motivationalQuotes[DateTime.now().millisecond % _motivationalQuotes.length];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              randomQuote,
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

  Widget _buildFilterSection() {
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
                label: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.grey[400])),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _calendarFilterMode = null; // clear calendar override when using chips
                    _calendarAnchorDate = null;
                    _selectedFilter = filter;
                  });
                },
                backgroundColor: const Color(0xFF2A2A2A),
                selectedColor: const Color(0xFF667EEA),
                checkmarkColor: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalIncome, double totalExpenses, double netAmount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A3A3A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _getEffectiveFilterTitle(),
            style: const TextStyle(
              color: Colors.white,
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
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF667EEA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 60,
              color: Color(0xFF667EEA),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No expenses found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your ${_getEffectiveFilterTitle().toLowerCase()}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddExpenseDialog(ref.read(expenseProvider.notifier)),
            icon: const Icon(Icons.add),
            label: const Text('Add First Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
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

  Widget _buildExpenseCard(ExpenseEntry expense, ExpenseStateManager notifier) {
    final isIncome = expense.type == 'Income';
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.trending_up : Icons.trending_down;

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
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF3A3A3A)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
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
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (expense.description != null)
                        Text(
                          expense.description!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(expense.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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
                          color: Colors.grey,
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
    _selectedCategory = 'Food';
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

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isEditing ? 'Edit Transaction' : 'Add Transaction',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Type Selection
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
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
                              color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              type,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
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
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixText: '₹ ',
                    prefixStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                  ),
                  items: _expenseCategories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Description
                TextField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF667EEA)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Date and Time
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Date', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.calendar_today, color: Colors.grey),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF667EEA),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF2A2A2A),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
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
                        title: const Text('Time', style: TextStyle(color: Colors.white)),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(Icons.access_time, color: Colors.grey),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFF667EEA),
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF2A2A2A),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
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
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
                backgroundColor: const Color(0xFF667EEA),
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(ExpenseEntry expense, ExpenseStateManager notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.remove(expense.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667EEA),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
    // Assuming week starts on Monday (1)
    final int weekday = date.weekday; // 1..7 (Mon..Sun)
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }
}
