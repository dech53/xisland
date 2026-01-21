import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:xisland/model/cookie.dart';
import 'package:xisland/provider/local/cookie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CookiePage extends ConsumerStatefulWidget {
  const CookiePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CookiePageState();
}

class _CookiePageState extends ConsumerState<CookiePage> {
  @override
  Widget build(BuildContext context) {
    final cookies = ref.watch(cookiesProvider);
    return Scaffold(
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        pos: ExpandableFabPos.left,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withValues(alpha: 0.9),
        ),
        distance: 60.0,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.menu),
          fabSize: ExpandableFabSize.small,
          // shape: const CircleBorder(),
        ),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          // shape: const CircleBorder(),
        ),
        children: [
          Row(
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  SmartDialog.show(
                    builder: (_) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      width: 300,
                      height: 300,
                      child: MobileScanner(
                        onDetect: (capture) async {
                          debugPrint(capture.barcodes.first.rawValue);

                          final raw = capture.barcodes.first.rawValue;
                          if (raw == null) return;

                          try {
                            final map = jsonDecode(raw) as Map<String, dynamic>;
                            final cookie = Cookie.fromJson(map);
                            await ref
                                .read(cookiesProvider.notifier)
                                .add(cookie);
                            SmartDialog.dismiss();
                          } catch (e) {
                            SmartDialog.showToast('不合法的二维码');
                            debugPrint('扫码内容不是合法 Cookie JSON: $e');
                          }
                        },
                      ),
                    ),
                    clickMaskDismiss: true,
                  );
                },
                child: Icon(Icons.qr_code_scanner_outlined),
              ),
              SizedBox(width: 8),
              Text('扫码'),
            ],
          ),
          Row(
            children: [
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  SmartDialog.show(
                    builder: (_) {
                      String cookieText = '';
                      String nameText = '';

                      return Center(
                        child: Material(
                          type:
                              MaterialType.transparency, // 关键：让内部 TextField 可聚焦
                          child: Container(
                            width: 320,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: FocusScope(
                              // 关键！允许 TextField 处理焦点
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      '手动添加 Cookie',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: 'Cookie 值',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) => cookieText = value,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      decoration: const InputDecoration(
                                        labelText: '名称',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) => nameText = value,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              SmartDialog.dismiss(),
                                          child: const Text('取消'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () {
                                            final cookie = Cookie(
                                              cookie: cookieText.trim(),
                                              name: nameText.trim(),
                                              isMain: false,
                                            );

                                            ref
                                                .read(cookiesProvider.notifier)
                                                .add(cookie);

                                            SmartDialog.dismiss();
                                          },
                                          child: const Text('确定'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    clickMaskDismiss: true,
                  );
                },
                child: Icon(Icons.edit),
              ),
              SizedBox(width: 8),
              Text('手动添加'),
            ],
          ),
        ],
      ),
      appBar: AppBar(title: Text('饼干管理'), centerTitle: false),
      body: cookies.when(
        data: (cookies) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              ...cookies.map((cookie) {
                final index = cookies.indexOf(cookie);
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref.read(cookiesProvider.notifier).setMain(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Icon(
                              !cookie.isMain
                                  ? Icons.cookie_outlined
                                  : Icons.cookie_rounded,
                              color: !cookie.isMain
                                  ? null
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                cookie.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              ref
                                  .read(cookiesProvider.notifier)
                                  .removeAt(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              // SizedBox(height: 16.0),
              // ElevatedButton.icon(
              //   icon: Icon(Icons.add),
              //   onPressed: () {
              //     SmartDialog.show(
              //       builder: (_) => Container(
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(4),
              //         ),
              //         width: 300,
              //         height: 300,
              //         child: MobileScanner(
              //           onDetect: (capture) async {
              //             debugPrint(capture.barcodes.first.rawValue);

              //             final raw = capture.barcodes.first.rawValue;
              //             if (raw == null) return;

              //             try {
              //               final map = jsonDecode(raw) as Map<String, dynamic>;
              //               final cookie = Cookie.fromJson(map);
              //               await ref
              //                   .read(cookiesProvider.notifier)
              //                   .add(cookie);
              //               SmartDialog.dismiss();
              //             } catch (e) {
              //               debugPrint('扫码内容不是合法 Cookie JSON: $e');
              //             }
              //           },
              //         ),
              //       ),
              //       clickMaskDismiss: true,
              //       onDismiss: () async {
              //         // _handled = false;
              //       },
              //     );
              //   },
              //   label: Text('扫描二维码添加饼干'),
              // ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
}
