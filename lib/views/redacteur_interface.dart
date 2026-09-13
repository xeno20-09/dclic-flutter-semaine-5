import 'package:flutter/material.dart';

import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _databaseManager = DatabaseManager();

  final TextEditingController _nomController = TextEditingController();

  final TextEditingController _prenomController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();
  List<Redacteur> _redacteurs = [];
  Future<void> _chargerRedacteurs() async {
    final redacteurs = await _databaseManager.getAllRedacteurs();

    setState(() {
      _redacteurs = redacteurs;
    });
  }

  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final nomController = TextEditingController(text: redacteur.nom);

    final prenomController = TextEditingController(text: redacteur.prenom);

    final emailController = TextEditingController(text: redacteur.email);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier le rédacteur'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),

              TextField(
                controller: prenomController,
                decoration: const InputDecoration(labelText: 'Prénom'),
              ),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              onPressed: () async {
                final nouveauRedacteur = Redacteur(
                  id: redacteur.id,
                  nom: nomController.text.trim(),
                  prenom: prenomController.text.trim(),
                  email: emailController.text.trim(),
                );

                await _databaseManager.updateRedacteur(nouveauRedacteur);

                if (!context.mounted) return;

                Navigator.pop(context);

                await _chargerRedacteurs();
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerRedacteur(Redacteur redacteur) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le rédacteur'),

          content: Text(
            'Voulez-vous vraiment supprimer '
            '${redacteur.prenom} ${redacteur.nom} ?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annuler'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmation == true) {
      await _databaseManager.deleteRedacteur(redacteur.id!);

      await _chargerRedacteurs();
    }
  }

  Future<void> _ajouterRedacteur() async {
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    } else {
      final redacteur = Redacteur(nom: nom, prenom: prenom, email: email);

      await _databaseManager.insertRedacteur(redacteur);
      _nomController.clear();
      _prenomController.clear();
      _emailController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rédacteur ajouté avec succès')),
      );
      await _chargerRedacteurs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Magazine Infos')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _ajouterRedacteur,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un rédacteur'),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (context, index) {
                  final redacteur = _redacteurs[index];

                  return Card(
                    child: ListTile(
                      title: Text('${redacteur.prenom} ${redacteur.nom}'),
                      subtitle: Text(redacteur.email),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _modifierRedacteur(redacteur);
                            },
                          ),

                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _supprimerRedacteur(redacteur);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
