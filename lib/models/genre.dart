import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'genre.g.dart';

@JsonSerializable()
class Genre extends Equatable {
  final String name;
  final String color;
  final String description;

  const Genre({
    required this.name,
    required this.color,
    required this.description,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);

  @override
  List<Object?> get props => [name, color, description];

  // Helper to convert hex color string to Color object
  Color get colorValue {
    return Color(int.parse(color.replaceFirst('#', '0xFF')));
  }

  // Predefined genres
  static const List<Genre> defaultGenres = [
    Genre(
      name: 'Pop',
      color: '#FF6B6B',
      description: 'Musik populer modern',
    ),
    Genre(
      name: 'Rock',
      color: '#4ECDC4',
      description: 'Musik rock klasik dan modern',
    ),
    Genre(
      name: 'Jazz',
      color: '#45B7D1',
      description: 'Musik jazz klasik dan kontemporer',
    ),
    Genre(
      name: 'Lo-Fi',
      color: '#96CEB4',
      description: 'Musik santai untuk study dan relaksasi',
    ),
    Genre(
      name: 'Indie',
      color: '#FFEAA7',
      description: 'Musik indie dan alternatif',
    ),
  ];
}
