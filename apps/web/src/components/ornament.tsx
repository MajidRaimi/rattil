"use client";

import { motion } from "framer-motion";

export function Ornament({ className = "" }: { className?: string }) {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      whileInView={{ opacity: 1 }}
      viewport={{ once: true }}
      transition={{ duration: 0.8 }}
      className={`flex items-center justify-center gap-5 py-20 ${className}`}
    >
      <div className="w-24 sm:w-32 h-px bg-[var(--gold-active)]/25" />
      <div className="w-2.5 h-2.5 rotate-45 bg-[var(--gold-active)]/40" />
      <div className="w-24 sm:w-32 h-px bg-[var(--gold-active)]/25" />
    </motion.div>
  );
}
