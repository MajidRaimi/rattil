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
      <div className="w-full max-w-5xl rounded-2xl overflow-hidden border border-[var(--gold-active)]/25 bg-[var(--gold-active)]/25">
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-px">
          {features.map((f, i) => (
            <motion.div
              key={f.titleKey}
              initial={{ opacity: 0, y: 15 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.4, delay: i * 0.08 }}
              whileHover={{ backgroundColor: "var(--surface-variant)" }}
              className="px-5 py-5 sm:px-6 sm:py-6 bg-[var(--bg)] text-center sm:text-start cursor-default transition-colors"
            >
              <h3 className="text-xs sm:text-sm font-semibold text-[var(--text-primary)] mb-1">
                {t(f.titleKey)}
              </h3>
              <p className="text-[11px] sm:text-xs text-[var(--text-tertiary)] leading-relaxed">
                {t(f.descKey)}
              </p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
