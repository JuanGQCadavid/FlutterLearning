import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class WebsocketClient {
  Stream<int> getCountStream([int start]);
}

class FakeWebsocketClient implements WebsocketClient {
  @override
  Stream<int> getCountStream([int start = 0]) async* {
    int i = start;
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      i = i + 1;
      yield i;
    }
  }
}

final webSocketProvider = Provider<WebsocketClient>(
  (ref) {
    return FakeWebsocketClient();
  },
);

final newCounterProvider = StreamProvider.family<int,int>((ref,startValue) {
  final wsClient = ref.watch(webSocketProvider);
  return wsClient.getCountStream(startValue);
});

final counterProvider = StateProvider.autoDispose((ref) => 0);

void main() => runApp(ProviderScope(
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Counter App",
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
          child: ElevatedButton(
        child: const Text("Go to counter page"),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const CounterPageStream()));
        },
      )),
    );
  }
}

class CounterPage extends ConsumerWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int counter = ref.watch(counterProvider);

    ref.listen<int>(counterProvider, (previous, next) {
      if (next >= 5) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text("Counter is more tha 5"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  )
                ],
              );
            });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter"),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: () {
              ref.invalidate(counterProvider);
            },
          )
        ],
      ),
      body: Center(
          child: Text(
        counter.toString(),
        style: Theme.of(context).textTheme.displayMedium,
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          ref.read(counterProvider.notifier).state++;
        },
      ),
    );
  }
}

class CounterPageStream extends ConsumerWidget {
  const CounterPageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<int> counter = ref.watch(newCounterProvider(5));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Counter"),
        actions: [
          IconButton(
            icon: Icon(Icons.restart_alt),
            onPressed: () {
              ref.invalidate(counterProvider);
            },
          )
        ],
      ),
      body: Center(
          child: Text(
        counter
            .when(
                data: (int value) => value,
                error: (Object e, _) => e,
                loading: () => 0)
            .toString(),
        style: Theme.of(context).textTheme.displayMedium,
      )),
    );
  }
}
