
import { NativeModules, Platform } from 'react-native';

const { RNApplePay } = NativeModules;

const throwError = () => {
  throw new Error(`Apple Pay is for iOS only, use Platform.OS === 'ios'`)
};

const RNModule =
  Platform.OS === 'ios'
    ? RNApplePay :
    {
      RequestStatus: {},
      canMakePayments: throwError,
      complete: throwError,
      requestPayment: throwError
    };

const { RequestStatus, canMakePayments, complete, requestPayment } = RNModule;

export const ApplePay = { canMakePayments, complete, requestPayment };
export const ApplePayRequestStatus = RequestStatus;
