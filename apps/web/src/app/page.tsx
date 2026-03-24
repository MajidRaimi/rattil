import { Navbar } from "@/components/navbar";
import { Hero } from "@/components/hero";
import { FeaturesGrid } from "@/components/features-grid";
import { Screenshots } from "@/components/screenshots";
import { PrivacySection } from "@/components/privacy-section";
import { DownloadCta } from "@/components/download-cta";
import { ContactSection } from "@/components/contact-section";
import { Footer } from "@/components/footer";
import { Ornament } from "@/components/ornament";

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      name: "Rattil",
      alternateName: "رتّل",
      url: "https://rattil.app",
    },
    {
      "@type": "SoftwareApplication",
      name: "Rattil",
      alternateName: "رتّل",
      applicationCategory: "LifestyleApplication",
      operatingSystem: "iOS",
      url: "https://rattil.app",
      description:
        "Your companion for reading and memorizing the Holy Quran. Free, offline-first, no accounts, no tracking.",
      offers: {
        "@type": "Offer",
        price: "0",
        priceCurrency: "USD",
      },
      author: {
        "@type": "Person",
        name: "Majid Raimi",
      },
      aggregateRating: undefined,
    },
  ],
};

export default function Home() {
  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <Navbar />
      <Hero />
      <FeaturesGrid />
      <Ornament />
      <Screenshots />
      <Ornament />
      <PrivacySection />
      <Ornament />
      <DownloadCta />
      <Ornament />
      <ContactSection />
      <Footer />
    </>
  );
}
