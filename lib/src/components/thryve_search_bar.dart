import 'package:flutter/material.dart';
import 'package:thryve/src/utilities/helpers.dart';

class ThryveSearchBar extends StatelessWidget {
  const ThryveSearchBar({
    super.key,
    required this.searchController,
    required this.suggestionsBuilder,
    this.hintText,
    this.focusNode,
  });

  final SearchController searchController;
  final Future<List<Widget>> Function(
      BuildContext context, SearchController controller) suggestionsBuilder;
  final String? hintText;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getHorizontalMargin(context),
        vertical: 20.0,
      ),
      child: SearchAnchor(
        searchController: searchController,
        builder: (BuildContext context, SearchController controller) {
          return SearchBar(
            focusNode: focusNode,
            controller: controller,
            elevation: const WidgetStatePropertyAll<double>(0.0),
            padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0),
            ),
            shape: WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: (_) {
              controller.openView();
            },
            leading: const Icon(Icons.search),
            hintText: hintText,
          );
        },
        suggestionsBuilder: suggestionsBuilder,
      ),
    );
  }
}
