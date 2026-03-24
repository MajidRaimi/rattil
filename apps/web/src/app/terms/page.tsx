import { Navbar } from "@/components/navbar";
import { Footer } from "@/components/footer";
import { getTranslate } from "@/tolgee/server";

export const metadata = {
  title: "Terms & Conditions",
  description: "Rattil terms and conditions. Free to use, open source, no subscriptions.",
  openGraph: {
    title: "Terms & Conditions — Rattil",
    description: "Rattil terms and conditions. Free to use, open source, no subscriptions.",
    url: "https://rattil.app/terms",
  },
  twitter: {
    card: "summary" as const,
    title: "Terms & Conditions — Rattil",
    description: "Rattil terms and conditions. Free to use, open source, no subscriptions.",
  },
  alternates: {
    canonical: "https://rattil.app/terms",
  },
};

export default async function TermsPage() {
  const t = await getTranslate();

  return (
    <>
      <Navbar />
      <main className="px-4 flex justify-center pt-32 pb-24"><div className="w-full max-w-5xl">
        <article className="prose-custom">
          <h1>{t("terms_page_title")}</h1>
          <p className="meta">{t("legal_updated")}</p>

          <h2>{t("terms_acceptance_title")}</h2>
          <p>{t("terms_acceptance")}</p>

          <h2>{t("terms_license_title")}</h2>
          <p>{t("terms_license")}</p>

          <h2>{t("terms_content_title")}</h2>
          <p>{t("terms_content")}</p>

          <h2>{t("terms_availability_title")}</h2>
          <p>{t("terms_availability")}</p>

          <h2>{t("terms_liability_title")}</h2>
          <p>{t("terms_liability")}</p>

          <h2>{t("terms_modifications_title")}</h2>
          <p>{t("terms_modifications")}</p>

          <h2>{t("terms_contact_title")}</h2>
          <p>
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
