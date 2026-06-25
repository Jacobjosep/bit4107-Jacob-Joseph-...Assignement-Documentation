import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/loan_provider.dart';
import '../providers/auth_provider.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _guarantorNameController = TextEditingController();
  final _guarantorPhoneController = TextEditingController();
  int _durationMonths = 6;

  void _applyForLoan() {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        loanProvider.applyForLoan(
          userId: user.id,
          userName: user.fullName,
          amount: double.parse(_amountController.text.trim()),
          purpose: _purposeController.text.trim(),
          durationMonths: _durationMonths,
          guarantorName: _guarantorNameController.text.trim(),
          guarantorPhone: _guarantorPhoneController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Loan application submitted successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        _amountController.clear();
        _purposeController.clear();
        _guarantorNameController.clear();
        _guarantorPhoneController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Loan'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.monetization_on,
                size: 60,
                color: Color(0xFF1B5E20),
              ),
              const SizedBox(height: 10),
              const Text(
                'Loan Application',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Fill in the details below to apply for a loan',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Loan Amount (KES)',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > 100000) {
                    return 'Maximum loan amount is KES 100,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Loan Purpose',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Text(
                'Loan Duration: $_durationMonths months',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Slider(
                value: _durationMonths.toDouble(),
                min: 1,
                max: 12,
                divisions: 11,
                label: '$_durationMonths months',
                onChanged: (value) {
                  setState(() {
                    _durationMonths = value.round();
                  });
                },
                activeColor: const Color(0xFF1B5E20),
              ),
              const SizedBox(height: 15),
              const Text(
                'Guarantor Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _guarantorNameController,
                decoration: const InputDecoration(
                  labelText: 'Guarantor Full Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter guarantor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _guarantorPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Guarantor Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '254XXXXXXXXX',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter guarantor phone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loan Preview',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildPreviewRow(
                        'Principal Amount',
                        _amountController.text.isNotEmpty
                            ? 'KES ${double.parse(_amountController.text).toStringAsFixed(2)}'
                            : 'KES 0.00',
                      ),
                      _buildPreviewRow(
                        'Interest Rate',
                        _calculateInterestRate().toStringAsFixed(1) + '%',
                      ),
                      _buildPreviewRow('Duration', '$_durationMonths months'),
                      _buildPreviewRow(
                        'Total Repayment',
                        'KES ${_calculateTotalRepayment().toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Consumer<LoanProvider>(
                  builder: (context, loanProvider, child) {
                    return ElevatedButton(
                      onPressed: loanProvider.isLoading ? null : _applyForLoan,
                      child: loanProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'SUBMIT APPLICATION',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  double _calculateInterestRate() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return 8.0;
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 10000) return 8.0;
    if (amount <= 50000) return 10.0;
    if (amount <= 100000) return 12.0;
    return 14.0;
  }

  double _calculateTotalRepayment() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return 0.0;
    final amount = double.tryParse(amountText) ?? 0;
    final interestRate = _calculateInterestRate();
    return amount + (amount * interestRate / 100);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _guarantorNameController.dispose();
    _guarantorPhoneController.dispose();
    super.dispose();
  }
}
