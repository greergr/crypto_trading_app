import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onCompleted;
  final int length;

  const PinInput({
    Key? key,
    required this.controller,
    this.onCompleted,
    this.length = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: length,
        obscureText: true,
        obscuringCharacter: '●',
        style: const TextStyle(fontSize: 24),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          counterText: '',
          hintText: '● ' * length,
          hintStyle: const TextStyle(fontSize: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          if (value.length == length && onCompleted != null) {
            onCompleted!(value);
          }
        },
      ),
    );
  }
}
