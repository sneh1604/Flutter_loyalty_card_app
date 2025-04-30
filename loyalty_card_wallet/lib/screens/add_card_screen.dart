import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/card_model.dart';
import '../providers/cards_provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddCardScreen extends StatefulWidget {
  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _expirationDate;

  Future<void> _scanBarcode() async {
    try {
      final barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      if (barcode != '-1') {
        setState(() {
          _barcodeController.text = barcode;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan barcode')),
      );
    }
  }

  void _saveCard() {
    if (_formKey.currentState?.validate() ?? false) {
      final card = LoyaltyCard(
        title: _titleController.text,
        barcodeData: _barcodeController.text,
        expirationDate: _expirationDate,
        notes: _notesController.text,
      );

      context.read<CardsProvider>().addCard(card);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Loyalty Card'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Card Title'),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: InputDecoration(labelText: 'Barcode'),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Please enter barcode' : null,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner),
                  onPressed: _scanBarcode,
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveCard,
        child: Icon(Icons.save),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _barcodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
