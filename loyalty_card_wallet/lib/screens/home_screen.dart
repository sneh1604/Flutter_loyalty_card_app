import 'dart:io';
import 'package:ext/pages/card_details_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ext/blocs/dashboard/dashboard_bloc.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:ext/widgets/loyalty_card_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:ext/pages/statistics_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            if (state is DashboardInitial) {
              context.read<DashboardBloc>().add(LoadDashboard());
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 180.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Loyalty Cards',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${state.cards.length} Active Cards',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.analytics),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StatisticsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Stats Overview
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildStatCard(
                          context,
                          'Active',
                          state.cards
                              .where((card) => !card.isUsed)
                              .length
                              .toString(),
                          Colors.green,
                        ),
                        const SizedBox(width: 12),
                        _buildStatCard(
                          context,
                          'Used',
                          state.cards
                              .where((card) => card.isUsed)
                              .length
                              .toString(),
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),

                // Cards Grid
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final card = state.cards[index];
                        return Hero(
                          tag: 'card-${card.id}',
                          child: Material(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CardDetailsPage(card: card),
                                  ),
                                );
                              },
                              child: Dismissible(
                                key: Key(card.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  context
                                      .read<DashboardBloc>()
                                      .add(DeleteCard(card.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${card.cardName} deleted'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete, color: Colors.white),
                                      SizedBox(height: 4),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                                child: LoyaltyCardWidget(
                                  card: card,
                                  onMarkUsed: (cardToUpdate, isUsed) {
                                    context.read<DashboardBloc>().add(
                                          UpdateCardUsage(
                                            cardId: cardToUpdate.id,
                                            isUsed: isUsed,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.cards.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                  ),
                ),
              ],
            );
          } else if (state is DashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Card'),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loyalty Cards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bc) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Loyalty Card',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildOptionTile(
                context: context,
                icon: Icons.qr_code_2_rounded,
                title: 'Scan QR Code',
                subtitle: 'Quick add from QR code',
                iconColor: const Color(0xFF6C63FF),
                onTap: () {
                  Navigator.pop(context);
                  _showCodeEntryDialog(context);
                },
              ),
              _buildOptionTile(
                context: context,
                icon: Icons.add_card_rounded,
                title: 'Manual Entry',
                subtitle: 'Enter card details manually',
                iconColor: const Color(0xFF4CAF50),
                onTap: () {
                  Navigator.pop(context);
                  _showManualEntryDialog(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showCodeEntryDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Code'),
          content: TextField(
            controller: codeController,
            decoration:
                const InputDecoration(hintText: "Enter loyalty card code"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                print('Entered code: ${codeController.text}');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Code entry/scanning not implemented yet.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final cardNameController = TextEditingController();
    final couponCodeController = TextEditingController();
    DateTime? selectedDate;
    XFile? pickedImage;

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> selectDate(BuildContext context) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
              }
            }

            Future<void> pickImageDialog(ImageSource source) async {
              try {
                final XFile? image = await picker.pickImage(source: source);
                if (image != null) {
                  setState(() {
                    pickedImage = image;
                  });
                }
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to pick image: $e')),
                );
              }
            }

            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Card',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add your loyalty card details',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: cardNameController,
                              decoration: InputDecoration(
                                labelText: 'Card Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.card_membership),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a card name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        selectedDate == null
                                            ? 'Select Expiry Date'
                                            : 'Expires: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: couponCodeController,
                              decoration: InputDecoration(
                                labelText: 'Coupon Code (Optional)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.code),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildImagePickerButton(
                                  Icons.photo_library,
                                  'Gallery',
                                  Colors.purple,
                                  () => pickImageDialog(ImageSource.gallery),
                                ),
                                _buildImagePickerButton(
                                  Icons.camera_alt,
                                  'Camera',
                                  Colors.blue,
                                  () => pickImageDialog(ImageSource.camera),
                                ),
                              ],
                            ),
                            if (pickedImage != null) ...[
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.network(pickedImage!.path,
                                        height: 150)
                                    : Image.file(File(pickedImage!.path),
                                        height: 150),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              if (formKey.currentState!.validate() &&
                                  selectedDate != null) {
                                final newCard = LoyaltyCard(
                                  id: const Uuid().v4(),
                                  cardName: cardNameController.text,
                                  expiryDate: selectedDate!,
                                  couponCode:
                                      couponCodeController.text.isNotEmpty
                                          ? couponCodeController.text
                                          : null,
                                  imagePath: pickedImage?.path,
                                  isUsed:
                                      false, // Ensure new cards start as not used
                                );
                                context
                                    .read<DashboardBloc>()
                                    .add(AddCard(newCard));
                                Navigator.of(context).pop();
                              } else if (selectedDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Please select an expiry date.')),
                                );
                              }
                            },
                            child: const Text('Save Card'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImagePickerButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
