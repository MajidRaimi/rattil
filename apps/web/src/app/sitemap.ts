import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    {
      url: "https://rattil.app",
      lastModified: new Date(),
      changeFrequency: "weekly",
      priority: 1,
    },
    {
      url: "https://rattil.app/privacy",
      lastModified: new Date("2026-03-19"),
      changeFrequency: "yearly",
      priority: 0.3,
    },
    {
      url: "https://rattil.app/terms",
      lastModified: new Date("2026-03-19"),
      changeFrequency: "yearly",
      priority: 0.3,
    },
  ];
}
