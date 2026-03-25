import type { Metadata } from "next";
import "./globals.css";
import { neueFrutiger, uthmanicHafs } from "@/lib/fonts";
import { TolgeeNextProvider } from "@/tolgee/client";
import { getTolgee, getTranslate } from "@/tolgee/server";
import { getLanguage } from "@/tolgee/language";
import { cookies } from "next/headers";
import { SmoothScroll } from "@/components/smooth-scroll";
import { AnchorScroll } from "@/components/anchor-scroll";

export async function generateMetadata(): Promise<Metadata> {
  const locale = await getLanguage();
  const t = await getTranslate();

  const title = locale === "ar" ? "رتّل — Rattil" : "Rattil — رتّل";
  const description = t("hero_tagline");

  return {
    metadataBase: new URL("https://rattil.app"),
    title: {
      default: title,
      template: locale === "ar" ? "%s — رتّل" : "%s — Rattil",
    },
    description,
    keywords: [
      "Quran",
      "القرآن",
      "Rattil",
      "رتّل",
      "Hifz",
      "حفظ",
      "Quran reader",
      "قارئ القرآن",
      "Wird",
      "ورد",
      "Tikrar",
      "تكرار",
      "memorization",
      "حفظ القرآن",
      "Islamic app",
      "تطبيق إسلامي",
      "offline Quran",
      "Quran app",
      "free Quran app",
      "Tafseer",
      "تفسير",
    ],
    authors: [{ name: "Majid Raimi" }],
    creator: "Majid Raimi",
    openGraph: {
      type: "website",
      locale: locale === "ar" ? "ar_SA" : "en_US",
      siteName: "Rattil",
      title,
      description,
      url: "https://rattil.app",
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
    alternates: {
      canonical: "https://rattil.app",
      languages: {
        ar: "https://rattil.app",
        en: "https://rattil.app",
      },
    },
    robots: {
      index: true,
      follow: true,
      googleBot: {
        index: true,
        follow: true,
        "max-video-preview": -1,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },
    manifest: "/manifest.webmanifest",
  };
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const locale = await getLanguage();
  const tolgee = await getTolgee();
  const staticData = await tolgee.loadRequired();

  const cookieStore = await cookies();
  const themeCookie = cookieStore.get("theme")?.value;
  const dataTheme =
    themeCookie === "light" || themeCookie === "dark"
      ? themeCookie
      : undefined;

  return (
    <html
      lang={locale}
      dir={locale === "ar" ? "rtl" : "ltr"}
      className={`${neueFrutiger.variable} ${uthmanicHafs.variable} h-full`}
      {...(dataTheme ? { "data-theme": dataTheme } : {})}
    >
      <head>
          <script defer data-domain="rattil.app" src="https://analytics.rattil.app/js/script.tagged-events.outbound-links.pageview-props.js" data-platform="web" />
        </head>
      <body className="min-h-full flex flex-col antialiased">
        <TolgeeNextProvider language={locale} staticData={staticData}>
          <SmoothScroll />
          <AnchorScroll />
          {children}
        </TolgeeNextProvider>
      </body>
    </html>
  );
}
