import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ChickenProApp());
}

class ChickenProApp extends StatelessWidget {
  const ChickenProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chicken Pro',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class Chicken {
  final String name;
  final String breed;
  int eggsToday;
  Map<String, int> eggHistory;

  Chicken({
    required this.name,
    required this.breed,
    this.eggsToday = 0,
    Map<String, int>? eggHistory,
  }) : eggHistory = eggHistory ?? {};
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chicken> chickens = [];

  void _addChicken(String name, String breed) {
    setState(() {
      chickens.add(Chicken(name: name, breed: breed));
    });
  }

  void _showAddChickenDialog() {
    String name = '';
    String breed = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Chicken'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Breed'),
                onChanged: (value) => breed = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                if (name.isNotEmpty && breed.isNotEmpty) {
                  _addChicken(name, breed);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _logEggForChicken(int index) {
    setState(() {
      chickens[index].eggsToday++;
      String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      chickens[index].eggHistory[today] = (chickens[index].eggHistory[today] ?? 0) + 1;
    });
  }

  void _showHistoryDialog(Chicken chicken) {
    showDialog(
      context: context,
      builder: (context) {
        final entries = chicken.eggHistory.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key));
        return AlertDialog(
          title: Text('${chicken.name} Egg History'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text('${entry.value} egg(s)'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  int _getTotalEggsToday() {
    return chickens.fold(0, (sum, chicken) => sum + chicken.eggsToday);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chicken Tracker'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    'Eggs Collected Today',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_getTotalEggsToday()}',
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Your Chickens',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: chickens.length,
                itemBuilder: (context, index) {
                  final chicken = chickens[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.pets, color: Colors.brown[400]),
                      title: Text(chicken.name),
                      subtitle: Text('Breed: ${chicken.breed} | Eggs Today: ${chicken.eggsToday}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () => _logEggForChicken(index),
                        tooltip: 'Log Egg for ${chicken.name}',
                        color: Colors.brown,
                      ),
                      onTap: () => _showHistoryDialog(chicken),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _showAddChickenDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                ),
                child: const Text('Add Chicken'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
