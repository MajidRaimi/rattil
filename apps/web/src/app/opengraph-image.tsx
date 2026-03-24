import { ImageResponse } from "next/og";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default async function Image() {
  const fontBold = await readFile(
    join(process.cwd(), "public/fonts/NeueFrutigerWorld-Bold.ttf")
  );
  const fontRegular = await readFile(
    join(process.cwd(), "public/fonts/NeueFrutigerWorld-Regular.ttf")
  );

  // Vertical bars for bottom-right pattern
  const bars = [
    { height: 180, opacity: 0.06 },
    { height: 260, opacity: 0.05 },
    { height: 340, opacity: 0.04 },
    { height: 220, opacity: 0.06 },
    { height: 300, opacity: 0.04 },
    { height: 160, opacity: 0.05 },
    { height: 280, opacity: 0.03 },
    { height: 200, opacity: 0.05 },
  ];

  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          backgroundColor: "#0D0D0D",
          padding: "60px 80px",
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Vertical bars pattern — bottom right */}
        <div
          style={{
            position: "absolute",
            right: 60,
            bottom: 0,
            display: "flex",
            alignItems: "flex-end",
            gap: 12,
          }}
        >
          {bars.map((bar, i) => (
            <div
              key={i}
              style={{
                width: 28,
                height: bar.height,
                borderRadius: 14,
                backgroundColor: `rgba(212, 168, 67, ${bar.opacity})`,
              }}
            />
          ))}
        </div>

        {/* Top — gold diamond + name */}
        <div style={{ display: "flex", alignItems: "center", gap: 14 }}>
          <div
            style={{
              width: 20,
              height: 20,
              backgroundColor: "#D4A843",
              transform: "rotate(45deg)",
            }}
          />
          <span
            style={{
              fontSize: 20,
              color: "#F5F5F5",
              fontFamily: "NeueFrutiger",
              fontWeight: 700,
              letterSpacing: 1,
            }}
          >
            Rattil
          </span>
        </div>

        {/* Headline */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            marginTop: "auto",
            marginBottom: 28,
          }}
        >
          <div
            style={{
              fontSize: 64,
              fontWeight: 700,
              color: "#F5F5F5",
              fontFamily: "NeueFrutiger",
              lineHeight: 1.15,
            }}
          >
            Read. Memorize.
          </div>
          <div
            style={{
              fontSize: 64,
              fontWeight: 700,
              color: "#D4A843",
              fontFamily: "NeueFrutiger",
              lineHeight: 1.15,
            }}
          >
            Recite beautifully.
          </div>
        </div>

        {/* Description */}
        <div
          style={{
            fontSize: 18,
            color: "#707070",
            fontFamily: "NeueFrutiger",
            fontWeight: 400,
            maxWidth: 460,
            lineHeight: 1.6,
          }}
        >
          Your companion for reading and memorizing the Holy Quran. Free, offline-first, no accounts, no tracking.
        </div>

        {/* Bottom — domain with gold accent */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: 10,
            marginTop: "auto",
          }}
        >
          <div
            style={{
              width: 28,
              height: 2,
              backgroundColor: "#D4A843",
              borderRadius: 1,
            }}
          />
          <span
            style={{
              fontSize: 14,
              color: "#5A5A5A",
              fontFamily: "NeueFrutiger",
              fontWeight: 400,
              letterSpacing: 0.5,
            }}
          >
            rattil.app
          </span>
        </div>
      </div>
    ),
    {
      ...size,
      fonts: [
        {
          name: "NeueFrutiger",
          data: fontBold,
          style: "normal",
          weight: 700,
        },
        {
          name: "NeueFrutiger",
          data: fontRegular,
          style: "normal",
          weight: 400,
        },
      ],
    }
  );
}
