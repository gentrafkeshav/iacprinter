import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:iac_login_app/AppHeader.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'CommonConst/CustomLoader.dart';

import 'package:html/parser.dart' as htmlParser;

import 'main.dart';


class GenerateQRCode extends StatefulWidget {
  @override
  _GenerateQRCodeState createState() => _GenerateQRCodeState();
}

class _GenerateQRCodeState extends State<GenerateQRCode> {
  String? selectedMachine;
  String? selectedMachineId;
  String? selectedPart;
  String? selectedPartId;
  String batchNumber = "";
  bool isQrVisible = false;
  GlobalKey imageKey = GlobalKey();
  Map<String, dynamic> qrData = {};

  List<String> machines = [];
  List<String> parts = [];

  @override
  void initState() {
    super.initState();
    _fetchMachines(); // Fetch machines on screen load
  }

  // Fetch machines from API
  Future<void> _fetchMachines() async {
    const String url = '${BASE_URL}/machine_api_desktop';
    try {

      //LoaderManager.callLoader(context, true); // Show loader


      final response = await http.post(Uri.parse(url));




      final data = json.decode(response.body);

      //LoaderManager.callLoader(context, false); // Show loader

      if (data['status'] == true) {
        setState(() {
          machines = (data['data'] as List).map((item) => item['name'] as String).toList();
        });
      } else {
        print('Failed to fetch machines');
      }
    } catch (e) {
      print('Error fetching machines: $e');
    }
  }

  // Fetch parts based on selected machine ID
  Future<void> _fetchParts(String machineId) async {
    final String url = '${BASE_URL}/desktop_machine_parts/$machineId';
    try {

      LoaderManager.callLoader(context, true); // Show loader


      final response = await http.get(Uri.parse(url));

      LoaderManager.callLoader(context, false); // Show loader


      final data = json.decode(response.body);
      setState(() {
        parts = (data as List).map((item) => item['name'] as String).toList();
        selectedPart = null; // Reset part selection
        selectedPartId = null;
      });
    } catch (e) {
      print('Error fetching parts: $e');
    }
  }

  // Generate QR code data from API
  Future<void> _generateQR() async {
    if (selectedMachine != null && selectedPart != null) {
      const String url = '${BASE_URL}/desktop_generate_qr';
      try {

        LoaderManager.callLoader(context, true); // Show loader


        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {'part_id': selectedPartId},
        );

        LoaderManager.callLoader(context, false); // Show loader


        final data = json.decode(response.body);
        if (data['status'] == true) {
          setState(() {
            qrData = data['data'];
            isQrVisible = true;
          });
        } else {
          print('Failed to generate QR');
        }
      } catch (e) {
        print('Error generating QR: $e');
      }
    }
  }

  // Print QR PDF using the provided URL
  Future<void> _printQR() async {
    const String url = '${BASE_URL}/desktop_print_qr';
    try {

      LoaderManager.callLoader(context, true); // Show loader


      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'part_id': selectedPartId,
          'batch_no': batchNumber,
        },
      );

      LoaderManager.callLoader(context, false); // Show loader


      final data = json.decode(response.body);
      if (data['status'] == true) {
        final String pdfUrl = data['data']['print_btn_url'];
        await _printPdfFromUrl(pdfUrl);
      } else {
        print('Failed to get print URL');
      }
    } catch (e) {
      print('Error printing QR: $e');
    }
  }

  // Print PDF from URL
 // Print PDF from URL


Future<void> _printPdfFromUrl(String initialUrl) async {
  print('Fetching actual PDF URL from: $initialUrl');

  try {
    final response = await http.get(Uri.parse(initialUrl));

    if (response.statusCode == 200) {
      // Parse the HTML to extract the PDF URL
      final document = htmlParser.parse(response.body);
      final iframeElement = document.querySelector('iframe');

      if (iframeElement != null) {
        String? pdfUrl = iframeElement.attributes['src'];

        if (pdfUrl != null && pdfUrl.endsWith('.pdf')) {
          print('Extracted PDF URL: $pdfUrl');
          await _downloadAndPrintPdf(pdfUrl);
        } else {
          print('Could not find a valid PDF URL in the iframe.');
        }
      } else {
        print('No iframe found in the HTML response.');
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
    } else {
      print('Failed to download PDF: HTTP ${pdfResponse.statusCode}');
    }
  } catch (e) {
    print('Error downloading or printing PDF: $e');
  }
}



  void _cancelQR() {
    setState(() {
      isQrVisible = false;
      selectedMachine = null;
      selectedMachineId = null;
      selectedPart = null;
      selectedPartId = null;
      batchNumber = "";
      qrData = {};
    });
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
          "Total\nProduction\n${qrData['production_count'] ?? '0'}", // Use qrData to get production count
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
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
                  flex: 3, // 2 "points" of space
                  child: _qrGenerationForm(),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 5, // 5 "points" of space
                  child: isQrVisible ? _qrOutputSection() : Container(),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1, // 1 "point" of space
                  child: _totalProductionBox(),
                ),
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
          _dropdownField(
            "Machine",
            machines,
            selectedMachine,
                (value) async {
              final machineIndex = machines.indexOf(value!);
              final machineData = json.decode((await http.post(Uri.parse('${BASE_URL}/machine_api_desktop'))).body)['data'][machineIndex];
              setState(() {
                selectedMachine = value;
                selectedMachineId = machineData['id'];
                _fetchParts(selectedMachineId!);
              });
            },
            hintText: "Select Machine", // Hint text for Machine dropdown
          ),
          SizedBox(height: 10),
          _dropdownField(
            "Part",
            parts,
            selectedPart,
                (value) async {
              final partIndex = parts.indexOf(value!);
              final partData = json.decode((await http.get(Uri.parse('${BASE_URL}/desktop_machine_parts/$selectedMachineId'))).body)[partIndex];
              setState(() {
                selectedPart = value;
                selectedPartId = partData['id'];
              });
            },
            hintText: "Select Part", // Hint text for Part dropdown
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: (selectedMachine != null && selectedPart != null) ? _generateQR : null,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: Text("Generate QR", style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _cancelQR,
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

print('qr image data = ${qrData['image_url']}');

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
            _tableRow("Part Name", qrData['part_name'] ?? "---"),
            _tableRow("Machine Name", qrData['machine_name'] ?? "---"),
            _tableRow("Prod Num.", qrData['production_number'] ?? "---"),
            _tableRow("Ser. Num.", qrData['serial_number'].toString() ?? "---"),
            _tableRow("Shift", qrData['shift_name'] ?? "---"),
            _tableRow("SAP No.", qrData['sap_no'] ?? "---"),
            _tableRow("Date", qrData['date'] ?? "---"),
          ],
        ),
        SizedBox(height: 10),
        Center(
          child: Image.network(
            '${qrData['image_url']}',
             
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          style: TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => batchNumber = val), // Update batchNumber
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

        // Print & Regenerate Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: batchNumber.isNotEmpty ? _printQR : null, // Disable if batchNumber is empty
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Print QR", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: batchNumber.isNotEmpty ? _regenerateQR : null, // Disable if batchNumber is empty
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text("Regenerate", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget _dropdownField(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged, {String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white),
          textAlign: TextAlign.start,
          overflow: TextOverflow.clip,
        ),
        DropdownButtonFormField<String>(
          value: selectedValue,
          hint: hintText != null ? Text(hintText, style: TextStyle(color: Colors.grey)) : null, // Hint text when nothing is selected
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
  Future<void> _regenerateQR() async {
  if (selectedPartId == null || batchNumber.isEmpty) {
    print('⚠️ Please enter a batch number and select a part before regenerating.');
    return;
  }

  const String url = '${BASE_URL}/desktop_regnerate';

  try {
    LoaderManager.callLoader(context, true); // Show loader

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Cookie'] = 'ci_session=fc2453f2a59baa91e75e50c05b110ae7c170251b'; // Set session cookie

    request.fields['regnerate_id'] = Uri.encodeComponent(qrData['qr_generated_id'].toString()); // Use serial number as regenerate ID
    request.fields['batch_no'] = Uri.encodeComponent(batchNumber);
    request.fields['part_id'] = selectedPartId!;

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var data = json.decode(responseBody);

    LoaderManager.callLoader(context, false); // Hide loader

    if (data['status'] == true) {
      setState(() {
        qrData = data['data']; // Update QR data with regenerated values
      });
      print('✅ QR Code regenerated successfully');
    } else {
      print('❌ Failed to regenerate QR: ${data['message']}');
    }
  } catch (e) {
    print('❌ Error regenerating QR: $e');
  }
}
}


