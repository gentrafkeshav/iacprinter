import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:iac_login_app/AppHeader.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart'; // Import this for PdfPageFormat
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';


/*




class GenerateQRCode extends StatefulWidget {
  @override
  _GenerateQRCodeState createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  String? selectedMachine;
  String? selectedPart;
  String batchNumber = "";
  bool isQrVisible = false;
  String qrData = "";

  final List<String> machines = ["1850T", "Machine 2", "Machine 3"];
  final List<String> parts = ["S201 TOPPER PAD RHD", "Part 2", "Part 3"];

  void generateQR() {
    if (selectedMachine != null && selectedPart != null) {
      setState(() {
        qrData = "Machine: $selectedMachine, Part: $selectedPart";
        isQrVisible = true;
      });
    }
  }

  void cancelQR() {
    setState(() {
      isQrVisible = false;
      selectedMachine = null;
      selectedPart = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppHeader(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _qrGenerationForm(),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: isQrVisible ? _qrOutputSection() : Container(),
                ),
                SizedBox(width: 16),
                _totalProductionBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrGenerationForm() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("QR GEN", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          _dropdownField("Machine", machines, selectedMachine, (value) => setState(() => selectedMachine = value)),
          SizedBox(height: 10),
          _dropdownField("Part", parts, selectedPart, (value) => setState(() => selectedPart = value)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: generateQR,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("Generate QR", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: cancelQR,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qrOutputSection() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Output of QR GEN", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: Colors.white),
            children: [
              _tableRow("Part Name", selectedPart ?? "---"),
              _tableRow("Machine Name", selectedMachine ?? "---"),
              _tableRow("Prod Num.", "2"),
              _tableRow("Ser. Num.", "1668"),
              _tableRow("Shift", "1"),
              _tableRow("SAP No.", "16033486"),
              _tableRow("Date", "2025-02-28 12:23:52"),
            ],
          ),
          SizedBox(height: 10),
          Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 120,
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            style: TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => batchNumber = val),
            decoration: InputDecoration(
              labelText: "Enter Batch",
              labelStyle: TextStyle(color: Colors.white),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 5),
          Text("Enter batch no. first", style: TextStyle(color: Colors.red, fontSize: 12)),
          SizedBox(height: 10),
          Center(
            child: ElevatedButton(
              onPressed: () => _printStaticPdf(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Print PDF", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _printStaticPdf() async {
    print("🖨️ Printing process started...");

    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      print("📄 PDF Document and Font loaded successfully.");

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Static Data PDF', style: pw.TextStyle(font: font, fontSize: 24)),
                  pw.SizedBox(height: 20),
                  pw.Text('This is a sample PDF generated with static data.', style: pw.TextStyle(font: font)),
                ],
              ),
            );
          },
        ),
      );

      // Show the layout with a print button
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      // Automatically trigger the print action after a delay
      Future.delayed(Duration(seconds: 2), () async {
        List<Printer> printers = await Printing.listPrinters();
        print("🖨️ Found ${printers.length} printers.");

        // Debug: Print printer names
        for (var p in printers) {
          print("🔹 Printer: ${p.name}");
        }

        // Select a real printer (ignore XPS, OneNote, Microsoft Print to PDF)
        Printer realPrinter = printers.firstWhere(
              (printer) => !printer.name.toLowerCase().contains("microsoft print")
              && !printer.name.toLowerCase().contains("onenote")
              && !printer.name.toLowerCase().contains("xps"),
          orElse: () => printers.isNotEmpty ? printers.first : Printer(name: 'Default', url: 'default'),
        );

        if (realPrinter == null) {
          print("❌ No real printer found. Exiting.");
          return;
        }

        print("✅ Selected Printer: ${realPrinter.name}");



        await Printing.directPrintPdf(
          printer: realPrinter, // Ensure this is a physical printer
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );

        print("🎉 Print job sent successfully!");
      });

    } catch (e) {
      print("❌ Printing Error: $e");
    }
  }


  void _printStaticPdfy() async {
    setState(() {
      isQrVisible = false;
    });

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(child: CircularProgressIndicator());
      },
    );

    try {
      final pdf = pw.Document();

      // Load a Google Font
      final font = await PdfGoogleFonts.robotoRegular();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text('Static Data PDF', style: pw.TextStyle(font: font, fontSize: 24)),
                  pw.SizedBox(height: 20),
                  pw.Text('This is a sample PDF generated with static data.', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 20),
                  pw.Text('Here are some statistics:', style: pw.TextStyle(font: font)),
                  pw.Bullet(text: 'Statistic 1: 100', style: pw.TextStyle(font: font)),
                  pw.Bullet(text: 'Statistic 2: 200', style: pw.TextStyle(font: font)),
                  pw.Bullet(text: 'Statistic 3: 300', style: pw.TextStyle(font: font)),
                ],
              ),
            );
          },
        ),
      );

      List<Printer> printers = await Printing.listPrinters();
      if (printers.isEmpty) {
        Navigator.pop(context);
        print("No printers found");
        return;
      }

      Printer defaultPrinter = printers.first;

      await Printing.directPrintPdf(
        printer: defaultPrinter,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

    } catch (e) {
      print("Printing Error: $e");
    } finally {
      Navigator.pop(context);
    }
  }




  void _printStaticPdfx() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Static Data PDF', style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 20),
                pw.Text('This is a sample PDF generated with static data.'),
                pw.SizedBox(height: 20),
                pw.Text('Here are some statistics:'),
                pw.Bullet(text: 'Statistic 1: 100'),
                pw.Bullet(text: 'Statistic 2: 200'),
                pw.Bullet(text: 'Statistic 3: 300'),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }




  Widget _totalProductionBox() {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "Total\nProduction\n1",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _dropdownField(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white)),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  TableRow _tableRow(String label, String value) {
    return TableRow(children: [
      Padding(padding: EdgeInsets.all(8), child: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      Padding(padding: EdgeInsets.all(8), child: Text(value, style: TextStyle(color: Colors.white))),
    ]);
  }
}




 */