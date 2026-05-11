import 'package:flutter/material.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加餐點'),
      ),
      body: const Center(
        child: Text('添加餐點頁面'),
      ),
    );
  }
}