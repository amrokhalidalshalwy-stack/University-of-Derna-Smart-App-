import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String hintText;
  final IconData prefixIcon; // e.g. Icons.bookmark
  final void Function(T?)? onChanged;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down), // Default dropdown arrow
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Icon(prefixIcon), // In RTL, suffixIcon is on the left, prefixIcon is on the right. Wait, the prompt says: "Dropdown suffix: Icons.bookmark or context icon on the RIGHT side", "Dropdown prefix: Icons.keyboard_arrow_down on the LEFT side". In RTL, prefix is right, suffix is left. 
        // If we want bookmark on RIGHT, that's prefixIcon.
        // If we want keyboard_arrow_down on LEFT, that's the default Dropdown icon which is at the end (left in RTL).
        prefixIcon: Icon(prefixIcon),
      ),
      style: const TextStyle(fontFamily: 'Cairo', color: Colors.black, fontSize: 14),
    );
  }
}
