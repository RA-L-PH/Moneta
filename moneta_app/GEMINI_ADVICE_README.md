# Gemini Financial Advice Feature

This document explains the Gemini AI-powered financial advice feature integrated into the Moneta app.

## Overview

The financial advice feature uses Google's Gemini AI to provide personalized financial tips, budget planning, and investment advice based on user's transaction history and preferences.

## Features

### 🧠 **AI-Powered Financial Tips**
- Analyzes your spending patterns from the last 3 months
- Provides personalized savings tips
- Identifies overspending categories
- Suggests optimization strategies
- Uses Indian financial context (SIP, FD, ELSS, etc.)

### 💰 **Budget Planning**
- Creates customized monthly budget plans
- Sets realistic savings targets
- Recommends expense allocations by category
- Provides emergency fund guidance
- Includes investment recommendations

### 📈 **Investment Advice**
- Personalized investment recommendations
- Asset allocation strategies
- SIP suggestions with fund categories
- Risk-based portfolio recommendations
- Projected returns calculations
- Tax-saving investment options

## How It Works

### Data Analysis
1. **Transaction Analysis**: Reviews local transaction data from last 3 months
2. **Spending Patterns**: Identifies top spending categories and amounts
3. **Financial Metrics**: Calculates savings rate, monthly averages, and trends
4. **Context Building**: Creates comprehensive financial profile for AI analysis

### AI Integration
- **Direct API Calls**: Makes HTTP requests to Gemini AI API
- **Smart Prompting**: Uses detailed prompts with financial context
- **Fallback Handling**: Provides default advice when API is unavailable
- **Local-First**: Works without cloud dependencies using local transaction data

## User Interface

### Three Main Tabs

#### 1. **Financial Tips Tab**
- **Financial Overview Card**: Shows current balance, monthly spending, savings rate, top categories
- **Personalized Tips Card**: AI-generated financial advice based on spending patterns
- **Pull-to-Refresh**: Updates tips with latest transaction data

#### 2. **Budget Planning Tab**
- **Settings Form**: Monthly income input and target savings rate slider
- **Budget Plan Card**: AI-generated detailed budget with category allocations
- **Key Metrics**: Target savings amount, current savings rate, recommended expense limits

#### 3. **Investment Advice Tab**
- **Profile Form**: Age, monthly investment amount, risk tolerance, investment horizon
- **Advice Card**: Personalized investment recommendations
- **Projected Returns**: Conservative, moderate, and aggressive return calculations

## Technical Implementation

### Service Architecture

```dart
// Main service class
class GeminiAdviceService {
  // Get financial tips based on spending patterns
  static Future<FinancialTipsResponse> getFinancialTips()
  
  // Generate personalized budget plan
  static Future<BudgetPlanResponse> generateBudgetPlan()
  
  // Get investment advice based on user profile
  static Future<InvestmentAdviceResponse> getInvestmentAdvice()
}
```

### Data Models

```dart
// Response models with comprehensive financial data
class FinancialTipsResponse {
  final String tips;
  final FinancialMetrics metrics;
}

class FinancialMetrics {
  final double totalIncome;
  final double totalExpenses;
  final double currentBalance;
  final double avgMonthlySpending;
  final double savingsRate;
  final List<CategorySpending> topCategories;
}
```

### API Integration

- **Endpoint**: Google Gemini API (`gemini-2.0-flash` model)
- **Authentication**: API key-based authentication
- **Request Format**: JSON with conversation-style prompts
- **Response Handling**: Parses AI-generated text responses
- **Error Handling**: Graceful fallback to predefined advice

## Example AI Prompts

### Financial Tips Prompt
```
You are a financial advisor providing personalized savings tips.

User's Financial Profile (Last 3 months):
- Total Income: ₹150,000.00
- Total Expenses: ₹120,000.00
- Current Balance: ₹45,000.00
- Savings Rate: 20.0%
- Top Categories: Food & Beverages: ₹35,000 (29.2%), Transport: ₹25,000 (20.8%)

Provide 5-7 personalized tips focusing on savings opportunities, 
category optimization, budgeting, and investment advice.
Use Indian financial context (SIP, FD, ELSS).
```

### Budget Plan Prompt
```
Create a personalized monthly budget plan for an Indian user.

User Details:
- Monthly Income: ₹50,000.00
- Target Savings Rate: 25%
- Current Spending: Food: ₹12,000, Transport: ₹8,000, Shopping: ₹5,000

Create detailed budget with category allocations, savings targets, 
emergency fund recommendations, and investment suggestions.
```

## Sample AI Responses

### Financial Tips Example
```
• Reduce food delivery expenses by ₹5,000/month - try meal prep on weekends
• Consider carpooling or public transport to save ₹3,000/month on transport
• Start a SIP of ₹10,000/month in diversified equity funds
• Build emergency fund of ₹6 months expenses (₹72,000)
• Review and cancel unused subscriptions
• Set up automatic savings transfer on salary day
• Consider ELSS funds for tax savings under 80C
```

### Budget Plan Example
```
**Recommended Monthly Budget (₹50,000 income):**

**Fixed Allocations:**
• Savings & Investments: ₹12,500 (25%)
• Emergency Fund: ₹2,500 (5%)
• Essential Expenses: ₹25,000 (50%)
  - Food & Groceries: ₹8,000
  - Rent/EMI: ₹12,000
  - Utilities: ₹3,000
  - Transport: ₹2,000

**Discretionary Spending: ₹10,000 (20%)**
• Entertainment: ₹3,000
• Shopping: ₹4,000
• Miscellaneous: ₹3,000

**Investment Strategy:**
• Start SIP: ₹8,000/month in equity funds
• PPF contribution: ₹2,000/month
• Emergency fund: ₹2,500/month until 6 months saved
```

## Security & Privacy

### Data Handling
- **Local Data**: Only uses locally stored transaction data
- **API Calls**: Sends aggregated financial metrics, not raw transaction details
- **No Storage**: AI responses are not permanently stored
- **Anonymized**: No personal identifiers sent to AI service

### API Security
- **HTTPS**: All API calls use encrypted connections
- **API Key**: Securely embedded (should be moved to environment variables in production)
- **Rate Limiting**: Handles API rate limits gracefully
- **Error Handling**: Secure error messages without exposing sensitive data

## Configuration

### Environment Setup
```dart
// In production, move to environment variables
static const String _geminiApiKey = 'YOUR_GEMINI_API_KEY';
static const String _geminiModel = 'gemini-2.0-flash';
```

### Fallback Configuration
- **Default Tips**: Comprehensive fallback advice when API fails
- **Offline Mode**: Full functionality without internet connection
- **Graceful Degradation**: Users always get helpful advice

## Usage Examples

### Getting Financial Tips
```dart
final response = await GeminiAdviceService.getFinancialTips();
print(response.tips); // AI-generated personalized tips
print('Savings Rate: ${response.metrics.savingsRate}%');
```

### Generating Budget Plan
```dart
final budget = await GeminiAdviceService.generateBudgetPlan(
  targetSavingsRate: 25,
  monthlyIncome: 75000,
);
print(budget.budgetPlan); // AI-generated budget
```

### Getting Investment Advice
```dart
final advice = await GeminiAdviceService.getInvestmentAdvice(
  riskTolerance: 'moderate',
  investmentHorizon: 10,
  monthlyInvestment: 10000,
  age: 30,
);
print(advice.investmentAdvice); // AI-generated investment advice
```

## Testing

### Unit Tests
- **Service Tests**: Validates API integration and fallback handling
- **Model Tests**: Ensures data parsing and validation
- **Edge Cases**: Tests error scenarios and empty data handling

### Integration Tests
- **UI Tests**: Validates complete user flows
- **API Tests**: Tests real API interactions (with test keys)
- **Performance Tests**: Ensures responsive UI during AI calls

## Future Enhancements

### Planned Features
- **Goal-Based Planning**: Specific financial goals (house, car, education)
- **Expense Optimization**: AI-powered expense reduction suggestions
- **Investment Tracking**: Monitor investment performance
- **Alerts & Reminders**: Proactive financial guidance
- **Multi-Language Support**: Local language financial advice

### Technical Improvements
- **Caching**: Cache AI responses to reduce API calls
- **Offline AI**: Local AI models for basic advice
- **Enhanced Prompts**: More sophisticated prompt engineering
- **User Feedback**: Learn from user preferences and feedback

## Troubleshooting

### Common Issues
1. **API Errors**: Check internet connection and API key validity
2. **Empty Responses**: Verify transaction data availability
3. **Slow Loading**: Large transaction datasets may take time to process
4. **Fallback Mode**: App works offline with predefined advice

### Debug Mode
```dart
// Enable debug mode for detailed logging
debugPrint('Gemini API response: $response');
```

This feature transforms the Moneta app into an intelligent financial advisor, providing users with personalized, actionable financial guidance powered by AI! 🚀
