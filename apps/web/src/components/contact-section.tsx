"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";

export function ContactSection() {
  const { t } = useTranslate();

  return (
    <section className="inset-x-0 px-4 pb-20 flex justify-center">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5 }}
        className="relative w-full max-w-5xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-6 bg-[var(--gold-active)] rounded-2xl px-8 py-7 sm:px-10 sm:py-8 overflow-hidden"
      >
        {/* Scrolling ayahs background */}
        <div className="absolute inset-0 overflow-hidden select-none pointer-events-none" dir="rtl">
          {Array.from({ length: 5 }).map((_, row) => (
            <motion.div
              key={row}
              initial={{ x: row % 2 === 0 ? "0%" : "-5%" }}
              animate={{ x: row % 2 === 0 ? "-5%" : "0%" }}
              transition={{ duration: 25 + row * 4, repeat: Infinity, repeatType: "reverse", ease: "linear" }}
              className="whitespace-nowrap text-[11px] leading-[2.4] font-mono text-white/[0.08]"
              style={{ fontFamily: "var(--font-quran)" }}
            >
              {Array.from({ length: 3 }).map((_, i) => (
                <span key={i}>
                  بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ &middot; الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ &middot; الرَّحْمَنِ الرَّحِيمِ &middot; مَالِكِ يَوْمِ الدِّينِ &middot; إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ &middot; اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ &middot;{" "}
                </span>
              ))}
            </motion.div>
          ))}
        </div>

        {/* Content */}
        <div className="relative">
          <h3 className="text-base sm:text-lg font-semibold text-white">
            {t("contact_heading")}
          </h3>
          <p className="text-xs sm:text-sm text-white/70 mt-1">
            {t("contact_desc")}
          </p>
        </div>

        <a
          href="mailto:majidsraimi@gmail.com?subject=Rattil Feature Request"
          className="relative flex-shrink-0 flex items-center gap-2 bg-white/15 text-white px-5 py-2.5 rounded-xl text-sm font-medium hover:bg-white/25 transition-colors"
        >
          {t("contact_cta")}
          <svg
            className="w-3.5 h-3.5 rtl:rotate-180"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth="2.5"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M8.25 4.5l7.5 7.5-7.5 7.5"
            />
          </svg>
        </a>
      </motion.div>
    </section>
  );
}
