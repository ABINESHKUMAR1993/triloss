import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final int talktime;
  final int payableAmount;
  final double cgstRate = 0.09;
  final double sgstRate = 0.09;

  const PaymentScreen({
    super.key,
    required this.talktime,
    required this.payableAmount,
  });

  double get cgstAmount => payableAmount * cgstRate;
  double get sgstAmount => payableAmount * sgstRate;
  double get totalAmount => payableAmount + cgstAmount + sgstAmount;

  Future<void> _handlePayment() async {
    // TODO: Implement payment gateway integration
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          padding: const EdgeInsets.only(left: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            PaymentRow(label: 'Talktime', amount: talktime.toString()),
            PaymentRow(
              label: 'Tax (CGST ${(cgstRate * 100).toInt()}%)',
              amount: cgstAmount.toStringAsFixed(2),
            ),
            PaymentRow(
              label: 'Tax (SGST ${(sgstRate * 100).toInt()}%)',
              amount: sgstAmount.toStringAsFixed(2),
            ),
            const Divider(height: 32),
            PaymentRow(
              label: 'Payable Amount',
              amount: totalAmount.toStringAsFixed(2),
              isBold: true,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class PaymentRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool isBold;

  const PaymentRow({
    super.key,
    required this.label,
    required this.amount,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            '₹$amount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
