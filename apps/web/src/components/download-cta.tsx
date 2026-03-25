"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";
import { DownloadButton } from "./download-button";

export function DownloadCta() {
  const { t } = useTranslate();

  return (
    <section id="download" className="px-4 flex justify-center">
      <div className="w-full max-w-5xl flex flex-col sm:flex-row items-center sm:items-center justify-between gap-6 py-2 text-center sm:text-start">
        <motion.div
          initial={{ opacity: 0, x: -15 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5 }}
        >
          <h3 className="text-base sm:text-lg font-semibold text-[var(--text-primary)]">
            {t("download_title")}
          </h3>
          <p className="text-xs sm:text-sm text-[var(--text-tertiary)] mt-1">
            {t("download_subtitle")}
          </p>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, x: 15 }}
          whileInView={{ opacity: 1, x: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.15 }}
          className="flex-shrink-0"
        >
          <DownloadButton />
        </motion.div>
      </div>
    </section>
  );
}
