import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;

class CalendarEvent {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  CalendarEvent({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() => 'Event: $title ($startTime - $endTime)';
}

class CalendarService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      calendar.CalendarApi.calendarEventsScope,
      calendar.CalendarApi.calendarScope,
    ],
  );

  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Mencoba login secara diam-diam dulu
      final account = await _googleSignIn.signInSilently();
      if (account != null) return account;
      
      // Jika tidak bisa, tampilkan dialog login
      return await _googleSignIn.signIn();
    } catch (e) {
      debugPrint("Error Google Sign In: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<List<calendar.CalendarListEntry>> getCalendars() async {
    final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (account == null) throw Exception("User not signed in");

    final authHeaders = await account.authHeaders;
    final authenticateClient = _AuthClient(authHeaders, http.Client());
    final calendarApi = calendar.CalendarApi(authenticateClient);

    final calendarList = await calendarApi.calendarList.list();
    return calendarList.items ?? [];
  }

  Future<void> exportEvents(List<CalendarEvent> events, {String calendarId = 'primary'}) async {
    final account = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (account == null) throw Exception("Gagal masuk ke akun Google. Silakan coba lagi.");

    final authHeaders = await account.authHeaders;
    final authenticateClient = _AuthClient(authHeaders, http.Client());
    final calendarApi = calendar.CalendarApi(authenticateClient);

    int successCount = 0;
    List<String> errors = [];

    for (var eventData in events) {
      try {
        final event = calendar.Event()
          ..summary = eventData.title
          ..description = eventData.description
          ..start = (calendar.EventDateTime()
            ..dateTime = eventData.startTime.toUtc()
            ..timeZone = "UTC")
          ..end = (calendar.EventDateTime()
            ..dateTime = eventData.endTime.toUtc()
            ..timeZone = "UTC");

        await calendarApi.events.insert(event, calendarId);
        successCount++;
      } catch (e) {
        debugPrint("Gagal membuat event '${eventData.title}': $e");
        errors.add(eventData.title);
      }
    }

    if (errors.isNotEmpty) {
      if (successCount == 0) {
        throw Exception("Gagal mengekspor semua jadwal. Periksa koneksi atau izin kalender.");
      } else {
        throw Exception("Berhasil mengekspor $successCount jadwal, namun gagal untuk: ${errors.join(', ')}");
      }
    }
  }
}

class _AuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client;

  _AuthClient(this._headers, this._client);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
