import { motion } from 'framer-motion';
import { MdDownload, MdAndroid, MdSettings, MdCheckCircle, MdInfo } from 'react-icons/md';

const REPO = 'https://github.com/RA-L-PH/Moneta/releases/download/Latest';
const APKs = [
  { name: 'ARM64 (Recommended)', file: 'moneta-v2.0.0-arm64-v8a.apk', note: 'Most modern phones (2019+)', size: '18.3 MB', recommended: true },
  { name: 'ARM', file: 'moneta-v2.0.0-armeabi-v7a.apk', note: 'Older Android phones', size: '16.0 MB', recommended: false },
  { name: 'x86_64', file: 'moneta-v2.0.0-x86_64.apk', note: 'Emulators, Chromebooks, tablets', size: '19.7 MB', recommended: false },
  { name: 'Universal', file: 'moneta-v2.0.0.apk', note: 'All architectures (larger file)', size: '52.0 MB', recommended: false },
];

const installationSteps = [
  {
    icon: MdDownload,
    title: '1. Download the APK',
    desc: 'Select the file matching your device architecture above. (ARM64 is standard for 95%+ of modern phones).',
  },
  {
    icon: MdSettings,
    title: '2. Enable Unknown Sources',
    desc: 'If prompted by your browser, enable "Install unknown apps" in Settings to permit the installation.',
  },
  {
    icon: MdCheckCircle,
    title: '3. Tap to Install',
    desc: 'Open your Downloads folder, tap the APK file, and follow the system prompts to complete installation.',
  },
];

export default function DownloadAssistance() {
  return (
    <section id="download-assistance" className="py-24 px-6 bg-card border-t border-b border-green-muted/10">
      <div className="max-w-6xl mx-auto">
        <div className="text-center mb-16">
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-green/10 text-green mb-4"
          >
            <MdAndroid size={16} />
            Android Download & Help
          </motion.div>
          <motion.h2
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-3xl md:text-5xl font-bold font-display text-ink"
          >
            Download <span className="text-gradient-green">Assistance</span>
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            className="text-green-muted max-w-lg mx-auto mt-4 text-base md:text-lg"
          >
            Select the variant tailored for your device or follow our quick step-by-step setup guide below.
          </motion.p>
        </div>

        {/* APK Variants Grid */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-20">
          {APKs.map((apk, index) => (
            <motion.div
              key={apk.file}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className={`relative flex flex-col justify-between p-6 rounded-2xl bg-white border-2 transition-all hover:shadow-xl ${
                apk.recommended
                  ? 'border-green shadow-lg shadow-green/5 scale-105 md:scale-100 lg:scale-105'
                  : 'border-green-muted/10 hover:border-green-muted/30'
              }`}
            >
              {apk.recommended && (
                <span className="absolute -top-3 left-1/2 -translate-x-1/2 bg-green text-white text-[10px] uppercase font-bold tracking-widest px-3 py-1 rounded-full">
                  Recommended
                </span>
              )}
              <div className="mb-6">
                <h3 className="text-lg font-bold text-ink mb-1">{apk.name}</h3>
                <p className="text-xs text-green-muted min-h-[32px]">{apk.note}</p>
                <div className="mt-4 flex items-baseline gap-1.5">
                  <span className="text-2xl font-extrabold text-ink">{apk.size}</span>
                  <span className="text-[10px] text-green-muted font-medium uppercase">size</span>
                </div>
              </div>
              <a
                href={`${REPO}/${apk.file}`}
                className={`w-full flex items-center justify-center gap-2 py-3 rounded-xl font-semibold transition-all ${
                  apk.recommended
                    ? 'bg-green text-white hover:bg-green-deep'
                    : 'bg-card text-ink hover:bg-ink hover:text-white border border-green-muted/10'
                }`}
              >
                <MdDownload size={18} />
                Download
              </a>
            </motion.div>
          ))}
        </div>

        {/* Installation Instructions */}
        <div className="bg-white rounded-3xl p-8 md:p-12 border border-green-muted/10 shadow-sm">
          <h3 className="text-xl md:text-2xl font-bold font-display text-ink mb-8 flex items-center gap-2">
            <MdInfo className="text-green" size={24} />
            How to Install Moneta APK
          </h3>
          <div className="grid md:grid-cols-3 gap-8">
            {installationSteps.map((step, index) => (
              <div key={index} className="flex flex-col">
                <div className="w-12 h-12 rounded-xl bg-green/5 border border-green/10 flex items-center justify-center mb-4 text-green">
                  <step.icon size={22} />
                </div>
                <h4 className="font-bold text-ink text-lg mb-2">{step.title}</h4>
                <p className="text-sm leading-relaxed text-green-muted">{step.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
