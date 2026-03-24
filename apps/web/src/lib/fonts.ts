import localFont from "next/font/local";

export const neueFrutiger = localFont({
  src: [
    {
      path: "../../public/fonts/NeueFrutigerWorld-Regular.ttf",
      weight: "400",
      style: "normal",
    },
    {
      path: "../../public/fonts/NeueFrutigerWorld-Medium.ttf",
      weight: "500",
      style: "normal",
    },
    {
      path: "../../public/fonts/NeueFrutigerWorld-Bold.ttf",
      weight: "700",
      style: "normal",
    },
  ],
  variable: "--font-neue-frutiger",
  display: "swap",
});

export const uthmanicHafs = localFont({
  src: "../../public/fonts/UthmanicHafs.ttf",
  variable: "--font-uthmanic",
  display: "swap",
});
