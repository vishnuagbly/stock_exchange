import 'package:flutter/material.dart';
import 'package:stockexchange/global.dart';

class LeadingArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {
          currentPage.value = StockPage.home;
          if(fromCompanyPage)
            Navigator.pushNamed(context, "/company_page");
        },
        child: Icon(
          Icons.arrow_back_ios,
        ),
      ),
    );
  }
}
