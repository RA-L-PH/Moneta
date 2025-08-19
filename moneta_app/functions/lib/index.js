"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.analyzeHabits = exports.generateReports = exports.processSmsHttp = exports.generateSummary = exports.processSmsMessage = void 0;
const functions = __importStar(require("firebase-functions/v2"));
const params_1 = require("firebase-functions/params");
const admin = __importStar(require("firebase-admin"));
const node_fetch_1 = __importDefault(require("node-fetch"));
admin.initializeApp();
const db = admin.firestore();
const GEMINI_MODEL = 'gemini-2.0-flash';
// Secret for Gemini API key (set via `firebase functions:secrets:set GEMINI_API_KEY`)
const GEMINI_API_KEY_SECRET = (0, params_1.defineSecret)('GEMINI_API_KEY');
// Helper: naive parser for SMS amounts & entities
function parseSms(text) {
    const lower = text.toLowerCase();
    const type = lower.includes('credit') || lower.includes('credited') ? 'credit' : 'debit';
    const amountMatch = text.match(/(?:rs\.?|inr|usd|\$|₦|₹|€|£)?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]{1,2})?)/i);
    const amount = amountMatch ? parseFloat(amountMatch[1].replace(/,/g, '')) : 0;
    // Guess description by known verbs
    let description = 'Transaction';
    const sentToMatch = text.match(/sent to ([A-Za-z0-9 &._-]+)/i) || text.match(/to ([A-Za-z0-9 &._-]+)/i);
    if (sentToMatch)
        description = sentToMatch[1].trim();
    const merchantMatch = text.match(/at ([A-Za-z0-9 &._-]+)/i);
    if (merchantMatch)
        description = merchantMatch[1].trim();
    // Simple category mapping
    const cats = {
        netflix: 'Entertainment', prime: 'Entertainment', spotify: 'Entertainment',
        uber: 'Transport', lyft: 'Transport', fuel: 'Transport', petrol: 'Transport',
        amazon: 'Shopping', flipkart: 'Shopping', shop: 'Shopping', store: 'Shopping',
        starbucks: 'Food', cafe: 'Food', restaurant: 'Food', pizza: 'Food',
        electricity: 'Bills', recharge: 'Bills', bill: 'Bills'
    };
    const key = Object.keys(cats).find(k => lower.includes(k));
    const category = key ? cats[key] : 'Other';
    return { type, amount, description, category };
}
// processSmsMessage: callable
exports.processSmsMessage = functions.https.onCall(async (data, context) => {
    if (!context.auth?.uid)
        throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
    const uid = context.auth.uid;
    const text = data.text || '';
    if (!text)
        throw new functions.https.HttpsError('invalid-argument', 'Missing text');
    const parsed = parseSms(text);
    const now = new Date();
    await db.collection('users').doc(uid).collection('transactions').add({
        amount: parsed.amount,
        description: parsed.description,
        category: parsed.category,
        date: admin.firestore.Timestamp.fromDate(now),
        type: parsed.type,
        source: 'sms',
        raw: text,
    });
    return { ok: true };
});
// generateSummary: callable — calls Gemini with a concise prompt
exports.generateSummary = functions.https.onCall({ secrets: [GEMINI_API_KEY_SECRET] }, async (data, context) => {
    if (!context.auth?.uid)
        throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
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
    const txns = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    const summaryInput = txns.map((t) => `${t.date?.toDate?.()?.toISOString?.() ?? ''}\t${t.type}\t${t.category}\t${t.amount}\t${t.description}`).join('\n');
    const apiKey = GEMINI_API_KEY_SECRET.value() || process.env.GEMINI_API_KEY;
    if (!apiKey)
        throw new functions.https.HttpsError('failed-precondition', 'Missing GEMINI_API_KEY');
    const prompt = `You are a finance assistant. Summarize the user's spending for the period. \n
Return 4-8 bullet points max, include totals, top categories, unusual items, and a simple call-to-action.\n
Transactions TSV (date\ttype\tcategory\tamount\tdescription):\n${summaryInput}`;
    const resp = await (0, node_fetch_1.default)(`https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            contents: [{ parts: [{ text: prompt }] }]
        })
    });
    if (!resp.ok)
        throw new functions.https.HttpsError('internal', 'Gemini API failed: ' + (await resp.text()));
    const body = await resp.json();
    const text = body?.candidates?.[0]?.content?.parts?.[0]?.text || 'No summary available.';
    return { summary: text };
});
// Optional: HTTP variant for SMS processing. Expects Authorization: Bearer <ID_TOKEN>
exports.processSmsHttp = functions.https.onRequest(async (req, res) => {
    if (req.method !== 'POST') {
        res.status(405).send('Method not allowed');
        return;
    }
    try {
        const authHeader = req.headers.authorization || '';
        const token = authHeader.startsWith('Bearer ') ? authHeader.substring(7) : undefined;
        if (!token) {
            res.status(401).send('Missing token');
            return;
        }
        const decoded = await admin.auth().verifyIdToken(token);
        const uid = decoded.uid;
        const text = req.body?.text || '';
        if (!text) {
            res.status(400).send('Missing text');
            return;
        }
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
    }
    catch (e) {
        res.status(500).send(e?.message || 'Internal error');
    }
});
// Stub: generateReports — produce simple monthly totals per category
exports.generateReports = functions.https.onCall(async (data, context) => {
    if (!context.auth?.uid)
        throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
    const uid = context.auth.uid;
    const period = data?.period || 'month';
    const now = new Date();
    const start = period === 'week'
        ? new Date(now.getFullYear(), now.getMonth(), now.getDate() - 7)
        : new Date(now.getFullYear(), now.getMonth(), 1);
    const end = now;
    const snap = await db.collection('users').doc(uid).collection('transactions')
        .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
        .where('date', '<=', admin.firestore.Timestamp.fromDate(end)).get();
    const byCat = {};
    let debit = 0, credit = 0;
    snap.forEach(d => {
        const data = d.data();
        const amt = Number(data.amount) || 0;
        if ((data.type || 'debit') === 'credit')
            credit += amt;
        else {
            debit += amt;
            byCat[data.category || 'Other'] = (byCat[data.category || 'Other'] || 0) + amt;
        }
    });
    return { period, start: start.toISOString(), end: end.toISOString(), totals: { debit, credit }, byCategory: byCat };
});
// Stub: analyzeHabits — compute simple ratios and flags
exports.analyzeHabits = functions.https.onCall(async (data, context) => {
    if (!context.auth?.uid)
        throw new functions.https.HttpsError('unauthenticated', 'Must be signed in');
    const uid = context.auth.uid;
    const lookbackDays = Number(data?.days) || 90;
    const end = new Date();
    const start = new Date(end.getTime() - lookbackDays * 86400000);
    const snap = await db.collection('users').doc(uid).collection('transactions')
        .where('date', '>=', admin.firestore.Timestamp.fromDate(start))
        .where('date', '<=', admin.firestore.Timestamp.fromDate(end)).get();
    let debit = 0, credit = 0;
    const byCat = {};
    snap.forEach(d => {
        const v = d.data();
        const amt = Number(v.amount) || 0;
        if ((v.type || 'debit') === 'credit')
            credit += amt;
        else {
            debit += amt;
            byCat[v.category || 'Other'] = (byCat[v.category || 'Other'] || 0) + amt;
        }
    });
    const topCat = Object.entries(byCat).sort((a, b) => b[1] - a[1])[0]?.[0] || 'Other';
    const ratio = credit > 0 ? debit / credit : null;
    return { windowDays: lookbackDays, totals: { debit, credit }, topCategory: topCat, debitToCreditRatio: ratio };
});
//# sourceMappingURL=index.js.map