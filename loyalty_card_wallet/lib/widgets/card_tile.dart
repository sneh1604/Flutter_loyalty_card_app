import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardTile extends StatelessWidget {
  final LoyaltyCard card;

  const CardTile({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(card.title),
        subtitle: Text(card.notes),
        trailing: card.expirationDate != null
            ? Text('Expires: ${_formatDate(card.expirationDate!)}')
            : null,
        onTap: () {
          // Show barcode display screen
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
