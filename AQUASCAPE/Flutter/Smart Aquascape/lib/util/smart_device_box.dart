import 'dart:math';

import 'package:flutter/material.dart';

class SmartDeviceBox extends StatelessWidget {
  final String smartDeviceName;
  final String iconPath;
  final bool powerOn;
  final void Function(bool)? onChanged;

  SmartDeviceBox({
    super.key,
    required this.smartDeviceName,
    required this.iconPath,
    required this.powerOn,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              iconPath,
              height: 75, // ukuran gambar
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      smartDeviceName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: pi,
                  child: Switch(
                    value: powerOn,
                    onChanged: onChanged,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
