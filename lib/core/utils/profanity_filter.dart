/// Basit kelime listesi tabanlı küfür/hakaret filtresi.
///
/// %100 kapsamlı DEĞİLDİR: liste sınırlıdır ve Türkçe ekli çekimleri
/// (örn. kelimenin sonuna ek almış halleri) yakalayamayabilir. Bu
/// yüzden akışta ayrıca kullanıcı tabanlı "bildir" (report) mekanizması
/// vardır; filtre sadece ilk savunma hattıdır.
library;

/// Uygunsuz içerik tespit edildiğinde fırlatılan işaretleyici exception.
///
/// Kullanıcıya gösterilecek metin burada değil, UI katmanında
/// AppLocalizations üzerinden üretilir (l10n.profanityWarning) —
/// servis katmanının context'i/locale'i yoktur.
class ProfanityException implements Exception {
  const ProfanityException();

  @override
  String toString() => 'ProfanityException';
}

/// Türkçe + İngilizce yaygın küfür/hakaret kelimeleri (başlangıç seti).
const Set<String> _blocklist = {
  // Türkçe
  'salak',
  'aptal',
  'gerizekalı',
  'ahmak',
  'şerefsiz',
  'orospu',
  'piç',
  'sik',
  'sikik',
  'siktir',
  'amk',
  'aq',
  'göt',
  'yavşak',
  'dallama',
  'ibne',
  'pezevenk',
  'kahpe',
  'sürtük',
  'bok',
  // İngilizce
  'fuck',
  'fucking',
  'shit',
  'bullshit',
  'bitch',
  'asshole',
  'bastard',
  'dick',
  'cunt',
  'whore',
  'slut',
  'motherfucker',
  'wanker',
  'prick',
};

/// Harf olmayan her şey kelime sınırıdır (Türkçe karakterler dahil).
final RegExp _nonLetter = RegExp(r'[^a-zçğıiöşüâîû]+');

/// Metinde blokliste birebir eşleşen bir kelime var mı?
///
/// Kelime sınırlarına dikkat eder: metin token'lara bölünür ve tam
/// eşleşme aranır — "sınıf" ya da "sikke" gibi kelimeler alt-string
/// benzerliği yüzünden yakalanmaz.
bool containsProfanity(String text) {
  // 'İ'.toLowerCase() 'i' + birleşik nokta (U+0307) üretir; nokta
  // temizlenmezse token yanlış bölünür ve kelime kaçar.
  final normalized = text.toLowerCase().replaceAll('\u0307', '');
  final tokens = normalized.split(_nonLetter);
  return tokens.any(_blocklist.contains);
}
