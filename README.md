### Flutter Isolate 사용 예제

Flutter에서 무거운 작업을 처리할 때 UI가 멈추는 현상을 Isolate를 통해 해결하는 방법을 보여주는 예제 프로젝트입니다.

<br>

### 개요

Flutter가 사용하는 Dart 언어는 싱글 스레드로 동작합니다.
이 프로젝트는 싱글 스레드로 동작하는 Dart에서 일반적인 비동기 작업과 별도의 isolate를 이용한 작업의 차이를 시각적으로 확인할 수 있습니다.

<br>

### async & Isolate

async : 비동기 프로그래밍 방식이지만 작업이 메인 스레드에서 실행되므로, 큰 작업을 수행하면 UI가 멈추는 현상이 발생합니다.

Isolate : 독립적인 메모리와 이벤트 루프를 가진 별도의 스레드에서 실행합니다. 큰 작업을 Isolate로 실행하면 메인 스레드는 UI 렌더링에만 집중할 수 있어 화면 멈춤 현상이 발생하지 않습니다. 단, Isolate 간의 통신은 오직 Port를 통한 메시지로 이루어집니다.

<br>

### 예제 코드
30억 번의 반복 연산을 수행하는 큰 작업을 두 가지 방식으로 실행하여 차이를 비교합니다.

1. 일반 async 함수
단순히 Future를 사용한 비동기 함수로 실행 시 UI가 멈추게 됩니다.

```dart
// 일반 비동기 함수
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

// 버튼 클릭 시 호출
FilledButton(
  onPressed: () async {
    setState(() => isAsyncTaskDone = false);
    await bigTask(); // UI 멈춤 현상 발생
    setState(() => isAsyncTaskDone = true);
  },
  child: Text("실행"),
)
```

2. Isolate를 사용한 함수
Isolate.spawn()을 사용하여 별도의 스레드에서 동일한 작업을 실행합니다.
작업이 완료되면 SendPort를 통해 메인 스레드에 완료 메시지를 전달합니다.

```dart
// Isolate에서 실행될 함수
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

  sendPort.send(true); // 작업 완료 메시지 전송
}

// 버튼 클릭 시 호출
FilledButton(
  onPressed: () async {
    ReceivePort receivePort = ReceivePort();
    setState(() => isIsolateTaskDone = false);

    // 함수 실행
    _isolate = await Isolate.spawn(
      isolatedBigTask,
      receivePort.sendPort,
    );

    // 포트 리스닝
    receivePort.listen((message) {
      if (message is bool && message) {
        setState(() {
          isIsolateTaskDone = true;
          _isolate?.kill();
          _isolate = null;
          receivePort.close();
        });
      }
    });
  },
  child: Text("실행"),
)
```

### 실행 화면
비동기 작업![image](https://github.com/user-attachments/assets/5d95600e-ffaf-4898-ae57-35d2e75195ed)|Isolate 작업![image (1)](https://github.com/user-attachments/assets/e62c71b2-bf97-43c6-873c-50a4b9a48afd)|
---|---|

Flutter Docs : https://docs.flutter.dev/perf/isolates
Velog : https://velog.io/@mth1150/Flutter-Isolate%EB%A5%BC-%EC%82%AC%EC%9A%A9%ED%95%98%EC%97%AC-%ED%81%B0-%EC%9E%91%EC%97%85-%EB%B6%84%EB%A6%AC%ED%95%98%EA%B8%B0
