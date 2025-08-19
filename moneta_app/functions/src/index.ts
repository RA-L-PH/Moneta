import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import fetch from 'node-fetch';

admin.initializeApp();
const db = admin.firestore();
const GEMINI_MODEL = 'gemini-2.0-flash';

// Ensure a consistent region to match the mobile client
functions.setGlobalOptions({ region: 'us-central1' });


// Enhanced SMS parser based on BCCB transaction format
function parseSms(text: string) {
  const transaction = {
    type: '',
    amount: 0,
    date: '',
    recipient: '',
    category: '',
    transactionId: '',
    balance: null as number | null,
    description: ''
  };

  // Step 1: Determine transaction type (Debit or Credit)
  const lower = text.toLowerCase();
  if (lower.includes('debited') || lower.includes('spent') || lower.includes('paid') || 
      lower.includes('deducted') || lower.includes('withdrawn') || lower.includes('purchase') ||
      lower.includes('payment') || lower.includes('transfer') || lower.includes('sent')) {
    transaction.type = 'debit';
  } else if (lower.includes('credited') || lower.includes('received') || lower.includes('deposited') ||
             lower.includes('refund') || lower.includes('cashback') || lower.includes('salary') ||
             lower.includes('interest') || lower.includes('dividend')) {
    transaction.type = 'credit';
  } else {
    transaction.type = 'debit'; // Default to debit
  }

  // Step 2: Extract Amount
  const amountPatterns = [
    /INR\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i,
    /Rs\.?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i,
    /₹\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i,
    /amount\s*(?:of\s*)?(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i
  ];

  for (const pattern of amountPatterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      transaction.amount = parseFloat(match[1].replace(/,/g, ''));
      break;
    }
  }

  // Step 3: Extract Date
  const datePatterns = [
    /On\s+(\d{2}-[A-Z]{3}-\d{4})/i,
    /(\d{2}-\d{2}-\d{4})/,
    /(\d{2}\/\d{2}\/\d{4})/,
    /(\d{1,2}\s+[A-Z]{3}\s+\d{4})/i
  ];

  for (const pattern of datePatterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      transaction.date = match[1];
      break;
    }
  }

  // Step 4: Extract Transaction ID
  const idPatterns = [
    /UPI\/(?:DR|CR)\/(\d+)/i,
    /REF\s*(?:NO\.?\s*)?(\w+)/i,
    /TXN\s*(?:ID\s*)?(\w+)/i,
    /TRANSACTION\s*(?:ID\s*)?(\w+)/i
  ];

  for (const pattern of idPatterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      transaction.transactionId = match[1];
      break;
    }
  }

  // Step 5: Extract Recipient/Organization Name
  const recipientPatterns = [
    /by\s+UPI\/(?:DR|CR)\/\d+\/([^.]+)/i,
    /to\s+([A-Z\s&.-]+?)(?:\s+on|\s+at|\.|$)/i,
    /at\s+([A-Z\s&.-]+?)(?:\s+on|\s+at|\.|$)/i,
    /from\s+([A-Z\s&.-]+?)(?:\s+on|\s+at|\.|$)/i
  ];

  for (const pattern of recipientPatterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      transaction.recipient = match[1].trim();
      break;
    }
  }

  // If no recipient found, try to extract merchant name
  if (!transaction.recipient) {
    const merchantPattern = /([A-Z]{2,}(?:\s+[A-Z]+)*)/g;
    const matches = text.match(merchantPattern);
    if (matches) {
      for (const match of matches) {
        const merchant = match.trim();
        if (merchant.length > 2 && 
            !merchant.includes('BCCB') && 
            !merchant.includes('INR') && 
            !merchant.includes('UPI')) {
          transaction.recipient = merchant;
          break;
        }
      }
    }
  }

  if (!transaction.recipient) {
    transaction.recipient = 'Unknown';
  }

  // Step 6: Extract Balance
  const balancePatterns = [
    /(?:Clear|Avl|Available)\s+bal(?:ance)?\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i,
    /Balance\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)/i
  ];

  for (const pattern of balancePatterns) {
    const match = text.match(pattern);
    if (match && match[1]) {
      transaction.balance = parseFloat(match[1].replace(/,/g, ''));
      break;
    }
  }

  // Step 7: Classify based on Recipient Name
  const knownBusinesses: Record<string, string> = {
    'STAR B': 'Food & Beverages',
    'STARBUCKS': 'Food & Beverages',
    'MCDONALDS': 'Food & Beverages',
    'KFC': 'Food & Beverages',
    'PIZZA HUT': 'Food & Beverages',
    'DOMINOS': 'Food & Beverages',
    'SWIGGY': 'Food & Beverages',
    'ZOMATO': 'Food & Beverages',
    'UBER EATS': 'Food & Beverages',
    
    'AMAZON': 'Shopping',
    'AMZN': 'Shopping',
    'FLIPKART': 'Shopping',
    'MYNTRA': 'Shopping',
    'BIGBASKET': 'Shopping',
    
    'NETFLIX': 'Entertainment',
    'SPOTIFY': 'Entertainment',
    'PRIME VIDEO': 'Entertainment',
    'YOUTUBE': 'Entertainment',
    'HOTSTAR': 'Entertainment',
    
    'UBER': 'Transport',
    'OLA': 'Transport',
    'RAPIDO': 'Transport',
    'METRO': 'Transport',
    'PETROL': 'Transport',
    'FUEL': 'Transport',
    
    'ELECTRICITY': 'Bills & Utilities',
    'WATER': 'Bills & Utilities',
    'GAS': 'Bills & Utilities',
    'INTERNET': 'Bills & Utilities',
    'MOBILE': 'Bills & Utilities',
    'RECHARGE': 'Bills & Utilities',
    
    'HOSPITAL': 'Healthcare',
    'PHARMACY': 'Healthcare',
    'CLINIC': 'Healthcare',
    'APOLLO': 'Healthcare',
    
    'ATM': 'Cash Withdrawal',
    'CASH': 'Cash Withdrawal',
    'WITHDRAWAL': 'Cash Withdrawal',
    
    'SALARY': 'Income',
    'DIVIDEND': 'Income',
    'INTEREST': 'Income',
    'REFUND': 'Income',
    'CASHBACK': 'Income'
  };

  const upperRecipient = transaction.recipient.toUpperCase();
  
  // Direct match
  if (knownBusinesses[upperRecipient]) {
    transaction.category = knownBusinesses[upperRecipient];
  } else {
    // Partial match
    let categoryFound = false;
    for (const business of Object.keys(knownBusinesses)) {
      if (upperRecipient.includes(business) || business.includes(upperRecipient)) {
        transaction.category = knownBusinesses[business];
        categoryFound = true;
        break;
      }
    }
    
    // Keyword-based classification
    if (!categoryFound) {
      const lowerRecipient = transaction.recipient.toLowerCase();
      
      if (['restaurant', 'cafe', 'food', 'kitchen', 'dining'].some(keyword => lowerRecipient.includes(keyword))) {
        transaction.category = 'Food & Beverages';
      } else if (['shop', 'store', 'mall', 'market', 'retail'].some(keyword => lowerRecipient.includes(keyword))) {
        transaction.category = 'Shopping';
      } else if (['hospital', 'clinic', 'medical', 'pharmacy', 'doctor'].some(keyword => lowerRecipient.includes(keyword))) {
        transaction.category = 'Healthcare';
      } else if (['school', 'college', 'university', 'education', 'course'].some(keyword => lowerRecipient.includes(keyword))) {
        transaction.category = 'Education';
      } else if (['bank', 'atm', 'loan', 'emi', 'finance'].some(keyword => lowerRecipient.includes(keyword))) {
        transaction.category = 'Banking & Finance';
      } else {
        transaction.category = 'Other';
      }
    }
  }

  // Step 8: Generate description
  const typeText = transaction.type === 'debit' ? 'Payment' : 'Received';
  transaction.description = `${typeText} to ${transaction.recipient}`;

  return transaction;
}

// processSmsMessage: callable
export const processSmsMessage = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  const text: string = data.text || '';
  if (!text) throw new functions.https.HttpsError('invalid-argument', 'Missing text');

  const parsed = parseSms(text);
  const ms = Number(data.dateMs);
  const when = !isNaN(ms) && ms > 0 ? new Date(ms) : new Date();
  
  await db.collection('users').doc(uid).collection('transactions').add({
    amount: parsed.amount,
    description: parsed.description,
    category: parsed.category,
    date: admin.firestore.Timestamp.fromDate(when),
    type: parsed.type,
    source: 'sms',
    raw: text,
    balance: parsed.balance ?? null,
    recipient: parsed.recipient,
    transactionId: parsed.transactionId,
    extractedDate: parsed.date,
  });
  
  return { 
    ok: true, 
    parsed: {
      type: parsed.type,
      amount: parsed.amount,
      recipient: parsed.recipient,
      category: parsed.category,
      balance: parsed.balance
    }
  };
});

// generateSummary: callable — calls Gemini with a concise prompt
export const generateSummary = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  const start = new Date(data.start);
  const end = new Date(data.end);
  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid date range');
  }

  const snap = await db
    .collection('users').doc(uid)
    .collection('transactions')
    .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
    .where('date', '<=', admin.firestore.Timestamp.fromDate(end))
    .get();

  const txns = snap.docs.map((d: any) => ({ id: d.id, ...(d.data() as any) }));
  const summaryInput = txns.map((t: any) => `${t.date?.toDate?.()?.toISOString?.() ?? ''}\t${t.type}\t${t.category}\t${t.amount}\t${t.description}`).join('\n');



  const prompt = `You are a finance assistant. Summarize the user's spending for the period. \n
Return 4-8 bullet points max, include totals, top categories, unusual items, and a simple call-to-action.\n
Transactions TSV (date\ttype\tcategory\tamount\tdescription):\n${summaryInput}`;

  const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=AIzaSyBEEVjMe01KFNP3taowo3EVbV748B5FsoY` , {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }]
    })
  });
  if (!resp.ok) throw new functions.https.HttpsError('internal', 'Gemini API failed: ' + (await resp.text()));
  const body: any = await resp.json();
  const text = body?.candidates?.[0]?.content?.parts?.[0]?.text || 'No summary available.';
  return { summary: text };
});

// Optional: HTTP variant for SMS processing. Expects Authorization: Bearer <ID_TOKEN>
export const processSmsHttp = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') { res.status(405).send('Method not allowed'); return; }
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : undefined;
    if (!token) { res.status(401).send('Missing token'); return; }
    const decoded = await admin.auth().verifyIdToken(token);
    const uid = decoded.uid;
    const text = (req.body?.text as string) || '';
    if (!text) { res.status(400).send('Missing text'); return; }
    const parsed = parseSms(text);
    await db.collection('users').doc(uid).collection('transactions').add({
      amount: parsed.amount,
      description: parsed.description,
      category: parsed.category,
      date: admin.firestore.Timestamp.fromDate(new Date()),
      type: parsed.type,
      source: 'sms',
      raw: text,
    });
    res.json({ ok: true });
  } catch (e: any) {
    res.status(500).send(e?.message || 'Internal error');
  }
});

// Stub: generateReports — produce simple monthly totals per category
export const generateReports = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  const period = (data?.period as string) || 'month';
  const now = new Date();
  const start = period === 'week'
    ? new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7)
    : new Date(now.getFullYear(), now.getMonth(), 1);
  const end = now;
  const snap = await db.collection('users').doc(uid).collection('transactions')
    .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
    .where('date', '<=', admin.firestore.Timestamp.fromDate(end)).get();
  const byCat: Record<string, number> = {};
  let debit = 0, credit = 0;
  snap.forEach(d => {
    const data = d.data() as any;
    const amt = Number(data.amount) || 0;
    if ((data.type || 'debit') === 'credit') credit += amt; else { debit += amt; byCat[data.category || 'Other'] = (byCat[data.category || 'Other'] || 0) + amt; }
  });
  return { period, start: start.toISOString(), end: end.toISOString(), totals: { debit, credit }, byCategory: byCat };
});

// generateFinancialTips: callable — provides personalized savings tips based on spending patterns
export const generateFinancialTips = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  
  // Get user's transaction data for the last 3 months for better analysis
  const end = new Date();
  const start = new Date(end.getTime() - 90 * 24 * 60 * 60 * 1000); // 90 days
  
  const snap = await db.collection('users').doc(uid).collection('transactions')
    .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
    .where('date', '<=', admin.firestore.Timestamp.fromDate(end))
    .orderBy('date', 'desc')
    .get();

  const txns = snap.docs.map((d: any) => ({ id: d.id, ...(d.data() as any) }));
  
  // Calculate spending patterns
  const byCat: Record<string, number> = {};
  let totalDebit = 0, totalCredit = 0;
  let highestBalance = 0, lowestBalance = Number.MAX_VALUE;
  const monthlySpending: Record<string, number> = {};
  
  txns.forEach((t: any) => {
    const amt = Number(t.amount) || 0;
    const date = t.date?.toDate?.()?.toISOString?.()?.substring(0, 7) || ''; // YYYY-MM format
    
    if (t.type === 'credit') {
      totalCredit += amt;
    } else {
      totalDebit += amt;
      byCat[t.category || 'Other'] = (byCat[t.category || 'Other'] || 0) + amt;
      monthlySpending[date] = (monthlySpending[date] || 0) + amt;
    }
    
    if (t.balance) {
      highestBalance = Math.max(highestBalance, t.balance);
      lowestBalance = Math.min(lowestBalance, t.balance);
    }
  });

  // Calculate key metrics
  const avgMonthlySpending = Object.values(monthlySpending).reduce((a, b) => a + b, 0) / Math.max(Object.keys(monthlySpending).length, 1);
  const topCategories = Object.entries(byCat).sort((a, b) => b[1] - a[1]).slice(0, 3);
  const savingsRate = totalCredit > 0 ? ((totalCredit - totalDebit) / totalCredit) * 100 : 0;
  const currentBalance = txns.length > 0 && txns[0].balance ? txns[0].balance : 0;

  // Create detailed prompt for Gemini
  const prompt = `You are a financial advisor providing personalized savings tips and money management advice.

User's Financial Profile (Last 3 months):
- Total Income: ₹${totalCredit.toFixed(2)}
- Total Expenses: ₹${totalDebit.toFixed(2)}
- Current Balance: ₹${currentBalance.toFixed(2)}
- Average Monthly Spending: ₹${avgMonthlySpending.toFixed(2)}
- Savings Rate: ${savingsRate.toFixed(1)}%
- Top Spending Categories: ${topCategories.map(([cat, amt]) => `${cat}: ₹${amt.toFixed(2)}`).join(', ')}

Top Categories Breakdown:
${topCategories.map(([cat, amt], idx) => `${idx + 1}. ${cat}: ₹${amt.toFixed(2)} (${((amt / totalDebit) * 100).toFixed(1)}%)`).join('\n')}

Provide 5-7 personalized financial tips focusing on:
1. Specific savings opportunities based on their spending patterns
2. Category-wise optimization suggestions
3. Budgeting recommendations
4. Investment advice if applicable
5. Emergency fund guidance
6. Practical money-saving tips

**Format Requirements:**
- Use markdown formatting with headers (##), bullet points (-), and bold text (**text**)
- Be specific with amounts where relevant
- Keep it actionable and encouraging
- Use Indian financial context (INR, Indian investment options like SIP, FD, etc.)
- Structure as: ## Financial Tips, then bullet points for each tip`;

  try {
    const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=AIzaSyBEEVjMe01KFNP3taowo3EVbV748B5FsoY`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        }
      })
    });

    if (!resp.ok) {
      throw new functions.https.HttpsError('internal', 'Gemini API failed: ' + (await resp.text()));
    }

    const body: any = await resp.json();
    const tips = body?.candidates?.[0]?.content?.parts?.[0]?.text || 'Unable to generate tips at the moment.';

    return {
      tips,
      metrics: {
        totalIncome: totalCredit,
        totalExpenses: totalDebit,
        currentBalance,
        avgMonthlySpending,
        savingsRate,
        topCategories: topCategories.map(([cat, amt]) => ({ category: cat, amount: amt, percentage: (amt / totalDebit) * 100 }))
      }
    };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', 'Failed to generate financial tips: ' + error.message);
  }
});

// generateBudgetPlan: callable — creates a personalized budget plan
export const generateBudgetPlan = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  const targetSavings = Number(data?.targetSavings) || 20; // Default 20% savings rate
  const monthlyIncome = Number(data?.monthlyIncome) || 0;

  // Get historical spending data
  const end = new Date();
  const start = new Date(end.getTime() - 90 * 24 * 60 * 60 * 1000);
  
  const snap = await db.collection('users').doc(uid).collection('transactions')
    .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
    .where('date', '<=', admin.firestore.Timestamp.fromDate(end))
    .get();

  const txns = snap.docs.map((d: any) => ({ id: d.id, ...(d.data() as any) }));
  
  const byCat: Record<string, number> = {};
  let totalDebit = 0, totalCredit = 0;
  
  txns.forEach((t: any) => {
    const amt = Number(t.amount) || 0;
    if (t.type === 'credit') {
      totalCredit += amt;
    } else {
      totalDebit += amt;
      byCat[t.category || 'Other'] = (byCat[t.category || 'Other'] || 0) + amt;
    }
  });

  const avgMonthlyIncome = monthlyIncome > 0 ? monthlyIncome : totalCredit / 3;
  const avgMonthlySpending = totalDebit / 3;

  const prompt = `Create a personalized monthly budget plan for an Indian user.

User Details:
- Monthly Income: ₹${avgMonthlyIncome.toFixed(2)}
- Current Average Monthly Spending: ₹${avgMonthlySpending.toFixed(2)}
- Target Savings Rate: ${targetSavings}%
- Historical Spending by Category: ${Object.entries(byCat).map(([cat, amt]) => `${cat}: ₹${(amt/3).toFixed(2)}`).join(', ')}

Create a detailed budget plan with:
1. Recommended allocation for each expense category
2. Specific savings targets
3. Emergency fund recommendations
4. Investment suggestions (SIP, FD, etc.)
5. Tips to achieve the target savings rate

**Format Requirements:**
- Use markdown formatting with headers (##), bullet points (-), and bold text (**text**)
- Structure as: ## Monthly Budget Plan, then sections for different allocations
- Include specific amounts in INR
- Be practical and achievable`;

  try {
    const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=AIzaSyBEEVjMe01KFNP3taowo3EVbV748B5FsoY`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.6,
          maxOutputTokens: 1200,
        }
      })
    });

    if (!resp.ok) {
      throw new functions.https.HttpsError('internal', 'Gemini API failed: ' + (await resp.text()));
    }

    const body: any = await resp.json();
    const budgetPlan = body?.candidates?.[0]?.content?.parts?.[0]?.text || 'Unable to generate budget plan.';

    return {
      budgetPlan,
      targetSavingsAmount: (avgMonthlyIncome * targetSavings) / 100,
      currentSavingsRate: avgMonthlyIncome > 0 ? ((avgMonthlyIncome - avgMonthlySpending) / avgMonthlyIncome) * 100 : 0,
      recommendedExpenseLimit: avgMonthlyIncome * (100 - targetSavings) / 100
    };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', 'Failed to generate budget plan: ' + error.message);
  }
});

// generateInvestmentAdvice: callable — provides investment recommendations
export const generateInvestmentAdvice = functions.https.onCall(async (data: any, context: any) => {
  if (!context.auth?.uid) throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
  const uid = context.auth.uid;
  
  const riskTolerance = data?.riskTolerance || 'moderate'; // low, moderate, high
  const investmentHorizon = Number(data?.investmentHorizon) || 5; // years
  const monthlyInvestment = Number(data?.monthlyInvestment) || 5000;
  const age = Number(data?.age) || 30;
  const financialGoals = data?.financialGoals || 'wealth building';

  const prompt = `Provide personalized investment advice for an Indian investor.

Investor Profile:
- Age: ${age} years
- Risk Tolerance: ${riskTolerance}
- Investment Horizon: ${investmentHorizon} years
- Monthly Investment Budget: ₹${monthlyInvestment}
- Financial Goals: ${financialGoals}

Provide specific recommendations including:
1. Asset allocation strategy
2. Recommended mutual funds/investment products
3. SIP recommendations with specific fund suggestions
4. Tax-saving options (ELSS, PPF, etc.)
5. Portfolio diversification advice
6. Expected returns and growth projections
7. Risk management strategies

Focus on Indian investment options and current market conditions. Be specific with fund categories and allocation percentages.`;

  try {
    const resp = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=AIzaSyBEEVjMe01KFNP3taowo3EVbV748B5FsoY`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.5,
          maxOutputTokens: 1200,
        }
      })
    });

    if (!resp.ok) {
      throw new functions.https.HttpsError('internal', 'Gemini API failed: ' + (await resp.text()));
    }

    const body: any = await resp.json();
    const advice = body?.candidates?.[0]?.content?.parts?.[0]?.text || 'Unable to generate investment advice.';

    return {
      investmentAdvice: advice,
      projectedReturns: {
        conservative: monthlyInvestment * 12 * investmentHorizon * 1.08, // 8% annual return
        moderate: monthlyInvestment * 12 * investmentHorizon * 1.12, // 12% annual return
        aggressive: monthlyInvestment * 12 * investmentHorizon * 1.15, // 15% annual return
      }
    };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', 'Failed to generate investment advice: ' + error.message);
  }
});
