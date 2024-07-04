import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'api_service.dart';

class ComparisonPage extends StatelessWidget {
  final List<Location> locations;

  ComparisonPage({required this.locations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comparison Chart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  interval: 1,
                  labelRotation: -45,
                  labelStyle: TextStyle(fontSize: 10),
                  labelIntersectAction: AxisLabelIntersectAction.multipleRows,
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                ),
                title: ChartTitle(text: 'Location Ratings Comparison'),
                legend: Legend(isVisible: false),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <ChartSeries>[
                  LineSeries<Location, String>(
                    dataSource: locations,
                    xValueMapper: (Location location, _) =>
                        location.name.length > 10
                            ? location.name.substring(0, 10) + '...'
                            : location.name,
                    yValueMapper: (Location location, _) => location.rating,
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                    enableTooltip: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
