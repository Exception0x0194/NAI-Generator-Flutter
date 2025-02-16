class GenerationSize {
  final int width;
  final int height;

  const GenerationSize({
    required this.width,
    required this.height,
  });

  Map<String, dynamic> toJson() {
    return {"width": width, "height": height};
  }

  factory GenerationSize.fromJson(Map<String, dynamic> json) {
    return GenerationSize(
        width: json["width"] ?? 1024, height: json["height"] ?? 1024);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GenerationSize) return false;
    return other.width == width && other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}
