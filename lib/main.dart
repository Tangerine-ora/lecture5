// 生命周期日志按课堂要求使用 print 观察钩子顺序，生产代码应换 debugPrint/日志框架
// ignore_for_file: avoid_print

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

  // ---- 改造二：State 生命周期日志（每个钩子一行 print） ----
  @override
  void initState() {
    super.initState();
    print('[lifecycle] initState：一次性初始化，State 挂载');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('[lifecycle] didChangeDependencies：依赖的 InheritedWidget（Theme）变化');
  }

  @override
  void didUpdateWidget(covariant CounterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('[lifecycle] didUpdateWidget：父级传入新配置 title=${oldWidget.title}');
  }

  @override
  void deactivate() {
    print('[lifecycle] deactivate：被暂时从树上摘下');
    super.deactivate();
  }

  @override
  void dispose() {
    print('[lifecycle] dispose：State 销毁，此处应取消订阅/释放控制器');
    super.dispose();
  }

  // ---- 交互逻辑 ----
  void _increment() {
    print('[lifecycle] FAB 点击：setState 即将把当前 Element 标记为 dirty');
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
    print('[lifecycle] build：count=$_count, step=$_step');
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
            // 改造二：资源图片作空状态插画（pubspec 声明 assets/images/）
            if (_count == 0) ...[
              Image.asset(
                'assets/images/logo.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 12),
              const Text('点右下角 + 开始计数'),
              const SizedBox(height: 12),
            ],
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
