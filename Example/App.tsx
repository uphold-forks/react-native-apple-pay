import { ApplePay, ApplePayRequest, ApplePayRequestStatus } from 'react-native-apple-pay';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import React from 'react';

const requestData: ApplePayRequest = {
  countryCode: 'US',
  currencyCode: 'USD',
  merchantCapabilities: ['3ds', 'credit'],
  merchantIdentifier: 'merchant.com.payture.applepay.Busfor',
  supportedNetworks: ['mastercard', 'visa'],
  paymentSummaryItems: [
    {
      label: 'Item label',
      amount: '100.00',
    },
  ],
}

export const App = () => {
  const payWithApplePay = async (status: ApplePayRequestStatus) => {
    // Check if ApplePay is available
    if (ApplePay.canMakePayments) {
      try {
        const paymentData = await ApplePay.requestPayment(requestData);

        console.log({ paymentData })

        setTimeout(async () => {
          try {
            await ApplePay.complete(status)

            console.log('complete')
          } catch (error) {
            console.log({ error })
          }
        }, 1000)
      } catch (error) {
        console.log({ error })

        if (error.code === ApplePayRequestStatus.dismissed) {
          console.log('dismissed')
        }

        if (error.code === ApplePayRequestStatus.requestError) {
          console.log('requestError', error.message)
        }
      }
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.welcome}>Welcome to react-native-apple-pay!</Text>

      <TouchableOpacity style={styles.button} onPress={() => payWithApplePay(ApplePayRequestStatus.success)}>
        <Text style={styles.buttonText}>Buy with Apple Pay (SUCCESS)</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={() => payWithApplePay(ApplePayRequestStatus.failure)}>
        <Text style={styles.buttonText}>Buy with Apple Pay (FAILURE)</Text>
      </TouchableOpacity>
    </View>
  );
};


const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#ffffff',
  },
  welcome: {
    fontSize: 18,
    color: '#222',
  },
  button: {
    marginTop: 24,
    backgroundColor: '#007aff',
    borderRadius: 14,
    height: 56,
    paddingHorizontal: 24,
    justifyContent: 'center',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 18,
  },
});
