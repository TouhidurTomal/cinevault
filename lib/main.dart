import 'package:Cinevault/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'movie_model.dart';

// API Key (Consider securing this)
const String apiKey = '676a51e72c11d85eb2d36bcc305c5ea8';

class MovieController extends GetxController {
  var movies = <Movie>[].obs;
  var currentMovieIndex = 0.obs;
  var selectedCategory = "All".obs;
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController(); // For infinite scroll
  final Dio _dio = Dio();
  Timer? _timer;
  var currentPage = 1.obs; // Track pagination
  var isLoadingMore = false.obs; // Prevent duplicate calls

  @override
  void onInit() {
    super.onInit();
    fetchMovies();
    startAutoShuffle();
    _setupScrollListener();
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    movies.clear(); // Reset movies list when category changes
    currentPage.value = 1; // Reset pagination
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    if (isLoadingMore.value) return; // Prevent multiple API calls
    isLoadingMore.value = true;

    try {
      final response = await _dio.get(
        'https://api.themoviedb.org/3/movie/popular',
        queryParameters: {'api_key': apiKey, 'page': currentPage.value},
      );
      var movieList = (response.data['results'] as List)
          .map((e) => Movie.fromJson(e))
          .toList();

      movies.addAll(movieList);
      currentPage.value++; // Increment page
    } catch (e) {
      debugPrint('❌ Error fetching movies: $e');
    }

    isLoadingMore.value = false;
  }

  void startAutoShuffle() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (movies.isNotEmpty) {
        currentMovieIndex.value = (currentMovieIndex.value + 1) % movies.length;
        pageController.animateToPage(
          currentMovieIndex.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        Future.delayed(Duration(milliseconds: 200), () => fetchMovies());
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
