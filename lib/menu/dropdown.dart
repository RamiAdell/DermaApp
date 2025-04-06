import 'package:flutter/material.dart';

class MyDropDown extends StatefulWidget {
  final String text;
  final List<String> list;
  static int? daysSelectedIndex; // Static variable to store selected index for days
  static int?
      activitiesSelectedIndex; // Static variable to store selected index for activities

  const MyDropDown({
    required this.text,
    required this.list,
    
  });

  @override
  _MyDropDownState createState() => _MyDropDownState();
}

class _MyDropDownState extends State<MyDropDown> {
  String _selectedText = '';

  @override
  void initState() {
    super.initState();
    _selectedText = widget.text;
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      height: 65,
      width: 330,
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Color(0xff79747e))),
        borderRadius: BorderRadius.circular(8.0), // Set border radius here
      ),
      child: InkWell(
        onTap: () {
          _showDropDown(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedText,
              style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,fontFamily: "Teachers",
                color: Color(0xff052C47)),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showDropDown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.builder(
            itemCount: widget.list.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    if (widget.text == 'Select number of days') {
                      MyDropDown.daysSelectedIndex = index;
                    } else {
                      MyDropDown.activitiesSelectedIndex = index;
                    }
                    _selectedText = widget.list[index];
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    widget.list[index],
                    style: TextStyle(
                      fontFamily: "Teachers",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: index == (widget.text == 'Select number of days'
                          ? MyDropDown.daysSelectedIndex
                          : MyDropDown.activitiesSelectedIndex)
                          ? Color(0xff052C47)
                          : Color(0xff052C47),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
