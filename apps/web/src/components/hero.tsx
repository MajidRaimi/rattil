"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";
import { Ornament } from "./ornament";
import { DownloadButton } from "./download-button";

export function Hero() {
  const { t } = useTranslate();

  return (
    <section className="relative h-[100dvh] flex flex-col items-center justify-center px-6 pt-14">
      <div className="flex flex-col items-center text-center max-w-2xl mx-auto">
        {/* The Verse */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-3xl sm:text-5xl md:text-6xl text-[var(--text-tertiary)]"
          style={{ fontFamily: "var(--font-quran)", lineHeight: 2 }}
          dir="rtl"
        >
          أَوْ زِدْ عَلَيْهِ وَ
          <span className="text-[var(--gold-active)]">رَتِّلِ</span>{" "}
          الْقُرْآنَ تَرْتِيلًا
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
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 1.1 }}
          className="mt-10"
        >
          <DownloadButton />
        </motion.div>
      </div>

      {/* Scroll indicator */}
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
