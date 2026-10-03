# AI Challenge: PushService FCM

## Prompt

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## checklist
| Pemeriksaan                  | Bukti pada kode                                                                                                                                                  | Hasil                                            |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| Background handler top-level | `firebaseMessagingBackgroundHandler` berada di top-level, memakai `@pragma('vm:entry-point')`, dan hanya menginisialisasi Firebase.                              | Lulus                           |
| Refresh token ke backend     | `onTokenRefresh` memanggil `_registerDevice`, lalu `POST /devices` dengan body `{"token": token}`. Nilai token tidak dicetak ke log.                             | Jalur POST ada |
| Notifikasi foreground        | `FirebaseMessaging.onMessage` memanggil `flutter_local_notifications.show` secara manual.                                                                        | Lulus                             |
| Klik background              | `onMessageOpenedApp` mengarahkan ke nilai `data.route`.                                                                                                          | Jalur ada             |
| Klik terminated              | `getInitialMessage` mengarahkan ke nilai `data.route`.                                                                                                           | Jalur ada             |
| Token dan secret             | Tidak ada Firebase API key/service-account key di source tracked; preview UI hanya 12 karakter. Request body memuat token untuk registrasi, tanpa logging token. | Lulus                   |