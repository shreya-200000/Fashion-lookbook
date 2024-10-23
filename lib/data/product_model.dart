class Product {
  final String name;
  final String id;
  final String description;
  final List tags;
  final List media;
  final List reviews;
  final List buyingLinks;

  Product({
    required this.reviews,
    required this.buyingLinks,
    required this.id,
    required this.name,
    required this.description,
    required this.tags,
    required this.media,
  });
}
