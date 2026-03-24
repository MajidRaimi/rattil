import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Rattil — رتّل",
    short_name: "Rattil",
    description:
      "Your companion for reading and memorizing the Holy Quran",
    start_url: "/",
    display: "standalone",
    background_color: "#F7F5F0",
    theme_color: "#D4A843",
    icons: [
      {
        src: "/images/app-icon.png",
        sizes: "512x512",
        type: "image/png",
      },
    ],
  };
}
