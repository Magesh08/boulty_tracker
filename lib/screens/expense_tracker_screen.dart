// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../models/tracking_models.dart';
// import '../state/comprehensive_tracking_state.dart';
// import '../theme/design_system.dart';

// class ExpenseTrackerScreen extends ConsumerStatefulWidget {
//   const ExpenseTrackerScreen({super.key});

//   @override
//   ConsumerState<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
// }

// class _ExpenseTrackerScreenState extends ConsumerState<ExpenseTrackerScreen> {
//   final _amountController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   String _selectedCategory = 'Food';
//   String _selectedType = 'Expense';
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();

//   // Calendar filter state
//   String _filterMode = 'All'; // All | Date | Month | Year
//   DateTime? _filterAnchorDate; // stores the picked date/month/year anchor

//   final List<String> _expenseCategories = [
//     'Food',
//     'Transport',
//     'Entertainment',
//     'Shopping',
//     'Bills',
//     'Healthcare',
//     'Education',
//     'Travel',
//     'Other',
//   ];

//   final List<String> _types = ['Expense', 'Income'];

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final expenses = ref.watch(expenseProvider);
//     final expenseNotifier = ref.read(expenseProvider.notifier);

//     // Compute filtered list based on calendar filter
//     final List<ExpenseEntry> filteredExpenses = _applyCalendarFilter(expenses);

//     // Summary period label and totals based on filter
//     final String periodLabel = _buildPeriodLabel();

//     final totalExpenses = filteredExpenses
//         .where((e) => e.type == 'Expense')
//         .fold(0.0, (sum, e) => sum + e.amount);

//     final totalIncome = filteredExpenses
//         .where((e) => e.type == 'Income')
//         .fold(0.0, (sum, e) => sum + e.amount);

//     final netAmount = totalIncome - totalExpenses;

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//       appBar: AppBar(
//         title: const Text('💵 Expense Tracker'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           IconButton(
//             tooltip: 'Add',
//             onPressed: () => _showAddExpenseDialog(expenseNotifier),
//             icon: const Icon(Icons.add),
//           ),
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.calendar_month),
//             tooltip: 'Filter by date/month/year',
//             onSelected: (value) async {
//               switch (value) {
//                 case 'date':
//                   await _pickExactDate();
//                   break;
//                 case 'month':
//                   await _pickMonth();
//                   break;
//                 case 'year':
//                   await _pickYear();
//                   break;
//                 case 'clear':
//                   setState(() {
//                     _filterMode = 'All';
//                     _filterAnchorDate = null;
//                   });
//                   break;
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(value: 'date', child: Text('Filter by date')),
//               const PopupMenuItem(value: 'month', child: Text('Filter by month')),
//               const PopupMenuItem(value: 'year', child: Text('Filter by year')),
//               const PopupMenuDivider(),
//               const PopupMenuItem(value: 'clear', child: Text('Clear filter')),
//             ],
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Monthly/Period Summary Card
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             // color: DesignSystem.primaryColor,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [Color.fromARGB(255, 171, 175, 192), DesignSystem.primaryColor],
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF667EEA).withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Text(
//                   periodLabel,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     _buildSummaryItem('Income', totalIncome, Colors.green),
//                     _buildSummaryItem('Expenses', totalExpenses, Colors.red),
//                     _buildSummaryItem('Net', netAmount, netAmount >= 0 ? Colors.green : Colors.red),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Expense List
//           Expanded(
//             child: filteredExpenses.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: filteredExpenses.length,
//                     itemBuilder: (context, index) {
//                       final expense = filteredExpenses[index];
//                       return _buildExpenseCard(expense, expenseNotifier);
//                     },
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showAddExpenseDialog(expenseNotifier),
//         backgroundColor: const Color(0xFF667EEA),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   // Helpers for calendar filter
//   List<ExpenseEntry> _applyCalendarFilter(List<ExpenseEntry> expenses) {
//     if (_filterMode == 'All' || _filterAnchorDate == null) {
//       return expenses;
//     }
//     final DateTime anchor = _filterAnchorDate!;
//     switch (_filterMode) {
//       case 'Date':
//         return expenses.where((e) => _isSameDate(e.date, anchor)).toList();
//       case 'Month':
//         return expenses.where((e) => e.date.year == anchor.year && e.date.month == anchor.month).toList();
//       case 'Year':
//         return expenses.where((e) => e.date.year == anchor.year).toList();
//       default:
//         return expenses;
//     }
//   }

//   String _buildPeriodLabel() {
//     if (_filterMode == 'All' || _filterAnchorDate == null) {
//       final now = DateTime.now();
//       return DateFormat('MMMM yyyy').format(now);
//     }
//     switch (_filterMode) {
//       case 'Date':
//         return DateFormat('MMM dd, yyyy').format(_filterAnchorDate!);
//       case 'Month':
//         return DateFormat('MMMM yyyy').format(_filterAnchorDate!);
//       case 'Year':
//         return DateFormat('yyyy').format(_filterAnchorDate!);
//       default:
//         return DateFormat('MMMM yyyy').format(DateTime.now());
//     }
//   }

//   bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   Future<void> _pickExactDate() async {
//     final initial = _filterAnchorDate ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now().add(const Duration(days: 3650)),
//     );
//     if (picked != null) {
//       setState(() {
//         _filterMode = 'Date';
//         _filterAnchorDate = picked;
//       });
//     }
//   }

//   Future<void> _pickMonth() async {
//     final initial = _filterAnchorDate ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now().add(const Duration(days: 3650)),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null) {
//       setState(() {
//         _filterMode = 'Month';
//         _filterAnchorDate = DateTime(picked.year, picked.month, 1);
//       });
//     }
//   }

//   Future<void> _pickYear() async {
//     final initial = _filterAnchorDate ?? DateTime.now();
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: initial,
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now().add(const Duration(days: 3650)),
//       initialDatePickerMode: DatePickerMode.year,
//     );
//     if (picked != null) {
//       setState(() {
//         _filterMode = 'Year';
//         _filterAnchorDate = DateTime(picked.year, 1, 1);
//       });
//     }
//   }

//   Widget _buildSummaryItem(String label, double amount, Color color) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           '\$${amount.toStringAsFixed(2)}',
//           style: TextStyle(
//             color: color,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               color: const Color(0xFF667EEA).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.receipt_long,
//               size: 60,
//               color: Color(0xFF667EEA),
//             ),
//           ),
//           const SizedBox(height: 24),
//           const Text(
//             'No expenses yet',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2D3748),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Start tracking your expenses to manage your finances better',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 16,
//               color: Color(0xFF718096),
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => _showAddExpenseDialog(ref.read(expenseProvider.notifier)),
//             icon: const Icon(Icons.add),
//             label: const Text('Add First Expense'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF667EEA),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildExpenseCard(ExpenseEntry expense, ExpenseStateManager notifier) {
//     final isIncome = expense.type == 'Income';
//     final color = isIncome ? Colors.green : Colors.red;
//     final icon = isIncome ? Icons.trending_up : Icons.trending_down;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _showEditExpenseDialog(expense, notifier),
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 48,
//                   height: 48,
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Icon(icon, color: color, size: 24),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         expense.category,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D3748),
//                         ),
//                       ),
//                       if (expense.description != null)
//                         Text(
//                           expense.description!,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF718096),
//                           ),
//                         ),
//                       Text(
//                         DateFormat('MMM dd, yyyy').format(expense.date),
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: Color(0xFFA0AEC0),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       '${isIncome ? '+' : '-'}\$${expense.amount.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: color,
//                       ),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           onPressed: () => _showEditExpenseDialog(expense, notifier),
//                           icon: const Icon(Icons.edit, size: 16),
//                           color: const Color(0xFF718096),
//                         ),
//                         IconButton(
//                           onPressed: () => _showDeleteConfirmation(expense, notifier),
//                           icon: const Icon(Icons.delete, size: 16),
//                           color: Colors.red,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showAddExpenseDialog(ExpenseStateManager notifier) {
//     _amountController.clear();
//     _descriptionController.clear();
//     _selectedCategory = 'Food';
//     _selectedType = 'Expense';
//     _selectedDate = DateTime.now();
//     _selectedTime = TimeOfDay.now();

//     showDialog(
//       context: context,
//       builder: (context) => _buildExpenseDialog(notifier, null),
//     );
//   }

//   void _showEditExpenseDialog(ExpenseEntry expense, ExpenseStateManager notifier) {
//     _amountController.text = expense.amount.toString();
//     _descriptionController.text = expense.description ?? '';
//     _selectedCategory = expense.category;
//     _selectedType = expense.type;
//     _selectedDate = expense.date;
//     _selectedTime = TimeOfDay.fromDateTime(expense.date);

//     showDialog(
//       context: context,
//       builder: (context) => _buildExpenseDialog(notifier, expense),
//     );
//   }

//   Widget _buildExpenseDialog(ExpenseStateManager notifier, ExpenseEntry? expense) {
//     final isEditing = expense != null;

//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Type Selection
//             Row(
//               children: _types.map((type) {
//                 return Expanded(
//                   child: RadioListTile<String>(
//                     title: Text(type),
//                     value: type,
//                     groupValue: _selectedType,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedType = value!;
//                       });
//                     },
//                   ),
//                 );
//               }).toList(),
//             ),
//             const SizedBox(height: 16),
//             // Amount
//             TextField(
//               controller: _amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Amount',
//                 prefixText: '\$ ',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Category
//             DropdownButtonFormField<String>(
//               value: _selectedCategory,
//               decoration: const InputDecoration(
//                 labelText: 'Category',
//                 border: OutlineInputBorder(),
//               ),
//               items: _expenseCategories.map((category) {
//                 return DropdownMenuItem(
//                   value: category,
//                   child: Text(category),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedCategory = value!;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             // Description
//             TextField(
//               controller: _descriptionController,
//               decoration: const InputDecoration(
//                 labelText: 'Description (Optional)',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Date & Time
//             Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     title: const Text('Date'),
//                     subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
//                     trailing: const Icon(Icons.calendar_today),
//                     onTap: () async {
//                       final date = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime.now().add(const Duration(days: 3650)),
//                       );
//                       if (date != null) {
//                         setState(() {
//                           _selectedDate = date;
//                         });
//                       }
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: const Text('Time'),
//                     subtitle: Text(_selectedTime.format(context)),
//                     trailing: const Icon(Icons.access_time),
//                     onTap: () async {
//                       final time = await showTimePicker(
//                         context: context,
//                         initialTime: _selectedTime,
//                       );
//                       if (time != null) {
//                         setState(() {
//                           _selectedTime = time;
//                         });
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             final amount = double.tryParse(_amountController.text);
//             if (amount != null && amount > 0) {
//               final dateTime = DateTime(
//                 _selectedDate.year,
//                 _selectedDate.month,
//                 _selectedDate.day,
//                 _selectedTime.hour,
//                 _selectedTime.minute,
//               );

//               final newExpense = ExpenseEntry(
//                 id: isEditing ? expense.id : DateTime.now().millisecondsSinceEpoch.toString(),
//                 date: dateTime,
//                 amount: amount,
//                 category: _selectedCategory,
//                 type: _selectedType,
//                 description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
//               );

//               if (isEditing) {
//                 notifier.update(newExpense);
//               } else {
//                 notifier.add(newExpense);
//               }

//               Navigator.of(context).pop();
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Please enter a valid amount')),
//               );
//             }
//           },
//           child: Text(isEditing ? 'Update' : 'Add'),
//         ),
//       ],
//     );
//   }

//   void _showDeleteConfirmation(ExpenseEntry expense, ExpenseStateManager notifier) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Expense'),
//         content: const Text('Are you sure you want to delete this expense?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               notifier.remove(expense.id);
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//   }
// }
