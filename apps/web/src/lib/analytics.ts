export function trackEvent(name: string, props?: Record<string, string>) {
  if (typeof window !== "undefined" && (window as any).plausible) {
    (window as any).plausible(name, props ? { props } : undefined);
  }
}
