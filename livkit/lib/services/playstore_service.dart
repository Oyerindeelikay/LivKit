import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PlayStoreService {
  static const String _productId = 'lifetime_premium';
  static final InAppPurchase _iap = InAppPurchase.instance;

  static Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception("Play Store not available");
    }
  }



  static Future<ProductDetails> _getProduct() async {
    final response =
        await _iap.queryProductDetails({_productId});

    if (response.error != null) {
      throw Exception(response.error!.message);
    }

    if (response.productDetails.isEmpty) {
      throw Exception("Product not found");
    }

    return response.productDetails.first;

  }

  /// Starts purchase flow and returns purchaseToken
  static Future<String> buyPremium() async {
    await init();

    final product = await _getProduct();
    final completer = Completer<String>();

    late StreamSubscription sub;

    sub = _iap.purchaseStream.listen((purchases) async {
      for (final purchase in purchases) {
        if (purchase.productID != _productId) continue;

        if (purchase.status == PurchaseStatus.purchased) {
          if (purchase.verificationData.serverVerificationData.isEmpty) {
            throw Exception("Missing purchase token");
          }

          // IMPORTANT: complete purchase
          await _iap.completePurchase(purchase);

          completer.complete(
            purchase.verificationData.serverVerificationData,
          );
        }

        if (purchase.status == PurchaseStatus.error) {
          completer.completeError(purchase.error!);
        }
      }
    });

    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);

    final token = await completer.future;
    await sub.cancel();
    return token;
  }

  static Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

}
