import Navbar from './components/Navbar';
import Hero from './components/Hero';
import SmsDemo from './components/SmsDemo';
import Features from './components/Features';
import HowItWorks from './components/HowItWorks';
import DownloadAssistance from './components/DownloadAssistance';
import Footer from './components/Footer';

function App() {
  return (
    <div className="min-h-screen bg-canvas text-ink overflow-x-hidden">
      <Navbar />
      <Hero />
      <SmsDemo />
      <Features />
      <HowItWorks />
      <DownloadAssistance />
      <Footer />
    </div>
  );
}

export default App;
