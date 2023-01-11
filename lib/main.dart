// @dart = 2.9
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repository List',
      home: RepositoryList(),
    );
  }
}

class RepositoryList extends StatefulWidget {
  @override
  _RepositoryListState createState() => _RepositoryListState();
}

class _RepositoryListState extends State<RepositoryList> {
  List<dynamic> _repositories = [];
  Map<String, dynamic> _lastCommits = {};
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _getRepositories() async {
    String username = _usernameController.text;
    final response =
        await http.get("https://api.github.com/users/$username/repos");
    if (response.statusCode == 200) {
      setState(() {
        _repositories = json.decode(response.body);
      });
      for (var repo in _repositories) {
        var lastCommit = await _getLastCommit(username, repo['name']);
        setState(() {
          _lastCommits[repo['name']] = lastCommit;
        });
      }
    } else {
      throw Exception('Failed to fetch repositories');
    }
  }

  Future<dynamic> _getLastCommit(String username, String repoName) async {
    final commitResponse = await http
        .get("https://api.github.com/repos/$username/$repoName/commits");
    if (commitResponse.statusCode == 200) {
      return json.decode(commitResponse.body)[0];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repositories'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Enter the Github username",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _getRepositories,
              child: const Text('Fetch Repositories'),
            ),
            ..._repositories.map((repo) {
              return ListTile(
                title: Text(
                  repo['name'],
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                subtitle: Text(
                  _lastCommits[repo['name']] != null
                      ? _lastCommits[repo['name']]['commit']['message']
                      : '',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                trailing: Text(repo['stargazers_count'].toString()),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
