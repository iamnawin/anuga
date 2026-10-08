// Notification texts in English, Telugu and Hindi (Telugu/Hindi need native review).
// Rendered by the dispatcher in the recipient's `profiles.preferred_language`.

export type Language = 'en' | 'te' | 'hi';
export interface Rendered { title: string; body: string }

const STATUS: Record<string, Record<Language, string>> = {
  scheduled: { en: 'Scheduled', te: 'షెడ్యూల్ అయింది', hi: 'निर्धारित' },
  companion_en_route: { en: 'Companion is on the way', te: 'సహచరులు దారిలో ఉన్నారు', hi: 'साथी रास्ते में हैं' },
  picked_up: { en: 'Picked up from home', te: 'ఇంటి నుండి పికప్ అయింది', hi: 'घर से पिकअप हो गया' },
  at_centre: { en: 'Reached the dialysis centre', te: 'డయాలసిస్ కేంద్రానికి చేరుకున్నారు', hi: 'डायलिसिस केंद्र पहुँच गए' },
  handed_over: { en: 'Handed over to centre staff', te: 'కేంద్ర సిబ్బందికి అప్పగించారు', hi: 'केंद्र स्टाफ़ को सौंप दिया' },
  session_done: { en: 'Session finished', te: 'సెషన్ పూర్తయింది', hi: 'सत्र पूरा हुआ' },
  returning: { en: 'On the way home', te: 'ఇంటికి వస్తున్నారు', hi: 'घर लौट रहे हैं' },
  dropped_home: { en: 'Dropped home safely', te: 'సురక్షితంగా ఇంటి వద్ద దించారు', hi: 'सुरक्षित घर छोड़ दिया' },
  completed: { en: 'Visit completed', te: 'సందర్శన పూర్తయింది', hi: 'विज़िट पूरी हुई' },
  cancelled: { en: 'Visit cancelled', te: 'సందర్శన రద్దు అయింది', hi: 'विज़िट रद्द' },
  no_show: { en: 'Patient was not available', te: 'రోగి అందుబాటులో లేరు', hi: 'मरीज़ उपलब्ध नहीं थे' },
  issue_reported: { en: 'Issue reported; our team is on it', te: 'సమస్య నివేదించబడింది; మా బృందం చూస్తోంది', hi: 'समस्या दर्ज; हमारी टीम देख रही है' },
};

const TEXT: Record<string, Record<Language, Rendered>> = {
  trip_update: {
    en: { title: 'Visit update', body: '' },
    te: { title: 'సందర్శన అప్‌డేట్', body: '' },
    hi: { title: 'विज़िट अपडेट', body: '' },
  },
  companion_assigned: {
    en: { title: 'Companions assigned', body: 'Your weekly schedule has a primary and a backup companion.' },
    te: { title: 'సహచరులు కేటాయించబడ్డారు', body: 'మీ వారపు షెడ్యూల్‌కు ప్రధాన మరియు బ్యాకప్ సహచరులు ఉన్నారు.' },
    hi: { title: 'साथी तय हुए', body: 'आपके साप्ताहिक शेड्यूल के लिए मुख्य और बैकअप साथी तय हैं।' },
  },
  companion_changed: {
    en: { title: 'Companion changed', body: 'A different companion will come for an upcoming visit.' },
    te: { title: 'సహచరులు మారారు', body: 'రాబోయే సందర్శనకు వేరే సహచరులు వస్తారు.' },
    hi: { title: 'साथी बदला गया', body: 'आने वाली विज़िट के लिए दूसरा साथी आएगा।' },
  },
  trip_assigned: {
    en: { title: 'New trip assigned', body: 'Open the app to see the trip.' },
    te: { title: 'కొత్త ప్రయాణం కేటాయించబడింది', body: 'ప్రయాణం చూడటానికి యాప్ తెరవండి.' },
    hi: { title: 'नई यात्रा सौंपी गई', body: 'यात्रा देखने के लिए ऐप खोलें।' },
  },
  schedule_assigned: {
    en: { title: 'Weekly schedule assigned', body: 'You have a new weekly patient schedule. Open the app for details.' },
    te: { title: 'వారపు షెడ్యూల్ కేటాయించబడింది', body: 'మీకు కొత్త వారపు షెడ్యూల్ ఉంది. వివరాలకు యాప్ తెరవండి.' },
    hi: { title: 'साप्ताहिक शेड्यूल सौंपा गया', body: 'आपको नया साप्ताहिक शेड्यूल मिला है। जानकारी के लिए ऐप खोलें।' },
  },
};

export function languageOf(value: string | null | undefined): Language {
  return value === 'te' || value === 'hi' ? value : 'en';
}

// Messages carry no patient health data: status words and the companion's note only.
export function render(template: string, payload: Record<string, unknown>, language: string | null): Rendered {
  const lang = languageOf(language);
  if (template === 'trip_status_changed') {
    const status = typeof payload.to_status === 'string' ? STATUS[payload.to_status]?.[lang] : undefined;
    const note = typeof payload.note === 'string' && payload.note.trim() ? payload.note.trim() : null;
    return {
      title: TEXT.trip_update[lang].title,
      body: [status ?? TEXT.trip_update[lang].title, note].filter(Boolean).join(' — '),
    };
  }
  const text = TEXT[template]?.[lang];
  if (!text) throw new UnknownTemplateError(template);
  return text;
}

export class UnknownTemplateError extends Error {
  constructor(template: string) {
    super(`unknown notification template: ${template}`);
    this.name = 'UnknownTemplateError';
  }
}

export const TEMPLATES = ['trip_status_changed', ...Object.keys(TEXT).filter((k) => k !== 'trip_update')];
export const STATUSES = Object.keys(STATUS);
