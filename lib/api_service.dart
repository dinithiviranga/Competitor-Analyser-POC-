import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey =
      'AIzaSyBEEtcXOfXHSlJv9EIqBDS_-a5c4gxS7PI'; // Replace with your actual API key
  static const String apiUrl =
      'https://places.googleapis.com/v1/places:searchText';

  Future<Map<String, dynamic>> fetchLocations(String query,
      {String? pageToken}) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': '*',
      },
      body: jsonEncode({
        'textQuery': query,
        if (pageToken != null) 'pageToken': pageToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final locations = (data['places'] as List)
          .map((json) => Location.fromJson(json))
          .toList();
      return {
        'locations': locations,
        'nextPageToken': data['nextPageToken'],
      };
    } else {
      throw Exception('Failed to load locations');
    }
  }
}

class Location {
  final String id;
  final String phoneNumber;
  final String address;
  final double latitude;
  final double longitude;
  final double rating;
  final String website;
  final String name;
  final List<Review> reviews;

  Location({
    required this.id,
    required this.phoneNumber,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.website,
    required this.name,
    required this.reviews,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] ?? 'No ID available',
      phoneNumber:
          json['internationalPhoneNumber'] ?? 'No phone number available',
      address: json['formattedAddress'] ?? 'No address available',
      latitude: json['location'] != null ? json['location']['latitude'] : 0.0,
      longitude: json['location'] != null ? json['location']['longitude'] : 0.0,
      rating: json['rating']?.toDouble() ?? 0.0,
      website: json['websiteUri'] ?? 'No website available',
      name: json['displayName'] != null
          ? json['displayName']['text']
          : 'No name available',
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
              .map((reviewJson) => Review.fromJson(reviewJson))
              .toList()
          : [],
    );
  }
}

class Review {
  final String authorName;
  final String text;
  final int rating;
  final String relativeTime;

  Review({
    required this.authorName,
    required this.text,
    required this.rating,
    required this.relativeTime,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      authorName: json['authorAttribution'] != null
          ? json['authorAttribution']['displayName']
          : 'Unknown author',
      text: json['text'] != null
          ? json['text']['text']
          : 'No review text available',
      rating: json['rating'] ?? 0,
      relativeTime:
          json['relativePublishTimeDescription'] ?? 'No time available',
    );
  }
}
