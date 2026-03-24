import { ImageResponse } from "next/og";
import { readFile } from "node:fs/promises";
import { join } from "node:path";

export const size = { width: 64, height: 64 };
export const contentType = "image/png";

export default async function Icon() {
  const iconData = await readFile(
    join(process.cwd(), "public/images/app-icon.png")
  );
  const iconBase64 = `data:image/png;base64,${iconData.toString("base64")}`;

  return new ImageResponse(
    (
      <div
        style={{
          width: 64,
          height: 64,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "transparent",
        }}
      >
        <img
          src={iconBase64}
          width={64}
          height={64}
          style={{ borderRadius: 18 }}
        />
      </div>
    ),
    { ...size }
  );
}
