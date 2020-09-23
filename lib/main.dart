import 'package:flutter/material.dart';
import 'auth.dart';
import 'root_page.dart';

void main() {
  runApp(Fire());
}

class Fire extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RootPage(auth: Auth());
  }
}
