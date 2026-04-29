/// Default / offline fallback for known-languages (value => label).
/// At runtime, [getSpokenLanguages] replaces this in UI when the API returns options.
const Map<String, String> kLanguageOptions = {
  'english': 'English',
  'german': 'German',
  'french': 'French',
  'italian': 'Italian',
  'spanish': 'Spanish',
};
