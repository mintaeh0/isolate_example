import 'dart:isolate';

import 'package:flutter/material.dart';

class IsolateView extends StatefulWidget {
  const IsolateView({super.key});

  @override
  State<IsolateView> createState() => _IsolateViewState();
}

class _IsolateViewState extends State<IsolateView> {
  bool isAsyncTaskDone = false;
  bool isIsolateTaskDone = false;

  Isolate? _isolate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Isolate Example")),
      body: SafeArea(
        child: Center(
          child: Row(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Text("async", style: TextStyle(fontSize: 30)),
                  isAsyncTaskDone
                      ? Text("완료", style: TextStyle(fontSize: 40))
                      : CircularProgressIndicator(),
                  FilledButton(
                    onPressed: () async {
                      setState(() => isAsyncTaskDone = false);
                      await bigTask();
                      setState(() => isAsyncTaskDone = true);
                    },
                    child: Text("실행"),
                  ),
                ],
              ),
              Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  Text("isolate", style: TextStyle(fontSize: 30)),
                  isIsolateTaskDone
                      ? Text("완료", style: TextStyle(fontSize: 40))
                      : CircularProgressIndicator(),
                  FilledButton(
                    onPressed: () async {
                      ReceivePort receivePort = ReceivePort();

                      setState(() => isIsolateTaskDone = false);

                      _isolate = await Isolate.spawn(
                        isolatedBigTask,
                        receivePort.sendPort,
                      );

                      receivePort.listen((message) {
                        if (!mounted) {
                          return;
                        }

                        if (message is bool) {
                          if (message) {
                            setState(() {
                              isIsolateTaskDone = true;
                              _isolate?.kill();
                              _isolate = null;
                              receivePort.close();
                            });
                          }
                        }
                      });
                    },
                    child: Text("실행"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> bigTask() async {
  int index = 0;
  int index2 = 0;
  int index3 = 0;

  while (index < 1000000000) {
    index++;
  }

  while (index2 < 1000000000) {
    index2++;
  }

  while (index3 < 1000000000) {
    index3++;
  }
}

Future<void> isolatedBigTask(SendPort sendPort) async {
  int index = 0;
  int index2 = 0;
  int index3 = 0;

  while (index < 1000000000) {
    index++;
  }

  while (index2 < 1000000000) {
    index2++;
  }

  while (index3 < 1000000000) {
    index3++;
  }

  sendPort.send(true);
}
