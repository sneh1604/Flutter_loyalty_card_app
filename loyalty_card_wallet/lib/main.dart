import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/local_storage_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'providers/cards_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  final notificationService = NotificationService();
  await notificationService.init();

  // TODO: Replace with actual user ID from authentication
  const userId = 'test_user';
  final firebaseService = FirebaseService(userId: userId);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CardsProvider(
            localStorageService,
            firebaseService,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loyalty Card Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}
