"use client";

import React, { useRef, useState, useCallback, useEffect } from "react";

interface BorderGlowProps {
  children: React.ReactNode;
  edgeSensitivity?: number;
  glowColor?: string;
  backgroundColor?: string;
  borderRadius?: number;
  glowRadius?: number;
  glowIntensity?: number;
  coneSpread?: number;
  animated?: boolean;
  colors?: string[];
  className?: string;
}

const BorderGlow: React.FC<BorderGlowProps> = ({
  children,
  edgeSensitivity = 30,
  glowColor = "212 168 67",
  backgroundColor,
  borderRadius = 16,
  glowRadius = 40,
  glowIntensity = 1,
  coneSpread = 25,
  animated = false,
  colors = ["#D4A843", "#E8C97A", "#8B7335"],
  className = "",
}) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [glowStyle, setGlowStyle] = useState<React.CSSProperties>({});
  const [isNearEdge, setIsNearEdge] = useState(false);
  const animFrameRef = useRef<number>(0);

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (!containerRef.current) return;

      cancelAnimationFrame(animFrameRef.current);
      animFrameRef.current = requestAnimationFrame(() => {
        const rect = containerRef.current!.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        const w = rect.width;
        const h = rect.height;

        const distToEdge = Math.min(x, y, w - x, h - y);
        const near = distToEdge < edgeSensitivity;
        setIsNearEdge(near);

        if (!near) return;

        const angle =
          Math.atan2(y - h / 2, x - w / 2) * (180 / Math.PI) + 90;

        const gradientStops = colors
          .map((color, i) => {
            const offset = (i / (colors.length - 1)) * coneSpread * 2;
            return `${color} ${angle - coneSpread + offset}deg`;
          })
          .join(", ");

        setGlowStyle({
          background: `conic-gradient(from 0deg at ${x}px ${y}px, transparent ${angle - coneSpread}deg, ${gradientStops}, transparent ${angle + coneSpread}deg)`,
          opacity: glowIntensity * (1 - distToEdge / edgeSensitivity),
          filter: `blur(${glowRadius}px)`,
        });
      });
    },
    [edgeSensitivity, glowRadius, glowIntensity, coneSpread, colors]
  );

  const handleMouseLeave = useCallback(() => {
    setIsNearEdge(false);
  }, []);

  useEffect(() => {
    const el = containerRef.current;
    if (!el) return;
    el.addEventListener("mousemove", handleMouseMove);
    el.addEventListener("mouseleave", handleMouseLeave);
    return () => {
      el.removeEventListener("mousemove", handleMouseMove);
      el.removeEventListener("mouseleave", handleMouseLeave);
      cancelAnimationFrame(animFrameRef.current);
    };
  }, [handleMouseMove, handleMouseLeave]);

  return (
    <div
      ref={containerRef}
      className={`relative overflow-hidden ${className}`}
      style={{ borderRadius }}
    >
      {/* Glow layer */}
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-300"
        style={{
          ...glowStyle,
          opacity: isNearEdge ? glowStyle.opacity : 0,
          borderRadius,
        }}
      />
      {/* Content with inset background */}
      <div
        className="relative"
        style={{
          borderRadius: borderRadius - 1,
          margin: 1,
          backgroundColor: backgroundColor || "var(--surface)",
        }}
      >
        {children}
      </div>
    </div>
  );
};

export default BorderGlow;
