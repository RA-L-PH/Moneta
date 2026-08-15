export default function Footer() {
  return (
    <footer className="py-10 px-6 border-t border-green-muted/10">
      <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-4">
        <div className="flex items-center gap-2.5">
          <img src="/favicon.png" alt="Moneta" className="w-6 h-6 rounded" />
          <span className="font-bold text-sm text-ink">Moneta</span>
        </div>

        <p className="text-xs text-green-muted">
          Open source. Privacy first.
        </p>

        <div className="flex items-center gap-4">
          <a href="https://github.com/RA-L-PH" target="_blank" rel="noopener noreferrer"
            className="text-green-muted hover:text-green transition-colors text-xs flex items-center gap-1.5">
            <span>@RA-L-PH</span>
          </a>
        </div>
      </div>
    </footer>
  );
}
