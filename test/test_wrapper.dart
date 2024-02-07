import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TestWrapper extends StatelessWidget {
  const TestWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }
}
