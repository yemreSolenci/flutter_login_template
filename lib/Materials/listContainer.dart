import 'package:flutter/material.dart';

class ListContainer extends StatelessWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String> onItemSelected;
  final double? height;

  const ListContainer({
    Key? key,
    required this.items,
    required this.selectedItem,
    required this.onItemSelected,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerHeight =
        height ?? MediaQuery.of(context).size.height * 0.35;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(100),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: selectedItem == items[index]
                    ? Theme.of(context)
                        .primaryColor
                        .withOpacity(0.8) // Selected item color
                    : Theme.of(context)
                        .primaryColor
                        .withOpacity(0.3), // Other items
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10), // Corner radius
              ),
              child: ListTile(
                title: Text(items[index]),
                onTap: () => onItemSelected(items[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
