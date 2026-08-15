import { useState, useEffect } from 'react';
import { HiMenuAlt3, HiX } from 'react-icons/hi';
import { MdDownload } from 'react-icons/md';

const REPO = 'https://github.com/RA-L-PH/Moneta/releases/download/Latest';

const links = [
  { name: 'Features', href: '#features' },
  { name: 'How It Works', href: '#how-it-works' },
  { name: 'Downloads', href: '#download-assistance' },
  { name: 'GitHub', href: 'https://github.com/RA-L-PH/Moneta' },
];

export default function Navbar() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <nav className={`fixed top-0 w-full z-50 transition-all duration-300 ${scrolled ? 'bg-white/90 backdrop-blur-xl border-b border-green-muted/10 shadow-sm' : ''
      }`}>
      <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
        <a href="#" className="flex items-center gap-2.5">
          <img src="/favicon.png" alt="Moneta" className="w-8 h-8 rounded-lg" />
          <span className="text-lg font-bold text-ink">Moneta</span>
        </a>

        <div className="hidden md:flex items-center gap-6">
          {links.map(l => (
            <a key={l.name} href={l.href}
              target={l.href.startsWith('http') ? '_blank' : undefined}
              rel={l.href.startsWith('http') ? 'noopener noreferrer' : undefined}
              className="text-sm font-medium text-green-muted hover:text-green transition-colors">
              {l.name}
            </a>
          ))}
          <a href={`${REPO}/moneta-v2.0.0-arm64-v8a.apk`} target="_blank" rel="noopener noreferrer"
            className="flex items-center gap-2 bg-ink text-white px-5 py-2 rounded-full text-sm font-semibold hover:bg-ink/90 transition-colors shadow-md">
            <MdDownload size={16} />
            Download
          </a>
        </div>

        <button onClick={() => setOpen(!open)} className="md:hidden p-2 text-ink">
          {open ? <HiX size={22} /> : <HiMenuAlt3 size={22} />}
        </button>
      </div>

      {open && (
        <div className="md:hidden bg-white border-t border-green-muted/10">
          <div className="px-6 py-4 space-y-3">
            {links.map(l => (
              <a key={l.name} href={l.href} onClick={() => setOpen(false)}
                className="block text-sm py-2 text-green-muted hover:text-green">
                {l.name}
              </a>
            ))}
            <a href={`${REPO}/moneta-v2.0.0-arm64-v8a.apk`} target="_blank" rel="noopener noreferrer"
              className="flex items-center justify-center gap-2 bg-ink text-white px-5 py-2.5 rounded-full text-sm font-semibold mt-2">
              <MdDownload size={16} />
              Download
            </a>
          </div>
        </div>
      )}
    </nav>
  );
}
