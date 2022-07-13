@import PassKit;

#import <React/RCTBridgeModule.h>

@interface RNApplePay : NSObject <RCTBridgeModule, PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) PKPaymentAuthorizationViewController * _Nullable viewController;

@property (nonatomic, strong, nullable) RCTPromiseResolveBlock completeResolve;

@property (nonatomic, strong, nullable) RCTPromiseRejectBlock requestPaymentReject;
@property (nonatomic, strong, nullable) RCTPromiseResolveBlock requestPaymentResolve;

@property (nonatomic, copy, nullable) void (^completion)(PKPaymentAuthorizationResult * _Nullable);

@end
