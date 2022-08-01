export type ApplePayCardNetwork = "amex" | "cartebancaires" | "cartesbancaires" | "chinaunionpay" | "discover" | "eftpos" | "electron" | "elo" | "girocard" | "idcredit" | "interac" | "jcb" | "mada" | "maestro" | "mastercard"| "mir" | "privatelabel" | "quicpay" | "suica" | "vpay" | "visa";

export type ApplePayMerchantCapability = "3ds" | "credit" | "debit" | "emv";

export type ApplePayPaymentResultCardType = "credit" | "debit" | "emoney" | "prepaid" | "store" | "unknown";

export enum ApplePayRequestStatus {
  dismissed = "DISMISSED",
  failure = 1,
  success = 0
}

export interface ApplePayPaymentSummaryItem {
  amount: string
  label: string
  pending?: boolean
}

export interface ApplePayPaymentResult {
  cardType: ApplePayPaymentResultCardType
  displayName: string
  network: string
  paymentData: string
  transactionId: string
}

export interface ApplePayRequest {
  countryCode: string
  currencyCode: string
  merchantCapabilities: ApplePayMerchantCapability[]
  merchantIdentifier: string
  paymentSummaryItems: ApplePayPaymentSummaryItem[]
  supportedNetworks: ApplePayCardNetwork[]
}

export class ApplePay {
  static canMakePayments: boolean
  static complete: (status: ApplePayRequestStatus) => Promise<void>
  static requestPayment: (requestData: ApplePayRequest) => Promise<ApplePayPaymentResult>
}
