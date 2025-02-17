class Movie {
  final String title;
  final String posterPath;
  final String backdropPath;
  final double rating;

  Movie({
    required this.title,
    required this.posterPath,
    required this.backdropPath,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Unknown Title', // Handle null title
      posterPath: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : 'https://via.placeholder.com/150', // Fallback image

      backdropPath: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['backdrop_path']}'
          : 'https://via.placeholder.com/500', // Fallback image

      rating: (json['vote_average'] as num?)?.toDouble() ?? 0.0, // Handle null rating
    );
  }
}
