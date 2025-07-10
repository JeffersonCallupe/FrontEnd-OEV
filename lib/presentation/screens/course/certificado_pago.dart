import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:flutter/services.dart';
import 'package:oev_mobile_app/presentation/screens/course/comprobante_pago.dart';

class CertificadoPagoScreen extends StatefulWidget {
  final CourseEnrolled courseEnrolled;

  const CertificadoPagoScreen({super.key, required this.courseEnrolled});

  @override
  _CertificadoPagoScreenState createState() => _CertificadoPagoScreenState();
}

class _CertificadoPagoScreenState extends State<CertificadoPagoScreen> {
  String cardNumber = '';
  String cardHolder = 'NOMBRE Y APELLIDO';
  String expiryDate = 'MM/AA';
  String selectedPaymentMethod =
      'Tarjeta de crédito/débito'; // Método por defecto
  final String cuentaInterbancaria = '123-456-789-000';
  final String cuentaVisa = '987-654-321-000';

  bool _isPaymentInfoComplete() {
    return cardNumber.length == 16 &&
        cardHolder.isNotEmpty &&
        expiryDate != 'MM/AA' &&
        expiryDate.isNotEmpty;
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.blue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        expiryDate = DateFormat('MM/yy').format(picked);
      });
    }
  }

  void _showPaymentCompletedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.green[100],
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Text('Pago completado', style: TextStyle(color: Colors.green)),
            ],
          ),
          content: const Text('El pago se ha procesado correctamente.',
              style: TextStyle(color: Colors.green)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo

                // Generar un número de transacción único (ejemplo simple)
                String transactionNumber =
                    DateTime.now().millisecondsSinceEpoch.toString();

                // Navegar al comprobante de pago con los datos correctos
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComprobantePagoScreen(
                      courseEnrolled:
                          widget.courseEnrolled, // Pasar el objeto completo
                      transactionNumber: transactionNumber,
                    ),
                  ),
                );
              },
              child: const Text('Ver Comprobante',
                  style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Pago del Certificado',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de pago
            Text('Resumen de pago', style: _titleStyle),
            const SizedBox(height: 5),
            Text('Curso: ${widget.courseEnrolled.courseName}',
                style: _textStyle),
            Text('Instructor: ${widget.courseEnrolled.instructorName}',
                style: _textStyle),
            Text('Costo: S/. 25', style: _textStyle),
            const SizedBox(height: 20),
            // Métodos de pago
            Text('Método de pago', style: _titleStyle),
            const SizedBox(height: 10),
            _buildPaymentMethods(),
            // Cuadro separado con CCI si se elige transferencia bancaria
            if (selectedPaymentMethod == 'Transferencia Bancaria')
              _buildCCIBankInfo(),

            if (selectedPaymentMethod == 'Tarjeta de crédito/débito') ...[
              // Tarjeta de crédito
              const SizedBox(height: 20),
              _buildCreditCard(),
              const SizedBox(height: 20),
              _buildTextField(
                'Número de la tarjeta',
                onChanged: (value) {
                  setState(() {
                    cardNumber = value.replaceAll(RegExp(r'\D'), '');
                  });
                },
                isNumber: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
              ),
              _buildTextField('Nombre en la tarjeta', onChanged: (value) {
                setState(() {
                  cardHolder = value.toUpperCase();
                });
              }),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'CVC',
                      onChanged: (value) {
                        setState(() {});
                      },
                      isNumber: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _buildDateField()),
                ],
              ),
              const SizedBox(height: 20),
              _buildPayButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectExpiryDate(context),
      child: AbsorbPointer(
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Fecha de Vencimiento',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          controller: TextEditingController(text: expiryDate),
        ),
      ),
    );
  }

  Widget _buildCreditCard() {
    String maskedNumber;
    if (cardNumber.isEmpty) {
      maskedNumber = '**** **** **** ****';
    } else if (cardNumber.length <= 4) {
      maskedNumber = cardNumber;
    } else {
      String hiddenPart = '*' * (cardNumber.length - 4);
      hiddenPart =
          hiddenPart.replaceAllMapped(RegExp(r'.{4}'), (match) => '**** ');
      maskedNumber =
          '$hiddenPart${cardNumber.substring(cardNumber.length - 4)}';
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.grey, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 20),
          Text(maskedNumber, style: _cardTextStyle),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(cardHolder, style: _cardTextStyle),
              Text(expiryDate, style: _cardTextStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildPaymentOption(
              'Tarjeta de crédito/débito', 'assets/images/visa.png'),
          _buildPaymentOption(
              'Transferencia Bancaria', 'assets/images/pago_efectivo.png'),
        ],
      ),
    );
  }

  Widget _buildCCIBankInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              cuentaInterbancaria, // CCI genérico
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: cuentaInterbancaria));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CCI copiado al portapapeles')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String asset) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = title;
        });
      },
      child: Row(
        children: [
          Radio(
            value: title,
            groupValue: selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                selectedPaymentMethod = value.toString();
              });
            },
            activeColor: Colors.blue,
          ),
          Text(title, style: _textStyle),
          const Spacer(),
          Image.asset(asset, width: 18, height: 18),
        ],
      ),
    );
  }

  Widget _buildTextField(String label,
      {bool isNumber = false,
      Function(String)? onChanged,
      List<TextInputFormatter>? inputFormatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {});
          if (onChanged != null) {
            onChanged(value);
          }
        },
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[900],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPayButton() {
    bool isEnabled = _isPaymentInfoComplete();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _showPaymentCompletedDialog : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? Colors.blue : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Pagar', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  TextStyle get _titleStyle {
    return const TextStyle(
        fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold);
  }

  TextStyle get _textStyle {
    return const TextStyle(fontSize: 14, color: Colors.white);
  }

  TextStyle get _cardTextStyle {
    return const TextStyle(fontSize: 14, color: Colors.white70);
  }
}
