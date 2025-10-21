import 'package:clarity/features/products/domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String title;
  final String description;
  final num price;

  final String? imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,

    this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],

      imageUrl: json['thumbnail'] ?? (json['images'] != null && (json['images'] as List).isNotEmpty ? json['images'][0] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,

      'image': imageUrl,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      description: description,
      price: price as double,

      imageUrl: imageUrl,
    );
  }
}
