---
name: add-bloc
description: "Generate a BLoC or Cubit for an existing feature using Dart 3 sealed classes and Equatable. Use when adding state management to a feature."
user-invocable: true
---

# add-bloc — Generate BLoC or Cubit

Generates event + state + bloc files with Dart 3 sealed classes.

**Trigger:** `/add-bloc {feature}` or `/add-cubit {feature}`

---

## Step 1 — Choose BLoC or Cubit

| Use BLoC when | Use Cubit when |
|---------------|----------------|
| Multiple named events from the UI | Simple load/error state |
| Need to trace specific event flows | Toggle, counter, selection |
| auth, product, checkout, order | cart, profile, theme, nav |

---

## Step 2 — BLoC Files

### Event

```dart
// lib/features/{feature}/presentation/bloc/{feature}_event.dart
import 'package:equatable/equatable.dart';

sealed class {Feature}Event extends Equatable {
  const {Feature}Event();
  @override
  List<Object?> get props => [];
}

final class {Feature}ListRequested extends {Feature}Event {
  const {Feature}ListRequested();
}

final class {Feature}DetailRequested extends {Feature}Event {
  final String id;
  const {Feature}DetailRequested(this.id);

  @override
  List<Object?> get props => [id];
}
```

### State

```dart
// lib/features/{feature}/presentation/bloc/{feature}_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/{feature}_entity.dart';

sealed class {Feature}State extends Equatable {
  const {Feature}State();
  @override
  List<Object?> get props => [];
}

final class {Feature}Initial extends {Feature}State {
  const {Feature}Initial();
}

final class {Feature}Loading extends {Feature}State {
  const {Feature}Loading();
}

final class {Feature}Loaded extends {Feature}State {
  final List<{Feature}Entity> items;
  const {Feature}Loaded(this.items);
  @override
  List<Object?> get props => [items];
}

final class {Feature}DetailLoaded extends {Feature}State {
  final {Feature}Entity item;
  const {Feature}DetailLoaded(this.item);
  @override
  List<Object?> get props => [item];
}

final class {Feature}Error extends {Feature}State {
  final String message;
  const {Feature}Error(this.message);
  @override
  List<Object?> get props => [message];
}
```

### Bloc

```dart
// lib/features/{feature}/presentation/bloc/{feature}_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import '../../domain/usecases/get_{feature}s_usecase.dart';
import '../../domain/repositories/{feature}_repository.dart';
import '{feature}_event.dart';
import '{feature}_state.dart';

class {Feature}Bloc extends Bloc<{Feature}Event, {Feature}State> {
  final Get{Feature}sUseCase _getUseCase;
  final {Feature}Repository _repository;

  {Feature}Bloc({
    required Get{Feature}sUseCase getUseCase,
    required {Feature}Repository repository,
  })  : _getUseCase = getUseCase,
        _repository = repository,
        super(const {Feature}Initial()) {
    on<{Feature}ListRequested>(_onListRequested);
    on<{Feature}DetailRequested>(_onDetailRequested);
  }

  Future<void> _onListRequested(
    {Feature}ListRequested event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}Loading());
    final result = await _getUseCase();
    switch (result) {
      case Success(:final data):
        emit({Feature}Loaded(data));
      case ResultFailure(:final failure):
        emit({Feature}Error(failure.message));
    }
  }

  Future<void> _onDetailRequested(
    {Feature}DetailRequested event,
    Emitter<{Feature}State> emit,
  ) async {
    emit(const {Feature}Loading());
    final result = await _repository.getById(event.id);
    switch (result) {
      case Success(:final data):
        emit({Feature}DetailLoaded(data));
      case ResultFailure(:final failure):
        emit({Feature}Error(failure.message));
    }
  }
}
```

---

## Step 3 — Cubit Files

```dart
// lib/features/{feature}/presentation/cubit/{feature}_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/{feature}_entity.dart';

sealed class {Feature}State extends Equatable {
  const {Feature}State();
  @override List<Object?> get props => [];
}

final class {Feature}Initial extends {Feature}State { const {Feature}Initial(); }
final class {Feature}Loading extends {Feature}State { const {Feature}Loading(); }

final class {Feature}Loaded extends {Feature}State {
  final List<{Feature}Entity> items;
  const {Feature}Loaded(this.items);
  @override List<Object?> get props => [items];
}

final class {Feature}Error extends {Feature}State {
  final String message;
  const {Feature}Error(this.message);
  @override List<Object?> get props => [message];
}
```

```dart
// lib/features/{feature}/presentation/cubit/{feature}_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import '../../domain/repositories/{feature}_repository.dart';
import '{feature}_state.dart';

class {Feature}Cubit extends Cubit<{Feature}State> {
  final {Feature}Repository _repository;
  {Feature}Cubit(this._repository) : super(const {Feature}Initial());

  Future<void> load() async {
    emit(const {Feature}Loading());
    final result = await _repository.getAll();
    switch (result) {
      case Success(:final data): emit({Feature}Loaded(data));
      case ResultFailure(:final failure): emit({Feature}Error(failure.message));
    }
  }
}
```

---

## Step 4 — Using BLoC in a Page

```dart
// Dispatch event safely from initState
@override
void initState() {
  super.initState();
  Future.microtask(() {
    if (!mounted) return;
    context.read<{Feature}Bloc>().add(const {Feature}ListRequested());
  });
}

// Consume state — use switch expression on sealed class
BlocBuilder<{Feature}Bloc, {Feature}State>(
  builder: (context, state) => switch (state) {
    {Feature}Loading() => const CircularProgressIndicator(),
    {Feature}Loaded(:final items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) => Text(items[i].id),
      ),
    {Feature}Error(:final message) => Text(message),
    _ => const SizedBox.shrink(),
  },
)
```

---

## Anti-Patterns

- ❌ `default:` arm in a switch on sealed state — defeats exhaustiveness
- ❌ `context.read<>()` directly in `initState()` — use `Future.microtask`
- ❌ BLoC calling API directly — must go through a UseCase
- ❌ `abstract class` for Event/State — must be `sealed class`
- ❌ Emitting state from outside the BLoC/Cubit
