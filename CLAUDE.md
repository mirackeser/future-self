# Future Self (Yarınki Ben) — Proje Talimatları

## Ürün Vizyonu

Build a mobile application for iOS and Android that helps users become the person they want to be in the future.

Bu bir görev yöneticisi, alışkanlık takipçisi veya prodüktivite aracı DEĞİL.
Bu bir "hayat ilerleme sistemi"dir.

Kullanıcı, karakterin kendisi olduğu bir RPG oynuyormuş gibi hissetmeli.
Her aksiyon, alışkanlık, hedef ve karar, geleceğin daha iyi bir versiyonunu inşa etmeye katkı sağlamalı.

Uygulama ilk 30 saniyede tamamen anlaşılır olmalı. Kullanıcı asla bunalmamalı.
Çoğu aksiyon doğrudan dashboard'dan yapılabilmeli.

Hedef kitle: 18-60 yaş, öğrenciler, profesyoneller, girişimciler, fitness meraklıları, kişisel gelişim kullanıcıları.

Tasarım: temiz, modern, sakin, minimal. Karmaşık navigasyon yapılarından kaçın.

## Ana Yapı

Üç sistem:
1. Future Self Engine (Ana Sistem)
2. Life Missions (Bucket List Sistemi)
3. Life Lessons (Topluluk Bilgeliği Sistemi)

Future Self Engine ana özelliktir. Diğer ikisi destekleyici sistemlerdir.

## Onboarding Akışı (max 60 saniye)

1. Karşılama ekranı — "Kim olmak istiyorsun?"
2. Hayat kategorileri seçimi: Sağlık, Kariyer, Finans, Öğrenme, İlişkiler, Maneviyat, Kişisel Gelişim
3. Mevcut durum girişi (örn: Kilo 85kg → Hedef 75kg, İngilizce A2 → Hedef C1)
4. Bildirim izni isteği
5. Hesap oluşturma: Apple Sign In, Google Sign In, Email
6. Dashboard açılır

## Dashboard (En Önemli Ekran)

- Header: kullanıcı adı, seviye, Future Self Score (örn: Level 12, 1250 XP)
- Bugünkü İlerleme Kartı: %78 ilerleme, 3 hedef ilerletildi, 14 günlük streak
- Future Self Status: AI üretimi özet, basit dil ("Geçen aydan daha hızlı ilerliyorsun")
- Top 3 Aktif Hedef: kart olarak, her biri ilerleme %, tahmini tamamlanma, streak, hızlı güncelleme butonu

## Life Missions

Bucket list sistemi. Sınırsız görev eklenebilir. Her görev: oluşturulma tarihi, ilerleme durumu, tahmini tamamlanma, kişisel notlar. Nazik hatırlatmalar (asla suçlayıcı dil kullanma).

## Life Lessons

Topluluk destekli bilgelik. Kullanıcılar anonim olarak ders/pişmanlık paylaşır. Beğen, kaydet, düşün (reflect) özellikleri. Sadece anonim paylaşım. Twitter benzeri anonim akış: kullanıcılar deneyim/pişmanlık paylaşır, herkes görebilir/kaydırabilir, beğenebilir, kaydedebilir, anonim yorum yapabilir. Küfür filtresi ve bildirme (report) mekanizması var ama otomatik gizleme yok (MVP).

## Future Self AI Coach

Hedef değerlendirme, motivasyon, ilerleme analizi, planlama önerileri, yansıma soruları sunar. Asla terapist ya da tıbbi uzman gibi davranmaz.

## Monetizasyon

Free: 3 aktif hedef, temel AI, Life Lessons, Life Missions
Premium: sınırsız hedef, gelişmiş AI Coach, detaylı raporlar, Future Self Forecasts, öncelikli widget'lar, gelişmiş analitik, bulut yedekleme

## Teknik Yığın

- Frontend: Flutter
- Backend: Firebase (Auth, Firestore, Cloud Functions, Messaging, Analytics, Crashlytics)
- AI Katmanı: OpenAI API veya eşdeğeri

## Kod Standartları

- Flutter, null-safety, Riverpod (state management)
- Klasör yapısı: feature-first (lib/features/dashboard, lib/features/onboarding,
