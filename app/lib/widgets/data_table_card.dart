import 'package:flutter/material.dart';

class DataTableCard extends StatelessWidget {
  const DataTableCard({
    required this.title,
    required this.columns,
    required this.rows,
    this.actions = const [],
    super.key,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 12,
                    children: actions,
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  for (final column in columns)
                    DataColumn(label: Text(column)),
                ],
                rows: [
                  for (final row in rows)
                    DataRow(
                      cells: [
                        for (final cell in row)
                          DataCell(Text(cell)),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
