# BackFlow - App Store Connect & RevenueCat Setup Guide

## Overview

This guide walks through setting up BackFlow in App Store Connect (ASC) and RevenueCat (RC) with separate test and production environments.

---

## 1. App Store Connect Setup

### Create the App

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to **My Apps** → Click **+** → **New App**
3. Fill in the details:
   - **Platform:** iOS
   - **Name:** BackFlow
   - **Primary Language:** English (US)
   - **Bundle ID:** com.albgra.BackFlow
   - **SKU:** BACKFLOW001
   - **User Access:** Full Access

### Create In-App Purchases

1. In your app, go to **In-App Purchases** → **Manage**
2. Click **+** to create new subscriptions

#### Monthly Subscription
- **Reference Name:** BackFlow Premium Monthly
- **Product ID:** com.albgra.BackFlow.premium.monthly
- **Subscription Duration:** 1 Month
- **Subscription Group:** BackFlow Premium
- **Pricing:**
  - Tier 3 ($2.99 USD)
  - Available in all territories

#### Yearly Subscription
- **Reference Name:** BackFlow Premium Yearly
- **Product ID:** com.albgra.BackFlow.premium.yearly
- **Subscription Duration:** 1 Year
- **Subscription Group:** BackFlow Premium
- **Pricing:**
  - Tier 22 ($19.99 USD) - ~33% discount
  - Available in all territories

### Configure Subscription Group

1. Create subscription group: **BackFlow Premium**
2. Set up auto-renewable subscription options
3. Configure free trial (optional):
   - 7 days for new subscribers
4. Set up upgrade/downgrade/crossgrade rules

### Add Localization

For each subscription, add:
- **Display Name:** 
  - Monthly: "BackFlow Premium"
  - Yearly: "BackFlow Premium (Annual)"
- **Description:**
  ```
  Unlock the full potential of your recovery journey:
  • iCloud sync across all devices
  • Advanced progress analytics
  • Export data (CSV/PDF)
  • Home screen widgets
  • Custom progression settings
  ```

---

## 2. RevenueCat Setup

### Create Projects

Log in to [RevenueCat Dashboard](https://app.revenuecat.com)

#### Test Project (for development)
1. Click **Create New Project**
2. Name: **BackFlow (Test)**
3. Platform: iOS
4. Add App:
   - App Name: BackFlow Test
   - Bundle ID: com.albgra.BackFlow
   - App Store Connect App ID: (from ASC)
   - Use Sandbox environment

#### Production Project
1. Click **Create New Project**
2. Name: **BackFlow (Production)**
3. Platform: iOS
4. Add App:
   - App Name: BackFlow
   - Bundle ID: com.albgra.BackFlow
   - App Store Connect App ID: (from ASC)
   - Use Production environment

### Configure Products

For **BOTH** projects:

1. Go to **Products** → **+ New**
2. Add products:

#### Monthly Product
- **Identifier:** premium_monthly
- **App Store ID:** com.albgra.BackFlow.premium.monthly
- **Display Name:** Premium Monthly

#### Yearly Product
- **Identifier:** premium_yearly
- **App Store ID:** com.albgra.BackFlow.premium.yearly
- **Display Name:** Premium Yearly

### Configure Entitlements

1. Go to **Entitlements** → **+ New**
2. Create entitlement:
   - **Identifier:** premium
   - **Display Name:** Premium Access
   - **Products:** Select both monthly and yearly

### Configure Offerings

1. Go to **Offerings** → **+ New**
2. Create default offering:
   - **Identifier:** default
   - **Display Name:** Default Offering
3. Add packages:
   - **Monthly Package:**
     - Identifier: $rc_monthly
     - Product: premium_monthly
   - **Yearly Package:**
     - Identifier: $rc_annual
     - Product: premium_yearly

### Get API Keys

1. **Test Project:**
   - Go to **API Keys** → **Public App-Specific API Keys**
   - Copy the key for iOS
   - This goes in the `#if DEBUG` section

2. **Production Project:**
   - Go to **API Keys** → **Public App-Specific API Keys**
   - Copy the key for iOS
   - This replaces `appl_PRODUCTION_KEY_TO_BE_ADDED`

---

## 3. Update Code with Production Key

```swift
private var apiKey: String {
    #if DEBUG
    return "appl_RXHcJwOudlHkCnQGUzrHnTwLNXt" // Test store API key
    #else
    return "appl_YOUR_PRODUCTION_KEY_HERE" // Production API key from RevenueCat
    #endif
}
```

---

## 4. Testing Configuration

### StoreKit Configuration File

Create `.storekit` configuration in Xcode:

1. File → New → File → StoreKit Configuration File
2. Name: `BackFlow.storekit`
3. Add products matching ASC configuration
4. Enable in scheme for testing

### RevenueCat Debug Settings

In `RevenueCatSubscriptionService.swift`:
```swift
#if DEBUG
Purchases.logLevel = .debug
Purchases.simulatesAskToBuyInSandbox = true
#endif
```

---

## 5. App Store Connect Settings

### App Information
- **Category:** Health & Fitness
- **Content Rights:** Own all rights
- **Age Rating:** 12+ (Medical/Treatment Information)

### Privacy Policy URL
https://backflow.app/privacy

### Support URL
https://backflow.app/support

### Marketing URL
https://backflow.app

---

## 6. RevenueCat Webhooks (Optional)

For server-side subscription tracking:

1. In RevenueCat, go to **Integrations** → **Webhooks**
2. Add endpoint URL for subscription events
3. Configure events to track:
   - Initial purchase
   - Renewal
   - Cancellation
   - Billing issues

---

## 7. Launch Checklist

- [ ] App Store Connect app created
- [ ] Bundle ID matches across all services
- [ ] In-App Purchases created and localized
- [ ] RevenueCat test project configured
- [ ] RevenueCat production project configured
- [ ] API keys updated in code
- [ ] StoreKit configuration file created
- [ ] Test purchases working in sandbox
- [ ] Production API key added (before release)
- [ ] App metadata complete in ASC
- [ ] Privacy policy and support URLs active

---

## Important Notes

1. **Subscription Group:** Keep all subscriptions in the same group for upgrade/downgrade functionality
2. **Pricing:** Yearly discount should be significant (20-33%)
3. **Free Trial:** Consider offering to increase conversions
4. **Grace Period:** Enable 16-day grace period for billing issues
5. **Testing:** Always test full purchase flow in sandbox before production

---

## Support Links

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [RevenueCat Documentation](https://docs.revenuecat.com)
- [StoreKit Testing](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_storekit_testing_in_xcode)