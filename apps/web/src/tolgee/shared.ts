import { Tolgee, FormatSimple } from '@tolgee/web';

export const ALL_LANGUAGES = ['en', 'ar'];
export const DEFAULT_LANGUAGE = 'ar';

export function TolgeeBase() {
  return Tolgee()
    .use(FormatSimple())
    .updateDefaults({
      staticData: {
        en: () => import('../../messages/en.json'),
        ar: () => import('../../messages/ar.json'),
      },
    });
}
