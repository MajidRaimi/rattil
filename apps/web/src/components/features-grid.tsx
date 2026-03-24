"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";

const features = [
  { titleKey: "feature_quran_title", descKey: "feature_quran_desc" },
  { titleKey: "feature_hifz_title", descKey: "feature_hifz_desc" },
  { titleKey: "feature_wird_title", descKey: "feature_wird_desc" },
  { titleKey: "feature_tikrar_title", descKey: "feature_tikrar_desc" },
  { titleKey: "feature_search_title", descKey: "feature_search_desc" },
  { titleKey: "feature_bookmarks_title", descKey: "feature_bookmarks_desc" },
];

export function FeaturesGrid() {
  const { t } = useTranslate();

  return (
    <section id="features" className="px-4 flex justify-center">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.5 }}
        className="w-full max-w-5xl grid grid-cols-1 sm:grid-cols-3 border border-[var(--gold-active)]/25 rounded-2xl overflow-hidden"
      >
        {features.map((f, i) => {
          const isTopRow = i < 3;
          const isLeftOrMiddle = i % 3 !== 2;

          return (
            <div
              key={f.titleKey}
              className={`px-6 py-6 ${
                isTopRow ? "border-b border-[var(--gold-active)]/25" : ""
              } ${
                isLeftOrMiddle ? "sm:border-e border-[var(--gold-active)]/25" : ""
              }`}
            >
              <h3 className="text-sm font-semibold text-[var(--text-primary)] mb-1.5">
                {t(f.titleKey)}
              </h3>
              <p className="text-xs text-[var(--text-tertiary)] leading-relaxed">
                {t(f.descKey)}
              </p>
            </div>
          );
        })}
      </motion.div>
    </section>
  );
}
