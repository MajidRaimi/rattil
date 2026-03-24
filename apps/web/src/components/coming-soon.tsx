"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";

export function ComingSoon() {
  const { t } = useTranslate();

  return (
    <section className="max-w-3xl mx-auto px-6 py-12">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6 }}
        className="border border-[var(--divider)] rounded-[var(--radius-card)] px-8 py-10 sm:px-12 sm:py-14 text-center"
      >
        <span className="inline-block px-3 py-1 rounded-full border border-[var(--gold-active)]/30 text-[var(--gold-active)] text-[11px] font-medium tracking-wider uppercase mb-6">
          {t("coming_soon")}
        </span>

        <p
          className="text-3xl sm:text-4xl text-[var(--gold-active)] mb-4"
          style={{ fontFamily: "var(--font-quran)" }}
          dir="rtl"
        >
          تسميع
        </p>

        <p className="text-sm text-[var(--text-secondary)] max-w-md mx-auto leading-relaxed">
          {t("tasmi_desc")}
        </p>
      </motion.div>
    </section>
  );
}
