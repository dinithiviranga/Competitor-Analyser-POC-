import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'api_service.dart';
import 'detail_page.dart';
import 'comparison_page.dart';

class ListPage extends StatefulWidget {
  final String textCategory;
  final String textLocation;

  ListPage({required this.textCategory, required this.textLocation});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ApiService apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  List<Location> locations = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? nextPageToken;

  @override
  void initState() {
    super.initState();
    _fetchLocations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore &&
          nextPageToken != null) {
        _fetchLocations(pageToken: nextPageToken);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations({String? pageToken}) async {
    if (pageToken == null) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }

    try {
      final textQuery = '${widget.textCategory} in ${widget.textLocation}';
      final result =
          await apiService.fetchLocations(textQuery, pageToken: pageToken);
      setState(() {
        locations.addAll(result['locations']);
        nextPageToken = result['nextPageToken'];
        isLoading = false;
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.textCategory.toUpperCase()),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : locations.isEmpty
              ? Center(child: Text('No locations found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            locations.length + (nextPageToken != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == locations.length) {
                            // Load more indicator
                            return Center(child: CircularProgressIndicator());
                          }

                          final location = locations[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              title: Text(location.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Address: ${location.address}',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                  SizedBox(height: 8),
                                  RatingBarIndicator(
                                    rating: location.rating,
                                    itemBuilder: (context, index) =>
                                        Icon(Icons.star, color: Colors.amber),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(location: location),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    if (isLoadingMore)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: locations.isEmpty
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ComparisonPage(locations: locations),
                                  ),
                                );
                              },
                        child: Text('Compare Locations'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
