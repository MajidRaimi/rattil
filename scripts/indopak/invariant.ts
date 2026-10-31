export class BundleBuildError extends Error {
  override name = "BundleBuildError";
}

export function invariant(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new BundleBuildError(message);
  }
}

export function defined<T>(value: T | undefined, message: string): T {
  invariant(value !== undefined, message);
  return value;
}
