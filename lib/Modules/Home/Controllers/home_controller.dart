import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Data/Models/tech_pack_model.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  
  // Tech pack data
  final RxList<TechPackModel> allTechPacks = <TechPackModel>[].obs;
  final RxList<TechPackModel> myDesigns = <TechPackModel>[].obs;
  final RxList<TechPackModel> myCollections = <TechPackModel>[].obs;
  final RxList<TechPackModel> favorites = <TechPackModel>[].obs;
  
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _filterTechPacks();
    });
    fetchTechPacks();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _filterTechPacks();
  }

  // Fetch tech packs from Firebase
  Future<void> fetchTechPacks() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      print('Fetching tech packs for user: ${user.uid}');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tech_packs')
          .orderBy('created_at', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} tech packs');

      final techPacks = querySnapshot.docs.map((doc) {
        return TechPackModel.fromMap(doc.data(), doc.id);
      }).toList();

      allTechPacks.value = techPacks;
      _organizeTechPacks();
      
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error fetching tech packs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Organize tech packs into designs and collections
  void _organizeTechPacks() {
    // For now, treat all tech packs as both designs and collections
    // You can add logic here to differentiate based on your business rules
    myDesigns.value = List.from(allTechPacks);
    
    // Group by collection name for collections view
    Map<String, List<TechPackModel>> groupedByCollection = {};
    for (var techPack in allTechPacks) {
      if (!groupedByCollection.containsKey(techPack.collectionName)) {
        groupedByCollection[techPack.collectionName] = [];
      }
      groupedByCollection[techPack.collectionName]!.add(techPack);
    }
    
    // Take one representative from each collection
    myCollections.value = groupedByCollection.values
        .map((collection) => collection.first)
        .toList();
    
    // Filter favorites
    favorites.value = allTechPacks.where((tp) => tp.isFavorite).toList();
    
    // Only apply filter if there's a search query
    if (searchQuery.value.isNotEmpty) {
      _applySearchFilter();
    }
  }

  // Apply search filter without causing recursion
  void _applySearchFilter() {
    final query = searchQuery.value.toLowerCase();
    
    // Filter designs by project name primarily
    myDesigns.value = allTechPacks.where((tp) =>
        tp.projectName.toLowerCase().contains(query) ||
        tp.collectionName.toLowerCase().contains(query)
    ).toList();
    
    // For collections, filter and then group by collection name
    final filteredForCollections = allTechPacks.where((tp) =>
        tp.projectName.toLowerCase().contains(query) ||
        tp.collectionName.toLowerCase().contains(query)
    ).toList();
    
    Map<String, List<TechPackModel>> groupedByCollection = {};
    for (var techPack in filteredForCollections) {
      if (!groupedByCollection.containsKey(techPack.collectionName)) {
        groupedByCollection[techPack.collectionName] = [];
      }
      groupedByCollection[techPack.collectionName]!.add(techPack);
    }
    
    myCollections.value = groupedByCollection.values
        .map((collection) => collection.first)
        .toList();
    
    favorites.value = allTechPacks.where((tp) =>
        tp.isFavorite && (
          tp.projectName.toLowerCase().contains(query) ||
          tp.collectionName.toLowerCase().contains(query)
        )
    ).toList();
  }

  // Filter tech packs based on search query
  void _filterTechPacks() {
    if (searchQuery.value.isEmpty) {
      // Reset to original organized data without recursion
      myDesigns.value = List.from(allTechPacks);
      
      Map<String, List<TechPackModel>> groupedByCollection = {};
      for (var techPack in allTechPacks) {
        if (!groupedByCollection.containsKey(techPack.collectionName)) {
          groupedByCollection[techPack.collectionName] = [];
        }
        groupedByCollection[techPack.collectionName]!.add(techPack);
      }
      
      myCollections.value = groupedByCollection.values
          .map((collection) => collection.first)
          .toList();
      
      favorites.value = allTechPacks.where((tp) => tp.isFavorite).toList();
      return;
    }

    _applySearchFilter();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(TechPackModel techPack) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final newFavoriteStatus = !techPack.isFavorite;
      
      // Update in Firebase
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tech_packs')
          .doc(techPack.id)
          .update({'is_favorite': newFavoriteStatus});

      // Update local state
      final index = allTechPacks.indexWhere((tp) => tp.id == techPack.id);
      if (index != -1) {
        allTechPacks[index] = techPack.copyWith(isFavorite: newFavoriteStatus);
        _organizeTechPacks();
      }

      print('Toggled favorite for ${techPack.projectName}: $newFavoriteStatus');
      
    } catch (e) {
      print('Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'Failed to update favorite status',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get unique collection names
  List<String> get collectionNames {
    final names = allTechPacks.map((tp) => tp.collectionName).toSet().toList();
    names.sort();
    return names;
  }

  // Get tech packs by collection name
  List<TechPackModel> getTechPacksByCollection(String collectionName) {
    return allTechPacks.where((tp) => tp.collectionName == collectionName).toList();
  }

  // Get grouped collections (Map of collection name to tech packs)
  Map<String, List<TechPackModel>> get groupedCollections {
    final techPacksToGroup = searchQuery.value.isEmpty ? allTechPacks : 
        allTechPacks.where((tp) =>
            tp.projectName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
            tp.collectionName.toLowerCase().contains(searchQuery.value.toLowerCase())
        ).toList();
    
    Map<String, List<TechPackModel>> grouped = {};
    for (var techPack in techPacksToGroup) {
      if (!grouped.containsKey(techPack.collectionName)) {
        grouped[techPack.collectionName] = [];
      }
      grouped[techPack.collectionName]!.add(techPack);
    }
    return grouped;
  }

  // Check if there are any tech packs
  bool get hasDesigns => myDesigns.isNotEmpty;
  bool get hasCollections => myCollections.isNotEmpty;
  bool get hasFavorites => favorites.isNotEmpty;
  bool get hasAnyData => allTechPacks.isNotEmpty;

  void startNewProject() {
    // Navigate to create project screen
    Get.toNamed('/gathering_brief');
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterTechPacks();
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchTechPacks();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
