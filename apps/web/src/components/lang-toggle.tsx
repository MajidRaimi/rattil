"use client";

import { useTolgee } from "@tolgee/react";
import { setLanguage } from "@/tolgee/language";
import { trackEvent } from "@/lib/analytics";

export function LangToggle() {
  const tolgee = useTolgee(["language"]);
  const lang = tolgee.getLanguage();

  function toggle() {
    const newLang = lang === "ar" ? "en" : "ar";
    trackEvent("Language Toggle", { to: newLang });
    setLanguage(newLang);
  }

  return (
    <button
      onClick={toggle}
      className="flex items-center justify-center h-9 px-3 rounded-[var(--radius-sm)] text-sm font-medium transition-colors hover:bg-[var(--surface-variant)] cursor-pointer"
    >
      {lang === "ar" ? "EN" : "عربي"}
    </button>
  );
}
