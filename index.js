
import { NativeModules, Platform } from 'react-native';

const { RNApplePay } = NativeModules;

const defaultModule = {
  RequestStatus: {},
  canMakePayments: throwError,
  complete: throwError,
  requestPayment: throwError
};

const throwError = () => {
  throw new Error(`Apple Pay is for iOS only, use Platform.OS === 'ios'`)
};

const RNModule = Platform.OS === 'ios' ? RNApplePay : defaultModule;

const { RequestStatus, canMakePayments, complete, requestPayment } = RNModule || defaultModule;

export const ApplePay = { canMakePayments, complete, requestPayment };
export const ApplePayRequestStatus = RequestStatus;
