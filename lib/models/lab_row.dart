import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

class LabRow {
  final String dateEn, dateAm, risk;
  final double hb, sugar, weight;
  final int sys, dia;

  LabRow(this.dateEn, this.dateAm, this.hb, this.sys, this.dia,
      this.sugar, this.weight, this.risk);

  Color get riskColor => risk == 'red'
      ? TColors.statusRed
      : risk == 'yellow'
          ? TColors.statusYellow
          : TColors.statusGreen;
}
