import 'dart:ffi';
import 'dart:io';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = ShowFavouritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    print('Selected index: $value');
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favourites = <WordPair>[];

  void toggleFavourite() {
    if (favourites.contains(current)) {
      favourites.remove(current);
      print('Removed from favourites: $current');
    } else {
      favourites.add(current);
      print('Added to favourites: $current');
    }
    notifyListeners();
  }

  void removeFavourite(WordPair pair) {
    favourites.remove(pair);
    print('Removed from favourites: $pair');
    notifyListeners();
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pairWord = appState.current;
    var heartIcon = appState.favourites.contains(pairWord)
        ? Icons.favorite
        : Icons.favorite_border;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WordCard(pairWord: pairWord),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    print('toggleFavourite button pressed!');
                    appState.toggleFavourite();
                  },
                  icon: Icon(heartIcon, color: Colors.red),
                  label: Text('Like', style: TextStyle(fontSize: 30)),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    print('getNext button pressed!');
                    appState.getNext();
                  },
                  child: Text('Next', style: TextStyle(fontSize: 30)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.pairWord});

  final WordPair pairWord;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.primary;
    final fontStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold,
    );

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          pairWord.asPascalCase,
          style: fontStyle,
          semanticsLabel: "${pairWord.first}${pairWord.second}",
        ),
      ),
    );
  }
}

class ShowFavouritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final Color colorTheme = Theme.of(context).colorScheme.primary;

    return Container(
      color: colorTheme,
      child: appState.favourites.isEmpty
          ? Center(
            child: Text('No favourites yet!', 
            style: TextStyle(
              color : Theme.of(context).colorScheme.onPrimary,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              ),
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You have ${appState.favourites.length} favourites:',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                for (var pair in appState.favourites)
                  ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: TextStyle(color : Theme.of(context).colorScheme.onPrimary),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        color : Theme.of(context).colorScheme.onPrimary,
                        onPressed: (){
                          appState.removeFavourite(pair);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${pair.asPascalCase} from favourites'),
                              duration: Duration(seconds: 2,)
                            )
                          );
                        }
                      )
                    ),
              ],
            ),
    );
  }
}
