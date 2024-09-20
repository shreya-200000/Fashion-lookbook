import 'package:flutter/material.dart';
import 'package:logbook/data/product_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _currentMediaIndex = 0;
  bool _showMediaCarousel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 0,
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.teal.shade50, Colors.white],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style:
                                Theme.of(context).textTheme.headline4?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                          ),
                          SizedBox(height: 24),
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade600,
                                        ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    widget.product.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        ?.copyWith(
                                          color: Colors.grey.shade700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Hashtags:',
                            style:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade600,
                                    ),
                          ),
                          SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.product.tags
                                .map((hashtag) => Chip(
                                      label: Text(hashtag),
                                      backgroundColor:
                                          Colors.teal.withOpacity(0.1),
                                      labelStyle: TextStyle(
                                          color: Colors.teal.shade700),
                                      elevation: 2,
                                      shadowColor: Colors.teal.withOpacity(0.3),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showMediaCarousel = true;
                        });
                      },
                      child: Hero(
                        tag: 'productMedia',
                        child: Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          margin: EdgeInsets.all(24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: _buildMediaWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showMediaCarousel) _buildMediaCarousel(),
        ],
      ),
      bottomNavigationBar: _buildMediaSelector(),
    );
  }

  Widget _buildMediaWidget() {
    final media = widget.product.media[_currentMediaIndex];
    final isVideo = media['file_type'] == 'video';

    if (isVideo) {
      return _buildVideoPlayer(media['file_url']);
    } else {
      return PhotoView(
        imageProvider: NetworkImage(media['file_url']),
        minScale: PhotoViewComputedScale.covered,
        maxScale: PhotoViewComputedScale.covered * 2,
        scaleStateController: PhotoViewScaleStateController(),
        enableRotation: false,
        backgroundDecoration: BoxDecoration(
          color: Colors.teal.shade50,
        ),
      );
    }
  }

  Widget _buildVideoPlayer(String url) {
    final videoPlayerController = VideoPlayerController.network(url);
    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );

    return Chewie(controller: chewieController);
  }

  Widget _buildMediaSelector() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.product.media.length,
        itemBuilder: (context, index) {
          final media = widget.product.media[index];
          final isVideo = media['file_type'] == 'video';

          return GestureDetector(
            onTap: () {
              setState(() {
                _currentMediaIndex = index;
              });
            },
            child: Container(
              width: 120,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _currentMediaIndex == index
                      ? Colors.teal
                      : Colors.grey.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      isVideo ? media['thumbnail_url'] : media['file_url'],
                      fit: BoxFit.cover,
                    ),
                    if (isVideo)
                      Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaCarousel() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showMediaCarousel = false;
        });
      },
      child: Container(
        color: Colors.teal.withOpacity(0.9),
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            initialPage: _currentMediaIndex,
            onPageChanged: (index, reason) {
              setState(() {
                _currentMediaIndex = index;
              });
            },
          ),
          items: widget.product.media.map((media) {
            final isVideo = media['file_type'] == 'video';
            if (isVideo) {
              return _buildVideoPlayer(media['file_url']);
            } else {
              return PhotoView(
                imageProvider: NetworkImage(
                  media['file_url'],
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                scaleStateController: PhotoViewScaleStateController(),
                enableRotation: false,
                backgroundDecoration: BoxDecoration(
                  color: Colors.teal.shade50,
                ),
              );
            }
          }).toList(),
        ),
      ),
    );
  }
}
