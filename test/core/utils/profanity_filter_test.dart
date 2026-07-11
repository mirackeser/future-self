import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/utils/profanity_filter.dart';

void main() {
  group('containsProfanity — yakalaması gerekenler', () {
    test('Türkçe küfür yakalanır', () {
      expect(containsProfanity('siktir git buradan'), isTrue);
      expect(containsProfanity('ne salak adammış'), isTrue);
    });

    test('büyük/küçük harf duyarsız (Türkçe İ dahil)', () {
      expect(containsProfanity('SALAK mısın sen'), isTrue);
      expect(containsProfanity('SİKTİR'), isTrue);
      expect(containsProfanity('Aptal'), isTrue);
    });

    test('İngilizce küfür yakalanır', () {
      expect(containsProfanity('this is complete bullshit'), isTrue);
      expect(containsProfanity('What the FUCK'), isTrue);
    });

    test('noktalama bitişikken de yakalanır', () {
      expect(containsProfanity('salak!'), isTrue);
      expect(containsProfanity('(aptal)'), isTrue);
      expect(containsProfanity('bok...gibi'), isTrue);
    });
  });

  group('containsProfanity — yanlış pozitif vermemesi gerekenler', () {
    test('temiz metin geçer', () {
      expect(
        containsProfanity(
          'Keşke 20\'lerimde daha çok kitap okusaydım, pişmanım.',
        ),
        isFalse,
      );
    });

    test('alt-string benzerliği yakalanmaz (kelime sınırı)', () {
      // "sınıf" hiçbir blok kelimeyi içermiyor ama benzer harf dizileri
      // barındıran kelimeler token bazında ayrışmalı:
      expect(containsProfanity('Bu sınıfta çok şey öğrendim'), isFalse);
      // "sikke" ≠ "sik" (tam eşleşme aranır)
      expect(containsProfanity('Eski sikke koleksiyonuna başladım'), isFalse);
      // "shiitake" içinde "shit" alt-string'i var ama token farklı
      expect(containsProfanity('shiitake mantarı denedim'), isFalse);
      // "bokser" ≠ "bok"
      expect(containsProfanity('bokser köpeğimle koşuyorum'), isFalse);
    });

    test('boş metin geçer', () {
      expect(containsProfanity(''), isFalse);
    });
  });
}
