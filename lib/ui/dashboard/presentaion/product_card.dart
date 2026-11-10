import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecom/core/theme/colors.dart';
import 'package:flutter_ecom/ui/dashboard/data/controller/product_cart_controller.dart';
import 'package:flutter_ecom/ui/dashboard/data/model/dashboard_model.dart';
import 'package:flutter_ecom/ui/product_detail/data/model/product_model.dart';
import 'package:flutter_ecom/ui/product_detail/presentation/product_details.dart';

class ProductCardWidget extends StatefulWidget {
  final SimilarProductModel product;
  final Function? callbackAction;
  const ProductCardWidget({super.key, required this.product, this.callbackAction});

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
 late ProductCartController productCartController;

 @override
  void initState() {
    // TODO: implement initState
   productCartController = ProductCartController(widget.product);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isInStock = widget.product.status == "In-Stock";

    return ListenableBuilder(listenable: productCartController,
        builder: (context, _){
      return GestureDetector(
        onTap: () {
          if(widget.callbackAction==null) {
            Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                productId: widget.product.id,
                colorId: widget.product.colorId,
                sizeId: widget.product.sizeId,
              ),
            ),
          );
          } else {
            widget.callbackAction?.call();
          }
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0.2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // IMAGE
              // ============================================================

              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: widget.product.image.isEmpty
                          ? Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                      )
                          : CachedNetworkImage(
                        imageUrl: widget.product.image,
                        alignment: Alignment.topCenter,
                        width: double.infinity,

                        // Disk cache
                        maxWidthDiskCache: 400,
                        maxHeightDiskCache: 400,

                        // Memory cache
                        memCacheWidth: 400,
                        fit: BoxFit.fitWidth,
                        placeholder: (context, url) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },

                        errorWidget: (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 38,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),

                    // ========================================================
                    // FAVOURITE BUTTON
                    // ========================================================

                    if(productCartController.product!=null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withValues(alpha: .94),
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            productCartController.toggleFavourite();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 180,
                              ),
                              transitionBuilder: (
                                  child,
                                  animation,
                                  ) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Icon(
                                productCartController.product!.isFavourite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey(
                                  widget.product.isFavourite,
                                ),
                                size: 19,
                                color: productCartController.product!.isFavourite
                                    ? primaryRedButtonColor
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ========================================================
                    // STOCK STATUS
                    // ========================================================

                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.94),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isInStock
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.product.status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isInStock
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============================================================
              // PRODUCT INFO
              // ============================================================

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  6,
                  4,
                  6,
                  4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      widget.product.product,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),


                    // Color + Size
                    if (widget.product.colorName.isNotEmpty ||
                        widget.product.sizeName.isNotEmpty)
                      Text(
                        [
                          if (widget.product.colorName.isNotEmpty)
                            widget.product.colorName,
                          if (widget.product.sizeName.isNotEmpty)
                            widget.product.sizeName,
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),


                    // Price
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.salePrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        if (widget.product.salePrice.isNotEmpty)
                          Text(
                            '₹${widget.product.salePrice}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                              decoration:
                              TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
        });
  }
}


