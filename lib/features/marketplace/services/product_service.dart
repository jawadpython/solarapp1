import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:noor_energy/features/marketplace/models/product_model.dart';

/// Service for fetching products from Firestore
/// Handles real-time streams and one-time fetches
class ProductService {
  /// Lazy getter for FirebaseFirestore instance
  /// Throws exception if Firebase is not initialized
  FirebaseFirestore get _db {
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase is not initialized. Please configure Firebase first.');
    }
    return FirebaseFirestore.instance;
  }

  /// Reference to the 'products' collection
  CollectionReference get _productsCollection => _db.collection('products');

  /// Get products as a stream for real-time updates
  /// 
  /// Returns a stream of ProductModel list that updates automatically
  /// when products are added, modified, or deleted in Firestore.
  /// 
  /// Use with StreamBuilder in the UI for live data updates.
  /// 
  /// Example:
  /// ```dart
  /// StreamBuilder<List<ProductModel>>(
  ///   stream: ProductService().getProducts(),
  ///   builder: (context, snapshot) {
  ///     if (snapshot.hasError) {
  ///       return Text('Error: ${snapshot.error}');
  ///     }
  ///     if (!snapshot.hasData) {
  ///       return CircularProgressIndicator();
  ///     }
  ///     return ListView.builder(
  ///       itemCount: snapshot.data!.length,
  ///       itemBuilder: (context, index) {
  ///         return ProductCard(product: snapshot.data![index]);
  ///       },
  ///     );
  ///   },
  /// )
  /// ```
  Stream<List<ProductModel>> getProducts() {
    // Use StreamController to handle errors gracefully
    final controller = StreamController<List<ProductModel>>();
    
    try {
      // Fetch all products and filter in memory to avoid index requirement
      final subscription = _productsCollection
          .snapshots()
          .listen(
        (snapshot) {
          try {
            final allProducts = <ProductModel>[];

            for (var doc in snapshot.docs) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                final product = ProductModel.fromJson(data);
                allProducts.add(product);
              } catch (e) {
                if (kDebugMode) debugPrint('❌ Error parsing product ${doc.id}: $e');
              }
            }

            // Filter: only status == 'active' (case-insensitive)
            var activeProducts = allProducts.where((product) {
              return product.status.toLowerCase().trim() == 'active';
            }).toList();

            // Sort by brand then category in memory
            activeProducts.sort((a, b) {
              final brandCompare = a.brand.compareTo(b.brand);
              if (brandCompare != 0) return brandCompare;
              return a.category.compareTo(b.category);
            });

            controller.add(activeProducts);
          } catch (e) {
            if (kDebugMode) debugPrint('❌ Error mapping products snapshot: $e');
            controller.addError(e);
          }
        },
        onError: (error) {
          if (kDebugMode) debugPrint('Error in getProducts stream: $error');
          controller.addError(error);
        },
        cancelOnError: false, // Don't cancel on error
      );
      
      // Clean up subscription when stream is closed
      controller.onCancel = () {
        subscription.cancel();
      };
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting up getProducts stream: $e');
      controller.addError(e);
    }
    
    return controller.stream;
  }

  /// Get products once (non-streaming)
  /// 
  /// Fetches all active products from Firestore once and returns them.
  /// Use this when you don't need real-time updates.
  /// 
  /// Returns empty list if:
  /// - Firebase is not initialized
  /// - Collection doesn't exist
  /// - No products found
  /// - Error occurs during fetch
  /// 
  /// Example:
  /// ```dart
  /// final products = await ProductService().getProductsOnce();
  /// if (products.isEmpty) {
  ///   print('No products found');
  /// } else {
  ///   print('Found ${products.length} products');
  /// }
  /// ```
  Future<List<ProductModel>> getProductsOnce() async {
    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase is not initialized');
        return [];
      }

      final snapshot = await _productsCollection
          .where('status', isEqualTo: 'Active')
          // No orderBy to avoid index requirement - we'll sort in memory
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Timeout fetching products');
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (snapshot.docs.isEmpty) {
        debugPrint('No products found in Firestore');
        return [];
      }

      final products = <ProductModel>[];
      
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>;
          final product = ProductModel.fromJson(data);
          products.add(product);
        } catch (e) {
          debugPrint('Error parsing product document ${doc.id}: $e');
          // Continue with other products even if one fails
          continue;
        }
      }

      // Sort by brand, then category in memory (no index needed)
      products.sort((a, b) {
        final brandCompare = a.brand.compareTo(b.brand);
        if (brandCompare != 0) return brandCompare;
        return a.category.compareTo(b.category);
      });

      debugPrint('Successfully fetched ${products.length} products');
      return products;
    } on TimeoutException {
      debugPrint('Timeout while fetching products');
      return [];
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching products: ${e.code} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('Unexpected error fetching products: $e');
      return [];
    }
  }

  /// Get a single product by document ID
  /// 
  /// Returns null if product doesn't exist or error occurs
  Future<ProductModel?> getProductById(String productId) async {
    try {
      if (Firebase.apps.isEmpty) {
        debugPrint('Firebase is not initialized');
        return null;
      }

      final doc = await _productsCollection
          .doc(productId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timeout', const Duration(seconds: 10));
            },
          );

      if (!doc.exists) {
        debugPrint('Product $productId does not exist');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        debugPrint('Product $productId has no data');
        return null;
      }

      return ProductModel.fromJson(data);
    } on TimeoutException {
      debugPrint('Timeout while fetching product $productId');
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Firebase error fetching product $productId: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Unexpected error fetching product $productId: $e');
      return null;
    }
  }

  /// Get products filtered by category
  /// 
  /// Returns a stream of products filtered by the specified category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    try {
      return _productsCollection
          .where('status', isEqualTo: 'Active')
          .where('category', isEqualTo: category)
          // No orderBy to avoid index requirement - we'll sort in memory
          .snapshots()
          .map((snapshot) {
        try {
          final products = snapshot.docs
              .map((doc) {
                try {
                  final data = doc.data() as Map<String, dynamic>;
                  return ProductModel.fromJson(data);
                } catch (e) {
                  debugPrint('Error parsing product document ${doc.id}: $e');
                  return null;
                }
              })
              .whereType<ProductModel>()
              .toList();
          
          // Sort by brand in memory
          products.sort((a, b) => a.brand.compareTo(b.brand));
          
          return products;
        } catch (e) {
          debugPrint('Error mapping products by category: $e');
          return <ProductModel>[];
        }
      }).handleError((error) {
        debugPrint('Error in getProductsByCategory stream: $error');
        return <ProductModel>[];
      });
    } catch (e) {
      debugPrint('Error setting up getProductsByCategory stream: $e');
      return Stream.value(<ProductModel>[]);
    }
  }
}

