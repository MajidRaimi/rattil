"use client";

import { AnimatePresence, motion } from "framer-motion";
import { QRCodeSVG } from "qrcode.react";
import { useTranslate } from "@tolgee/react";

const APP_STORE_URL =
  "https://apps.apple.com/us/app/rattil-%D8%B1%D8%AA%D9%84/id6760684737";

interface Props {
  open: boolean;
  onClose: () => void;
}

export function AppStoreModal({ open, onClose }: Props) {
  const { t } = useTranslate();

  return (
    <AnimatePresence>
      {open && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="fixed inset-0 z-[80] bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />

          {/* Modal */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 10 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.95, y: 10 }}
            transition={{ duration: 0.25, ease: [0.16, 1, 0.3, 1] }}
            className="fixed inset-0 z-[90] flex items-center justify-center p-6"
            onClick={onClose}
          >
            <div
              className="bg-[var(--surface)] border border-[var(--divider)] rounded-2xl p-8 sm:p-10 max-w-sm w-full text-center"
              onClick={(e) => e.stopPropagation()}
            >
              {/* Logo */}
              <img
                src="/images/logo.svg"
                alt="Rattil"
                width={40}
                height={40}
                className="mx-auto mb-4"
              />

              <h3 className="text-lg font-semibold text-[var(--text-primary)] mb-1">
                {t("qr_title")}
              </h3>
              <p className="text-xs text-[var(--text-tertiary)] mb-8">
                {t("qr_desc")}
              </p>

              {/* QR Code */}
              <div className="inline-flex p-4 bg-white rounded-2xl mb-8">
                <QRCodeSVG
                  value={APP_STORE_URL}
                  size={180}
                  level="M"
                  bgColor="#FFFFFF"
                  fgColor="#0D0D0D"
                />
              </div>

              <a
                href={APP_STORE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="block text-xs text-[var(--gold-active)] hover:opacity-70 transition-opacity"
              >
                {t("qr_open_link")}
              </a>
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

export { APP_STORE_URL };
