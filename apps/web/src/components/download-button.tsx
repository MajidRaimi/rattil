"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";
import { useOs } from "@mantine/hooks";
import { useState } from "react";
import { AppStoreModal, APP_STORE_URL } from "./app-store-modal";

const AppleIcon = () => (
  <svg width="16" height="20" viewBox="0 0 814 1000" fill="currentColor">
    <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76.5 0-103.7 40.8-165.9 40.8s-105.6-57.8-155.5-127.4c-58.3-81.2-105.9-207.6-105.9-328.2 0-192.8 124.9-295.1 248-295.1 65.4 0 119.9 43.5 161 43.5 39.5 0 101.1-46.2 175.2-46.2 28.2 0 130 2.5 197.3 95.4zm-271-174.8c31.5-38.2 53.8-91.3 53.8-144.3 0-7.4-.6-14.8-1.9-20.8-51.3 1.9-111.5 34.6-148 76.6-26.3 29.6-53.8 82.7-53.8 136.5 0 8.1 1.3 16.2 1.9 18.8 3.2.6 8.4 1.3 13.5 1.3 46.1 0 103.7-30.7 134.5-68.1z" />
  </svg>
);

const PlayIcon = () => (
  <svg width="16" height="18" viewBox="0 0 24 24" fill="currentColor">
    <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 01-.61-.92V2.734a1 1 0 01.609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.199l2.302 2.302L22.302 13l-2.302 1.19-2.302-2.302 2.302-2.38zM5.864 1.27L16.8 7.602l-2.302 2.302L5.864 1.27z" />
  </svg>
);

export function DownloadButton({ className = "" }: { className?: string }) {
  const { t } = useTranslate();
  const os = useOs();
  const [showQr, setShowQr] = useState(false);

  const isIos = os === "ios";
  const isAndroid = os === "android";

  function handleClick(e: React.MouseEvent) {
    if (!isIos) {
      e.preventDefault();
      setShowQr(true);
    }
  }

  return (
    <>
      <motion.a
        whileHover={{ scale: 1.03 }}
        whileTap={{ scale: 0.97 }}
        href={APP_STORE_URL}
        onClick={handleClick}
        className={`inline-flex items-center gap-2.5 bg-[var(--text-primary)] text-[var(--bg)] px-6 py-3 rounded-full text-sm font-medium transition-shadow hover:shadow-lg ${className}`}
      >
        {isAndroid ? <PlayIcon /> : <AppleIcon />}
        {isAndroid ? t("download_google_play") : t("download_app_store")}
      </motion.a>

      <AppStoreModal open={showQr} onClose={() => setShowQr(false)} />
    </>
  );
}
