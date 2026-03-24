"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";

const stats = [
  { value: "114", key: "stat_surahs" },
  { value: "6,236", key: "stat_ayahs" },
  { value: "44", key: "stat_languages" },
  { value: "100%", key: "stat_free" },
];

export function StatsBar() {
  const { t } = useTranslate();

  return (
    <section className="border-y border-[var(--divider)]">
      <div className="max-w-6xl mx-auto px-6 py-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
          className="grid grid-cols-2 sm:grid-cols-4 gap-8 text-center"
        >
          {stats.map((stat) => (
            <div key={stat.key} className="space-y-1">
              <p className="text-3xl sm:text-4xl font-bold text-[var(--gold-active)]">
                {stat.value}
              </p>
              <p className="text-sm text-[var(--text-tertiary)]">
                {t(stat.key)}
              </p>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
