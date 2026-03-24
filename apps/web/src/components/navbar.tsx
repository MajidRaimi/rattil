"use client";

import { useTranslate } from "@tolgee/react";
import Image from "next/image";
import { useEffect, useState } from "react";
import { ThemeToggle } from "./theme-toggle";
import { LangToggle } from "./lang-toggle";

export function Navbar() {
  const { t } = useTranslate();
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <div className="fixed top-4 inset-x-0 z-50 px-4 flex justify-center">
      <nav
        className={`w-full max-w-5xl rounded-2xl border transition-all duration-500 border-[var(--text-primary)]/[0.06] bg-[var(--text-primary)]/[0.03] backdrop-blur-xl`}
      >
        <div className="relative flex items-center justify-between h-14 px-3">
          {/* Logo */}
          <a className="shrink-0 relative z-10" href="/">
            <img
              src="/images/logo.svg"
              alt="Rattil"
              width={38}
              height={38}
            />
          </a>

          {/* Desktop center nav */}
          <div className="hidden md:flex items-center gap-1 absolute inset-x-0 top-0 bottom-0 justify-center pointer-events-none z-0">
            <div className="flex items-center gap-1 pointer-events-auto">
              <a
                href="/#features"
                className="px-4 py-1.5 text-[13px] rounded-lg transition-colors text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
              >
                {t("nav_features")}
              </a>
              <a
                href="/#screenshots"
                className="px-4 py-1.5 text-[13px] rounded-lg transition-colors text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
              >
                {t("nav_screenshots")}
              </a>
              <a
                href="/#download"
                className="px-4 py-1.5 text-[13px] rounded-lg transition-colors text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
              >
                {t("nav_download")}
              </a>
            </div>
          </div>

          {/* Desktop right */}
          <div className="hidden md:flex items-center gap-2 shrink-0 relative z-10">
            <ThemeToggle />
            <LangToggle />
          </div>

          {/* Mobile hamburger */}
          <button
            className="md:hidden relative w-9 h-9 flex items-center justify-center p-2 cursor-pointer"
            aria-label="Menu"
            onClick={() => setOpen(!open)}
          >
            <span
              className={`absolute block w-5 h-px bg-[var(--text-primary)] transition-all duration-300 ${
                open ? "rotate-45 translate-y-0" : "-translate-y-[5px]"
              }`}
            />
            <span
              className={`absolute block w-5 h-px bg-[var(--text-primary)] transition-all duration-300 ${
                open ? "opacity-0" : ""
              }`}
            />
            <span
              className={`absolute block w-5 h-px bg-[var(--text-primary)] transition-all duration-300 ${
                open ? "-rotate-45 translate-y-0" : "translate-y-[5px]"
              }`}
            />
          </button>
        </div>

        {/* Mobile menu (expands inside nav) */}
        <div
          className={`md:hidden transition-all duration-300 overflow-hidden ${
            open ? "max-h-[400px]" : "max-h-0"
          }`}
        >
          <div className="px-5 py-4 space-y-1">
            <a
              href="/#features"
              onClick={() => setOpen(false)}
              className="block px-4 py-3 text-sm rounded-xl transition-colors text-[var(--text-primary)] hover:bg-[var(--text-primary)]/[0.06]"
            >
              {t("nav_features")}
            </a>
            <a
              href="/#screenshots"
              onClick={() => setOpen(false)}
              className="block px-4 py-3 text-sm rounded-xl transition-colors text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
            >
              {t("nav_screenshots")}
            </a>
            <a
              href="/#download"
              onClick={() => setOpen(false)}
              className="block px-4 py-3 text-sm rounded-xl transition-colors text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
            >
              {t("nav_download")}
            </a>
            <div className="flex items-center justify-center gap-2 mt-3 px-4">
              <LangToggle />
              <ThemeToggle />
            </div>
          </div>
        </div>
      </nav>
    </div>
  );
}
