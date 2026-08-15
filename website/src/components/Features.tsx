import { motion } from 'framer-motion';
import { MdSms, MdSmartToy, MdLock, MdAutoGraph, MdCategory, MdNotificationsActive, MdChat, MdEdit, MdDarkMode, MdTrendingUp, MdRefresh, MdDashboard } from 'react-icons/md';

const features = [
  { icon: MdSms, title: 'Reads Your Bank SMS', desc: 'Forwarded 100 bank SMS to ChatGPT? Yeah, we did that. Moneta reads them automatically — no copy-paste, no screenshots, no drama.', gradient: 'from-green/5 to-transparent' },
  { icon: MdSmartToy, title: 'NVIDIA NIM AI', desc: 'Enterprise-grade NVIDIA silicon thinking about YOUR money.', gradient: 'from-blue-500/5 to-transparent', highlight: true },
  { icon: MdChat, title: 'AI That Gets You', desc: '"Where did my salary go?" — Ask. Get a markdown breakdown. YOUR data, YOUR answers.', gradient: 'from-purple-500/5 to-transparent' },
  { icon: MdLock, title: 'Your Phone, Your Data', desc: 'Zero cloud. Zero servers. Everything lives in Hive on your device. Even we can\'t see it.', gradient: 'from-red-500/5 to-transparent' },
  { icon: MdAutoGraph, title: 'Charts That Make Sense', desc: '6-month income vs expense trends. Category pie charts. Touch tooltips. The analytics your CA charges ₹5000 for.', gradient: 'from-amber-500/5 to-transparent' },
  { icon: MdCategory, title: 'Auto-Categorization', desc: 'Swiggy = Food. Uber = Transport. Netflix = Entertainment. Moneta sorts them so you don\'t have to.', gradient: 'from-pink-500/5 to-transparent' },
  { icon: MdEdit, title: 'Swipe to Fix', desc: 'Parser said "AMZN" is "Other"? Swipe, edit, done. Add descriptions, change categories.', gradient: 'from-cyan-500/5 to-transparent' },
  { icon: MdDarkMode, title: 'Dark Mode, Obviously', desc: 'Frosted glass UI with backdrop blur. Checking finances at 2AM should at least look good.', gradient: 'from-indigo-500/5 to-transparent' },
  { icon: MdTrendingUp, title: 'Trend Spotting', desc: 'Curved charts showing your 6-month trajectory. See if you\'re getting better at "adulting".', gradient: 'from-emerald-500/5 to-transparent' },
  { icon: MdNotificationsActive, title: 'Smart Pings', desc: 'Real-time alerts when money moves. Instant, local, no internet needed.', gradient: 'from-orange-500/5 to-transparent' },
  { icon: MdRefresh, title: 'Re-scan Anytime', desc: 'Hit re-import. Moneta re-scans your inbox and finds transactions you forgot about.', gradient: 'from-teal-500/5 to-transparent' },
  { icon: MdDashboard, title: 'Glass Bottom Nav', desc: 'Floating pill-shaped navigation with real backdrop blur. "Just an app" vs "damn, this is polished".', gradient: 'from-violet-500/5 to-transparent', highlight: true },
];

export default function Features() {
  return (
    <section id="features" className="py-24 px-6 bg-card">
      <div className="max-w-6xl mx-auto">
        <motion.div initial={{ opacity: 0, y: 20 }} whileInView={{ opacity: 1, y: 0 }} viewport={{ once: true }}
          className="text-center mb-16">
          <h2 className="text-3xl md:text-5xl font-bold mb-4 font-display text-ink">
            Everything you need.<br />
            <span className="text-gradient-green">Nothing you don't.</span>
          </h2>
          <p className="text-lg max-w-lg mx-auto text-green-muted">
            Built for people who want to understand their money without the complexity.
          </p>
        </motion.div>

        {/* Bento Grid - 4 columns, no gaps */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {features.map((f, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.04 }}
              className={`group relative overflow-hidden rounded-3xl border transition-all duration-500 hover:shadow-xl cursor-default ${
                f.highlight
                  ? 'border-green/30 bg-gradient-to-br ' + f.gradient
                  : 'border-green-muted/10 bg-white hover:border-green/20'
              }`}
            >
              {/* Hover gradient overlay */}
              <div className="absolute inset-0 bg-gradient-to-br from-green/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

              {/* Content */}
              <div className="relative p-5">
                <div className={`w-11 h-11 rounded-2xl flex items-center justify-center mb-4 transition-all duration-300 group-hover:scale-110 group-hover:rotate-3 ${
                  f.highlight
                    ? 'bg-green/15 text-green'
                    : 'bg-green/10 text-green group-hover:bg-green/15'
                }`}>
                  <f.icon size={22} />
                </div>
                <h3 className="text-base font-bold mb-2 text-ink group-hover:text-green transition-colors">{f.title}</h3>
                <p className="text-sm leading-relaxed text-green-muted">{f.desc}</p>
              </div>

              {/* Decorative corner element */}
              <div className="absolute -bottom-6 -right-6 w-20 h-20 bg-green/5 rounded-full blur-xl group-hover:bg-green/10 transition-colors" />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
