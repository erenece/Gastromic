import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

EventTransformer<E> debounceTransformer<E>(Duration duration) {
  return (events, mapper) {
    return events
        .transform(_DebounceStreamTransformer<E>(duration))
        .asyncExpand(mapper);
  };
}

class _DebounceStreamTransformer<T> extends StreamTransformerBase<T, T> {
  final Duration duration;
  _DebounceStreamTransformer(this.duration);

  @override
  Stream<T> bind(Stream<T> stream) {
    Timer? timer;
    late StreamController<T> controller;

    controller = StreamController<T>(
      onListen: () {
        stream.listen(
          (data) {
            timer?.cancel();
            timer = Timer(duration, () => controller.add(data));
          },
          onError: controller.addError,
          onDone: () {
            timer?.cancel();
            controller.close();
          },
        );
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }
}
