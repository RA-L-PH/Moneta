import { motion } from 'framer-motion';
import { FiGithub } from 'react-icons/fi';
import { MdDownload, MdCheckCircle, MdRestaurant, MdAttachMoney, MdChat, MdSignalCellularAlt, MdWifi, MdBatteryFull, MdArrowUpward, MdArrowDownward } from 'react-icons/md';

const REPO = 'https://github.com/RA-L-PH/Moneta/releases/download/Latest';

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center px-6 pt-24 pb-16 overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 -left-32 w-96 h-96 bg-green/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 -right-32 w-96 h-96 bg-green-neon/5 rounded-full blur-3xl" />
      </div>

      <div className="max-w-6xl mx-auto w-full grid lg:grid-cols-2 gap-12 items-center relative">
        {/* Left - Content */}
        <div className="text-center lg:text-left">
          {/* Badge */}
          <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
            <span className="inline-flex items-center gap-2.5 rounded-full px-5 py-2 text-xs font-semibold bg-card border border-green-muted/25 text-green">
              <span className="w-2 h-2 rounded-full bg-green-neon animate-pulse" />
              v2.0 — Open Source & Free
            </span>
          </motion.div>

          {/* Heading */}
          <motion.h1 initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
            className="text-5xl md:text-7xl font-bold leading-[1.1] mt-8 mb-6 font-display text-ink">
            Track your money.<br />
            <span className="text-gradient-green">Smartly.</span>
          </motion.h1>

          {/* Subtitle */}
          <motion.p initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
            className="text-lg md:text-xl max-w-lg mx-auto lg:mx-0 mb-10 leading-relaxed text-green-muted">
            Auto-reads your bank SMS, categorizes every transaction, and gives
            you NVIDIA NIM AI-powered insights — all stored locally on your device.
          </motion.p>

          {/* CTAs */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}
            className="flex flex-col sm:flex-row items-center gap-4 justify-center lg:justify-start relative w-full">
            <a href={`${REPO}/moneta-v2.0.0-arm64-v8a.apk`} target="_blank" rel="noopener noreferrer"
              className="group inline-flex items-center justify-center gap-2 bg-ink text-white px-8 py-3.5 rounded-full font-semibold hover:bg-ink/90 transition-all hover:shadow-lg hover:shadow-ink/20 whitespace-nowrap w-full sm:w-auto">
              <MdDownload size={20} />
              Download for Free
            </a>
            <a href="#download-assistance"
              className="inline-flex items-center justify-center gap-2 px-8 py-3.5 rounded-full font-semibold border-2 border-ink/10 text-ink/70 hover:border-green hover:text-green transition-all whitespace-nowrap w-full sm:w-auto">
              All Download Options
            </a>
            <a href="https://github.com/RA-L-PH/Moneta" target="_blank" rel="noopener noreferrer"
              className="inline-flex items-center justify-center gap-2 px-8 py-3.5 rounded-full font-semibold border-2 border-ink/10 text-ink/70 hover:border-green hover:text-green transition-all whitespace-nowrap w-full sm:w-auto">
              <FiGithub size={20} />
              View Source
            </a>
          </motion.div>

          {/* Stats */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}
            className="flex items-center gap-8 justify-center lg:justify-start mt-10">
            <div>
              <p className="text-2xl font-bold text-ink">50+</p>
              <p className="text-xs text-green-muted">Banks Supported</p>
            </div>
            <div className="w-px h-10 bg-green-muted/20" />
            <div>
              <p className="text-2xl font-bold text-ink">100%</p>
              <p className="text-xs text-green-muted">Local Storage</p>
            </div>
            <div className="w-px h-10 bg-green-muted/20" />
            <div>
              <p className="text-2xl font-bold text-green">Free</p>
              <p className="text-xs text-green-muted">Forever</p>
            </div>
          </motion.div>
        </div>

        {/* Right - Phone Preview */}
        <motion.div initial={{ opacity: 0, x: 30 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.4, duration: 0.6 }}
          className="relative flex justify-center lg:justify-end">
          {/* Floating elements */}
          <motion.div
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 4, repeat: Infinity }}
            className="absolute -top-8 -left-4 md:left-0 bg-white rounded-2xl p-3 shadow-xl border border-green-muted/10 z-10"
          >
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-green/10 rounded-full flex items-center justify-center">
                <MdArrowUpward size={16} className="text-green" />
              </div>
              <div>
                <p className="text-[10px] text-green-muted">Income</p>
                <p className="text-sm font-bold text-green">₹45,000</p>
              </div>
            </div>
          </motion.div>

          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 5, repeat: Infinity }}
            className="absolute -bottom-4 -right-4 md:right-0 bg-white rounded-2xl p-3 shadow-xl border border-green-muted/10 z-10"
          >
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-red-50 rounded-full flex items-center justify-center">
                <MdArrowDownward size={16} className="text-red-500" />
              </div>
              <div>
                <p className="text-[10px] text-green-muted">Expenses</p>
                <p className="text-sm font-bold text-red-500">₹32,500</p>
              </div>
            </div>
          </motion.div>

          <div className="relative">
            {/* Phone frame */}
            <div className="w-72 md:w-80 h-[580px] bg-ink rounded-[3rem] p-2 shadow-2xl shadow-ink/30">
              <div className="w-full h-full bg-canvas rounded-[2.5rem] overflow-hidden">
                {/* Status bar */}
                <div className="h-12 bg-gradient-to-r from-green to-green-deep flex items-center justify-between px-6">
                  <span className="text-white text-xs font-semibold">9:41</span>
                  <div className="flex items-center gap-1.5 text-white">
                    <MdSignalCellularAlt size={14} />
                    <MdWifi size={14} />
                    <MdBatteryFull size={16} />
                  </div>
                </div>
                {/* Dashboard content */}
                <div className="p-5">
                  <p className="text-xs text-green-muted mb-1">Total Balance</p>
                  <p className="text-3xl font-bold text-ink mb-5">₹1,25,430</p>
                  <div className="grid grid-cols-2 gap-3 mb-5">
                    <div className="bg-green/5 rounded-2xl p-3">
                      <p className="text-[10px] text-green-muted">Income</p>
                      <p className="text-lg font-bold text-green">₹45,000</p>
                    </div>
                    <div className="bg-red-50 rounded-2xl p-3">
                      <p className="text-[10px] text-red-400">Expenses</p>
                      <p className="text-lg font-bold text-red-500">₹32,500</p>
                    </div>
                  </div>
                  {/* Area chart */}
                  <div className="h-24 mb-5 relative">
                    <svg viewBox="0 0 300 100" className="w-full h-full">
                      <defs>
                        <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor="#0DF205" stopOpacity="0.3" />
                          <stop offset="100%" stopColor="#0DF205" stopOpacity="0" />
                        </linearGradient>
                      </defs>
                      <path d="M0,80 Q30,70 60,50 T120,40 T180,25 T240,35 T300,15 V100 H0 Z" fill="url(#chartGrad)" />
                      <path d="M0,80 Q30,70 60,50 T120,40 T180,25 T240,35 T300,15" fill="none" stroke="#188C4A" strokeWidth="2.5" />
                    </svg>
                  </div>
                  {/* Transactions */}
                  <div className="space-y-2.5">
                    {[
                      { name: 'Swiggy', amount: '-₹450', icon: MdRestaurant, tag: 'Food', color: 'bg-orange-100 text-orange-600' },
                      { name: 'Salary', amount: '+₹45,000', icon: MdAttachMoney, tag: 'Income', color: 'bg-green/10 text-green' },
                      { name: 'AI Chat', amount: 'Ask anything', icon: MdChat, tag: 'NVIDIA NIM', color: 'bg-blue-100 text-blue-600' },
                    ].map((item, i) => (
                      <motion.div
                        key={i}
                        initial={{ opacity: 0, x: -20 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.8 + i * 0.1 }}
                        className="flex items-center justify-between p-3 bg-card rounded-xl border border-green-muted/10"
                      >
                        <div className="flex items-center gap-3">
                          <div className={`w-10 h-10 ${item.color} rounded-full flex items-center justify-center`}>
                            <item.icon size={18} />
                          </div>
                          <div>
                            <p className="text-sm font-semibold text-ink">{item.name}</p>
                            <p className="text-[10px] text-green-muted">{item.tag}</p>
                          </div>
                        </div>
                        <span className={`text-sm font-bold ${item.amount.startsWith('+') ? 'text-green' : item.amount.startsWith('-') ? 'text-ink/60' : 'text-blue-600'}`}>
                          {item.amount}
                        </span>
                      </motion.div>
                    ))}
                  </div>
                </div>
              </div>
            </div>

            {/* Floating verified badge */}
            <motion.div animate={{ y: [0, -8, 0] }} transition={{ duration: 3, repeat: Infinity }}
              className="absolute -top-3 -right-3 w-14 h-14 bg-white rounded-2xl shadow-lg border border-green-muted/15 flex items-center justify-center">
              <MdCheckCircle size={28} className="text-green" />
            </motion.div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
