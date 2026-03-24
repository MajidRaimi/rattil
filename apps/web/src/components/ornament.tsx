"use client";

import { motion } from "framer-motion";

export function Ornament({ className = "" }: { className?: string }) {
  return (
    <div className={`flex items-center justify-center gap-5 py-20 ${className}`}>
      <motion.div
        initial={{ scaleX: 0 }}
        whileInView={{ scaleX: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, delay: 0.15 }}
        className="w-24 sm:w-32 h-px bg-[var(--gold-active)]/25 origin-center"
      />
      <motion.div
        initial={{ scale: 0, rotate: 0 }}
        whileInView={{ scale: 1, rotate: 45 }}
        viewport={{ once: true }}
        transition={{ type: "spring", duration: 0.5, bounce: 0.2 }}
        className="w-2.5 h-2.5 bg-[var(--gold-active)]/40"
      />
      <motion.div
        initial={{ scaleX: 0 }}
        whileInView={{ scaleX: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 0.6, delay: 0.15 }}
        className="w-24 sm:w-32 h-px bg-[var(--gold-active)]/25 origin-center"
      />
    </div>
  );
}
