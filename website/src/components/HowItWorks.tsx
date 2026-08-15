import { motion } from 'framer-motion';
import { MdDownload, MdSync, MdAutoGraph, MdTrendingUp, MdChat, MdSettings } from 'react-icons/md';

const steps = [
  { icon: MdDownload, num: '01', title: 'Download', desc: 'Get Moneta from GitHub releases. Install in seconds — no Play Store needed.' },
  { icon: MdSync, num: '02', title: 'Grant SMS Access', desc: 'One permission. Moneta reads only banking SMS — never stores raw messages.' },
  { icon: MdAutoGraph, num: '03', title: 'Auto-Track', desc: 'Transactions parsed, categorized, and logged instantly with our deterministic pipeline.' },
  { icon: MdChat, num: '04', title: 'Chat with AI', desc: 'Ask your AI assistant about spending patterns, budgets, or financial advice.' },
  { icon: MdTrendingUp, num: '05', title: 'Get Insights', desc: 'NVIDIA NIM AI analyzes your patterns and suggests ways to save money.' },
  { icon: MdSettings, num: '06', title: 'Customize', desc: 'Edit transactions, set categories, adjust SMS window, and configure AI settings.' },
];

export default function HowItWorks() {
  return (
    <section id="how-it-works" className="py-24 px-6">
      <div className="max-w-6xl mx-auto">
        <motion.h2 initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}
          className="text-3xl md:text-5xl font-bold text-center mb-20 font-display text-ink">
          Up and running in <span className="text-gradient-green">minutes</span>.
        </motion.h2>

        {/* Steps with connecting line */}
        <div className="relative">
          {/* Connecting line */}
          <div className="hidden md:block absolute top-7 left-[8.33%] right-[8.33%] h-[2px] bg-green-muted/20" />
          <div className="hidden md:block absolute top-7 left-[8.33%] w-[83.34%] h-[2px] bg-gradient-to-r from-green to-green-deep" />

          <div className="grid md:grid-cols-3 lg:grid-cols-6 gap-8 relative">
            {steps.map((s, i) => (
              <motion.div key={i} initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }} transition={{ delay: i * 0.1 }} className="text-center relative">
                {/* Step circle */}
                <div className="relative z-10 w-14 h-14 rounded-full bg-white border-2 border-green flex items-center justify-center mx-auto mb-5 shadow-sm">
                  <s.icon size={24} className="text-green" />
                </div>
                <span className="text-sm font-bold tracking-wider text-green-deep">{s.num}</span>
                <h3 className="text-lg font-semibold mt-2 mb-2 text-ink">{s.title}</h3>
                <p className="text-sm leading-relaxed text-green-muted">{s.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
