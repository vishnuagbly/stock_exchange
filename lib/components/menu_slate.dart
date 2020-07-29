import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class MenuSlate extends StatelessWidget {
  final page;
  final Icon icon;
  final String title;
  final bool getSelected;

  MenuSlate({
    this.page,
    this.icon: const Icon(
      Icons.check_circle_outline,
      color: Colors.white,
    ),
    this.getSelected: true,
    this.title: "None",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: screenWidth * 0.37,
        height: screenWidth * 0.4,
        constraints: BoxConstraints(
          maxWidth: 200,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Color(0xAF202020),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 17,
                    child: FittedBox(
                      child: icon,
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.028,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IgnorePointer(
              ignoring: currentPage.value == StockPage.start || !getSelected,
              child: GestureDetector(
                onTap: () {
                  print("tapped $page from menuOpt");
                  currentPage.value = page;
                  print("currentPage value changed to ${currentPage.value}");
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: currentPage.value == page
                        ? Color(0x20FFFFFF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                ),
              ),
            ),
          ],
        ));
  }
}
