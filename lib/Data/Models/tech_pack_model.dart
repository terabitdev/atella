class TechPackModel {
  final String id;
  final String projectName;
  final String collectionName;
  final Map<String, String> images;
  final String? selectedDesignImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isFavorite;
  final bool hasTechPack;

  TechPackModel({
    required this.id,
    required this.projectName,
    required this.collectionName,
    required this.images,
    this.selectedDesignImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.hasTechPack = true,
  });

  // Get the selected design image for display (preferred) or fallback to tech pack image
  String? get displayImage {
    // Prefer the selected design image if available
    if (selectedDesignImageUrl != null && selectedDesignImageUrl!.isNotEmpty) {
      return selectedDesignImageUrl;
    }
    // Fallback to first tech pack image
    if (images.isNotEmpty) {
      return images.values.first;
    }
    return null;
  }

  // Create from Firestore document
  factory TechPackModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TechPackModel(
      id: documentId,
      projectName: map['project_name'] ?? 'Untitled Project',
      collectionName: map['collection_name'] ?? 'General Collection',
      images: Map<String, String>.from(map['images'] ?? {}),
      selectedDesignImageUrl: map['selected_design_image_url'],
      createdAt: map['created_at']?.toDate() ?? DateTime.now(),
      updatedAt: map['updated_at']?.toDate() ?? DateTime.now(),
      isFavorite: map['is_favorite'] ?? false,
      hasTechPack: map['has_tech_pack'] ?? true,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'project_name': projectName,
      'collection_name': collectionName,
      'images': images,
      'selected_design_image_url': selectedDesignImageUrl,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_favorite': isFavorite,
      'has_tech_pack': hasTechPack,
    };
  }

  // Create a copy with updated fields
  TechPackModel copyWith({
    String? id,
    String? projectName,
    String? collectionName,
    Map<String, String>? images,
    String? selectedDesignImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? hasTechPack,
  }) {
    return TechPackModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      collectionName: collectionName ?? this.collectionName,
      images: images ?? this.images,
      selectedDesignImageUrl: selectedDesignImageUrl ?? this.selectedDesignImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      hasTechPack: hasTechPack ?? this.hasTechPack,
    );
  }

  @override
  String toString() {
    return 'TechPackModel(id: $id, projectName: $projectName, collectionName: $collectionName, isFavorite: $isFavorite)';
  }
}