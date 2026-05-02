# Khelgaah Frontend

## Run Against Local Backend

Start the Go API on port `8080`, then for a real Android phone use `adb reverse`
so the app can reach your laptop's backend over device localhost:

```bash
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=API_USE_ADB_REVERSE=true
```

You can also point the app at any backend directly:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080
```

Default base URLs:

- Web: `http://localhost:8080`
- Android emulator: `http://10.0.2.2:8080`
- Android phone with `API_USE_ADB_REVERSE=true`: `http://127.0.0.1:8080`
