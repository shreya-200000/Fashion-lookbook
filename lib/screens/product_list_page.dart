import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logbook/data/product_model.dart';
import 'package:logbook/data/temp.dart';
import 'package:logbook/screens/products_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData() async {
    final List<Product> loadedProducts = productsData.map((productData) {
      return Product(
        id: productData['id']?.toString() ?? '',
        name: productData['title']?.toString() ?? '',
        description: productData['description']?.toString() ?? '',
        tags: (productData['hashtags'] as List<dynamic>?)?.cast<String>() ?? [],
        media: (productData['media'] as List<dynamic>?)?.toList() ?? [],
      );
    }).toList();

    setState(() {
      products = loadedProducts;
      filteredProducts = products;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.blue[100],
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                onChanged: _filterProducts,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                ),
                style: TextStyle(color: Colors.black),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    )
                  : filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Out of trends',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800]),
                              ),
                              SizedBox(height: 15),
                              Icon(Icons.trending_down,
                                  size: 60, color: Colors.grey[600]),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(20.0),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            return ZoomTapAnimation(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                        product: filteredProducts[index]),
                                  ),
                                );
                              },
                              child:
                                  ProductCard(product: filteredProducts[index]),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _imageIndex = 0;
  Timer? _timer;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startImageTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (_isHovered) {
        setState(() {
          _imageIndex = (_imageIndex + 1) % widget.product.media.length;
        });
      }
    });
  }

  void _stopImageTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _startImageTimer();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _imageIndex = 0;
        });
        _stopImageTimer();
      },
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                ),
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 1000),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    child: Image.network(
                      widget.product.media[_imageIndex]["file_url"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      key: ValueKey<int>(_imageIndex),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                widget.product.name,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                widget.product.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
