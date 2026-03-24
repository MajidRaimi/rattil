"use client";

import { useEffect } from "react";
import { usePathname } from "next/navigation";

export function AnchorScroll() {
  const pathname = usePathname();

  // Handle hash on page load (e.g. navigating to /#features from another page)
  useEffect(() => {
    const hash = window.location.hash.slice(1);
    if (!hash) return;
    // Small delay to let the page render
    const timeout = setTimeout(() => {
      const el = document.getElementById(hash);
      if (el) el.scrollIntoView({ behavior: "smooth", block: "center" });
    }, 300);
    return () => clearTimeout(timeout);
  }, [pathname]);

  // Handle click on anchor links
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      const target = e.target as HTMLElement;
      const anchor = target.closest("a") as HTMLAnchorElement | null;
      if (!anchor) return;

      const href = anchor.getAttribute("href");
      if (!href) return;

      // Handle /#section links when already on home page
      if (href.startsWith("/#") && pathname === "/") {
        e.preventDefault();
        const id = href.slice(2);
        const el = document.getElementById(id);
        if (el) el.scrollIntoView({ behavior: "smooth", block: "center" });
        return;
      }

      // Handle plain #section links
      if (href.startsWith("#")) {
        const id = href.slice(1);
        const el = document.getElementById(id);
        if (!el) return;
        e.preventDefault();
        el.scrollIntoView({ behavior: "smooth", block: "center" });
      }
    }

    document.addEventListener("click", handleClick);
    return () => document.removeEventListener("click", handleClick);
  }, [pathname]);

  return null;
}
