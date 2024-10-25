import 'package:flutter/material.dart';
import 'package:okter/utils/color_pallet.dart';

class NumberPickerWheel extends StatefulWidget {
  final int minNumber;
  final int maxNumber;
  final ValueChanged<int> onSelectedItemChanged;

  const NumberPickerWheel({
    Key? key,
    required this.minNumber,
    required this.maxNumber,
    required this.onSelectedItemChanged,
  }) : super(key: key);

  @override
  _NumberPickerWheelState createState() => _NumberPickerWheelState();
}

class _NumberPickerWheelState extends State<NumberPickerWheel> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: 50,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 30, // Height of each item
        perspective: 0.01,
        onSelectedItemChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          widget.onSelectedItemChanged(widget.minNumber + index);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            if (index < 0 || index > (widget.maxNumber - widget.minNumber))
              return null;
            final isSelected = index == _selectedIndex;
            return Center(
              child: Text(
                (widget.minNumber + index).toString(),
                style: TextStyle(
                  color: isSelected ? themeColorPallet["green"] : Colors.white,
                  fontSize:
                      isSelected ? 24 : 18, // Larger font for selected item
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
          childCount: widget.maxNumber - widget.minNumber + 1,
        ),
      ),
    );
  }
}
