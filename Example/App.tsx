import { ApplePay, ApplePayDisbursementRequest, ApplePayRequest, ApplePayRequestStatus } from 'react-native-apple-pay';
import { Text, TouchableOpacity, SafeAreaView, View } from 'react-native';
import React from 'react';

const requestPaymentData: ApplePayRequest = {
  countryCode: 'US',
  currencyCode: 'USD',
  merchantCapabilities: ['3ds', 'credit'],
  merchantIdentifier: 'merchant.com.payture.applepay.Busfor',
  paymentSummaryItems: [{ amount: '100.00', label: 'Item label' }],
  supportedNetworks: ['mastercard', 'visa']
}

const requestDisbursementData: ApplePayDisbursementRequest = {
  currencyCode: 'USD',
  disbursementSummaryItem: { label: 'Amount received', amount: '100.00' },
  merchantCapabilities: ['3ds', 'credit'],
  merchantIdentifier: 'merchant.com.payture.applepay.Busfor',
  regionCode: 'US',
  paymentSummaryItems: [{ amount: '100.00', label: 'Business label' }],
  supportedNetworks: ['mastercard', 'visa'],
  supportedRegions: ['US']
}

export const App = () => {
  const content = [{
    buttons: [
      {
        onPress: () => payWithApplePay(ApplePayRequestStatus.success),
        description: "Payment with Apple Pay (SUCCESS)"
      },
      {
        onPress: () => payWithApplePay(ApplePayRequestStatus.failure),
        description: "Payment with Apple Pay (FAILURE)"
      }
    ],
    title: 'Payment flow'
  },
  {
    buttons: [
      {
        onPress: () => disbursementWithApplePay(ApplePayRequestStatus.success),
        description: "Disbursement with Apple Pay (SUCCESS)"
      },
      {
        onPress: () => disbursementWithApplePay(ApplePayRequestStatus.failure),
        description: "Disbursement with Apple Pay (FAILURE)"
      }
    ],
    title: 'Disbursement flow'
  }
  ];

  const disbursementWithApplePay = async (status: ApplePayRequestStatus) => {
    // Check if ApplePay can make disbursements
    if (ApplePay.supportsDisbursements) {
      try {
        const paymentData = await ApplePay.requestDisbursement(requestDisbursementData);

        console.log({ paymentData })

        setTimeout(async () => {
          try {
            await ApplePay.complete(status)

            console.log('complete')
          } catch (error) {
            console.log({ error })
          }
        }, 1000)
      } catch (error: any) {
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

  const payWithApplePay = async (status: ApplePayRequestStatus) => {
    // Check if ApplePay can make payments
    if (ApplePay.canMakePayments) {
      try {
        const paymentData = await ApplePay.requestPayment(requestPaymentData);

        console.log({ paymentData })

        setTimeout(async () => {
          try {
            await ApplePay.complete(status)

            console.log('complete')
          } catch (error) {
            console.log({ error })
          }
        }, 1000)
      } catch (error: any) {
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
    <SafeAreaView style={{
      alignItems: 'center',
      backgroundColor: 'white',
      flex: 1,
      justifyContent: 'center'
    }}>
      <View style={{ gap: 100 }}>
        {content.map(({ buttons, title }, index) => {
          return (
            <View style={{ gap: 8 }} key={index}>
              <Text style={{ color: 'black', fontSize: 18, textAlign: 'center' }}>{title}</Text>
              {buttons.map(({ description, onPress }, index) => {
                return (
                  <TouchableOpacity 
                    key={index} 
                    style={{
                      backgroundColor: 'blue',
                      borderRadius: 14,
                      height: 56,
                      justifyContent: 'center',
                      paddingHorizontal: 24
                    }} 
                    onPress={onPress}>
                    <Text style={{
                      color: 'white',
                      fontSize: 18,
                      textAlign: 'center'
                    }}>
                      {description}
                    </Text>
                  </TouchableOpacity>
                )
              })}
            </View>
          )
        })}
      </View>
    </SafeAreaView>
  );
};
