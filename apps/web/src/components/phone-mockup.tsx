import Image from "next/image";

type Props = {
  lightSrc: string;
  darkSrc: string;
  alt: string;
  className?: string;
  priority?: boolean;
};

export function PhoneMockup({
  lightSrc,
  darkSrc,
  alt,
  className = "",
  priority = false,
}: Props) {
  return (
    <div
      className={`relative rounded-[40px] border-[6px] border-[var(--text-primary)] overflow-hidden shadow-2xl ${className}`}
      style={{ aspectRatio: "9/19.5" }}
    >
      <Image
        src={lightSrc}
        alt={alt}
        fill
        className="object-cover block dark-hidden"
        sizes="(max-width: 640px) 240px, 300px"
        priority={priority}
        style={{ display: "var(--light-display, block)" }}
      />
      <Image
        src={darkSrc}
        alt={alt}
        fill
        className="object-cover"
        sizes="(max-width: 640px) 240px, 300px"
        priority={priority}
        style={{ display: "var(--dark-display, none)" }}
      />
    </div>
  );
}
