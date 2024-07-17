import { NativeModules, Platform } from 'react-native';

const { RNApplePay } = NativeModules;

const defaultModule = {
  RequestStatus: {},
  canMakePayments: throwError,
  complete: throwError,
  requestDisbursement: throwError,
  requestPayment: throwError,
  supportsDisbursements: throwError
};

const throwError = () => {
  throw new Error(`Apple Pay is for iOS only, use Platform.OS === 'ios'`);
};

const RNModule = Platform.OS === 'ios' ? RNApplePay : defaultModule;

const { RequestStatus, canMakePayments, complete, requestDisbursement, requestPayment, supportsDisbursements } = RNModule || defaultModule;

export const ApplePay = { canMakePayments, complete, requestDisbursement, requestPayment, supportsDisbursements };
export const ApplePayRequestStatus = RequestStatus;
