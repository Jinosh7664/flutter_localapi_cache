import "dart:convert";
import "dart:io";

import "package:flutter/material.dart";
import "package:http/http.dart";
import "package:path_provider/path_provider.dart";

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
  final String uri = "https://api.urbandictionary.com/v0/define?term=Love";

  Future<String> get _localPath async {
    final Directory directory = await getApplicationSupportDirectory();

    return directory.path;
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
                  final String path = "${await _localPath}love.json";

                  await File(path).writeAsString(response!.body);
                  debugPrint("Stored");
                },
                child: const Text("Store"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final String path = "${await _localPath}love.json";
                  final String data = await File(path).readAsString();
                  setState(() {
                    contentString = data;
                  });
                  debugPrint("Read");
                },
                child: const Text("View Content"),
              ),
              Text(
                jsonDecode(contentString).toString(),
                style: Theme.of(context).primaryTextTheme.bodyMedium!.copyWith(
                      color: Colors.black,
                    ),
              ),
            ],
          ),
        ),
      );
}
