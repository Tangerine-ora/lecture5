import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'counter_deep',
      theme: ThemeData(
        // 改造一：默认蓝(deepPurple)改为 teal 种子色，Material 3
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CounterPage(title: 'counter_deep 演示'),
    );
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _count = 0;
  int _step = 1; // 改造一：新增步长状态

  void _increment() {
    setState(() {
      _count += _step; // 每次按步长累加，不再是固定 +1
    });
  }

  void _changeStep(int step) {
    setState(() {
      _step = step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          // 改造一：AppBar 右侧步长选择器，弹层选择 1/2/5
          PopupMenuButton<int>(
            tooltip: '选择步长',
            onSelected: _changeStep,
            itemBuilder: (context) => [1, 2, 5]
                .map((s) => PopupMenuItem<int>(
                      value: s,
                      child: Text('步长 $s${s == _step ? '（当前）' : ''}'),
                    ))
                .toList(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text('步长')),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('你已经按了按钮这么多次：'),
            Text(
              '$_count',
              // Theme.of 取用①：大号数字用主题主色
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            // Theme.of 取用②：提示文字用主题次色
            Text(
              '当前步长 $_step',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: '按步长递增',
        child: const Icon(Icons.add),
      ),
    );
  }
}
