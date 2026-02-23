import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/calendar_service.dart';
import '../services/markdown_parser.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;

class ScheduleResultScreen extends StatefulWidget {
  final String scheduleResult;
  const ScheduleResultScreen({super.key, required this.scheduleResult});

  @override
  State<ScheduleResultScreen> createState() => _ScheduleResultScreenState();
}

class _ScheduleResultScreenState extends State<ScheduleResultScreen> {
  final CalendarService _calendarService = CalendarService();
  bool _isExporting = false;

  Future<void> _exportToGoogleCalendar() async {
    setState(() => _isExporting = true);

    try {
      // 1. Parse markdown
      final events = MarkdownParser.parseSchedule(widget.scheduleResult);
      if (events.isEmpty) {
        throw Exception("Tidak ada event yang ditemukan dalam jadwal. Pastikan format tabel benar.");
      }

      // 2. Auth & Get Calendars
      final calendars = await _calendarService.getCalendars();
      
      // 3. Show Calendar Selection (Bonus Challenge)
      if (!mounted) return;
      final selectedCalendarId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Pilih Kalender Tujuan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: calendars.length,
                  separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[100]),
                  itemBuilder: (context, index) {
                    final cal = calendars[index];
                    final isPrimary = cal.id == 'primary';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isPrimary ? Colors.indigo.shade50 : Colors.grey.shade50,
                        child: Icon(
                          isPrimary ? Icons.star : Icons.calendar_today,
                          color: isPrimary ? Colors.indigo : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        cal.summary ?? "Tanpa Nama",
                        style: TextStyle(
                          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
                          color: isPrimary ? Colors.indigo[900] : Colors.black87,
                        ),
                      ),
                      subtitle: Text(isPrimary ? "Kalender Utama" : "Kalender Kustom"),
                      onTap: () => Navigator.pop(context, cal.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );

      if (selectedCalendarId == null) {
        setState(() => _isExporting = false);
        return;
      }

      // 4. Export
      await _calendarService.exportEvents(events, calendarId: selectedCalendarId);

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text("Berhasil!"),
          ],
        ),
        content: const Text(
          "Semua jadwal telah berhasil ditambahkan ke Google Calendar Anda. Silakan cek aplikasi kalender Anda.",
          style: TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text("Gagal Export"),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Paham", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _exportToGoogleCalendar();
            },
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.indigo[900],
        title: const Text(
          "Hasil Jadwal AI",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: "Salin Jadwal",
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.scheduleResult));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.indigo[900],
                  content: const Text("Jadwal disalin ke clipboard"),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade600, Colors.indigo.shade800],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "AI Schedule Optimizer",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Jadwal telah dioptimalkan untuk produktivitas maksimal.",
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.indigo.shade50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Markdown(
                          data: widget.scheduleResult,
                          selectable: true,
                          padding: const EdgeInsets.all(24),
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[800]),
                            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo, height: 1.4),
                            h2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo[900], height: 1.4),
                            h3: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigoAccent[700], height: 1.4),
                            tableBorder: TableBorder.all(color: Colors.grey.shade100, width: 1.5),
                            tableHeadAlign: TextAlign.center,
                            tablePadding: const EdgeInsets.all(12),
                            tableHead: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[900], fontSize: 13),
                            tableBody: TextStyle(color: Colors.grey[700], fontSize: 13),
                            blockquotePadding: const EdgeInsets.all(12),
                            blockquoteDecoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.indigo.shade100),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Buat Baru", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: _isExporting ? null : _exportToGoogleCalendar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: _isExporting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.edit_calendar),
                          label: Text(
                            _isExporting ? "Menghubungkan..." : "Export ke Calendar",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isExporting)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.indigo),
                ),
              ),
            ),
        ],
      ),
    );
  }
}