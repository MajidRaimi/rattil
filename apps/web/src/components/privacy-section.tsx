"use client";

import { useTranslate } from "@tolgee/react";
import { motion, useInView, useSpring, useMotionValue } from "framer-motion";
import { useEffect, useRef } from "react";

function CountUp({ target, suffix = "" }: { target: number; suffix?: string }) {
  const ref = useRef<HTMLSpanElement>(null);
  const inView = useInView(ref, { once: true });
  const motionVal = useMotionValue(0);
  const spring = useSpring(motionVal, { duration: 1500, bounce: 0 });

  useEffect(() => {
    if (inView) motionVal.set(target);
  }, [inView, motionVal, target]);

  useEffect(() => {
    return spring.on("change", (v) => {
      if (ref.current) ref.current.textContent = Math.round(v) + suffix;
    });
  }, [spring, suffix]);

  return <span ref={ref}>0{suffix}</span>;
}

const highlights = [
  { target: 44, suffix: "+", labelKey: "stat_languages" },
  { target: 5, suffix: "+", labelKey: "stat_reciters" },
  { target: 20, suffix: "+", labelKey: "stat_tafsirs" },
];

export function PrivacySection() {
  const { t } = useTranslate();

  return (
    <section className="max-w-3xl mx-auto px-6 text-center">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6 }}
        className="space-y-16"
      >
        <div className="space-y-3">
          <p className="text-2xl sm:text-3xl font-semibold text-[var(--text-primary)]">
            {t("privacy_subtitle")}
          </p>
          <p className="text-sm text-[var(--text-tertiary)] max-w-md mx-auto leading-relaxed">
            {t("privacy_offline_desc")}
          </p>
        </div>

        <div className="grid grid-cols-3 gap-4" dir="ltr">
          {highlights.map((h, i) => (
            <div key={h.labelKey} className="flex flex-col items-center gap-3">
              <p className="text-4xl sm:text-6xl font-bold text-[var(--text-primary)]">
                <CountUp target={h.target} suffix={h.suffix} />
              </p>
              <div className="w-6 h-px bg-[var(--gold-active)]" />
              <p className="text-xs sm:text-sm text-[var(--text-tertiary)]">
                {t(h.labelKey)}
              </p>
            </div>
          ))}
        </div>
      </motion.div>
    </section>
  );
}
