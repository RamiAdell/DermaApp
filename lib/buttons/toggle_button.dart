import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
 

class ToggleButtonExample extends StatefulWidget {
  final String text;
  final IconData icon;
  final int index;
  final bool initialState; // Added initialState parameter
  final Function(int, bool) onToggle; // Changed the type of onToggle

  ToggleButtonExample({
    required this.text,
    required this.icon,
    required this.index,
    required this.onToggle,
    required this.initialState, // Added this line
  });

  @override
  _ToggleButtonExampleState createState() => _ToggleButtonExampleState();
}

class _ToggleButtonExampleState extends State<ToggleButtonExample> {
  bool _isToggled = false;
  // ignore: unused_field
  List<bool> _isSelected = List.generate(1, (index) => false);
  List<int> myList = List.filled(7, 0);
  @override
  void initState() {
    super.initState();
    _isToggled = widget.initialState; // Set initial state
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xff052C47),
        selectedColor: Color(0xff1CB78D),
        isSelected: _isSelected,
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              Icon(
                widget.icon,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.text,
                style: TextStyle(fontFamily: "Teachers", fontSize: 18 , fontWeight: FontWeight.w600),
              ),
              SizedBox(
                width: 15,
              ),
            ],
          ),
        ],
        onPressed: (index) {
          setState(() {
            _isSelected[index] = !_isSelected[index];
            widget.onToggle(widget.index,
                _isToggled); // Call onToggle with index and new state
          });
          
        },
      ),
    );
  }
}
