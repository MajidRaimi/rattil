"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";

const columns = [0, 1, 2, 3];

export function Footer() {
  const { t } = useTranslate();

  return (
    <footer className="border-t border-[var(--divider)]">
      <div className="max-w-5xl mx-auto px-6 py-14">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-10">
          {/* Logo + tagline */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4 }}
            className="col-span-2 sm:col-span-1"
          >
            <img
              src="/images/logo.svg"
              alt="Rattil"
              width={40}
              height={40}
              className="mb-3"
            />
            <p className="text-xs text-[var(--text-tertiary)] leading-relaxed max-w-[260px] mt-1">
              {t("footer_tagline_long")}
            </p>
          </motion.div>

          {/* Quick Links */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4, delay: 0.1 }}
          >
            <h4 className="text-sm font-semibold text-[var(--text-primary)] mb-4">
              {t("footer_quick_links")}
            </h4>
            <div className="flex flex-col gap-3 text-sm text-[var(--text-tertiary)]">
              <a href="/#features" className="hover:text-[var(--text-primary)] transition-colors w-fit">
                {t("nav_features")}
              </a>
              <a href="/#screenshots" className="hover:text-[var(--text-primary)] transition-colors w-fit">
                {t("nav_screenshots")}
              </a>
              <a href="/#download" className="hover:text-[var(--text-primary)] transition-colors w-fit">
                {t("nav_download")}
              </a>
            </div>
          </motion.div>

          {/* Legal */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4, delay: 0.2 }}
          >
            <h4 className="text-sm font-semibold text-[var(--text-primary)] mb-4">
              {t("footer_legal")}
            </h4>
            <div className="flex flex-col gap-3 text-sm text-[var(--text-tertiary)]">
              <a href="/privacy" className="hover:text-[var(--text-primary)] transition-colors w-fit">
                {t("footer_privacy")}
              </a>
              <a href="/terms" className="hover:text-[var(--text-primary)] transition-colors w-fit">
                {t("footer_terms")}
              </a>
            </div>
          </motion.div>

          {/* Contact */}
          <motion.div
            initial={{ opacity: 0, y: 10 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.4, delay: 0.3 }}
          >
            <h4 className="text-sm font-semibold text-[var(--text-primary)] mb-4">
              {t("footer_contact_us")}
            </h4>
            <div className="flex flex-col gap-3 text-sm text-[var(--text-tertiary)]">
              <a
                href="mailto:majidsraimi@gmail.com"
                className="flex items-center gap-3 hover:text-[var(--text-primary)] transition-colors w-fit"
              >
                <div className="w-8 h-8 rounded-lg bg-[var(--text-primary)]/[0.06] flex items-center justify-center flex-shrink-0">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <rect x="2" y="4" width="20" height="16" rx="2" />
                    <path d="M22 7l-8.97 5.7a1.94 1.94 0 01-2.06 0L2 7" />
                  </svg>
                </div>
                <span>majidsraimi@gmail.com</span>
              </a>
              <a
                href="https://github.com/MajidRaimi/rattil"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-3 hover:text-[var(--text-primary)] transition-colors w-fit"
              >
                <div className="w-8 h-8 rounded-lg bg-[var(--text-primary)]/[0.06] flex items-center justify-center flex-shrink-0">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
                    <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z" />
                  </svg>
                </div>
                <span>{t("footer_github")}</span>
              </a>
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-[var(--text-primary)]/[0.06] flex items-center justify-center flex-shrink-0">
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z" />
                    <circle cx="12" cy="10" r="3" />
                  </svg>
                </div>
                <span>{t("footer_location")}</span>
              </div>
            </div>
          </motion.div>
        </div>
      </div>

      {/* Bottom bar */}
      <div className="max-w-5xl mx-auto px-6">
        <div className="border-t border-[var(--divider)] py-5 flex flex-col sm:flex-row items-center justify-between gap-2 text-[11px] text-[var(--text-tertiary)] text-center sm:text-start">
          <bdi>© {new Date().getFullYear()} {t("footer_brand")}. {t("footer_rights")}</bdi>
          <span className="text-[var(--text-tertiary)]/60 italic">
            {t("footer_dedication")}
          </span>
        </div>
      </div>
    </footer>
  );
}
