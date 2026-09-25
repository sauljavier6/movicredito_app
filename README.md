# MoviCredito App

App Flutter para clientes de MoviCredito.

## Desarrollo

Por defecto Android Emulator consume la API local en `http://10.0.2.2:4000`.

```bash
flutter pub get
flutter run --dart-define=API_URL=http://10.0.2.2:4000
```

Para un dispositivo Android físico usa una URL accesible desde el teléfono (LAN, túnel o API desplegada).

La app no contiene saldos ni créditos simulados. La siguiente fase conecta autenticación/vinculación del cliente y el resumen real del crédito.
