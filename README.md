# 💰 Moneta - AI-Powered Personal Finance Tracker

<div align="center">

![Moneta Logo](moneta_app/assets/images/moneta-logo.png)

**Your Smart Financial Companion with AI-Powered Insights**

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Functions-orange.svg)](https://firebase.google.com/)
[![Gemini AI](https://img.shields.io/badge/Gemini%20AI-2.0%20Flash-green.svg)](https://ai.google.dev/)
[![License](https://img.shields.io/badge/License-Private-red.svg)](LICENSE)

</div>

## 🚀 Overview

Moneta is an intelligent personal finance tracking application built with Flutter that automatically captures and categorizes your transactions from banking SMS messages. Powered by Google's Gemini AI, it provides personalized financial advice, budget planning, and investment recommendations tailored specifically for Indian users.

## ✨ Key Features

### 📱 **Automatic SMS Transaction Capture**
- **Smart SMS Parsing**: Automatically captures and parses banking SMS notifications
- **Multi-Bank Support**: Works with all major Indian banks (HDFC, ICICI, SBI, Axis, PNB, BCCB, etc.)
- **Real-time Processing**: Instant transaction categorization and balance tracking
- **Duplicate Prevention**: Advanced filtering to prevent duplicate transaction entries

### 🧠 **AI-Powered Financial Intelligence**
- **Personalized Tips**: Gemini AI analyzes spending patterns to provide tailored financial advice
- **Smart Categorization**: Automatic transaction categorization with 15+ predefined categories
- **Budget Planning**: AI-generated monthly budget plans based on your spending habits
- **Investment Advice**: Personalized investment recommendations with SIP suggestions

### 📊 **Comprehensive Analytics**
- **Monthly Reports**: Detailed spending analysis with category breakdowns
- **Visual Insights**: Interactive charts and graphs for spending patterns
- **Savings Rate Tracking**: Monitor your financial health with savings rate calculations
- **Category Analysis**: Detailed breakdown of spending by categories with emoji tags

### 🏠 **Home Widget Integration**
- **Quick Overview**: Android home widget showing daily debit/credit totals
- **Real-time Updates**: Automatically updates with latest transaction data
- **Minimalist Design**: Clean, informative widget for your home screen

### 🔔 **Smart Notifications**
- **Transaction Alerts**: Instant notifications for new transactions
- **Bulk Processing**: Notifications for SMS inbox imports
- **Balance Updates**: Real-time balance notifications
- **Financial Reminders**: Proactive financial guidance alerts

## 🛠️ Technical Architecture

### **Frontend (Flutter)**
- **Framework**: Flutter 3.7.2 with Dart SDK
- **State Management**: Provider pattern for reactive UI
- **Local Storage**: Hive database for offline transaction storage
- **Charts**: FL Chart for beautiful data visualizations
- **Theming**: Dark/Light theme support with custom app themes

### **Backend (Firebase)**
- **Cloud Functions**: TypeScript-based serverless functions
- **Firestore**: NoSQL database for cloud transaction storage
- **Authentication**: Firebase Auth for secure user management
- **API Integration**: Direct Gemini AI API integration

### **AI Integration**
- **Model**: Google Gemini 2.0 Flash for financial analysis
- **Features**: Natural language processing for financial advice
- **Context**: Indian financial market awareness (SIP, FD, ELSS, PPF)
- **Personalization**: User-specific spending pattern analysis

## 📂 Project Structure

```
moneta_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   └── transaction.dart      # Transaction model
│   ├── screens/                  # UI screens
│   │   ├── home.dart            # Main dashboard
│   │   ├── dashboard.dart       # Financial overview
│   │   ├── insights.dart        # AI-powered insights
│   │   ├── financial_advice_screen.dart  # Financial advice
│   │   ├── local_transactions.dart       # Transaction history
│   │   └── monthly_reports.dart         # Monthly analytics
│   ├── services/                # Business logic
│   │   ├── sms_capture.dart     # SMS processing
│   │   ├── sms_parser_service.dart     # Transaction parsing
│   │   ├── gemini_advice_service.dart  # AI integration
│   │   ├── insights_service.dart       # Analytics engine
│   │   ├── notification_service.dart   # Push notifications
│   │   └── widget_service.dart         # Home widget
│   ├── widgets/                 # Reusable components
│   ├── theme/                   # App theming
│   └── local/                   # Local storage
├── functions/                   # Firebase Cloud Functions
├── android/                     # Android configuration
└── assets/                      # App resources
```

## 🎯 Core Features Deep Dive

### 1. **Enhanced SMS Transaction Parser**

**Supported Transaction Types:**
- ✅ Debit transactions (payments, purchases, transfers)
- ✅ Credit transactions (salary, refunds, deposits)
- ✅ UPI transactions with merchant details
- ✅ ATM withdrawals and cash transactions
- ✅ EMI and recurring payments

**Parsing Capabilities:**
- **Amount Extraction**: Supports INR, Rs., ₹ formats with comma separation
- **Date Recognition**: Multiple date formats (DD-MMM-YYYY, DD/MM/YYYY)
- **Merchant Detection**: Smart extraction of business names and payment recipients
- **Transaction ID**: Extracts UPI reference numbers and transaction IDs
- **Balance Tracking**: Current balance extraction from SMS

**Example SMS Processing:**
```
Input: "Your BCCB A/c XXXXXX is debited INR 60.00 On 17-AUG-2025 by UPI/DR/522916825224/STAR B. Clear bal INR 1,50,893.38."

Output: {
  type: 'debit',
  amount: 60.0,
  date: '17-AUG-2025',
  recipient: 'STAR B',
  category: 'Food & Beverages',
  transactionId: '522916825224',
  balance: 150893.38
}
```

### 2. **AI-Powered Financial Insights**

**Financial Analysis:**
- **Spending Pattern Recognition**: Identifies unusual spending behaviors
- **Category Optimization**: Specific recommendations for high-spending categories
- **Savings Opportunities**: Concrete steps to improve savings rate
- **Risk Assessment**: Alerts for concerning spending patterns

**Personalized Recommendations:**
- **Budget Allocation**: Category-wise spending recommendations
- **Investment Suggestions**: SIP, FD, ELSS recommendations based on surplus
- **Emergency Fund**: Guidance on emergency fund building
- **Tax Planning**: 80C investment suggestions for tax optimization

### 3. **Smart Categorization System**

**Pre-defined Categories with Emoji Tags:**
- 🍽️ **Food & Beverages**: Restaurants, food delivery, cafes
- 🚗 **Transport**: Uber, Ola, fuel, metro, parking
- 🛒 **Shopping**: Amazon, Flipkart, retail stores
- 🎬 **Entertainment**: Netflix, movies, games, subscriptions
- 💡 **Bills & Utilities**: Electricity, water, internet, mobile
- 🏥 **Healthcare**: Hospitals, pharmacies, medical expenses
- 📚 **Education**: Schools, courses, books, training
- ⛽ **Fuel**: Petrol pumps, vehicle fuel
- 🏦 **Banking & Finance**: ATM, loans, EMI, bank charges

**Frequency Tags:**
- 🔥 Very frequent (15+ transactions)
- ⚡ Frequent (10+ transactions)  
- 📍 Regular (5+ transactions)

### 4. **Advanced Dashboard**

**Three Key Metrics:**
- **Debited**: Total outgoing transactions
- **Credited**: Total incoming transactions  
- **Balance**: Current account balance

**Monthly Analytics Reset:**
- Automatic monthly report generation
- Analytics reset for fresh monthly insights
- Year-over-year comparison capabilities

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK 3.7.2 or higher
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Gemini AI API key

### 1. Clone the Repository
```bash
git clone https://github.com/RA-L-PH/Moneta.git
cd Moneta/moneta_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase project
firebase init

# Deploy Cloud Functions
cd functions
npm install
firebase deploy --only functions
```

### 4. Configure API Keys
```dart
// In lib/services/gemini_advice_service.dart
static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';
```

### 5. Android Permissions
The app requires the following permissions (automatically handled):
- `READ_SMS`: For SMS transaction capture
- `POST_NOTIFICATIONS`: For transaction notifications
- `INTERNET`: For AI API calls and cloud sync

### 6. Run the App
```bash
flutter run
```

## 📱 Usage Guide

### 1. **First Launch**
- Grant SMS and notification permissions
- The app automatically starts capturing banking SMS
- View transactions in the Dashboard tab

### 2. **Dashboard Overview**
- **Overview Section**: See your debited, credited, and balance amounts
- **Category Breakdown**: Visual charts of spending categories
- **Recent Transactions**: Latest transaction history

### 3. **AI Insights**
- Navigate to **Insights** tab
- Select date range for analysis
- Toggle AI insights for detailed analysis
- Get personalized spending tips with emoji tags

### 4. **Financial Advice**
- **Financial Tips**: AI-generated personalized tips
- **Budget Planning**: Set income and savings targets
- **Investment Advice**: Get portfolio recommendations

### 5. **Home Widget Setup**
- Long press on Android home screen
- Add **Moneta Widget**
- View daily transaction totals at a glance

## 🔒 Privacy & Security

### **Data Protection**
- **Local-First**: Transactions stored locally using Hive encryption
- **Selective Sync**: Only aggregated data sent to AI services
- **No Raw SMS**: Raw SMS content is anonymized for AI analysis
- **Secure API**: All API calls use HTTPS encryption

### **Permissions**
- **SMS Access**: Only reads banking SMS, no personal messages
- **Notification**: For transaction alerts only
- **Internet**: For AI insights and cloud backup (optional)

### **Google Play Protect Compliance**
- **Code Obfuscation**: ProGuard enabled for release builds
- **Network Security**: Configured security policies
- **No Malicious Behavior**: Transparent SMS processing only

## 🧪 Testing

### Unit Tests
```bash
# Run SMS parser tests
flutter test test/sms_parser_test.dart

# Run AI advice tests  
flutter test test/gemini_advice_test.dart

# Run all tests
flutter test
```

### Interactive Testing
- Use the **SMS Parser Test Screen** in the app
- Test sample banking SMS messages
- Verify parsing accuracy and categorization

## 🚀 Deployment

### Android Release Build
```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### Firebase Functions Deployment
```bash
cd functions
npm run build
firebase deploy --only functions
```

## 🔮 Future Roadmap

### **Planned Features**
- 📈 **Investment Tracking**: Monitor mutual fund and stock performance
- 🎯 **Goal-Based Planning**: Set and track financial goals
- 🤖 **Chatbot**: Conversational AI for financial queries
- 🔗 **Bank API Integration**: Direct bank account linking
- 📊 **Advanced Analytics**: Predictive spending analysis
- 🌐 **Multi-Language**: Support for regional Indian languages

### **Technical Enhancements**
- 🔄 **Real-time Sync**: Live transaction synchronization
- 📱 **iOS Version**: Full iOS app development
- 🌙 **Offline AI**: Local machine learning models
- 🔐 **Biometric Auth**: Fingerprint and face unlock
- ☁️ **Auto Backup**: Automated cloud backups

## 📊 Performance Metrics

- ⚡ **SMS Parsing**: < 5ms per message
- 🧠 **AI Response**: < 3 seconds average
- 💾 **Storage**: Efficient local storage with Hive
- 🔋 **Battery**: Optimized background processing
- 📱 **Memory**: < 50MB RAM usage

## 🤝 Contributing

We welcome contributions! Please read our contributing guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is proprietary software. All rights reserved.

## 🆘 Support

For support and questions:
- 📧 **Email**: support@moneta-app.com
- 🐛 **Issues**: Create a GitHub issue
- 📚 **Documentation**: Check the wiki section

## 🙏 Acknowledgments

- **Flutter Team**: For the amazing cross-platform framework
- **Google Gemini AI**: For powerful AI financial insights
- **Firebase**: For robust backend infrastructure
- **Indian Banking System**: For standardized SMS formats
- **Open Source Community**: For countless helpful packages

---

<div align="center">

**Made with ❤️ for better financial management**

*Moneta - Your AI-Powered Financial Companion*

</div>