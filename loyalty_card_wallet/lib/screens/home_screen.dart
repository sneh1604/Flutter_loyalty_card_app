import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cards_provider.dart';
import '../widgets/card_tile.dart';
import 'add_card_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loyalty Cards'),
      ),
      body: Consumer<CardsProvider>(
        builder: (context, cardsProvider, child) {
          final cards = cardsProvider.cards;

          if (cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, size: 64, color: Colors.grey),
                  Text('No loyalty cards yet'),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCardScreen(),
                      ),
                    ),
                    child: Text('Add Your First Card'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) => CardTile(card: cards[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddCardScreen()),
        ),
        child: Icon(Icons.add),
      ),
    );
  }
}
