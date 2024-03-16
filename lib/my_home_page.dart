import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchText = '';

  _onSearchTextChanged(String text) {
    setState(() {
      searchText = text;
    });
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            color: Colors.white,
            child: ListTile(
              leading: const Icon(Icons.search),
              title: TextField(
                decoration: const InputDecoration(
                    hintText: 'Search', border: InputBorder.none),
                onChanged: _onSearchTextChanged,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  _onSearchTextChanged('');
                },
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('waivers').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              var filteredItems = snapshot.data!.docs;
              var filteredItemCount = filteredItems.length;

              if (searchText != '') {
                final lowerCaseSearchText = searchText.toLowerCase();
                filteredItems = filteredItems
                    .where((i) =>
                        i
                            .get('fullName')
                            .toString()
                            .toLowerCase()
                            .contains(lowerCaseSearchText) ||
                        i
                            .get('email')
                            .toString()
                            .toLowerCase()
                            .contains(lowerCaseSearchText))
                    .toList();
                filteredItemCount = filteredItems.length;
              }

              if (filteredItemCount == 0) {
                return const Center(
                  child: Text(
                    'No waivers found',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                );
              }

              // return const Center(child: Text('Data'));
              return ListView.builder(
                itemCount: filteredItemCount,
                itemBuilder: (context, index) {
                  // Get the data from the snapshot
                  var data = filteredItems[index];

                  // Use the data to build your list view
                  return Card(
                    child: ListTile(
                      title: Text(data['fullName']),
                      subtitle: Text(data['email']),
                      trailing: ElevatedButton(
                        onPressed: () async {
                          await _launchUrl(data['downloadUrl']);
                        },
                        child: const Text('View Waiver'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
