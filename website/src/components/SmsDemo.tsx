import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { MdVerified, MdRestaurant, MdAccountBalance, MdArrowForward, MdSmartToy } from 'react-icons/md';

export default function SmsDemo() {
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    const checkMobile = () => setIsMobile(window.innerWidth < 768);
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, []);

  return (
    <section className="py-24 px-6 overflow-hidden">
      <div className="max-w-6xl mx-auto">
        <motion.div initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}
          className="text-center mb-16">
          <span className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-semibold bg-green/10 text-green mb-4">
            <MdSmartToy size={14} />
            Live Parser Demo
          </span>
          <h2 className="text-3xl md:text-5xl font-bold mb-4 font-display text-ink">
            See it in <span className="text-gradient-green">action</span>.
          </h2>
          <p className="text-lg max-w-lg mx-auto text-green-muted">
            Raw bank SMS transforms into structured insights instantly.
          </p>
        </motion.div>

        <div className="grid md:grid-cols-12 gap-6 items-center">
          {/* Left - SMS Bubble */}
          <motion.div
            initial={{ opacity: 0, x: -40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="md:col-span-5"
          >
            <div className="relative">
              {/* Glow effect */}
              <div className="absolute -inset-4 bg-green/10 rounded-3xl blur-2xl opacity-50" />

              <div className="relative bg-ink rounded-3xl p-6 shadow-2xl">
                {/* Header */}
                <div className="flex items-center gap-3 mb-5">
                  <div className="w-10 h-10 bg-green/20 rounded-full flex items-center justify-center">
                    <MdAccountBalance size={20} className="text-green-neon" />
                  </div>
                  <div>
                    <p className="text-sm font-bold text-white">SBI Bank</p>
                    <p className="text-xs text-white/50">Today, 2:34 PM</p>
                  </div>
                  <div className="ml-auto px-2.5 py-1 bg-green/20 rounded-full">
                    <span className="text-[10px] font-bold text-green-neon">INCOMING</span>
                  </div>
                </div>

                {/* SMS Content */}
                <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-4 border border-white/10">
                  <p className="text-sm text-white/80 leading-relaxed font-mono">
                    Your SBI A/c XX4567 is debited INR 1,250.00 on 17-AUG-2025 by UPI/DR/522916825224/SWIGGY. Clear bal INR 45,893.38.
                  </p>
                </div>

                {/* Timestamp */}
                <div className="mt-4 flex items-center justify-between text-xs text-white/40">
                  <span>Message ID: 82947291</span>
                  <span>Processed in 0.003s</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Center - Arrow */}
          <motion.div
            initial={{ opacity: 0, scale: 0.5 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            transition={{ delay: 0.3, duration: 0.5 }}
            className="md:col-span-2 flex justify-center py-4 md:py-0"
          >
            <div className="relative">
              <motion.div
                animate={isMobile ? { y: [0, 8, 0] } : { x: [0, 8, 0] }}
                transition={{ duration: 1.5, repeat: Infinity }}
                className="w-16 h-16 bg-green rounded-full flex items-center justify-center shadow-lg shadow-green/30"
              >
                <MdArrowForward size={28} className="text-white rotate-90 md:rotate-0" />
              </motion.div>
              <div className="absolute -inset-2 bg-green/20 rounded-full blur-xl animate-pulse" />
            </div>
          </motion.div>

          {/* Right - Parsed Card */}
          <motion.div
            initial={{ opacity: 0, x: 40 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="md:col-span-5"
          >
            <div className="relative">
              {/* Glow effect */}
              <div className="absolute -inset-4 bg-green/10 rounded-3xl blur-2xl opacity-50" />

              <div className="relative bg-white rounded-3xl p-6 shadow-xl border border-green-muted/15 hover:shadow-2xl hover:border-green/30 transition-all duration-300">
                {/* Header */}
                <div className="flex items-start justify-between mb-6">
                  <div className="flex items-center gap-3">
                    <div className="w-14 h-14 bg-gradient-to-br from-orange-400 to-red-500 rounded-2xl flex items-center justify-center shadow-lg">
                      <MdRestaurant size={28} className="text-white" />
                    </div>
                    <div>
                      <p className="text-xl font-bold text-ink">Swiggy</p>
                      <p className="text-xs text-green-muted">Food & Beverages</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-1.5 bg-green/10 text-green px-3 py-1.5 rounded-full">
                    <MdVerified size={16} />
                    <span className="text-xs font-bold">Verified</span>
                  </div>
                </div>

                {/* Stats Grid */}
                <div className="grid grid-cols-3 gap-4 mb-6">
                  <div className="bg-green/5 rounded-2xl p-3 text-center">
                    <p className="text-[10px] text-green-muted uppercase tracking-wider mb-1">Amount</p>
                    <p className="text-2xl font-extrabold text-green">₹1,250</p>
                  </div>
                  <div className="bg-ink/5 rounded-2xl p-3 text-center">
                    <p className="text-[10px] text-green-muted uppercase tracking-wider mb-1">Type</p>
                    <p className="text-lg font-bold text-ink">Debit</p>
                  </div>
                  <div className="bg-ink/5 rounded-2xl p-3 text-center">
                    <p className="text-[10px] text-green-muted uppercase tracking-wider mb-1">Balance</p>
                    <p className="text-lg font-bold text-ink">₹45,893</p>
                  </div>
                </div>

                {/* Tags */}
                <div className="flex items-center gap-2 flex-wrap">
                  {['UPI', 'SBI', 'Food', 'Instant'].map((tag, i) => (
                    <span key={i} className="px-3 py-1.5 bg-card rounded-full text-xs font-semibold text-green-muted border border-green-muted/10">
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
