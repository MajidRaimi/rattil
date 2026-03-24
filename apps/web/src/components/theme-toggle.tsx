"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { Moon, Sun } from "lucide-react";
import { flushSync } from "react-dom";

export function ThemeToggle() {
  const [isDark, setIsDark] = useState(false);
  const buttonRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const el = document.documentElement;
    const theme = el.getAttribute("data-theme");
    if (theme === "dark") {
      setIsDark(true);
    } else if (theme === "light") {
      setIsDark(false);
    } else {
      setIsDark(window.matchMedia("(prefers-color-scheme: dark)").matches);
    }
  }, []);

  const toggleTheme = useCallback(() => {
    const button = buttonRef.current;
    if (!button) return;

    const { top, left, width, height } = button.getBoundingClientRect();
    const x = left + width / 2;
    const y = top + height / 2;
    const viewportWidth = window.visualViewport?.width ?? window.innerWidth;
    const viewportHeight = window.visualViewport?.height ?? window.innerHeight;
    const maxRadius = Math.hypot(
      Math.max(x, viewportWidth - x),
      Math.max(y, viewportHeight - y)
    );

    const applyTheme = () => {
      const newTheme = !isDark;
      setIsDark(newTheme);
      document.documentElement.setAttribute(
        "data-theme",
        newTheme ? "dark" : "light"
      );
      document.cookie = `theme=${newTheme ? "dark" : "light"};path=/;max-age=${60 * 60 * 24 * 365}`;
    };

    if (typeof document.startViewTransition !== "function") {
      applyTheme();
      return;
    }

    const transition = document.startViewTransition(() => {
      flushSync(applyTheme);
    });

    const ready = transition?.ready;
    if (ready && typeof ready.then === "function") {
      ready.then(() => {
        document.documentElement.animate(
          {
            clipPath: [
              `circle(0px at ${x}px ${y}px)`,
              `circle(${maxRadius}px at ${x}px ${y}px)`,
            ],
          },
          {
            duration: 400,
            easing: "ease-in-out",
            pseudoElement: "::view-transition-new(root)",
          }
        );
      });
    }
  }, [isDark]);

  return (
    <button
      type="button"
      ref={buttonRef}
      onClick={toggleTheme}
      aria-label="Toggle theme"
      className="flex items-center justify-center w-8 h-8 rounded-lg text-[var(--text-tertiary)] hover:text-[var(--text-primary)] hover:bg-[var(--text-primary)]/[0.06] transition-colors cursor-pointer"
    >
      {isDark ? <Sun size={18} /> : <Moon size={18} />}
    </button>
  );
}
