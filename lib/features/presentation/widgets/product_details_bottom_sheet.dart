import 'package:flutter/material.dart';
import 'package:abhi/features/domain/entities/product.dart';

class ProductDetailsBottomSheet extends StatefulWidget {
  final Product product;
  final ScrollController? scrollController;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductDetailsBottomSheet({
    Key? key,
    required this.product,
    this.scrollController,
    required this.isFavorite,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<ProductDetailsBottomSheet> createState() => _ProductDetailsBottomSheetState();
}

class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          // Use Flexible to avoid layout overflow issues
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductImage(),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductHeader(),
                        SizedBox(height: 16),
                        _buildRatingSection(),
                        SizedBox(height: 24),
                        _buildDescriptionSection(),
                        SizedBox(height: 24),
                        _buildCategorySection(),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            widget.product.image,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 64,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[200],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              );
            },
          ),
          // Close button - top left
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey[800], size: 28),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ),
          // Favorite button - top right
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.grey,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  widget.onFavoriteToggle();
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '\$${widget.product.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(width: 4),
              Text(
                widget.product.rating.rate.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          '(${widget.product.rating.count} reviews)',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.product.category.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple[700],
        ),
      ),
    );
  }
}













// import 'package:flutter/material.dart';
// import 'package:abhi/features/domain/entities/product.dart';
// import 'package:abhi/features/data/models/product_model.dart';

// class ProductDetailsBottomSheet extends StatefulWidget {
//   final Product product;
//   final ScrollController? scrollController;
//   final bool isFavorite;
//   final VoidCallback onFavoriteToggle;

//   const ProductDetailsBottomSheet({
//     Key? key,
//     required this.product,
//     this.scrollController,
//     required this.isFavorite,
//     required this.onFavoriteToggle,
//   }) : super(key: key);

//   @override
//   State<ProductDetailsBottomSheet> createState() => _ProductDetailsBottomSheetState();
// }

// class _ProductDetailsBottomSheetState extends State<ProductDetailsBottomSheet> {
//   late bool _isFavorite;

//   @override
//   void initState() {
//     super.initState();
//     _isFavorite = widget.isFavorite;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildDragHandle(),
//           Expanded(
//             child: SingleChildScrollView(
//               controller: widget.scrollController,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildProductImage(),
//                   Padding(
//                     padding: EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildProductHeader(),
//                         SizedBox(height: 16),
//                         _buildRatingSection(),
//                         SizedBox(height: 24),
//                         _buildDescriptionSection(),
//                         SizedBox(height: 24),
//                         _buildCategorySection(),
//                         SizedBox(height: 32),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDragHandle() {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 12),
//       width: 40,
//       height: 4,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(2),
//       ),
//     );
//   }

//   Widget _buildProductImage() {
//     return Container(
//       height: 300,
//       width: double.infinity,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           Image.network(
//             widget.product.image,
//             fit: BoxFit.contain,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[200],
//                 child: Icon(
//                   Icons.image_not_supported,
//                   color: Colors.grey[400],
//                   size: 64,
//                 ),
//               );
//             },
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 color: Colors.grey[200],
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     value: loadingProgress.expectedTotalBytes != null
//                         ? loadingProgress.cumulativeBytesLoaded /
//                             loadingProgress.expectedTotalBytes!
//                         : null,
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//                   ),
//                 ),
//               );
//             },
//           ),
//           Positioned(
//             top: 16,
//             right: 16,
//             child: Container(
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.9),
//                 shape: BoxShape.circle,
//               ),
//               child: IconButton(
//                 icon: Icon(
//                   _isFavorite ? Icons.favorite : Icons.favorite_border,
//                   color: _isFavorite ? Colors.red : Colors.grey,
//                   size: 28,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _isFavorite = !_isFavorite;
//                   });
//                   widget.onFavoriteToggle();
//                 },
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildProductHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           widget.product.title,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           '\$${widget.product.price.toStringAsFixed(2)}',
//           style: TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: Colors.deepPurple,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRatingSection() {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.amber.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.star,
//                 color: Colors.amber,
//                 size: 20,
//               ),
//               SizedBox(width: 4),
//               Text(
//                 widget.product.rating.rate.toString(),
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.amber[800],
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(width: 8),
//         Text(
//           '(${widget.product.rating.count} reviews)',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Description',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         SizedBox(height: 8),
//         Text(
//           widget.product.description,
//           style: TextStyle(
//             fontSize: 16,
//             color: Colors.grey[800],
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCategorySection() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.deepPurple.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         widget.product.category.toUpperCase(),
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//           color: Colors.deepPurple[700],
//         ),
//       ),
//     );
//   }
// } 