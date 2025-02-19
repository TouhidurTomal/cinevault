import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'movie_model.dart';
import 'home_page.dart';

// API Key (Consider securing this)
const String apiKey = '676a51e72c11d85eb2d36bcc305c5ea8';

class MovieController extends GetxController {
  var movies = <Movie>[].obs;
  var currentMovieIndex = 0.obs;
  var selectedCategory = "All".obs;
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();
  final Dio _dio = Dio();
  Timer? _timer;
  var currentPage = 1.obs;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMovies(); // Initial fetch
    startAutoShuffle(); // Start shuffling movies
    _setupScrollListener();
  }

  /// Fetch movies based on selected category with pagination
  Future<void> fetchMovies() async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;

    try {
      String url = selectedCategory.value == "All"
          ? 'https://api.themoviedb.org/3/movie/popular'
          : 'https://api.themoviedb.org/3/discover/movie';

      Map<String, dynamic> queryParams = {
        'api_key': apiKey,
        'page': currentPage.value,
      };

      if (selectedCategory.value != "All") {
        queryParams['with_genres'] = categoryToGenreId(selectedCategory.value);
      }

      final response = await _dio.get(url, queryParameters: queryParams);
      var movieList = (response.data['results'] as List?)
          ?.map((e) => Movie.fromJson(e))
          .toList() ?? [];

      if (currentPage.value == 1) {
        movies.assignAll(movieList); // Reset only for new category
      } else {
        movies.addAll(movieList); // Append for pagination
      }

      if (movieList.isNotEmpty) {
        currentPage.value++;
      }
    } catch (e) {
      debugPrint('❌ Error fetching movies: $e');
    }

    isLoadingMore.value = false;
  }

  /// Updates category and resets pagination
  void updateCategory(String category) {
    selectedCategory.value = category;
    movies.clear();
    currentPage.value = 1;
    fetchMovies();
  }

  /// Auto-shuffle movie banners every 2 seconds (with manual swipe support)
  void startAutoShuffle() {
    _timer?.cancel(); // Stop existing timer to prevent duplicate calls
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (movies.isNotEmpty) {
        int nextIndex = (currentMovieIndex.value + 1) % movies.length;
        currentMovieIndex.value = nextIndex;
        pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  /// Infinite scrolling for pagination
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (!isLoadingMore.value) {
          fetchMovies();
        }
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    scrollController.dispose();
    super.onClose();
  }
}

/// Helper function to map category names to TMDb genre IDs
int categoryToGenreId(String category) {
  Map<String, int> genreMap = {
    "Action": 28,
    "Adventure": 12,
    "Animation": 16,
    "Comedy": 35,
    "Crime": 80,
    "Documentary": 99,
    "Drama": 18,
    "Family": 10751,
    "Fantasy": 14,
    "History": 36,
    "Horror": 27,
    "Music": 10402,
    "Mystery": 9648,
    "Romance": 10749,
    "Science Fiction": 878,
    "TV Movie": 10770,
    "Thriller": 53,
    "War": 10752,
    "Western": 37
  };
  return genreMap[category] ?? 0;
}

/// Entry point
void main() {
  Get.lazyPut(() => MovieController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
