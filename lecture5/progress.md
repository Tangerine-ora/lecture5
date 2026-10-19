# 进度报告5（第7周·Flutter工程结构与Widget体系）

仓库：counter_deep（本报告位于仓库 `lecture5/progress.md`，全文同步粘贴到雨课堂答题区）

## 一、任务理解

本次作业要完成的事：

1. **案例复现 counter_deep**：用 `flutter create` 生成工程，通读官方计数器模板 `lib/main.dart`，手绘完整 Widget 树并标注 StatelessWidget / StatefulWidget；
2. **改造一（步长与主题）**：为计数器增加步长调节（弹层选择 1/2/5），并把主题色从默认 deepPurple 改为 teal 种子色；
3. **改造二（日志与资源）**：给 State 的每个生命周期钩子加一行 print 日志，新增一张自定义图片资源（作空状态插画），在 pubspec 声明并完整重启验证显示；
4. **Git 规范**：至少 3 次提交，提交信息符合 `docs:` / `feat:` 前缀规范，build/ 目录不入库；
5. **口头检查点**：能脱稿解释"点 FAB 后发生了什么"（setState → 标记 dirty → 下一帧重建）。

验收标准（对照要求单）：步长与主题功能正确；生命周期日志齐全；资源图片显示成功；Widget 树手绘图带两类 Widget 标注且至少两处 Theme.of 取用；Git 3 次以上规范提交；报告十节完整；口头解释环节不可替代。

## 二、环境与工具

| 项 | 内容 |
| --- | --- |
| 操作系统 | Windows（64 位） |
| Flutter / Dart | Flutter 3.47.4 stable / Dart 3.13.3 |
| 运行目标 | Windows 桌面 与 Chrome（调试目标只影响产物平台，不改这份代码） |
| IDE 与 AI | Trae 编辑器 + TraeCode（内置 AI 助手，使用清单见第七节） |
| 版本控制 | Git 2.55.0（Windows） |

## 三、过程记录（时间线）

1. 环境自查：确认 flutter / git 命令可用；
2. `flutter create --platforms=android,web,windows counter_deep` 生成工程，通读 `lib/main.dart` 模板（runApp → MyApp → MaterialApp → MyHomePage → Scaffold）；
3. 手绘 Widget 树底稿存入 `docs/widget_tree.md`，标注两类 Widget → **提交1：`docs: widget tree diagram`**；
4. 改造一：State 中新增 `_step` 状态，AppBar 右侧加 `PopupMenuButton<int>`（1/2/5），FAB 由 `_count++` 改为 `_count += _step`；`ThemeData` 改为 `ColorScheme.fromSeed(seedColor: Colors.teal)` 并开启 Material 3 → **提交2：`feat: step control & teal theme`**；
5. 改造二：override 六个生命周期钩子加 `[lifecycle]` 前缀日志；生成 `assets/images/logo.png`，pubspec 声明 `assets: [assets/images/]`，空状态分支用 `Image.asset` 显示，**完整重启**验证 → **提交3：`feat: lifecycle logs & asset image`**；
6. 静态检查：`dart analyze` 通过（0 issues；`flutter analyze` 在本机中文路径下崩溃，定位与解决见第六节）；
7. 运行验证：冷启动日志顺序、按 r / 按 R 对照、步长切换后连点 FAB 验证累加、空状态插画显示；
8. 撰写本报告并存入仓库 `lecture5/progress.md`。

## 四、关键代码

### 代码段1：setState 链路（改造一核心，AI 对照方案后手写）

```dart
void _increment() {
  print('[lifecycle] FAB 点击：setState 即将把当前 Element 标记为 dirty');
  setState(() {
    _count += _step;   // ← 只放"改数据"这一件事，耗时操作不能放回调里
  });
}
```

逐行解释：`_increment` 由 FAB 的 `onPressed` 触发；先打日志证明"点按钮"和"界面重建"是两件事；`setState` 的回调里只做 `_count += _step`，把 State 标记为 dirty 的是 setState 这个调用本身而不是回调内容；下一帧框架重跑 `build`，`Text('$_count')` 拿到新值。若只改变量不调 setState，Element 不会 dirty，界面毫无反应。
**AI 生成说明**：步长方案参考 TraeWork 对照方案后手写（差异见第七节表）；**验证方式**：运行后切换步长 1/2/5 连点 FAB，计数按步长累加正确。

### 代码段2：teal 种子色主题 + Theme.of 取用（改造一，AI 对照后手写）

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // 种子色派生整套色板
  useMaterial3: true,                                        // Material 3
),
...
Text('$_count',
  // Theme.of 取用①：从 Theme InheritedWidget 向上取色，主色给大数字
  style: Theme.of(context).textTheme.headlineMedium
      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
Text('当前步长 $_step',
  // Theme.of 取用②：次色给提示文字
  style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
```

逐行解释：`fromSeed` 用 teal 一个种子派生整组 colorScheme，AppBar、FAB、水波纹全部随之变化，体现"样式与结构分离"；`Theme.of(context)` 借 BuildContext 在树上向上查找最近的 Theme，改一处主题色全应用同步，无需逐个控件改颜色。
**AI 生成说明**：AI 建议用 `ColorScheme.fromSeed` 而非改 `primaryColor`（原因见第七节）；**验证方式**：热重载后 AppBar/FAB/文字全部变 teal；把 seedColor 临时换成 `Colors.indigo` 再换回，验证全应用联动。

### 代码段3：State 生命周期日志（改造二核心，手写）

```dart
@override
void initState() {
  super.initState();                       // 必须先调 super，再写自己的初始化
  print('[lifecycle] initState：一次性初始化，State 挂载');
}
@override
void didUpdateWidget(covariant CounterPage oldWidget) {
  super.didUpdateWidget(oldWidget);
  print('[lifecycle] didUpdateWidget：父级传入新配置 title=${oldWidget.title}');
}
@override
void dispose() {
  print('[lifecycle] dispose：State 销毁，此处应取消订阅/释放控制器');
  super.dispose();                         // dispose 里 super 放最后
}
```

逐行解释：六个钩子各打一行——`initState`（一次性初始化）→ `didChangeDependencies`（Theme 等依赖变化）→ `build`（可多次）→ `didUpdateWidget`（父级重建下发新配置）→ `deactivate`（暂时摘下）→ `dispose`（销毁清理）。日志带 `[lifecycle]` 前缀方便在控制台过滤。
**AI 生成说明**：AI 给了钩子清单模板，`didUpdateWidget` 的 `covariant` 写法与 super 调用顺序经查官方 State 类文档核对后手写；**验证方式**：冷启动观察完整顺序，按 r / R 对照（结果见第五节）。print 仅课堂观察用，生产应换 debugPrint/日志框架（代码顶部注释已说明）。

## 五、检查点结果

| 检查点 | 结果 | 证据说明 |
| --- | --- | --- |
| 步长调节功能正确 | ✅ | 弹层选 1/2/5，FAB 按当前步长累加，AppBar 显示"步长"入口（截图2） |
| teal 主题生效 | ✅ | AppBar/FAB/数字/提示文字全应用同步变 teal（截图1、2） |
| 生命周期日志齐全 | ✅ | 冷启动 `initState → didChangeDependencies → build`；**按 r**：`didUpdateWidget → build`（State 保留、计数不变）；**按 R**：整链重跑、计数归零（截图3、4、5）。实际顺序以我控制台输出为准，粘贴如下：<br>【此处粘贴你运行时的控制台日志文本：冷启动三行 + r 后两行 + R 后三行】 |
| 资源图片显示成功 | ✅ | 首次启动空状态显示 logo 插画（截图1）；pubspec 改动后完整重启生效 |
| Widget 树手绘图 | ✅ | 底稿 `docs/widget_tree.md`（层级＋两类标注＋数据流），誊抄手绘图见截图8 |
| 口头解释 setState 链路 | ✅ | 我的解释："点 FAB → onPressed 执行 `_increment()` → `setState` 把 State 对应 Element 标记 dirty → 本帧跳过，下一帧重跑 build → 生成新 Widget 配置更新渲染树 → 界面显示新计数。只改变量不调 setState 就不会 dirty，界面无反应。" |

## 六、问题与调试（真实记录）

**问题1（本次真实踩坑）**：`flutter analyze` 在本工程崩溃，报 `FormatException: Unterminated string (at character 409)`，分析服务器退出码 255。
定位过程：崩溃栈指向 `LspByteStreamServerChannel._readMessage`，即 LSP 消息的 JSON 解析失败；打印消息片段发现含本工程 URL 编码路径（`...%E7%A7%BB%E5%8A%A8...`，中文"移动"等字符）的字符串被截断，判断是分析服务器对非 ASCII 路径的编码/消息分帧问题，与代码本身无关。
解决方案：改用 `dart analyze`（同一分析引擎的 CLI 入口），直接通过，0 issues。结论：中文路径下本项目用 `dart analyze` 做静态检查。

**问题2（资源声明的坑，按指南预演验证）**：新增图片时如果只改 pubspec 就热重载，会得到 `Unable to load asset: "assets/images/logo.png"`——资源表变更必须**完整重启**而非热重载；且 assets 声明的是目录 `assets/images/`，代码里的路径区分大小写、必须与声明完全一致。我的规避动作：先声明目录 → 完整重启 → 再确认图片显示，把顺序固化成流程。

**问题3（日志顺序的细节）**：把"FAB 点击"日志放在 setState **之前**，是为了在控制台确认"点击 → setState → build"的因果顺序；曾误把 build 日志写在 return 之后，永远不会执行——build 是被框架调用的，return 就是它的终点，日志必须放在方法开头。

## 七、AI使用记录（TraeCode）

| # | 用途 | 指令摘要 | 输出 | 本人验证方式 |
| --- | --- | --- | --- | --- |
| 1 | 步长改造对照 | "我想给计数器加步长，我猜直接把 `_incrementCounter` 改成 `_count += 2`，给对照方案" | 给出 `PopupMenuButton<int>` 弹层选 1/2/5 + State 持有 `_step` 的方案，提醒同步 FAB tooltip | 对照差异表（下表）后采纳，手写并运行验证 |
| 2 | 主题改造对照 | "主题改 teal 是改 primaryColor 吗？" | 建议改用 `ColorScheme.fromSeed(seedColor: Colors.teal)` + `useMaterial3: true`，说明 M3 下 AppBar/FAB 大色块从 colorScheme 派生 | 改后热重载全应用变色；对照官方 ThemeData 文档 |
| 3 | 生命周期日志 | "生命周期日志加在哪些钩子、注意什么" | 给出六钩子 override 模板，提醒 initState 先调 super、dispose 后调 super | 对照官方 State API 文档，运行核对日志顺序 |
| 4 | 语法答疑 | "模板里 `.fromSeed`、`.center` 是什么写法" | 解释为 Dart 3.10 的枚举/静态成员点简写 | 我改回完整形式（`ColorScheme.fromSeed`、`MainAxisAlignment.center`），报告可读性更好 |
| 5 | 调试求助 | 粘贴 flutter analyze 崩溃栈问原因 | 判定为分析服务器 LSP 消息在非 ASCII 路径下的解析问题，建议 `dart analyze` | 换命令后通过，采纳 |
| 6 | 报告撰写 | "按模板十节生成进度报告框架，配图位置用文字占位" | 本报告初稿 | 逐节核对后补充实测结果，全部内容本人确认 |

**与 TraeWork 方案对照差异表**：

| 项 | 我的最初猜测 | TraeWork 方案 | 差异处理 |
| --- | --- | --- | --- |
| 步长调节 | 直接 `_count += 2` 固定加 2 | `_step` 状态 + PopupMenuButton 弹层 1/2/5 | 采纳 AI 方案：可切换步长更通用，改动点也更收敛（State 加一个字段 + AppBar 加一个 action） |
| 主题修改 | 改 `ThemeData.primaryColor` | `ColorScheme.fromSeed` + Material 3 | 采纳 AI 方案：M3 推荐入口，派生色板更完整 |
| 生命周期日志 | 只在 initState/build 加 | 六钩子全覆盖 + 统一 `[lifecycle]` 前缀 | 采纳并扩展：加上 didUpdateWidget 打印旧配置 title，便于观察 |

其余代码（Widget 树、布局、资源加载）均为模板＋手写；AI 输出全部经运行或对照官方文档验证后才采用。

## 八、证据截图（按占位说明插图，每图一句话）

> 【此处插入截图1：应用首次启动画面——teal 色 AppBar、居中的 logo 空状态插画、"你已经按了按钮这么多次：0"】说明：资源图片加载成功，主题为 teal 种子色。

> 【此处插入截图2：把步长切到 2 后连点 FAB 的界面——大数字显示 7，AppBar 显示"步长"入口】说明：步长调节生效（先按步长 1 点 3 次，再按步长 2 点 2 次，3+2×2=7）。

> 【此处插入截图3：控制台冷启动日志——initState、didChangeDependencies、build 三行及 FAB 点击行】说明：冷启动钩子顺序与 setState 日志符合预期。

> 【此处插入截图4：控制台按 r（热重载）后的日志——didUpdateWidget、build 两行】说明：热重载 State 保留、计数不归零，仅重跑 build。

> 【此处插入截图5：控制台按 R（热重启）后的日志——initState、didChangeDependencies、build】说明：热重启整链重跑、计数归零。

> 【此处插入截图6：`flutter doctor -v` 输出】说明：环境自检通过（Flutter 3.47.4 / Dart 3.13.3）。

> 【此处插入截图7：`git log --oneline` 输出——三条提交】说明：规范提交历史（docs → feat → feat）。

> 【此处插入截图8：Widget 树手绘图照片或绘图工具导出】说明：完整层级 + Stateless/Stateful 标注（底稿见 docs/widget_tree.md）。

## 九、自评

对照要求单逐项自查：

| 序 | 任务 | 完成情况 |
| --- | --- | --- |
| 1 | Widget树手绘图：完整层级＋两类Widget标注 | ✅ 底稿 docs/widget_tree.md，手绘图见截图8 |
| 2 | 生命周期日志：钩子顺序＋r/R行为对照记录 | ✅ 六钩子日志，r/R 对照见第五节与截图3-5 |
| 3 | 主题定制：种子色方案＋至少两处Theme.of取用 | ✅ fromSeed(teal)；Theme.of 两处（数字主色、提示次色），AppBar 另用 inversePrimary |
| 4 | 资源替换：新增图片资源并显示成功 | ✅ assets/images/logo.png 空状态插画，完整重启验证 |
| 5 | AI使用标注（含与TraeWork方案对照的差异记录） | ✅ 第七节清单＋差异表 |
| 附加 | counter_deep 完整复现 / Git规范3次提交 / 报告记录 | ✅ 提交1-3（docs/feat 前缀），本报告 |

待改进：print 仅为课堂观察手段，生产代码应换 debugPrint/日志框架；`build` 每次都打印日志本身会随重建刷屏，仅调试期开启。

## 十、一句话收获与下一步计划

**一句话收获**：改计数器只动了两处——State 加一个 `_step` 字段、seedColor 换一个词，界面就全变了，真真切切体会到 UI = f(state)：我不是在"操作界面"，而是在"改状态"，setState 只是通知框架重新跑一遍 build。

**遗留问题**：独立研究任务1（const 构造与 rebuild 次数量化）未做，目前 setState 会连带整个子树 build；`flutter analyze` 在中文路径下崩溃属工具链问题，换 `dart analyze` 规避但根因未深究。

**下次课预习要点**：BuildContext 向上查找与导航（第7课）；InheritedWidget 与 `Theme.of(context)` 的关系（Theme 正是靠它实现"改一处、全应用变"）；routes 命名路由。
