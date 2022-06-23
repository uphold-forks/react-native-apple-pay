
import { NativeModules, Platform } from 'react-native';

const { RNApplePay } = NativeModules;

const throwError = () => {
  throw new Error(`Apple Pay is for iOS only, use Platform.OS === 'ios'`)
};

const mockAndroid = {
  requestPayment: throwError,
  complete: throwError,
};

const ApplePay = Platform.OS === 'ios' ? RNApplePay : mockAndroid

export { ApplePay };
