class Food {
  final String title;
  final String imageUrl;

  Food({required this.title, required this.imageUrl});

  factory Food.fromFirestore(Map<String, dynamic> data) {
    return Food(
      title: data['title'] as String,
      imageUrl: data['imageUrl'] as String,
    );
  }
}
