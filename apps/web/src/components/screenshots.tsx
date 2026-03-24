"use client";

import { useTranslate } from "@tolgee/react";
import { motion, useScroll, useTransform } from "framer-motion";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";

const screens = [
  { light: "light_01_quran_reader.png", dark: "dark_01_quran_reader.png", key: "screenshot_quran" },
  { light: "light_04_bookmarks.png", dark: "dark_04_bookmarks.png", key: "screenshot_bookmarks" },
  { light: "light_03_search_results.png", dark: "dark_03_search_results.png", key: "screenshot_results" },
  { light: "light_06_progress.png", dark: "dark_06_progress.png", key: "screenshot_progress" },
  { light: "light_05_hifz.png", dark: "dark_05_hifz.png", key: "screenshot_hifz" },
  { light: "light_02_search.png", dark: "dark_02_search.png", key: "screenshot_search" },
  { light: "light_07_settings.png", dark: "dark_07_settings.png", key: "screenshot_settings" },
  { light: "light_08_quran_clean.png", dark: "dark_08_quran_clean.png", key: "screenshot_clean" },
];

export function Screenshots() {
  const { t } = useTranslate();
  const containerRef = useRef<HTMLDivElement>(null);
  const rowRef = useRef<HTMLDivElement>(null);
  const [endX, setEndX] = useState(-1800);

  useEffect(() => {
    function calc() {
      if (rowRef.current) {
        const rowWidth = rowRef.current.scrollWidth;
        const viewportWidth = window.innerWidth;
        setEndX(-(rowWidth - viewportWidth + 24));
      }
    }
    calc();
    window.addEventListener("resize", calc);
    return () => window.removeEventListener("resize", calc);
  }, []);

  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end end"],
  });

  const x = useTransform(scrollYProgress, [0, 1], [0, endX]);

  return (
    <section id="screenshots" dir="ltr" style={{ position: "relative" }}>
      <div ref={containerRef} className="relative" style={{ height: `${screens.length * 28}vh` }}>
        <div className="sticky top-20 h-[calc(100vh-6rem)] flex items-center overflow-hidden">
          <motion.div
            ref={rowRef}
            className="flex gap-5 ps-6"
            style={{ x }}
          >
            {screens.map((s) => (
              <div key={s.key} className="flex-shrink-0">
                <div
                  className="relative w-[200px] sm:w-[240px] rounded-[30px] sm:rounded-[36px] border-[4px] border-[var(--text-primary)]/8 overflow-hidden"
                  style={{ aspectRatio: "9/19.5" }}
                >
                  <Image
                    src={`/images/screenshots/${s.light}`}
                    alt={t(s.key)}
                    fill
                    className="object-cover"
                    sizes="240px"
                    style={{ display: "var(--light-display, block)" }}
                  />
                  <Image
                    src={`/images/screenshots/${s.dark}`}
                    alt={t(s.key)}
                    fill
                    className="object-cover"
                    sizes="240px"
                    style={{ display: "var(--dark-display, none)" }}
                  />
                </div>
              </div>
            ))}
          </motion.div>
        </div>
      </div>
    </section>
  );
}
