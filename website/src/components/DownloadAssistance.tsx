import { useState } from 'react';
import { motion } from 'framer-motion';
import { MdDownload, MdAndroid, MdSettings, MdCheckCircle, MdInfo, MdTerminal, MdUsb, MdContentCopy } from 'react-icons/md';

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
  const [activeTab, setActiveTab] = useState<'standard' | 'adb'>('standard');
  const [selectedApkForAdb, setSelectedApkForAdb] = useState(APKs[0]);
  const [copied, setCopied] = useState(false);

  const adbCommand = `adb install ${selectedApkForAdb.file}`;

  const copyToClipboard = () => {
    navigator.clipboard.writeText(adbCommand);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

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
          {/* Tab Navigation */}
          <div className="flex border-b border-green-muted/10 mb-8 gap-6">
            <button
              onClick={() => setActiveTab('standard')}
              className={`pb-4 text-sm font-bold transition-all relative ${
                activeTab === 'standard' ? 'text-green' : 'text-green-muted hover:text-ink'
              }`}
            >
              Standard Device Install
              {activeTab === 'standard' && (
                <motion.div layoutId="activeTabUnderline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-green" />
              )}
            </button>
            <button
              onClick={() => setActiveTab('adb')}
              className={`pb-4 text-sm font-bold transition-all relative ${
                activeTab === 'adb' ? 'text-green' : 'text-green-muted hover:text-ink'
              }`}
            >
              Developer Install (ADB)
              {activeTab === 'adb' && (
                <motion.div layoutId="activeTabUnderline" className="absolute bottom-0 left-0 right-0 h-0.5 bg-green" />
              )}
            </button>
          </div>

          {activeTab === 'standard' ? (
            <div>
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
          ) : (
            <div className="grid lg:grid-cols-12 gap-8 items-start">
              {/* ADB Guides */}
              <div className="lg:col-span-7 space-y-6">
                <h3 className="text-xl md:text-2xl font-bold font-display text-ink flex items-center gap-2">
                  <MdTerminal className="text-green" size={24} />
                  ADB Stream Installation
                </h3>
                <div className="space-y-4">
                  <div className="flex gap-4">
                    <div className="w-8 h-8 rounded-full bg-green/5 border border-green/10 flex items-center justify-center flex-shrink-0 text-green font-bold text-xs">
                      1
                    </div>
                    <div>
                      <h4 className="font-bold text-ink text-sm mb-1">Enable USB Debugging</h4>
                      <p className="text-xs text-green-muted leading-relaxed">
                        Go to **Settings &gt; About Phone** and tap **Build Number** 7 times. Then go to **Developer Options** and enable **USB Debugging**.
                      </p>
                    </div>
                  </div>
                  <div className="flex gap-4">
                    <div className="w-8 h-8 rounded-full bg-green/5 border border-green/10 flex items-center justify-center flex-shrink-0 text-green font-bold text-xs">
                      2
                    </div>
                    <div>
                      <h4 className="font-bold text-ink text-sm mb-1">Connect to PC</h4>
                      <p className="text-xs text-green-muted leading-relaxed">
                        Connect your Android device to your computer via USB. Authorize debugging if prompted on your screen.
                      </p>
                    </div>
                  </div>
                  <div className="flex gap-4">
                    <div className="w-8 h-8 rounded-full bg-green/5 border border-green/10 flex items-center justify-center flex-shrink-0 text-green font-bold text-xs">
                      3
                    </div>
                    <div>
                      <h4 className="font-bold text-ink text-sm mb-1">Execute command</h4>
                      <p className="text-xs text-green-muted leading-relaxed">
                        Navigate to your downloaded APK folder in your CLI tool, and run the generated adb command to stream the install.
                      </p>
                    </div>
                  </div>
                </div>
              </div>

              {/* Dynamic ADB Command Card */}
              <div className="lg:col-span-5 bg-card border border-green-muted/15 rounded-2xl p-6">
                <div className="mb-4">
                  <label className="block text-xs font-bold uppercase tracking-wider text-green-muted mb-2">
                    Select Target APK
                  </label>
                  <select
                    value={selectedApkForAdb.file}
                    onChange={(e) => {
                      const selected = APKs.find((apk) => apk.file === e.target.value);
                      if (selected) setSelectedApkForAdb(selected);
                    }}
                    className="w-full px-3 py-2 bg-white rounded-lg border border-green-muted/20 text-xs font-semibold focus:outline-none focus:border-green"
                  >
                    {APKs.map((apk) => (
                      <option key={apk.file} value={apk.file}>
                        {apk.name} ({apk.size})
                      </option>
                    ))}
                  </select>
                </div>

                <div className="relative bg-ink text-zinc-300 p-4 rounded-xl font-mono text-xs mb-4 select-all group border border-white/5">
                  <div className="absolute top-2.5 right-2.5">
                    <button
                      onClick={copyToClipboard}
                      className="p-1.5 bg-white/5 rounded hover:bg-white/10 hover:text-white transition-all"
                      title="Copy command"
                    >
                      <MdContentCopy size={14} />
                    </button>
                  </div>
                  <span className="text-green-neon">$</span> {adbCommand}
                </div>

                <button
                  onClick={copyToClipboard}
                  className={`w-full py-2.5 rounded-xl font-semibold text-xs flex items-center justify-center gap-2 transition-all ${
                    copied
                      ? 'bg-green text-white'
                      : 'bg-ink text-white hover:bg-ink/90'
                  }`}
                >
                  {copied ? (
                    <>
                      <MdCheckCircle size={16} />
                      Copied!
                    </>
                  ) : (
                    <>
                      <MdUsb size={16} />
                      Copy ADB Command
                    </>
                  )}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
