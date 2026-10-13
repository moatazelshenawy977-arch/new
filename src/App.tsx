import { useRef } from 'react';
import { motion, useScroll, useTransform } from 'motion/react';

const LOGO_PATH =
  'M60 120C26.8629 120 0 93.1371 0 60V0C22.5654 0 42.2213 12.4569 52.4662 30.8691C38.4788 34.2089 28.0787 46.7902 28.0787 61.8006V63.1443C28.0787 79.9648 41.7146 93.6006 58.5353 93.6006H59.8789L59.8785 61.8006C59.8785 79.3633 74.1159 93.6006 91.6787 93.6006L91.6787 61.8006C91.6787 44.2783 77.5071 30.0661 60 30.0008L60 0H62.5352C94.2722 0 120 25.7279 120 57.4648V60C120 93.1371 93.1371 120 60 120Z';

const HERO_VIDEO =
  'https://pub-86dc5b5484314368ac5436a674b0d919.r2.dev/cloudinarry%20to%20cloudflare/baby-track-video_crqby5.mp4';
const BOTTOM_VIDEO =
  'https://pub-86dc5b5484314368ac5436a674b0d919.r2.dev/cloudinarry%20to%20cloudflare/track-video_2_haxdch.mp4';
const CLOUD_IMG =
  'https://res.cloudinary.com/dsdhxhhqh/image/upload/v1781500777/cloude_vj4pjv.png';

const HERO_PARAGRAPH_1 =
  'Our SaaS product takes over all exhausting operational activities, complex analytics, and tedious process management. While algorithms seamlessly build your success infrastructure and generate stable profit, you get time for truly important things.';
const HERO_PARAGRAPH_2 =
  'Delegate micromanagement to artificial intelligence and reliable cloud solutions to enjoy absolute peace of mind. We created a perfect ecosystem that automates marketing, finance, and communications, allowing you to scale your company without any stress.';

function Logo({ className }: { className: string }) {
  return (
    <svg className={className} viewBox="0 0 120 120" fill="white" xmlns="http://www.w3.org/2000/svg">
      <path d={LOGO_PATH} />
    </svg>
  );
}

export default function App() {
  const containerRef = useRef<HTMLDivElement>(null);
  const { scrollY } = useScroll({ container: containerRef });
  const cloudYDesktop = useTransform(scrollY, [0, 300], [0, -100]);
  const cloudYMobile = useTransform(scrollY, [0, 300], [0, -24]);

  return (
    <main
      ref={containerRef}
      className="h-screen overflow-y-auto overflow-x-hidden font-manrope bg-black relative"
    >
      {/* Section 1 — Video Hero */}
      <section className="relative h-screen w-full flex-shrink-0 overflow-hidden">
        <video
          className="absolute inset-0 z-10 w-full h-full object-cover"
          src={HERO_VIDEO}
          autoPlay
          loop
          muted
          playsInline
        />

        <div className="absolute inset-0 z-30 pointer-events-none">
          {/* Top-left logo block */}
          <div className="absolute top-[24px] left-[20px] md:top-[64px] md:left-[64px] pointer-events-auto max-w-[calc(100vw-140px)] md:max-w-none">
            <div className="flex flex-row gap-[16px] md:gap-[24px] items-center">
              <Logo className="w-[48px] h-[48px] md:w-[64px] md:h-[64px] shrink-0" />
              <p className="text-white text-[11px] md:text-[16px] w-[112px] md:w-auto leading-[1.2] font-semibold tracking-[0.02em]">
                <span className="hidden md:block">
                  Effortless Growth
                  <br />
                  Operations. We Handle All Tasks.
                  <br />
                  Stay Calm.
                  <br />
                </span>
                <span className="block md:hidden">
                  Complete Business
                  <br />
                  Automation. We Handle All
                  <br />
                  Tasks. You Relax.
                </span>
              </p>
            </div>

            {/* Left description (desktop only) */}
            <div className="hidden md:flex mt-[400px] flex-col gap-[24px] w-full max-w-[320px] text-white text-[14px] font-normal leading-relaxed">
              <p>{HERO_PARAGRAPH_1}</p>
              <p>{HERO_PARAGRAPH_2}</p>
            </div>
          </div>

          {/* Top-right CTA */}
          <div className="absolute top-[24px] right-[20px] md:top-[64px] md:right-[64px] pointer-events-auto">
            <button className="px-5 py-3 md:px-10 md:py-7 border border-white rounded-[100%] text-white text-[12px] md:text-[18px] font-italiana uppercase tracking-widest hover:bg-white/10 hover:backdrop-blur-[48px] transition-all duration-300 cursor-pointer bg-black/10 backdrop-blur-sm md:bg-transparent md:backdrop-blur-none">
              Get started
            </button>
          </div>

          {/* Bottom heading */}
          <div className="absolute bottom-[32px] left-[20px] right-[20px] md:left-auto md:bottom-[64px] md:right-[64px] md:max-w-[1200px] text-left md:text-right">
            <div className="md:hidden flex flex-col gap-[16px] max-w-[280px] text-white text-[12px] font-normal mb-[32px]">
              <p>{HERO_PARAGRAPH_1}</p>
              <p>{HERO_PARAGRAPH_2}</p>
            </div>
            <h1 className="text-white text-[36px] leading-[1.1] md:text-[96px] font-italiana md:leading-[88px]">
              <span className="hidden md:inline">
                Intelligent Daily
                <br />
                Routine Automation
                <br />
                For Your Business.
                <br />
                You Relax
              </span>
              <span className="inline md:hidden text-[32px]">
                Intelligent Daily Routine
                <br />
                Automation For Your
                <br />
                Business. You Relax
              </span>
            </h1>
          </div>
        </div>
      </section>

      {/* Section 2 — Red Background */}
      <section className="relative min-h-screen w-full bg-[#FF0000] flex flex-col z-10">
        {/* Cloud overlays */}
        <motion.div
          style={{ y: cloudYDesktop }}
          className="hidden md:block absolute top-0 left-0 w-full z-[100] pointer-events-none -translate-y-1/2"
        >
          <img src={CLOUD_IMG} alt="" className="w-full h-auto block" referrerPolicy="no-referrer" />
        </motion.div>
        <motion.div
          style={{ y: cloudYMobile }}
          className="block md:hidden absolute top-0 left-0 w-full z-[100] pointer-events-none -translate-y-1/2"
        >
          <img src={CLOUD_IMG} alt="" className="w-full h-auto block" referrerPolicy="no-referrer" />
        </motion.div>

        {/* Content */}
        <div className="flex-1 flex flex-col items-center w-full pt-[100px] md:pt-[400px]">
          <div className="flex flex-col items-center w-full px-8 text-center z-20 relative max-w-[900px] h-auto md:h-[620px] mx-auto">
            <Logo className="w-[80px] h-[80px] mb-[40px]" />
            <p className="text-white text-[16px] h-[100px] max-w-[400px] leading-[1.6] mb-[40px] uppercase tracking-wider mx-auto">
              We built this platform with a single purpose to eliminate operational chaos and restore balance to your
              daily business routine
            </p>
            <div className="font-marck text-white text-[120px] leading-none mb-[32px]">S.P.D</div>
            <div className="flex flex-col items-center mb-[100px] md:mb-24">
              <p className="text-white text-[16px] w-[400px] max-w-full font-light mb-[24px]">
                I Was Exhausted By Software That Demanded More Effort Than It Actually Saved. That Is Why We Engineered
                An Autonomous Architecture That Operates Silently In The Background.
              </p>
              <p className="text-white text-[16px] w-[400px] max-w-full font-light">
                Your Business Should Serve Your Life, Not Consume It. Let Our Algorithms Handle The Heavy Lifting, So
                You Can Focus On The Vision.
              </p>
            </div>
          </div>

          {/* Bottom video */}
          <div className="relative w-full shrink-0">
            <div className="absolute top-0 left-0 w-full h-[100px] bg-gradient-to-b from-[#FF0000] to-transparent z-10 pointer-events-none" />
            <video
              className="w-full h-auto block object-contain"
              src={BOTTOM_VIDEO}
              autoPlay
              loop
              muted
              playsInline
            />
          </div>
        </div>
      </section>
    </main>
  );
}
