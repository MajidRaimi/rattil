import { Navbar } from "@/components/navbar";
import { Footer } from "@/components/footer";
import { getTranslate } from "@/tolgee/server";

export const metadata = {
  title: "Privacy Policy",
  description: "Rattil privacy policy. Rattil does not collect, store, or transmit any personal data.",
  openGraph: {
    title: "Privacy Policy — Rattil",
    description: "Rattil does not collect, store, or transmit any personal data.",
    url: "https://rattil.app/privacy",
  },
  twitter: {
    card: "summary" as const,
    title: "Privacy Policy — Rattil",
    description: "Rattil does not collect, store, or transmit any personal data.",
  },
  alternates: {
    canonical: "https://rattil.app/privacy",
  },
};

export default async function PrivacyPage() {
  const t = await getTranslate();

  return (
    <>
      <Navbar />
      <main className="px-4 flex justify-center pt-32 pb-24"><div className="w-full max-w-5xl">
        <article className="prose-custom">
          <h1>{t("privacy_page_title")}</h1>
          <p className="meta">{t("legal_updated")}</p>

          <h2>{t("privacy_overview_title")}</h2>
          <p>{t("privacy_overview")}</p>

          <h2>{t("privacy_collection_title")}</h2>
          <p><strong>{t("privacy_collection")}</strong></p>

          <h2>{t("privacy_storage_title")}</h2>
          <p>{t("privacy_storage_intro")}</p>
          <ul>
            <li>{t("privacy_storage_1")}</li>
            <li>{t("privacy_storage_2")}</li>
            <li>{t("privacy_storage_3")}</li>
            <li>{t("privacy_storage_4")}</li>
            <li>{t("privacy_storage_5")}</li>
          </ul>
          <p>{t("privacy_storage_outro")}</p>

          <h2>{t("privacy_third_party_title")}</h2>
          <p>{t("privacy_third_party_intro")}</p>
          <ul>
            <li><strong>{t("privacy_third_party_1")}</strong></li>
            <li><strong>{t("privacy_third_party_2")}</strong></li>
          </ul>
          <p>{t("privacy_third_party_outro")}</p>

          <h2>{t("privacy_analytics_title")}</h2>
          <p>{t("privacy_analytics")}</p>

          <h2>{t("privacy_ads_title")}</h2>
          <p>{t("privacy_ads")}</p>

          <h2>{t("privacy_children_title")}</h2>
          <p>{t("privacy_children")}</p>

          <h2>{t("privacy_changes_title")}</h2>
          <p>{t("privacy_changes")}</p>

          <h2>{t("privacy_contact_title")}</h2>
          <p>
            <a
              href="https://github.com/MajidRaimi/rattil/issues"
              target="_blank"
              rel="noopener noreferrer"
            >
              github.com/MajidRaimi/rattil
            </a>
            {" · "}
            <a href="mailto:majidsraimi@gmail.com">
              majidsraimi@gmail.com
            </a>
          </p>
        </article>
      </div></main>
      <Footer />
    </>
  );
}
