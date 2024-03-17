import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:path_provider/path_provider.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(final BuildContext context) => const MaterialApp(
        home: HomeScreen(),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Response? response;
  String contentString = "";
  final String file = "love";
  final String uri = "https://api.urbandictionary.com/v0/define?term=Love";
  List<String> existingFiles = <String>[];
  final String fileListKey = "existingFiles";

  @override
  void initState() {
    super.initState();
    unawaited(checkLocal());
  }

  Future<void> checkLocal() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    existingFiles = preferences.getStringList(fileListKey) ?? <String>[];
    setState(() {});
  }

  Future<String> get _localPath async {
    final Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> readLocal() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    existingFiles = preferences.getStringList(fileListKey) ?? <String>[];
    if (existingFiles.contains(file)) {
      final String path = "${await _localPath}$file.json";
      final String data = await File(path).readAsString();
      setState(() {
        contentString = data;
      });
    }

    debugPrint("Read");
  }

  Future<void> writeData() async {
    if (response != null) {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      existingFiles = preferences.getStringList(fileListKey) ?? <String>[];
      final String path = "${await _localPath}$file.json";
      await File(path).writeAsString(response!.body);
      existingFiles.add(file);
      await preferences.setStringList(
        fileListKey,
        existingFiles,
      );
    }

    debugPrint("Stored");
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "LocalAPI Cache Manager",
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              Text("Existin Files are $existingFiles"),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final Response data = await get(
                      Uri.parse(
                        uri,
                      ),
                    );
                    setState(() {
                      response = data;
                    });

                    debugPrint("Downloaded");
                  },
                  child: const Text("Download"),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await writeData();
                },
                child: const Text("Store"),
              ),
              ElevatedButton(
                onPressed: () async {
                  await readLocal();
                },
                child: const Text("View Content"),
              ),
              Text(
                contentString.isNotEmpty
                    ? jsonDecode(contentString).toString()
                    : contentString,
                style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                    ),
              ),
            ],
          ),
        ),
      );
}
