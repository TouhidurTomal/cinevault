import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main.dart';

class HomePage extends StatelessWidget {
  final MovieController controller = Get.find<MovieController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Watchlist"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Movie Slider
            Obx(() => controller.movies.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              height: 250,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: (index) {
                  controller.currentMovieIndex.value = index;
                },
                itemCount: controller.movies.length,
                itemBuilder: (context, index) {
                  final movie = controller.movies[index];
                  return Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: movie.backdropPath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: double.infinity,
                        height: 250,
                        color: Colors.black.withAlpha(51),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                    (i) => Icon(
                                  Icons.star,
                                  color: i < (movie.rating / 2).floor()
                                      ? Colors.yellow
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            )),

            // Category Dropdown
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Category",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Obx(() => DropdownButton<String>(
                    value: controller.selectedCategory.value,
                    items: [
                      "All",
                      "Action",
                      "Comedy",
                      "Drama",
                      "Horror",
                      "Sci-Fi"
                    ]
                        .map((String category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        controller.updateCategory(newValue);
                      }
                    },
                  )),
                ],
              ),
            ),

            // Movie Grid with Pagination
            Expanded(
              child: Obx(() => GridView.builder(
                controller: controller.scrollController, // Attach scroll controller
                padding: EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: controller.movies.length,
                itemBuilder: (context, index) {
                  final movie = controller.movies[index];
                  return Column(
                    children: [
                      Expanded(
                        child: CachedNetworkImage(
                          imageUrl: movie.posterPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        movie.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              )),
            ),

            // Show Loading Indicator when fetching more movies
            Obx(() => controller.isLoadingMore.value
                ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            )
                : SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}