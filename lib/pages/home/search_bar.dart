import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({
    Key key,
    @required this.searchBarTop,
    @required this.scaffoldKey,
  }) : super(key: key);

  final double searchBarTop;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      left: 0.0,
      right: 0.0,
      top: searchBarTop,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        height: 48.0,
        // width: 360.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              spreadRadius: 0.5,
              offset: Offset(0.7, 0.7),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            TextFormField(
              onTap: () {
                print('text field pressed');
              },
              decoration: const InputDecoration(
                // labelText: 'Where to?',
                hintText: 'Where to?',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
            IconButton(
              // padding: EdgeInsets.all(0.0),
              icon: Icon(Icons.menu),
              onPressed: () {
                scaffoldKey.currentState.openDrawer();
              },
            )
          ],
        ),
      ),
    );
  }
}
