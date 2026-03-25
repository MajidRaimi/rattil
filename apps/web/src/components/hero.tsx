"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";
import { Ornament } from "./ornament";

export function Hero() {
  const { t } = useTranslate();

  return (
    <section className="relative h-[100dvh] flex flex-col items-center justify-center px-6 pt-14">
      <div className="flex flex-col items-center text-center max-w-2xl mx-auto">
        {/* The Verse — always Arabic */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-3xl sm:text-5xl md:text-6xl text-[var(--text-tertiary)]"
          style={{ fontFamily: "var(--font-quran)", lineHeight: 2 }}
          dir="rtl"
        >
          أَوْ زِدْ عَلَيْهِ وَ<span className="text-[var(--gold-active)]">رَتِّلِ</span> الْقُرْآنَ تَرْتِيلًا
        </motion.p>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 0.5 }}
          className="text-xs sm:text-sm tracking-widest text-[var(--text-tertiary)]/50 mt-3"
          dir="rtl"
        >
          المزمل - ٤
        </motion.p>

        <Ornament className="py-10" />

        {/* Tagline */}
        <motion.p
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.9 }}
          className="text-sm sm:text-base text-[var(--text-secondary)] max-w-xs leading-relaxed"
        >
          {t("hero_tagline")}
        </motion.p>

        {/* CTA */}
        <motion.a
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 1.1 }}
          whileHover={{ scale: 1.03 }}
          whileTap={{ scale: 0.97 }}
          href="https://apps.apple.com/us/app/rattil-%D8%B1%D8%AA%D9%84/id6760684737"
          className="mt-10 inline-flex items-center gap-2.5 bg-[var(--text-primary)] text-[var(--bg)] px-6 py-3 rounded-full text-sm font-medium transition-shadow hover:shadow-lg"
        >
          <svg width="16" height="20" viewBox="0 0 814 1000" fill="currentColor">
            <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76.5 0-103.7 40.8-165.9 40.8s-105.6-57.8-155.5-127.4c-58.3-81.2-105.9-207.6-105.9-328.2 0-192.8 124.9-295.1 248-295.1 65.4 0 119.9 43.5 161 43.5 39.5 0 101.1-46.2 175.2-46.2 28.2 0 130 2.5 197.3 95.4zm-271-174.8c31.5-38.2 53.8-91.3 53.8-144.3 0-7.4-.6-14.8-1.9-20.8-51.3 1.9-111.5 34.6-148 76.6-26.3 29.6-53.8 82.7-53.8 136.5 0 8.1 1.3 16.2 1.9 18.8 3.2.6 8.4 1.3 13.5 1.3 46.1 0 103.7-30.7 134.5-68.1z" />
          </svg>
          {t("app_store_download")}
        </motion.a>
      </div>

      {/* Scroll indicator — pulses */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: [0.3, 0.7, 0.3] }}
        transition={{ duration: 2.5, repeat: Infinity, delay: 1.5 }}
        className="absolute bottom-8"
      >
        <div className="w-px h-8 bg-gradient-to-b from-[var(--gold-active)] to-transparent" />
      </motion.div>
    </section>
  );
}
