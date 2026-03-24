"use client";

import { useTranslate } from "@tolgee/react";
import { motion } from "framer-motion";
import { useEffect, useState } from "react";
import { ThemeToggle } from "./theme-toggle";
import { LangToggle } from "./lang-toggle";

const sections = ["features", "screenshots", "download"] as const;
const heroId = "hero";

function useActiveSection() {
  const [active, setActive] = useState("");

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            if (entry.target.id === heroId) {
              setActive("");
            } else {
              setActive(entry.target.id);
            }
          }
        }
      },
      { rootMargin: "-40% 0px -40% 0px" }
    );

    // Observe hero to clear active state
    const heroEl = document.querySelector("section");
    if (heroEl) {
      heroEl.id = heroId;
      observer.observe(heroEl);
    }

    for (const id of sections) {
      const el = document.getElementById(id);
      if (el) observer.observe(el);
    }

    return () => observer.disconnect();
  }, []);

  return active;
}

export function Navbar() {
  const { t } = useTranslate();
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const active = useActiveSection();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const navKeys: Record<string, string> = {
    features: "nav_features",
    screenshots: "nav_screenshots",
    download: "nav_download",
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.2 }}
      className="fixed top-4 inset-x-0 z-50 px-4 flex justify-center"
    >
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
            <div className="flex items-center gap-1 pointer-events-auto relative">
              {sections.map((id) => (
                <a
                  key={id}
                  href={`/#${id}`}
                  className={`relative px-4 py-1.5 text-[13px] rounded-lg transition-colors ${
                    active === id
                      ? "text-[var(--text-primary)]"
                      : "text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
                  }`}
                >
                  {active === id && (
                    <motion.span
                      layoutId="nav-active"
                      className="absolute inset-0 rounded-lg bg-[var(--text-primary)]/[0.06]"
                      transition={{ type: "spring", duration: 0.4, bounce: 0.15 }}
                    />
                  )}
                  <span className="relative">{t(navKeys[id])}</span>
                </a>
              ))}
            </div>
          </div>

          {/* Desktop right */}
          <div className="hidden md:flex items-center gap-2 shrink-0 relative z-10">
            <ThemeToggle />
            <LangToggle />
          </div>

          {/* Mobile right */}
          <div className="md:hidden flex items-center gap-1">
            <LangToggle />
            <button
              className="relative w-9 h-9 flex items-center justify-center p-2 cursor-pointer"
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
        </div>

        {/* Mobile menu (expands inside nav) */}
        <div
          className={`md:hidden transition-all duration-300 overflow-hidden ${
            open ? "max-h-[400px]" : "max-h-0"
          }`}
        >
          <div className="px-5 py-4 space-y-1">
            {sections.map((id) => (
              <a
                key={id}
                href={`/#${id}`}
                onClick={() => setOpen(false)}
                className={`block px-4 py-3 text-sm rounded-xl transition-colors ${
                  active === id
                    ? "text-[var(--text-primary)] bg-[var(--text-primary)]/[0.06]"
                    : "text-[var(--text-tertiary)] hover:text-[var(--text-primary)]"
                }`}
              >
                {t(navKeys[id])}
              </a>
            ))}
            <div className="flex items-center justify-center gap-2 mt-3 px-4">
              <LangToggle />
              <ThemeToggle />
            </div>
          </div>
        </div>
      </nav>
    </motion.div>
  );
}
