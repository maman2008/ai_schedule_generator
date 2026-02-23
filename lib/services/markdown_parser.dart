import 'package:flutter/foundation.dart';
import '../services/calendar_service.dart';

class MarkdownParser {
  static List<CalendarEvent> parseSchedule(String markdown) {
    final List<CalendarEvent> events = [];
    final lines = markdown.split('\n');
    
    // Temukan baris tabel (biasanya dimulai dengan |)
    for (var line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('|') && trimmedLine.endsWith('|')) {
        // Skip header separator (e.g., | --- | --- |)
        if (trimmedLine.contains('---')) continue;

        final cells = trimmedLine
            .split('|')
            .where((c) => c.isNotEmpty || trimmedLine.indexOf(c) != 0 && trimmedLine.indexOf(c) != trimmedLine.length - 1)
            .map((c) => c.trim())
            .toList();
        
        // Bersihkan list dari elemen kosong di awal/akhir karena split('|') pada | a | b |
        if (cells.isNotEmpty && cells.first.isEmpty) cells.removeAt(0);
        if (cells.isNotEmpty && cells.last.isEmpty) cells.removeLast();

        if (cells.length < 2) continue;
        
        final timeStr = cells[0];
        final activity = cells[1];
        final description = cells.length > 2 ? cells[2] : "";

        // Skip header
        if (timeStr.toLowerCase() == 'waktu' || activity.toLowerCase() == 'aktivitas') continue;

        try {
          final times = _parseTimeRange(timeStr);
          if (times != null) {
            events.add(CalendarEvent(
              title: activity,
              description: description,
              startTime: times[0],
              endTime: times[1],
            ));
          }
        } catch (e) {
          debugPrint("Error parsing line: $trimmedLine - $e");
        }
      }
    }
    return events;
  }

  static List<DateTime>? _parseTimeRange(String timeStr) {
    // Regex untuk format HH:mm - HH:mm atau HH.mm - HH.mm
    // Menghandle: 08:00-09:00, 08.00 - 09.00, 8:00 - 9:00, dll
    final timePattern = r'\d{1,2}[:.]\d{2}';
    final rangeRegex = RegExp('($timePattern)\\s*[-–—]\\s*($timePattern)');
    final singleRegex = RegExp('($timePattern)');

    final now = DateTime.now();
    
    if (rangeRegex.hasMatch(timeStr)) {
      final match = rangeRegex.firstMatch(timeStr)!;
      final start = _parseTime(match.group(1)!, now);
      final end = _parseTime(match.group(2)!, now);
      return [start, end];
    } else if (singleRegex.hasMatch(timeStr)) {
      final match = singleRegex.firstMatch(timeStr)!;
      final start = _parseTime(match.group(1)!, now);
      // Jika cuma satu waktu, asumsikan durasi 1 jam
      final end = start.add(const Duration(hours: 1));
      return [start, end];
    }
    
    return null;
  }

  static DateTime _parseTime(String time, DateTime baseDate) {
    final cleanTime = time.replaceAll('.', ':');
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}
