
#import "RNApplePay.h"
#import <React/RCTUtils.h>

@implementation RNApplePay

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup
{
  return YES;
}

- (NSDictionary *)constantsToExport
{
  NSDictionary *requestStatus = @{
    @"dismissed": @"DISMISSED",
    @"failure": @(PKPaymentAuthorizationStatusFailure),
    @"requestError": @"REQUEST_ERROR",
    @"success": @(PKPaymentAuthorizationStatusSuccess)
  };

  BOOL supportsDisbursements = NO;

  if (@available(iOS 17, *)) {
    supportsDisbursements = [PKPaymentAuthorizationViewController supportsDisbursements];
  }

  return @{
    @"canMakePayments": @([PKPaymentAuthorizationViewController canMakePayments]),
    @"RequestStatus": requestStatus,
    @"supportsDisbursements": @(supportsDisbursements)
  };  
}

RCT_EXPORT_METHOD(requestDisbursement:(NSDictionary *)props promiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  if (!@available(iOS 17, *)) {
      NSString *errorCode = self.constantsToExport[@"RequestStatus"][@"requestError"];
      NSString *errorMessage = @"Disbursement request is not supported on this version of iOS.";
      NSError *error = nil;
      
      reject(errorCode, errorMessage, error);
      return;
  }

  PKDisbursementRequest *disbursementsRequest = [[PKDisbursementRequest alloc] initWithMerchantIdentifier:
                                          props[@"merchantIdentifier"] 
                                          currencyCode:props[@"currencyCode"]
                                          regionCode:props[@"regionCode"]
                                          supportedNetworks:[self getSupportedNetworks:props]
                                          merchantCapabilities:[self getMerchantCapabilities:props]
                                          summaryItems:[self getDisbursementSummaryItems:props]];

  self.viewController = [[PKPaymentAuthorizationViewController alloc] initWithDisbursementRequest: disbursementsRequest];
  self.viewController.delegate = self;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *rootViewController = RCTPresentedViewController();
    [rootViewController presentViewController:self.viewController animated:YES completion:nil];
    self.requestPaymentResolve = resolve;
    self.requestPaymentReject = reject;
  });
}

RCT_EXPORT_METHOD(requestPayment:(NSDictionary *)props promiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];

  paymentRequest.countryCode = props[@"countryCode"];
  paymentRequest.currencyCode = props[@"currencyCode"];
  paymentRequest.merchantCapabilities = [self getMerchantCapabilities:props];
  paymentRequest.merchantIdentifier = props[@"merchantIdentifier"];
  paymentRequest.paymentSummaryItems = [self getPaymentSummaryItems:props];
  paymentRequest.supportedNetworks = [self getSupportedNetworks:props];

  self.viewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest: paymentRequest];
  self.viewController.delegate = self;

  dispatch_async(dispatch_get_main_queue(), ^{
    UIViewController *rootViewController = RCTPresentedViewController();
    [rootViewController presentViewController:self.viewController animated:YES completion:nil];
    self.requestPaymentResolve = resolve;
    self.requestPaymentReject = reject;
  });
}

RCT_EXPORT_METHOD(complete:(NSNumber *_Nonnull)status promiseWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  self.completeResolve = resolve;

  [self handleCompletion:status];
}

- (NSArray<PKPaymentSummaryItem *> *_Nonnull)getDisbursementSummaryItems:(NSDictionary *_Nonnull)props
{  
    NSDictionary *disbursementSummaryItemProp = props[@"disbursementSummaryItem"];
    NSDecimalNumber *disbursementAmount = [NSDecimalNumber decimalNumberWithString: disbursementSummaryItemProp[@"amount"]];
    NSString *label = disbursementSummaryItemProp[@"label"];
    NSArray <PKPaymentSummaryItem *> *paymentSummaryItems = [self getPaymentSummaryItems:props];
    NSMutableArray <PKPaymentSummaryItem *> *summaryItems = [paymentSummaryItems mutableCopy];

    [summaryItems addObject: [PKDisbursementSummaryItem summaryItemWithLabel:label amount:disbursementAmount]];

    return summaryItems;
}

- (PKMerchantCapability)getMerchantCapabilities:(NSDictionary *_Nonnull)props
{
  NSArray *merchantCapabilitiesProp = props[@"merchantCapabilities"];
  PKMerchantCapability merchantCapability = 0;

  if([merchantCapabilitiesProp containsObject:@"3ds"]) {
    merchantCapability |= PKMerchantCapability3DS;
  }

  if([merchantCapabilitiesProp containsObject:@"emv"]) {
    merchantCapability |= PKMerchantCapabilityEMV;
  }

  if([merchantCapabilitiesProp containsObject:@"credit"] && ![merchantCapabilitiesProp containsObject:@"debit"]) {
    merchantCapability |= PKMerchantCapabilityCredit;
  } else if(![merchantCapabilitiesProp containsObject:@"credit"] && [merchantCapabilitiesProp containsObject:@"debit"]) {
    merchantCapability |= PKMerchantCapabilityDebit;
  }

  return merchantCapability;
}

- (NSArray *_Nonnull)getSupportedNetworks:(NSDictionary *_Nonnull)props
{
  NSMutableDictionary *supportedNetworksMapping = [[NSMutableDictionary alloc] init];

  if (@available(iOS 8, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkAmex forKey:@"amex"];
    [supportedNetworksMapping setObject:PKPaymentNetworkMasterCard forKey:@"mastercard"];
    [supportedNetworksMapping setObject:PKPaymentNetworkVisa forKey:@"visa"];
  }

  if (@available(iOS 9, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkDiscover forKey:@"discover"];
    [supportedNetworksMapping setObject:PKPaymentNetworkPrivateLabel forKey:@"privatelabel"];
  }

  if (@available(iOS 9.2, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkChinaUnionPay forKey:@"chinaunionpay"];
    [supportedNetworksMapping setObject:PKPaymentNetworkInterac forKey:@"interac"];
  }

  if (@available(iOS 10.1, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkJCB forKey:@"jcb"];
    [supportedNetworksMapping setObject:PKPaymentNetworkSuica forKey:@"suica"];
  }

  if (@available(iOS 10.3, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkCarteBancaires forKey:@"cartebancaires"];
    [supportedNetworksMapping setObject:PKPaymentNetworkIDCredit forKey:@"idcredit"];
    [supportedNetworksMapping setObject:PKPaymentNetworkQuicPay forKey:@"quicpay"];
  }

  if (@available(iOS 11.2, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkCartesBancaires forKey:@"cartesbancaires"];
  }

  if (@available(iOS 12.0, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkMaestro forKey:@"maestro"];
    [supportedNetworksMapping setObject:PKPaymentNetworkEftpos forKey:@"eftpos"];
    [supportedNetworksMapping setObject:PKPaymentNetworkElectron forKey:@"electron"];
    [supportedNetworksMapping setObject:PKPaymentNetworkVPay forKey:@"vpay"];
  }

  if (@available(iOS 12.1.1, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkElo forKey:@"elo"];
    [supportedNetworksMapping setObject:PKPaymentNetworkMada forKey:@"mada"];
  }

  if (@available(iOS 14.0, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkGirocard forKey:@"girocard"];
  }

  if (@available(iOS 14.5, *)) {
    [supportedNetworksMapping setObject:PKPaymentNetworkMir forKey:@"mir"];
  }

  NSArray *supportedNetworksProp = props[@"supportedNetworks"];
  NSMutableArray *supportedNetworks = [NSMutableArray array];
  for (NSString *supportedNetwork in supportedNetworksProp) {
    if ([supportedNetworksMapping objectForKey: supportedNetwork]) {
      [supportedNetworks addObject: supportedNetworksMapping[supportedNetwork]];
    }
  }

  return supportedNetworks;
}

- (NSArray<PKPaymentSummaryItem *> *_Nonnull)getPaymentSummaryItems:(NSDictionary *_Nonnull)props
{
  NSMutableArray <PKPaymentSummaryItem *> * paymentSummaryItems = [NSMutableArray array];

  NSArray *displayItems = props[@"paymentSummaryItems"];
  if (displayItems.count > 0) {
    for (NSDictionary *displayItem in displayItems) {
      NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:displayItem[@"amount"]];
      NSString *pending = displayItem[@"pending"];
      PKPaymentSummaryItemType type = (pending ? PKPaymentSummaryItemTypePending : PKPaymentSummaryItemTypeFinal);
      NSString *label = displayItem[@"label"];
      [paymentSummaryItems addObject: [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount type:type]];
    }
  }

  return paymentSummaryItems;
}

- (void)handleCompletion:(NSNumber *_Nonnull)status
{
  if (self.completion != NULL) {
    @try {
      if ([status isEqualToNumber: self.constantsToExport[@"RequestStatus"][@"success"]]) {
        self.completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
      } else {
        self.completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
      }
    }
    @catch (NSException *exception) {
      self.completion([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
    }
    self.completion = NULL;
  }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
             didAuthorizePayment:(PKPayment *)payment
                   handler:(void (^)(PKPaymentAuthorizationResult *result))completion
{
  self.completion = completion;

  if (self.requestPaymentResolve != NULL) {
    @try {
      NSDictionary *typeMapping = @{
        @(PKPaymentMethodTypeCredit): @"credit",
        @(PKPaymentMethodTypeDebit): @"debit",
        @(PKPaymentMethodTypeEMoney): @"emoney",
        @(PKPaymentMethodTypePrepaid): @"prepaid",
        @(PKPaymentMethodTypeStore): @"store",
        @(PKPaymentMethodTypeUnknown): @"unknown"
      };

      NSString *paymentData = [[NSString alloc] initWithData:payment.token.paymentData encoding:NSUTF8StringEncoding];

      NSDictionary *result = @{
        @"cardType": typeMapping[@(payment.token.paymentMethod.type)],
        @"displayName": payment.token.paymentMethod.displayName,
        @"network": payment.token.paymentMethod.network,
        @"paymentData": paymentData,
        @"transactionId": payment.token.transactionIdentifier
      };

      self.requestPaymentResolve(result);
      }
    @catch (NSException *exception) {
      NSString *status = self.constantsToExport[@"RequestStatus"][@"requestError"];

      self.requestPaymentReject(status, exception.reason, nil);
      [self handleCompletion:status];
    }
    @finally {
      self.requestPaymentResolve = NULL;
      self.requestPaymentReject = NULL;
    }
  }
}

- (void)paymentAuthorizationViewControllerDidFinish:(nonnull PKPaymentAuthorizationViewController *)controller {
  dispatch_async(dispatch_get_main_queue(), ^{
    [controller dismissViewControllerAnimated:YES completion:^void {
      if (self.completeResolve != NULL) {
        self.completeResolve(nil);
      }

      if (self.requestPaymentReject != NULL) {
        NSString *dismissedStatus = self.constantsToExport[@"RequestStatus"][@"dismissed"];

        self.requestPaymentReject(dismissedStatus, dismissedStatus, nil);
      } else if (self.requestPaymentResolve != NULL) {
        self.requestPaymentResolve(nil);
      }

      self.completeResolve = NULL;
      self.requestPaymentReject = NULL;
      self.requestPaymentResolve = NULL;
    }];
  });
}

@end
