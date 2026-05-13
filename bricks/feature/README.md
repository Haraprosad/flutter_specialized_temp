# feature

A Mason brick that scaffolds a complete Clean Architecture feature module.

## Usage

```sh
# Install mason (once per machine)
dart pub global activate mason_cli

# Add the brick to the project
mason add feature --path bricks/feature

# Generate a feature
mason make feature
```

## Variables

| Variable | Description | Default |
|---|---|---|
| `name` | Feature name, singular snake_case (e.g. `task`, `order`) | — |
| `package_name` | Flutter package name from `pubspec.yaml` | `flutter_specialized_temp` |

## Generated output

Running `mason make feature --name order` produces:

```
lib/features/order/
├── data/
│   ├── datasources/order_remote_datasource.dart
│   ├── models/order_model.dart
│   └── repositories/order_repository_impl.dart
├── domain/
│   ├── entities/order_entity.dart
│   ├── repositories/order_repository.dart
│   └── usecases/get_orders.dart
└── presentation/
    ├── bloc/
    │   ├── order_bloc.dart
    │   ├── order_event.dart
    │   └── order_state.dart
    └── pages/
        └── order_screen.dart
```

## After generation

1. Run `./scripts/codegen.sh` to generate `*.freezed.dart` and `*.g.dart` files.
2. Register the route in `lib/core/router/app_router.dart`.
3. Add the BLoC to your DI providers where the screen is rendered.
4. Replace the stub `id` field in the entity and model with real fields.
