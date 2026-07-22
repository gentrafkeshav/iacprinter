import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iac_login_app/AppHeader.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

import 'CommonConst/CustomLoader.dart';

import 'package:html/parser.dart' as htmlParser;

import 'main.dart';

// ============================================================================
// COLOR PALETTE
// Two modes. Dark is default: true black canvas for maximum contrast under
// harsh shop-floor lighting and for OLED/industrial panel displays. Light is
// available for bright offices via the toggle in the title bar.
// ============================================================================
class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  Color get canvas => isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);
  Color get surface => isDark ? const Color(0xFF1C1C1E) : const Color(0xFFFFFFFF);
  Color get fieldFill => isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F4);
  Color get hairline => isDark ? const Color(0xFF38383A) : const Color(0xFFE0E0E3);

  Color get textPrimary => isDark ? const Color(0xFFF5F5F7) : const Color(0xFF1D1D1F);
  Color get textSecondary => isDark ? const Color(0xFFAEAEB4) : const Color(0xFF6E6E73);
  Color get textTertiary => isDark ? const Color(0xFF7C7C80) : const Color(0xFFAEAEB2);
  Color get onAccent => const Color(0xFFFFFFFF);

  Color get accent => isDark ? const Color(0xFF0A84FF) : const Color(0xFF0071E3);
  Color get success => isDark ? const Color(0xFF32D74B) : const Color(0xFF1FA451);
  Color get warning => isDark ? const Color(0xFFFF9F0A) : const Color(0xFFC8790A);
  Color get danger => isDark ? const Color(0xFFFF453A) : const Color(0xFFD70015);
}

class AppType {
  final AppPalette c;
  const AppType(this.c);

  TextStyle _f(double size, FontWeight w, Color color, {double ls = 0}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: color, letterSpacing: ls, height: 1.25);

  TextStyle get largeTitle => _f(28, FontWeight.w700, c.textPrimary, ls: -0.4);
  TextStyle get title => _f(19, FontWeight.w700, c.textPrimary, ls: -0.2);
  TextStyle get body => _f(15, FontWeight.w500, c.textPrimary);
  TextStyle get bodyLarge => _f(17, FontWeight.w600, c.textPrimary);
  TextStyle get caption => _f(12.5, FontWeight.w600, c.textSecondary, ls: 0.1);
  TextStyle get footnote => _f(13, FontWeight.w500, c.textTertiary);
  TextStyle get button => _f(16, FontWeight.w600, c.onAccent, ls: -0.1);
}

class GenerateQRCode extends StatefulWidget {
  @override
  _GenerateQRCodeState createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  // Dark by default — best contrast for factory-floor lighting conditions.
  bool isDarkMode = true;

  Map<String, dynamic>? selectedMachine;
  Map<String, dynamic>? selectedPart;
  String batchNumber = "";
  String operatorName = "";
  bool isQrVisible = false;
  Map<String, dynamic> qrData = {};

  List<Map<String, dynamic>> machineList = [];
  List<Map<String, dynamic>> partList = [];
  bool machinesLoading = true;
  bool partsLoading = false;

  String? statusMessage;
  late Color statusColor;
  IconData statusIcon = CupertinoIcons.exclamationmark_circle;

  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();

  // Palette/type recomputed each build from isDarkMode — kept as fields so
  // every helper widget method below can just reference `c.` / `t.`.
  late AppPalette c;
  late AppType t;

  @override
  void initState() {
    super.initState();
    c = AppPalette(isDarkMode);
    statusColor = c.danger;
    _fetchMachines();
  }

  @override
  void dispose() {
    _operatorController.dispose();
    _batchController.dispose();
    super.dispose();
  }

  void _showStatus(String message, {required String kind, IconData? icon}) {
    setState(() {
      statusMessage = message;
      statusColor = kind == 'success' ? c.success : (kind == 'warning' ? c.warning : c.danger);
      statusIcon = icon ?? CupertinoIcons.exclamationmark_circle;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && statusMessage == message) setState(() => statusMessage = null);
    });
  }

  // ==========================================================================
  // API — unchanged from working version
  // ==========================================================================

  Future<void> _fetchMachines() async {
    const String url = '${BASE_URL}/machine_api_desktop';
    setState(() => machinesLoading = true);
    try {
      final response = await http.post(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          machineList = (data['data'] as List)
              .map((item) => {'id': item['id'], 'name': item['name'] as String})
              .toList();
          machinesLoading = false;
        });
      } else {
        setState(() => machinesLoading = false);
        _showStatus('Couldn\'t load machines. Try again.', kind: 'error', icon: CupertinoIcons.wifi_slash);
      }
    } catch (e) {
      setState(() => machinesLoading = false);
      _showStatus('No connection.', kind: 'error', icon: CupertinoIcons.wifi_slash);
      print('Error fetching machines: $e');
    }
  }

  Future<void> _fetchParts(String machineId) async {
    final String url = '${BASE_URL}/desktop_machine_parts/$machineId';
    setState(() {
      partsLoading = true;
      partList = [];
      selectedPart = null;
    });
    try {
      LoaderManager.callLoader(context, true);
      final response = await http.get(Uri.parse(url));
      LoaderManager.callLoader(context, false);
      final data = json.decode(response.body);
      setState(() {
        partList = (data as List)
            .map((item) => {'id': item['id'], 'name': item['name'] as String})
            .toList();
        partsLoading = false;
      });
    } catch (e) {
      LoaderManager.callLoader(context, false);
      setState(() => partsLoading = false);
      _showStatus('Couldn\'t load parts.', kind: 'error', icon: CupertinoIcons.wifi_slash);
      print('Error fetching parts: $e');
    }
  }

  Future<void> _generateQR() async {
    if (selectedMachine == null || selectedPart == null) return;
    const String url = '${BASE_URL}/desktop_generate_qr';
    try {
      LoaderManager.callLoader(context, true);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'part_id': selectedPart!['id'].toString()},
      );
      LoaderManager.callLoader(context, false);
      final data = json.decode(response.body);
      if (data['status'] == true) {
        setState(() {
          qrData = data['data'];
          isQrVisible = true;
          operatorName = "";
          batchNumber = "";
          _operatorController.clear();
          _batchController.clear();
        });
       // _showStatus('QR code ready.', kind: 'success', icon: CupertinoIcons.checkmark_alt_circle);
      } else {
        _showStatus('Couldn\'t generate a QR code.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      }
    } catch (e) {
      LoaderManager.callLoader(context, false);
      _showStatus('Something went wrong.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      print('Error generating QR: $e');
    }
  }

  Future<void> _printQR() async {
    if (batchNumber.trim().isEmpty || operatorName.trim().isEmpty) {
      _showStatus('Add operator name and batch number first.', kind: 'warning', icon: CupertinoIcons.exclamationmark_triangle);
      return;
    }
    if (operatorName.length > 40) {
      _showStatus('Operator name is too long (40 max).', kind: 'warning', icon: CupertinoIcons.exclamationmark_triangle);
      return;
    }

    const String url = '${BASE_URL}/desktop_print_qr';
    try {
      LoaderManager.callLoader(context, true);
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'part_id': selectedPart!['id'].toString(),
          'batch_no': batchNumber,
          'operator_name': operatorName,
        },
      );
      LoaderManager.callLoader(context, false);
      final data = json.decode(response.body);
      if (data['status'] == true) {
        final String pdfUrl = data['data']['print_btn_url'];
       // _showStatus('Sending to printer…', kind: 'info', icon: CupertinoIcons.printer);
        await _printPdfFromUrl(pdfUrl);
      } else {
        _showStatus('Print failed: ${data['message'] ?? 'Unknown error'}', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      }
    } catch (e) {
      LoaderManager.callLoader(context, false);
      _showStatus('Couldn\'t print.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      print('Error printing QR: $e');
    }
  }

  Future<void> _printPdfFromUrl(String initialUrl) async {
    print('Fetching actual PDF URL from: $initialUrl');
    try {
      final response = await http.get(Uri.parse(initialUrl));
      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);
        final iframeElement = document.querySelector('iframe');
        if (iframeElement != null) {
          String? pdfUrl = iframeElement.attributes['src'];
          if (pdfUrl != null && pdfUrl.endsWith('.pdf')) {
            print('Extracted PDF URL: $pdfUrl');
            await _downloadAndPrintPdf(pdfUrl);
          } else {
            print('Could not find a valid PDF URL in the iframe.');
            _showStatus('Couldn\'t find the print file.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
          }
        } else {
          print('No iframe found in the HTML response.');
          _showStatus('Print document not found.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
        }
      } else {
        print('Failed to fetch page: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching the final PDF URL: $e');
    }
  }

  Future<void> _downloadAndPrintPdf(String pdfUrl) async {
    try {
      final pdfResponse = await http.get(Uri.parse(pdfUrl));
      if (pdfResponse.statusCode == 200) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfResponse.bodyBytes,
        );
        print('PDF printed successfully');
        _showStatus('Label printed.', kind: 'success', icon: CupertinoIcons.checkmark_alt_circle);
      } else {
        print('Failed to download PDF: HTTP ${pdfResponse.statusCode}');
        _showStatus('Couldn\'t download the print file.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      }
    } catch (e) {
      print('Error downloading or printing PDF: $e');
    }
  }

  Future<void> _regenerateQR() async {
    if (selectedPart == null || batchNumber.trim().isEmpty || operatorName.trim().isEmpty) {
      _showStatus('Add operator name and batch number first.', kind: 'warning', icon: CupertinoIcons.exclamationmark_triangle);
      return;
    }

    const String url = '${BASE_URL}/desktop_regnerate';
    try {
      LoaderManager.callLoader(context, true);
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Cookie'] = 'ci_session=fc2453f2a59baa91e75e50c05b110ae7c170251b';
      request.fields['regnerate_id'] = Uri.encodeComponent(qrData['qr_generated_id'].toString());
      request.fields['batch_no'] = Uri.encodeComponent(batchNumber);
      request.fields['operator_name'] = Uri.encodeComponent(operatorName);
      request.fields['part_id'] = selectedPart!['id'].toString();

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);
      LoaderManager.callLoader(context, false);

      if (data['status'] == true) {
        setState(() => qrData = data['data']);
      //  _showStatus('QR code regenerated.', kind: 'success', icon: CupertinoIcons.checkmark_alt_circle);
      } else {
        _showStatus('Regenerate failed: ${data['message'] ?? 'Unknown error'}', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      }
    } catch (e) {
      LoaderManager.callLoader(context, false);
      _showStatus('Couldn\'t regenerate.', kind: 'error', icon: CupertinoIcons.exclamationmark_circle);
      print('Error regenerating QR: $e');
    }
  }

  void _cancelQR() {
    setState(() {
      isQrVisible = false;
      selectedMachine = null;
      selectedPart = null;
      partList = [];
      batchNumber = "";
      operatorName = "";
      _operatorController.clear();
      _batchController.clear();
      qrData = {};
      statusMessage = null;
    });
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      c = AppPalette(isDarkMode);
    });
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // Recompute palette/type fresh each build so every helper method below
    // reads the current mode without needing to thread parameters through.
    c = AppPalette(isDarkMode);
    t = AppType(c);
    final bool readyToGenerate = selectedMachine != null && selectedPart != null;

    return Scaffold(
      backgroundColor: c.canvas,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppHeader(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _titleBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _selectionPanel(readyToGenerate)),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: isQrVisible ? _outputPanel() : _emptyStatePanel(),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(width: 190, child: _productionCard()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (statusMessage != null)
              Positioned(top: 78, right: 28, child: _statusToast()),
          ],
        ),
      ),
    );
  }

  // ---- Title bar: title, step progress, and the theme toggle ----
  Widget _titleBar() {
    final int step = isQrVisible ? 2 : 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text("QR Label Station", style: t.largeTitle),
          const SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                _stepDot(1, step >= 1, step == 1),
                Container(width: 22, height: 1, color: c.hairline, margin: const EdgeInsets.symmetric(horizontal: 6)),
                _stepDot(2, step >= 2, step == 2),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 2, right: 16),
            child: Text(step == 1 ? "Select machine & part" : "Enter details & print", style: t.footnote),
          ),
          _themeToggle(),
        ],
      ),
    );
  }

  // Compact segmented control, like macOS System Settings appearance toggle.
  Widget _themeToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.fieldFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _themeOption(icon: CupertinoIcons.moon_fill, selected: isDarkMode, onTap: () {
            if (!isDarkMode) _toggleTheme();
          }),
          _themeOption(icon: CupertinoIcons.sun_max_fill, selected: !isDarkMode, onTap: () {
            if (isDarkMode) _toggleTheme();
          }),
        ],
      ),
    );
  }

  Widget _themeOption({required IconData icon, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? c.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.4 : 0.08), blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 15, color: selected ? c.accent : c.textTertiary),
      ),
    );
  }

  Widget _stepDot(int number, bool reached, bool active) {
    final Color color = active ? c.accent : (reached ? c.textPrimary : c.textTertiary);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: reached ? color : Colors.transparent,
        border: Border.all(color: color, width: 1.4),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: reached && !active
          ? Icon(CupertinoIcons.check_mark, color: isDarkMode ? Colors.black : Colors.white, size: 12)
          : Text('$number', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: reached ? (isDarkMode ? Colors.black : Colors.white) : color)),
    );
  }

  Widget _statusToast() {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: statusColor, width: 3)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.10), blurRadius: 18, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 18),
            const SizedBox(width: 10),
            Flexible(child: Text(statusMessage ?? '', style: t.body)),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => setState(() => statusMessage = null),
              child: Icon(CupertinoIcons.xmark, size: 14, color: c.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: c.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: c.hairline),
  );

  // ---- LEFT: selection ----
  Widget _selectionPanel(bool readyToGenerate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Setup", style: t.title),
          const SizedBox(height: 20),
          _pickerField(
            label: "Machine",
            value: selectedMachine?['name'],
            placeholder: "Choose machine",
            loading: machinesLoading,
            onTap: machinesLoading
                ? null
                : () => _openPicker(
              title: "Machine",
              items: machineList,
              onSelect: (item) {
                setState(() => selectedMachine = item);
                _fetchParts(item['id'].toString());
              },
            ),
          ),
          const SizedBox(height: 12),
          _pickerField(
            label: "Part",
            value: selectedPart?['name'],
            placeholder: selectedMachine == null ? "Choose machine first" : "Choose part",
            loading: partsLoading,
            onTap: (selectedMachine == null || partsLoading)
                ? null
                : () => _openPicker(
              title: "Part",
              items: partList,
              onSelect: (item) => setState(() => selectedPart = item),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: readyToGenerate ? _generateQR : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                disabledBackgroundColor: c.fieldFill,
                foregroundColor: Colors.white,
                disabledForegroundColor: c.textTertiary,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Generate QR Code", style: t.button.copyWith(color: readyToGenerate ? Colors.white : c.textTertiary)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: (selectedMachine != null || isQrVisible) ? _cancelQR : null,
              style: TextButton.styleFrom(
                backgroundColor: c.fieldFill,
                foregroundColor: c.textPrimary,
                disabledForegroundColor: c.textTertiary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Reset", style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required String? value,
    required String placeholder,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    final bool filled = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.caption),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: c.fieldFill,
              borderRadius: BorderRadius.circular(10),
              border: filled ? Border.all(color: c.accent.withOpacity(0.5)) : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: loading
                      ? Text("Loading…", style: t.body.copyWith(color: c.textTertiary))
                      : Text(
                    value ?? placeholder,
                    style: filled ? t.bodyLarge : t.body.copyWith(color: c.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (loading)
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.accent))
                else
                  Icon(CupertinoIcons.chevron_down, size: 15, color: onTap == null ? c.textTertiary : c.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openPicker({
    required String title,
    required List<Map<String, dynamic>> items,
    required ValueChanged<Map<String, dynamic>> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.62,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: c.hairline, borderRadius: BorderRadius.circular(10)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
                  child: Row(
                    children: [
                      Text(title, style: t.title),
                      const Spacer(),
                      IconButton(
                        icon: Icon(CupertinoIcons.xmark, color: c.textSecondary, size: 18),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(color: c.hairline, height: 1),
                Expanded(
                  child: items.isEmpty
                      ? Center(child: Text("Nothing available", style: t.body.copyWith(color: c.textTertiary)))
                      : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(color: c.hairline, height: 1, indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onSelect(item);
                          Navigator.pop(ctx);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Text(item['name'].toString(), style: t.bodyLarge),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ---- CENTER: empty state ----
  Widget _emptyStatePanel() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: _cardDecoration(),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.qrcode, size: 56, color: c.textTertiary.withOpacity(0.6)),
          const SizedBox(height: 16),
          Text("No QR code yet", style: t.title.copyWith(color: c.textSecondary)),
          const SizedBox(height: 6),
          Text("Choose a machine and part, then generate.", textAlign: TextAlign.center, style: t.footnote),
        ],
      ),
    );
  }

  // ---- CENTER: output + print form ----
  Widget _outputPanel() {
    final bool isFormValid = batchNumber.trim().isNotEmpty && operatorName.trim().isNotEmpty;
    final String serial = (qrData['serial_number'] ?? "---").toString();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Label details", style: t.title),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.hairline),
                  ),
                  child: qrData['image_url'] != null
                      ? Image.network(
                    '${qrData['image_url']}',
                    width: 128,
                    height: 128,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, e, s) => SizedBox(
                        width: 128, height: 128, child: Icon(CupertinoIcons.exclamationmark_triangle, color: c.textTertiary)),
                  )
                      : const SizedBox(width: 128, height: 128),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Part", qrData['part_name'] ?? "---"),
                      _infoRow("Machine", qrData['machine_name'] ?? "---"),
                      _infoRow("Prod. No.", qrData['production_number'] ?? "---"),
                      _infoRow("Serial No.", serial),
                      _infoRow("Shift", qrData['shift_name'] ?? "---"),
                      _infoRow("SAP No.", qrData['sap_no'] ?? "---"),
                      _infoRow("Date", qrData['date'] ?? "---"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Divider(color: c.hairline),
            const SizedBox(height: 18),
            Text("Print details", style: t.title),
            const SizedBox(height: 14),
            _textField(
              controller: _operatorController,
              label: "Operator name",
              hint: "Enter Operator Name",
              maxLength: 40,
              onChanged: (val) => setState(() => operatorName = val),
            ),
            const SizedBox(height: 12),
            _textField(
              controller: _batchController,
              label: "Batch Number",
              hint: "Enter Batch No.",
              onChanged: (val) => setState(() => batchNumber = val),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isFormValid ? _printQR : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? c.accent : c.textPrimary,
                        disabledBackgroundColor: c.fieldFill,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: c.textTertiary,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.printer, size: 18, color: isFormValid ? Colors.white : c.textTertiary),
                          const SizedBox(width: 8),
                          Text("Print QR", style: t.button.copyWith(color: isFormValid ? Colors.white : c.textTertiary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(

                        color: isFormValid ? c.fieldFill : c.fieldFill.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFormValid ? Colors.orangeAccent.withOpacity(0.5) : Colors.white10,
                          width: 1.2,
                        ),
                        boxShadow: isFormValid
                            ? [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          )
                        ]
                            : [],
                      ),
                      child: TextButton(
                        onPressed: isFormValid ? _regenerateQR : null,
                        style: TextButton.styleFrom(
                          foregroundColor: c.textPrimary,
                          disabledForegroundColor: c.textTertiary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.arrow_2_circlepath,
                              size: 16,
                              color: isFormValid ? Colors.orangeAccent : c.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Regenerate QR",
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isFormValid ? c.textPrimary : c.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 84, child: Text(label, style: t.caption)),
          Expanded(child: Text(value, style: t.body, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ValueChanged<String> onChanged,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.caption),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          style: t.bodyLarge,
          cursorColor: c.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: t.body.copyWith(color: c.textTertiary),
            filled: true,
            fillColor: c.fieldFill,
            counterStyle: t.footnote,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.accent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          ),
        ),
      ],
    );
  }

  // ---- RIGHT: production count ----
  Widget _productionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: c.success, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text("Live", style: t.footnote),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "${qrData['production_count'] ?? '0'}",
            style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w700, color: c.textPrimary, letterSpacing: -1),
          ),
          const SizedBox(height: 6),
          Text("Total production", textAlign: TextAlign.center, style: t.caption),
        ],
      ),
    );
  }
}