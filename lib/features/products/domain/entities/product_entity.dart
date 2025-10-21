import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, title, description, price, imageUrl];
}
