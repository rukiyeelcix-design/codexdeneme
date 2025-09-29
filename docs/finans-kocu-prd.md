# Finans Koçu Uygulaması — Tam Ürün Gereksinim Dokümanı (PRD) ve UX Akışları (TR)

> Bu doküman; tüm özellikler, sayfa düğmeleri, düğme konumları, davranışlar, veri modelleri, izinler, paket kısıtları, AI entegrasyonu, OCR/import akışları, çoklu dil/para birimi, güvenlik/KVKK, admin paneli ve test planlarını kapsar. Metnin sonunda **tam İngilizce versiyon** yer alır.

---

## 0) Üst Düzey Vizyon

* **Hedef**: Kişisel finansı uçtan uca yöneten, AI destekli, çok dilli ve çok para birimli, offline-first/online-sync hibrit bir mobil uygulama.
* **Kitle**: Bireyler, aileler ve küçük işletmeler.
* **Başarı Kriterleri**: 30 günlük deneme → %35+ aktif kalma, 90 gün içinde Pro/Premium’a %12+ dönüşüm, faturalı/ödeme hatırlatma tıklama oranı %40+, OCR doğruluk %90+ (alan başına).

---

## 1) Navigasyon, Yerleşim ve Global Bileşenler

### 1.1 Alt Çubuk (Reorderable Bottom Nav) — **6 ikon + merkezde Hızlı Ekle**

* **İkonlar (varsayılan sıra)**:

  1. **Kartlar & Hesaplar**
  2. **Gelir**
  3. **Dashboard (Ana Sayfa)**
  4. **Gider**
  5. **Analiz**
  6. **Net Kâr/Zarar**
* **Merkezde Floating Action Button (FAB)**: **Hızlı Ekle** (Gelir/Gider/Transfer/Not/Fatura fotoğrafı).
* **Davranışlar**:

  * Uzun basılı tut → ikonlar tek tek titreşir → sürükle-bırak ile **yer değiştir**. Tercih **yerel hafızaya** kaydedilir; giriş yaptıysa buluta da senkronlanır.
  * Scroll’da alt çubuk %50 saydamlaşır; dokununca geri görünür.

### 1.2 Üst Sol Bölge: **Izgara (Yan Menü)** + **AI İkonu**

* **Izgara (dört çizgi)**: Yandan açılır **Menü**: Tüm sayfalar + Ayarlar + Yardım/Rehber + Tema/Hızlı Değiştir.
* **AI İkonu**: Her sayfada görünür. Dokununca **küçük asistan penceresi** (popover) açılır: “Merhaba, size nasıl yardımcı olabilirim?”. **Popover** genişletilince **tam ekran AI sayfasına** gider.

### 1.3 Sağ Üst: **Profil Paneli Toggle**

* Dokununca ekran sola kayarak **Profil Paneli** açılır.
* Panel başı: **Sol üst: Giriş Yap**, **Sağ üst: Kayıt Ol** (karşılıklı konum). Giriş yapmadan da uygulama kullanılabilir.

### 1.4 Global Durum Göstergeleri

* **Senkronizasyon Durumu** (bulut simgesi), **Çevrimdışı Mod**, **Son Yedekleme Zamanı**, **Deneme Süresi Kalan Gün**.

---

## 2) Sayfalar ve Düğme Haritaları (Buton, Konum, İşlev)

### 2.1 Dashboard (Ana Sayfa)

* **Bileşenler**:

  * **Toplam Borç / Ödenen / Bekleyen** mini kartları (ödendi işaretlemeleriyle gerçek zamanlı güncellenir).
  * **Hızlı Özet**: Bu ay gelir, gider, net; önceki ay ile % kıyas.
  * **Hızlı Kısayollar**: Gelir Ekle, Gider Ekle, Fatura Tara (kamera), Transfer, Kategori Yönet.
  * **Bildirim kutusu**: Yaklaşan son ödeme tarihleri (kart, fatura, abonelik), AI önerileri.
* **Düğmeler**:

  * **Hızlı Ekle FAB** (merkez): modal açar.
  * **Ödendi/Ödenmedi Toggle**: Her kart/hareket satırında; değişiklik anlık tüm toplamları günceller.
  * **Zaman Filtresi**: 1–3–9 ay, 1–2 yıl, Özel Aralık (çift takvim). Seçim **Analiz** ile paylaşımlı global filtredir.

### 2.2 Kartlar & Hesaplar

* **Alanlar**: Hesap/Kart adı, tür (Kredi Kartı/Banka/Nakit/Cüzdan), para birimi, kart limiti, **Hesap Kesim Günü**, **Son Ödeme Günü**.
* **Davranış**:

  * İşlem eklemede **alışveriş tarihi** kesim gününden **önce** ise **ekstre dönemi = aynı ay/yıl**; **sonra** ise **gelecek ay**. Bu hesaplanmış **Ekstre Ayı/Yılı** her işlem satırında görünür.
  * Kart/harekette **Ödendi** işaretlenince **Dashboard Toplamları** (Toplam Borç/Ödenen/Bekleyen) otomatik güncellenir.
* **Düğmeler**: Hesap/Kart **Ekle**, **Düzenle**, **Sil** (yumuşak silme/geri alma); **Toplu Ödendi**; **İçeri Aktar** (şablon), **Dışa Aktar** (gizli watermark ile).

### 2.3 Gelir

* **Sütunlar**: Tarih, Açıklama, **Gelir Türü** (Ana/Alt kategori), Tutar, Para Birimi, Not, Kaynak (maaş, freelance vb.).
* **Hızlı Giriş Tekrar Sembolleri**: Alan üzerinde **tekrar** ikonu → açık yeşil olduğunda yeni girişlerde son değerler otomatik dolar; iki kez dokunarak sıfırlanır.
* **Düğmeler**: **Ekle** (aç/kapat davranışlı), **İçeri Aktar**, **QR/Kamera**, **Geri Al/İleri Al** (oturum süresince).

### 2.4 Gider

* **Sütunlar**: Tarih, Açıklama, Not, Tutar, Para Birimi, **Taksit Sayısı**, **Ekstre Ay/Yıl**, **İlk/ Son Taksit Ayı**, Ana/Alt Kategori, Kart/Hesap, Durum (Ödendi/Ödenmedi).
* **Gelecek Ödeme Matrisi**: 3/6/9/12 ay veya manuel ay sayısı; her ay için ödenecek tutar sütunlarda görünür.
* **Düğmeler**: **Ekle** (aç/kapat), **Fatura Tara** (kamera/galeri/dosya), **İçeri Aktar**, **Geri Al/İleri Al**.

### 2.5 Analiz

* **İlk Grafik (zorunlu)**: **Hesap/Kart Bazlı Harcama** + **Ödendi/Ödenmedi** filtreleri. Kart karşısında **Ödendi** işaretlenirse tüm **Toplam/Özet** grafikleri anında güncellenir.
* **Grafik Tipleri**: Pasta, Sütun, Çizgi, Alan, Yığılmış Sütun. En az 5 seçenek modalında değiştirilebilir.
* **İkili/Paketsel Grafikler**: Üst pasta **Ana kategori**; ikinci pasta **Alt kategoriler**.
* **Analiz Tabloları** (zaman filtresi ortak):

  1. **Aylık Harcama Özeti** (Her pakette)
  2. **Gelir–Gider Karşılaştırma** (Her pakette)
  3. **Kategori Bazlı Harcama** (Standart/Pro ve üstü)
  4. **Günlük/Haftalık Harcama** (Orta/Pro ve üstü)
  5. **Bütçe Takip** (Tüm paketler)
  6. **Harcama Alışkanlıkları** (Premium)
  7. **Borç & Ödeme Takip** (Premium)
  8. **Yıllık Finans Raporu** (Premium)
* **Düğmeler**: **Zaman Seçici**, **Grafik Tipi**, **CSV/PNG Dışa Aktar** (watermark), **AI Analiz Önerileri** (buton seti: ücretsizde hazır sorular).

### 2.6 Net Kâr/Zarar

* Ay/özel aralıkta **toplam gelir – toplam gider = net**. Trend çizgisi, sapma uyarıları.
* **Düğmeler**: **Aralık**, **Detayına Git** (ilgili sayfaya derin link), **AI Tasarruf Öner**.

### 2.7 Listeler & Kategoriler (Hızlı Erişim / Solda İlk)

* **Yapı**: 1. satır **Ana Kategori** (gri ipucu), altında 2./3./… satırlar **Alt Kategoriler**. Her Ana kategori etrafı yumuşak köşeli kart; altlar çizgili bölge altında.
* **Etkileşim**: Sürükle-bırak; **+ Alt Kutu Ekle** ile sınırsız ekleme; **Toplu Yeniden Adlandır**; Paket taşıma (ana ile altları birlikte).
* **AI Önerileri**: Kullanıcıya **kayıtlı kategori setleri** ve **otomatik/kişiselleştirilmiş setler**; tek tıkla **Aktif/Pasif**. 5+ öneri alternatifi.

---

## 3) AI Asistanı (Ücretsiz/Ücretli Davranışlar)

### 3.1 Ücretsiz

* **Popover içinde hızlı butonlar**: “Bu ay fazla harcadığım 3 kategori”, “Önümüzdeki 30 günde en riskli ödemelerim”, “Bütçe aşımlarını göster”, “Tasarruf hedefi öner”.
* **Veri okuma izni**: Yerel veri + kullanıcı izin verirse bulut senkronu.

### 3.2 Ücretli (Pro/Premium)

* **Tam Ekran Sohbet**: Serbest komut; “Yeni kategori şablonu oluştur”, “Son 6 ay trendini çıkar”, “Benzer işlemleri birleştir”.
* **Eylem Yetkileri**: Kategori oluşturma/düzenleme, toplu etiketleme, otomatik kural üretme (örn. “Açıklamada ‘market’ geçerse Alışveriş > Market”).
* **Model Seçici**: “Gemini / Grok / OpenAI …” (Ayarlarda **API Ekle** → **Üyelik Paketleri** akışı). Seçilen model selam verir: “Merhaba, ben {Model}. Senin için ne yapabilirim?”

### 3.3 Ekstra Yetenekler

* **Arka Plan Bilgi Toplama** (kullanıcı onayıyla): Abonelik/kampanya araştırması, kategori öneri zenginleştirme.
* **Gizlilik**: KVKK/GDPR uyarıları; kapatılabilir telemetri.

---

## 4) OCR, Belge ve Veri İçe Aktarma Akışları

### 4.1 Desteklenen Kaynaklar

* **Kamera** (fatura/fiş), **Galeri**, **PDF/CSV/Excel/Word**.

### 4.2 İşleyiş

1. Kullanıcı **tara/yükle** yapar → ön izleme.
2. **AI Çıkarım**: Tarih, tutar, para birimi, açıklama, taksit, ekstre ay/yıl, kart/hesap, kategori ana/alt, not.
3. **5+ Akıllı Tahmin**: Kategori, kart/hesap, taksit planı için çoklu öneri kartları. Sürükle-bırak ile birleştir/ince ayar.
4. **Onay Ekranı**: Hedef **Gelir** mi **Gider** mi? Alanlar düzenlenebilir. “Tüm satırlara uygula” seçenekleri.
5. **Kaydet**: **Geri Al/İleri Al** oturumda etkin; uygulama kapanınca temizlenir.

### 4.3 Doğruluk ve Hatalar

* Alan bazlı güven puanı; düşükse kullanıcıya vurgulu alan.
* Dil algılama ve çok dilli OCR; para birimi/format otomatik algılama.

### 4.4 Şablon

* Kullanıcı **örnek şablonu indirir**, doldurup yükler. Şema kontrolü, hatalı sütun/dalgalı tarih formatı uyarıları, otomatik düzeltme önerileri.

---

## 5) Çoklu Dil ve Para Birimi

* **İlk açılış**: Dil ve para birimi sorulur; otomatik algı + kullanıcı onayı.
* **Hızlı Değiştir**: Profilden ve Yandan Menü’den kısayol.
* **Para Birimi**: Varsayılanı değiştirince “Geçmişe uygula / Geleceğe uygula / Sadece seçili işlem/satır” seçenekleri.
* **Kur Güncelleme**: Manuel/günlük otomatik (kaynak seçimi), geçmiş veriye retro-uygulama opsiyonu.

---

## 6) Bildirimler ve Hatırlatmalar

* **Kredi kartı ekstresi** / **fatura son ödeme** / **abonelik yenileme** için **T–2 gün** uyarıları.
* Bildirimlerden **hızlı giriş**: “Bugün kaç TL harcadın?” gibi kısayollar.
* Kullanıcı **metinlerini kişiselleştirir**; çok dil desteği.

---

## 7) Paketler ve Kısıtlar (30 Gün Ücretsiz Deneme)

* **Free**:

  * CSV içe aktarma; diğer dosya türleri **kısıtlı**.
  * **Ayda 2** kamera/dosya tarama.
  * Tek cihaz, **bulut yedekleme son yedeklemeden sonra durur**.
  * Ücretsiz AI: **hazır butonlar** ile sınırlı.
* **Pro (Orta Paket)**:

  * Sınırsız kamera/dosya tarama (adil kullanım).
  * İleri analizler (bütçe, günlük/haftalık, kategori detay), AI sohbet açık.
  * Çok cihazlı eşitleme, otomatik yedekleme.
* **Premium (Aile/Ekip)**:

  * **Aile/Çok Kullanıcı** aynı hesaba erişim, ortak bütçe.
  * Banka bağlantıları (bölgesel entegrasyon), **AI Tasarruf Koçu**.
  * Faturalı/ekstre, abonelik uyarıları, gelişmiş borç/ödeme tabloları.

> **Not**: 30 gün sonunda Free’a düşüşte özellik kilitleme stratejisi devrede.

---

## 8) Admin Paneli

* **Ödeme Entegrasyonları**: Stripe, iyzico, vb. etkinleştirme/ayar.
* **Paket & Fiyat Yönetimi**: Özellik matrisi, kampanya/kupon, bölgesel fiyat.
* **Yetkiler**: Editör/Geliştirici yetkilendirmesi; kategori/öneri kütüphanesi düzenleme (AI destekli).
* **Raporlama**: Abonelik dönüşümü, OCR başarı oranı, AI kullanım istatistikleri.

---

## 9) Güvenlik, KVKK/GDPR ve Dışa Aktarım Watermark’ı

* **Şifreleme**: Yerel (AES-256) + aktarımda TLS. Hassas alanlar (kart son 4 hane) maskelenir.
* **Watermark**: Dışa aktarılan CSV/XLSX içine **gizli işaret** (örn. tuzlanmış hash + sentinel kolon), meta açıklama ve hücresel örüntüler. **Kullanıcıya bilgilendirme** yapılır.
* **İzinler**: Kamera/dosya/erişim izin akışları açık ve granular.

---

## 10) Veri Modeli ve Senkron

* **Yerel**: Hive/SQLite katmanı; **Undo/Redo** oturum tablosu.
* **Bulut**: Opsiyonel senkron (Açık/Kapalı); çakışma çözümü (son-yaz kazanır + kullanıcıya fark özetleri).
* **Tablolar (özet)**:

  * **Accounts**(id, ad, tür, para_birimi, limit, kesim_günü, son_ödeme_günü, banka, durum…)
  * **Transactions**(id, tip, tarih, açıklama, tutar, pb, taksit, ilk/son, ekstre_ay/yıl, hesap_id, ana_kat, alt_kat, not, durum, etiketler…)
  * **Categories**(ana, alt, aktiflik, sıralama…)
  * **Settings**(dil, pb, tema, nav_sırası, api_anahtarları…)

---

## 11) Onboarding ve Rehber

* **İlk Çalıştırma Turu**: 5 adım kartı (Dil & PB, Hızlı Ekle, OCR, Analiz, AI).
* **İçeride Rehber**: Her sayfada **?** ikonu: mini walkthrough.
* **Arama**: Ayarlar ve komutlar için evrensel arama kutusu.

---

## 12) Tema ve Tasarım

* **En az 5 tema** + **Hızlı Tema Değiştir** (profil menüsünden veya yan menüden).
* **Karanlık/Aydınlık/Sistem** modları.
* Grafik paletleri tema ile uyumlu; erişilebilirlik kontrast kontrolleri.

---

## 13) Erişilebilirlik ve Performans

* Dinamik font, ekran okuyucu etiketleri, büyük dokunma alanları.
* Lazy list, sanallaştırma, artımlı OCR (büyük PDF’lerde sayfa sayfa), önbellek.

---

## 14) Test Planı

* **Birim**: Kural motoru, tarih–ekstre eşlemesi, kur çevirim, undo/redo.
* **Entegrasyon**: OCR→Alan çıkarım→Onay→Kayıt akışı.
* **UI**: Reorder nav, tema geçişleri, bildirim tıklanabilir kısayollar.
* **Güvenlik**: Şifreli depolama, veri dışa aktarım watermark doğrulama.

---

## 15) Örnek Kategori Setleri (Gider & Gelir)

* Verilen uzun liste temel alınarak **derlenmiş bir çekirdek set** sunulur. Kullanıcı **tek tıkla etkinleştirir**, düzenleyebilir, altları sürükleyebilir. (Tam liste: Ekler bölümünde.)

---

## 16) Düğme/Davranış Hızlı Referans Tablosu

* **Her sayfada**: Sol üst **Izgara**, yanında **AI**; sağ üst **Profil**.
* **Alt Nav**: 6 ikon + **FAB**; uzun basılı tut → **yeniden sırala**.
* **Ekle** düğmeleri: Tek dokunuş aç, tekrar dokunuş kapat; **İptal** kapatır.
* **Geri Al/İleri Al**: Oturum boyunca aktif; uygulama kapanınca sıfırlanır.

---

## 17) Buton Haritası ve Mikro-İnteraksiyonlar (TR)

Aşağıdaki tablo; her sayfadaki **düğme adı**, **konumu**, **kısa davranış** ve **uzun basılı/ikincil davranışları** özetler. (Mobil ölçüler: iOS/Android, sağ/sol **thumb zone** optimizasyonu.)

| Sayfa                  | Düğme                      | Konum                       | Birincil Aksiyon                                   | İkincil/Uzun Basma                           |
| ---------------------- | -------------------------- | --------------------------- | -------------------------------------------------- | -------------------------------------------- |
| Global                 | **Izgara (Yan Menü)**      | Sol üst                     | Yan menüyü 0.3s animasyonla aç                     | Son sekmeyi hatırla ve oraya odaklan         |
| Global                 | **AI İkonu**               | Sol üst (ızgaranın sağında) | Popover aç → “Merhaba, nasıl yardımcı olabilirim?” | Uzun bas: Doğrudan **Tam ekran AI**          |
| Global                 | **Profil**                 | Sağ üst                     | Profil panelini sola kaydırarak aç                 | Uzun bas: “Hızlı Hesap Değiştir”             |
| Global                 | **FAB — Hızlı Ekle**       | Alt-orta (yüzer)            | Ekle modalı (Gelir/Gider/Transfer/Not/Tara)        | Uzun bas: Son kullanılan ekleme türü         |
| Global                 | **Alt Nav 6 İkon**         | Alt sabit                   | İlgili sayfaya git                                 | Uzun bas: **Sırala / Titret** (drag&drop)    |
| Dashboard              | **Zaman Filtresi**         | Sağ üst (içerik)            | 1–3–9 ay, 1–2 yıl, Özel                            | Uzun bas: “Bu filtreyi tüm sayfalara uygula” |
| Dashboard              | **Ödendi Toggle**          | Kart/satır içi              | Durumu değiştir, toplamları anında güncelle        | Çift dokun: “Tüm benzerleri ödendi yap”      |
| Kartlar & Hesaplar     | **Ekle**                   | Sağ alt                     | Yeni kart/hesap formu                              | Uzun bas: “Son kartı kopyala”                |
| Kartlar & Hesaplar     | **İçeri Aktar**            | Başlık sağ                  | Şablon import sihirbazı                            | Uzun bas: Şablon indir                       |
| Gelir/Gider            | **Ekle**                   | Sağ alt                     | Ekle seçenekleri aç/kapat                          | Uzun bas: Alan setini hatırla                |
| Gelir/Gider            | **Tara (QR/Kamera/Dosya)** | Başlık sol                  | OCR/Parse akışı                                    | Uzun bas: “Toplu işleme” kipi                |
| Gelir/Gider            | **Geri Al / İleri Al**     | Alt çubuk üstü              | Oturum içi undo/redo                               | Uzun bas: Undo geçmişini göster              |
| Analiz                 | **Grafik Tipi**            | Başlık sağ                  | Tip seçici (Pie/Bar/Line/Area/Stacked)             | Uzun bas: Çift grafik kipi                   |
| Analiz                 | **AI Analiz**              | Başlık sağ                  | Hazır sorular (Free) / Sohbet (Pro+)               | Uzun bas: Son 7 gün önerilerini getir        |
| Net K/Z                | **AI Tasarruf**            | Başlık sağ                  | Tasarruf önerileri                                 | Uzun bas: Kural önerileri oluştur            |
| Listeler & Kategoriler | **+ Alt Kutu**             | Ana kart altı               | Yeni alt kategori ekle                             | Uzun bas: Toplu ekle                         |

> **Öneri**: “Hızlı Öğrenme” için her yeni düğmede ilk 3 kullanımda mikro-ipucu (coachmark) göster.

---

## 18) Flutter Mimari, Widget Ağacı ve Durum Yönetimi (TR)

* **Katmanlar**: `presentation/` (Widgets & Routes) → `application/` (UseCases) → `infrastructure/` (Repositories, OCR adapters, Payment gateways) → `domain/` (Entities, ValueObjects, Services).
* **Durum Yönetimi**: **Provider** + `ChangeNotifier` (hafif ekran durumları) ve **ValueNotifier** (filtre/toggle). Genişleyen ihtiyaçta **Riverpod**’a geçiş noktaları tanımlı.
* **Yerel Depo**: **Hive** (kutular: `accounts`, `transactions`, `categories`, `settings`, `undo_journal`).
* **Yönlendirme**: `go_router` ile tip güvenli rotalar; deep-link: `/ai`, `/import`, `/analytics?range=YTD`.

### 18.1 Sayfa Ağaçları (kısaltılmış)

* **DashboardPage** → `SummaryCards`, `DueAlerts`, `QuickShortcuts`, `TrendMiniChart`.
* **AccountsPage** → `AccountList` (swipe actions: Düzenle/Sil), `AddAccountFAB`.
* **IncomePage** → `EntryTable`, `AddBar`, `ScanButton`, `UndoRedoBar`.
* **ExpensePage** → `EntryTable`, `FutureMatrix`, `ScanButton`, `UndoRedoBar`.
* **AnalyticsPage** → `PrimaryChart(Account/Card)`, `ChartTypePicker`, `DualPie`, `TablesPager`.
* **NetPnLPage** → `NetChart`, `DrilldownList`, `AISuggestions`.
* **CategoriesPage** → `MainCard` + `SubList` (drag & drop), `AIProposals`.
* **AIScreen** → `ChatThread`, `ActionChips`, `ModelSelector`.

---

## 19) Veri Modeli (Hive) ve İş Kuralları (TR)

**Accounts**: `id, name, type, currency, limit, cutoffDay, dueDay, bank, active`
**Transactions**: `id, kind(Income|Expense), date, desc, note, amount, currency, installments, firstInst, lastInst, statementMonth, statementYear, accountId, mainCat, subCat, merchant, country, tags[], method, status(Paid|Unpaid), receiptPath`
**Categories**: `main, sub, active, sortOrder`
**Settings**: `lang, defaultCurrency, theme, navOrder[], apiKeys{openai, gemini, grok}, sync{enabled, lastBackup}}`
**UndoJournal**: `opId, entity, before, after, ts`

**İş Kuralları** (örnek):

* **Ekstre Hesabı**: `statementMonth/Year` = (date ≤ cutoffDay ? date.MM/YYYY : nextMonth(date).MM/YYYY).
* **Ödendi Toggle**: `status` değişince **DashboardTotals** publish edilir; **Analytics** veri kaynağı invalidation.
* **Kur Dönüşümü**: Ekranda seçilen para birimi → geçmişe/geleceğe/tek satıra uygulama seçenekleri.

---

## 20) AI Entegrasyonu ve “API Ekle” Akışı (TR)

1. **Ayarlar > Yapay Zeka**: “API Ekle” butonu.
2. **Üyelik Paketleri** modalı (Free/Pro/Premium özellik farkları).
3. Model seçimi: **Gemini / Grok / OpenAI / …**
4. API anahtarı gir → şifreli **Settings.apiKeys**’e kaydet.
5. AI selamlama: “Merhaba, ben {Model}. Senin için ne yapabilirim?”.
6. **Free**: popover içinde hazır butonlar. **Pro+**: tam sohbet + eylem yetkileri (kategori oluştur/düzenle, toplu etiket).

**Güvenlik**: Anahtarlar sadece yerelde şifrelenmiş, senkron opsiyonel; ağda TLS.

---

## 21) OCR/Import Boru Hattı (TR)

* **Kaynak**: Kamera, Galeri, PDF/CSV/Excel/Word.
* **Ön-İşleme**: Perspektif/kontrast, çok dilli OCR, para birimi/dil algılama.
* **Alan Çıkarımı**: Tarih, tutar, açıklama, taksit, ekstre, hesap/kart, ana/alt kategori.
* **Akıllı Tahminler (≥5)**: kategori, hesap/kart, taksit planı; sürükle-bırak ile birleştir.
* **Onay**: Hedef **Gelir/Gider** seçimi, “tüm satırlara uygula” seçenekleri.
* **Kayıt**: **Undo/Redo** oturumda aktif; kapanınca temizlenir.

---

## 22) Kategori Zekâsı ve Kural Motoru (TR)

* **Heuristik + ML**: Anahtar kelime eşleme (örn. *manav* → Alışveriş/Meyve‑Sebze), POS/işyeri verisi, kullanıcı geçmişi.
* **Kurallar**: “Açıklamada ‘market’ geçerse → Ana: Alışveriş, Alt: Market”.
* **Öneri Paketleri**: Kullanıcının verdiği uzun liste baz alınarak **çekirdek set** + sektör bazlı ek setler; tek tıkla **Aktif/Pasif**.
* **Çatalla/Düzenle**: Öneriyi kabul et, düzenle veya yeni varyant oluştur.

---

## 23) Dışa Aktarım Watermark’ı (TR)

* **Teknik**: CSV/XLSX’e gizli **sentinel sütun** (örn. `_fx_sig`), satır başına salt+hash; dosya metadata açıklamasına imza; örüntü tabanlı sentinel değerleri.
* **Amaç**: Dışa taşınan veriler kaynak uygulamadan geldiği anlaşılabilir olsun.
* **Bilgilendirme**: Kullanıcıya açık metin politika ve devre dışı bırakma koşulları (varsa) gösterilir.

---

## 24) Tema, Renk Token’ları ve Grafik Paletleri (TR)

* **Token’lar**: `--color-primary, --color-secondary, --bg, --surface, --text, --muted, --success, --warning, --danger`
* **Temalar (≥5)**: *NeoMint*, *DeepOcean*, *SunsetCoral*, *CharcoalGold*, *IvoryForest*.
* **Hızlı Tema Değiştir**: Yan menü ve Profil’den. Grafikler tema paletine senkron.

---

## 25) Bildirim Metinleri (TR/EN)

* **Kredi Kartı Ekstresi (T‑2)**: “Hatırlatma: {kart} ekstresi {tarih}. Ödenecek: {tutar}.” / “Reminder: {card} statement {date}. Due: {amount}.”
* **Fatura**: “{servis} için son ödeme {tarih}.” / “{service} bill due {date}.”
* **Abonelik**: “{servis} yenileme {tarih}.” / “{service} renews on {date}.”
* Bildirimden **hızlı giriş** eylemleri: “Bugün {tutar} harcama ekle”.

---

## 26) Paket–Özellik Matrisi (TR)

* **Free**: CSV, ayda 2 tarama, tek cihaz, son yedekten sonra bulut kapalı, AI hazır butonlar.
* **Pro**: Sınırsız tarama, ileri analizler, çoklu cihaz sync, AI sohbet.
* **Premium**: Aile/ekip, banka bağlantıları, AI koçu, gelişmiş borç/ödeme tabloları ve uyarılar.

---

## 27) Admin Paneli (TR)

* **Ödemeler**: Stripe, iyzico vb. bağla/konfigüre et; bölgesel fiyatlandırma ve KDV.
* **Paketler**: Özellik atama, kupon/kampanya, A/B fiyat testleri.
* **Rol/Yetki**: Admin, Editör, Geliştirici; kategori/öneri kütüphanesi AI destekli düzenleme.
* **Gözlem**: Dönüşüm hunisi, OCR doğruluğu, AI kullanım grafikleri.

---

## 28) English Mirrors (Quick)

* **Button Map**, **Flutter Architecture**, **Data Model & Rules**, **AI Add Flow**, **OCR Pipeline**, **Category Intelligence**, **Export Watermark**, **Theme Tokens**, **Notifications**, **Plans**, **Admin** — mirrored in English under each section heading in the EN part above for parity.

---

## 29) Onboarding & Rehber (TR)

* **İlk Çalıştırma**: 5 adım (Dil/Para, Hızlı Ekle, OCR, Analiz, AI).
* **İç Rehber**: Her sayfada `?` mikro turlar, ilk 3 kullanımda coachmark.
* **Evrensel Arama**: Ayar ve komutlar için.

---

## 30) Güvenlik & KVKK (TR)

* Yerel AES‑256, aktarımda TLS; kişisel veriler için açık rıza ekranları; telemetri opt‑in.
* Dışa aktarım watermark politikası kullanıcıya görünür.

---

## 31) Ekler

* **C)** Paket–Özellik matrisi (detaylı tablo).
* **D)** TR/EN bildirim metin şablonları tam liste.
* **E)** Örnek i18n anahtarları.
* **F)** Kategori çekirdek seti (TR) + sektör setleri. (Uzun listenizden normalize edilmiştir; tam listeyi YAML/CSV olarak içe aktarma ekranında sunuyoruz.)

---

## 32) Adım Adım Kullanıcı Rehberi (TR)

**Amaç**: Uygulamayı ilk kez açan kullanıcının hiçbir dokunmayı boşa harcamadan hedefe ulaşması. Her adımda hangi düğmeye basılacağı, o düğmenin nerede olduğu ve ne yapacağı yazılıdır.

### 32.1 İlk Açılış

1. **Dil & Para Birimi Seçimi** (tam ekran modal): `TR/EN + TRY/EUR/USD…` → **Kaydet**.
2. **Alt Çubuk Tanıtım Coachmark’ı**: 6 ikon + **Hızlı Ekle FAB**. → **Anladım**.
3. **Senkron İzni** (opsiyonel): “Bulut yedekleme ve çoklu cihaz için aç?” → **Aç / Kapat**.
4. **AI Popover** tanıtımı: Sol üstte **AI** → “Merhaba, size nasıl yardımcı olabilirim?” → **Kapat**.

### 32.2 Kartlar & Hesaplar Ekleme

* **Ekle** (sağ alt FAB) → form açılır: *Ad, Tür, Para Birimi, Kesim Günü, Son Ödeme Günü…* → **Kaydet**.
* **İpucu**: Kesim gününe göre **ekstre ay/yıl** otomatik hesaplanır (alışveriş tarihi kesimden sonra ise **gelecek ay**).

### 32.3 Gelir Girişi (Hızlı)

* **Alt Çubuk > Gelir** → **Ekle** → alanlar görünür. `Tarih, Açıklama, Tutar, Gelir Türü, Not` doldur.
* **Tekrar Sembolü** (alan üstü): Aktif ettiğinde (açık yeşil), bir sonraki girişte aynı alan **otomatik dolar**. Kapatmak için **iki kez** dokun.
* **Kaydet** → **Geri Al** 10 adım, **İleri Al** 10 adım (oturum).

### 32.4 Gider Girişi + Taksit + Ekstre

* **Alt Çubuk > Gider** → **Ekle**.
* `Tarih, Açıklama, Tutar, Taksit Sayısı, Hesap/Kart` gir.
* **Ekstre Ay/Yıl** otomatik dolu; gerekirse kullanıcı **açar takvimi** ve değiştirir.
* **Gelecek Ödeme Matrisi**: Menüden *3/6/9/12 ay* veya **Manuel** seçim.

### 32.5 Fatura/Belge Tarama (OCR)

* **Tara** (başlık sol) → **Kamera/Galeri/Dosya**.
* Ön izleme → **AI Çıkarım** alanları → **5+ Tahmin Kartı** (kategori/hesap/taksit). Kartlardan birini **dokunarak seç**.
* **Onay Ekranı**: Hedef **Gelir** mü **Gider** mi? “**Tüm satırlara uygula**” veya tek tek düzenle → **Kaydet**.

### 32.6 Analiz

* İlk grafik: **Hesap/Kart Bazlı Harcama**; **Ödendi/Ödenmedi** filtreleri.
* **Grafik Tipi** butonu → **Pasta / Sütun / Çizgi / Alan / Yığılmış Sütun**.
* **Zaman Filtresi**: 1–3–9 ay, 1–2 yıl, **Özel Aralık** (çift takvim). Tüm tablolar senkron.

### 32.7 Net Kâr/Zarar

* Aralık seç → Net çizgisi + sapma uyarıları → **AI Tasarruf Öner** butonu ile aksiyon planı.

### 32.8 Kategoriler (Liste Yönetimi)

* **Sol Menü > Listeler & Kategoriler**.
* İlk satır **Ana Kategori**, alt satırlar **Alt**. **+ Alt Kutu** ile sınırsız ekle.
* **Sürükle-Bırak**: Altları sırala; **paket taşı** (ana + altlar birlikte).
* **AI Önerileri**: Kayıtlı setleri tek tıkla **Aktif/Pasif** yap.

---

## 33) İkon & Mikro-Kopya Kılavuzu (TR)

* **AI İkonu**: `sparkles-variant` veya `bot-2` (modern). Mikro-kopya: “Merhaba, size nasıl yardımcı olabilirim?”.
* **Izgara**: `grid-4` → “Menü”.
* **Hızlı Ekle FAB**: `plus-circle` → “Hızlı Ekle”.
* **Tara**: `camera-scan` → “Tara”. **(Öneri)**: Uzun bas → “Toplu Tara”.
* **Ödendi**: `check-circle` / **Ödenmedi**: `clock-alert`.
* **Grafik Tipi**: `chart-mixed` → “Grafik Tipi Seç”.
* **Zaman Filtresi**: `calendar-range`.
* **Geri Al/İleri Al**: `arrow-undo` / `arrow-redo`.

---

## 34) Paketlere Göre Özellik Bayrakları (TR)

* **Free**: CSV import, ayda **2** tarama, tek cihaz, son yedekten sonra bulut kapalı, AI **hazır butonlar**.
* **Pro**: Sınırsız tarama (adil kullanım), ileri analiz tabloları, çoklu cihaz senkron, tam **AI sohbet**.
* **Premium**: Aile/ekip çok kullanıcılı hesap, banka bağlantıları, **AI Tasarruf Koçu**, gelişmiş borç‑fatura uyarıları.

> Özellikler **feature flag** ile aç/kapa: `flags.ocr_unlimited`, `flags.ai_chat`, `flags.family_sharing`, `flags.bank_links`…

---

## 35) Backend API Tasarımı (TR)

* **Auth**: `POST /auth/signup`, `POST /auth/login`, `POST /auth/oauth/{google|facebook|outlook}`.
* **Accounts**: `GET/POST /accounts`, `PATCH/DELETE /accounts/{id}`.
* **Transactions**: `GET/POST /transactions`, `PATCH/DELETE /transactions/{id}`; sorgu parametreleri: `range, status, accountId, mainCat, subCat`.
* **Analytics**: `GET /analytics/summary`, `GET /analytics/by-account`, `GET /analytics/by-category`, `GET /analytics/pnl`.
* **OCR**: `POST /ocr/extract` (dosya), `POST /ocr/confirm` (kullanıcı onayı).
* **AI**: `POST /ai/query`, `POST /ai/action` (kural/kategori işlemleri).
* **Admin**: `POST /admin/payments/gateways`, `POST /admin/plans`, `POST /admin/feature-flags`.

**WebSocket/SSE**: Canlı senkron ve bildirim.

---

## 36) Veritabanı (TR)

* **transactions**: `(id PK, user_id, kind, date, desc, note, amount, currency, installments, first_inst, last_inst, stmt_month, stmt_year, account_id, main_cat, sub_cat, merchant, tags JSONB, status, created_at)`.
* **accounts**: `(id, user_id, name, type, currency, limit, cutoff_day, due_day, bank, active)`.
* **categories**: `(id, user_id, main, sub, active, sort_order)`.
* **settings**: `(user_id PK, lang, currency, theme, nav_order JSONB, api_keys JSONB, sync_enabled, last_backup)`.
* **indexler**: `(user_id, date)`, `(main_cat, sub_cat)`, `(status)`.
* **tetikleyici**: `before insert on transactions` → `stmt_month/year` hesapla.

---

## 37) Kural Motoru & Örnek DSL (TR)

```yaml
- when: desc ~ '(?i)manav|sebze|meyve'
  then:
    main: 'Alışveriş'
    sub: 'Meyve ve Sebze'
- when: desc ~ '(?i)fırın|unlu'
  then:
    main: 'Alışveriş'
    sub: 'Ekmek'
- when: merchant ~ '(?i)uber|taksi'
  then:
    main: 'Ulaşım'
    sub: 'Taksi'
- when: desc ~ '(?i)spotify|netflix'
  then:
    main: 'Abonelikler'
    sub: 'Dijital/Stream'
```

**Öneri**: Her kural için güven puanı; düşükse kullanıcı onayı iste.

---

## 38) Temalar (≥5) ve Paletler (TR)

* **NeoMint**: `#2BD9A9, #0E1C1B, #F5FFFB, #0AAE8A, #EAF7F4`
* **DeepOcean**: `#2E86DE, #0B2038, #F2F6FA, #1B4F72, #E8EEF6`
* **SunsetCoral**: `#FF6F61, #2B1B1B, #FFF5F3, #C6423A, #FBE9E7`
* **CharcoalGold**: `#D4AF37, #1C1C1C, #FAFAFA, #816A00, #EFE9D1`
* **IvoryForest**: `#2F855A, #1A202C, #F7FAFC, #276749, #E6FFFA`
  Grafik paletleri tema ana rengine türetilmiş 6‑8 tonluk dizilerden oluşur.

---

## 39) AI Asistan (TR)

* **Popover**: Hızlı butonlar (Free) — “Bu ay en pahalı 3 kategori”, “Yaklaşan ödemeler”, “Bütçe aşımı”.
* **Tam Ekran Sohbet** (Pro+): Serbest komut; **Eylemler**: kategori oluştur/düzenle, toplu etiket, kural üret.
* **API Ekle Akışı**: Ayarlar → Yapay Zeka → **API Ekle** → **Paket Seçimi** (upsell) → Anahtar kaydı → Model selamı.

---

## 40) Çoklu Dil & Para Birimi (TR)

* **İlk Çalıştırma**: Algılama + kullanıcıya onay ekranı.
* **Hızlı Değiştir** kısayolu: Profil ve Yan menü.
* **Kur Güncellemesi**: Günlük/manuel; değişikliği geçmiş/gelecek/tek satır opsiyonlarıyla uygula.

---

## 41) Bildirim & Hatırlatma (TR)

* Kredi kartı ekstresi / fatura / abonelik **T‑2 gün**.
* Bildirimden **hızlı işlem**: “Bugün 250₺ yemek ekle”.

---

## 42) Güvenlik & Uyumluluk (TR)

* Yerel **AES‑256**, aktarım **TLS**; PII en aza indir; anahtarlar şifreli.
* **Watermark**: CSV/XLSX’te sentinel sütun + metadata.
* **KVKK/GDPR**: Açık rıza akışları, silme/indirme talepleri için uç noktalar.

---

## 43) QA Senaryoları (TR)

* **Tarih–Ekstre** sınır günü testleri (ayın 28‑31’i).
* **Undo/Redo** yoğun ekleme/çıkarma.
* **OCR** düşük ışık/çapraz dil/çok sayfa PDF.
* **Tema** erişilebilirlik kontrastları.

---

## 17) Buton Haritası ve Mikro-İnteraksiyonlar (TR)

Aşağıdaki tablo; her sayfadaki **düğme adı**, **konumu**, **kısa davranış** ve **uzun basılı/ikincil davranışları** özetler. (Mobil ölçüler: iOS/Android, sağ/sol **thumb zone** optimizasyonu.)

| Sayfa                  | Düğme                      | Konum                       | Birincil Aksiyon                                   | İkincil/Uzun Basma                           |
| ---------------------- | -------------------------- | --------------------------- | -------------------------------------------------- | -------------------------------------------- |
| Global                 | **Izgara (Yan Menü)**      | Sol üst                     | Yan menüyü 0.3s animasyonla aç                     | Son sekmeyi hatırla ve oraya odaklan         |
| Global                 | **AI İkonu**               | Sol üst (ızgaranın sağında) | Popover aç → “Merhaba, nasıl yardımcı olabilirim?” | Uzun bas: Doğrudan **Tam ekran AI**          |
| Global                 | **Profil**                 | Sağ üst                     | Profil panelini sola kaydırarak aç                 | Uzun bas: “Hızlı Hesap Değiştir”             |
| Global                 | **FAB — Hızlı Ekle**       | Alt-orta (yüzer)            | Ekle modalı (Gelir/Gider/Transfer/Not/Tara)        | Uzun bas: Son kullanılan ekleme türü         |
| Global                 | **Alt Nav 6 İkon**         | Alt sabit                   | İlgili sayfaya git                                 | Uzun bas: **Sırala / Titret** (drag&drop)    |
| Dashboard              | **Zaman Filtresi**         | Sağ üst (içerik)            | 1–3–9 ay, 1–2 yıl, Özel                            | Uzun bas: “Bu filtreyi tüm sayfalara uygula” |
| Dashboard              | **Ödendi Toggle**          | Kart/satır içi              | Durumu değiştir, toplamları anında güncelle        | Çift dokun: “Tüm benzerleri ödendi yap”      |
| Kartlar & Hesaplar     | **Ekle**                   | Sağ alt                     | Yeni kart/hesap formu                              | Uzun bas: “Son kartı kopyala”                |
| Kartlar & Hesaplar     | **İçeri Aktar**            | Başlık sağ                  | Şablon import sihirbazı                            | Uzun bas: Şablon indir                       |
| Gelir/Gider            | **Ekle**                   | Sağ alt                     | Ekle seçenekleri aç/kapat                          | Uzun bas: Alan setini hatırla                |
| Gelir/Gider            | **Tara (QR/Kamera/Dosya)** | Başlık sol                  | OCR/Parse akışı                                    | Uzun bas: “Toplu işleme” kipi                |
| Gelir/Gider            | **Geri Al / İleri Al**     | Alt çubuk üstü              | Oturum içi undo/redo                               | Uzun bas: Undo geçmişini göster              |
| Analiz                 | **Grafik Tipi**            | Başlık sağ                  | Tip seçici (Pie/Bar/Line/Area/Stacked)             | Uzun bas: Çift grafik kipi                   |
| Analiz                 | **AI Analiz**              | Başlık sağ                  | Hazır sorular (Free) / Sohbet (Pro+)               | Uzun bas: Son 7 gün önerilerini getir        |
| Net K/Z                | **AI Tasarruf**            | Başlık sağ                  | Tasarruf önerileri                                 | Uzun bas: Kural önerileri oluştur            |
| Listeler & Kategoriler | **+ Alt Kutu**             | Ana kart altı               | Yeni alt kategori ekle                             | Uzun bas: Toplu ekle                         |

> **Öneri**: “Hızlı Öğrenme” için her yeni düğmede ilk 3 kullanımda mikro-ipucu (coachmark) göster.

---

## 18) Flutter Mimari, Widget Ağacı ve Durum Yönetimi (TR)

* **Katmanlar**: `presentation/` (Widgets & Routes) → `application/` (UseCases) → `infrastructure/` (Repositories, OCR adapters, Payment gateways) → `domain/` (Entities, ValueObjects, Services).
* **Durum Yönetimi**: **Provider** + `ChangeNotifier` (hafif ekran durumları) ve **ValueNotifier** (filtre/toggle). Genişleyen ihtiyaçta **Riverpod**’a geçiş noktaları tanımlı.
* **Yerel Depo**: **Hive** (kutular: `accounts`, `transactions`, `categories`, `settings`, `undo_journal`).
* **Yönlendirme**: `go_router` ile tip güvenli rotalar; deep-link: `/ai`, `/import`, `/analytics?range=YTD`.

### 18.1 Sayfa Ağaçları (kısaltılmış)

* **DashboardPage** → `SummaryCards`, `DueAlerts`, `QuickShortcuts`, `TrendMiniChart`.
* **AccountsPage** → `AccountList` (swipe actions: Düzenle/Sil), `AddAccountFAB`.
* **IncomePage** → `EntryTable`, `AddBar`, `ScanButton`, `UndoRedoBar`.
* **ExpensePage** → `EntryTable`, `FutureMatrix`, `ScanButton`, `UndoRedoBar`.
* **AnalyticsPage** → `PrimaryChart(Account/Card)`, `ChartTypePicker`, `DualPie`, `TablesPager`.
* **NetPnLPage** → `NetChart`, `DrilldownList`, `AISuggestions`.
* **CategoriesPage** → `MainCard` + `SubList` (drag & drop), `AIProposals`.
* **AIScreen** → `ChatThread`, `ActionChips`, `ModelSelector`.

---

## 19) Veri Modeli (Hive) ve İş Kuralları (TR)

**Accounts**: `id, name, type, currency, limit, cutoffDay, dueDay, bank, active`
**Transactions**: `id, kind(Income|Expense), date, desc, note, amount, currency, installments, firstInst, lastInst, statementMonth, statementYear, accountId, mainCat, subCat, merchant, country, tags[], method, status(Paid|Unpaid), receiptPath`
**Categories**: `main, sub, active, sortOrder`
**Settings**: `lang, defaultCurrency, theme, navOrder[], apiKeys{openai, gemini, grok}, sync{enabled, lastBackup}}`
**UndoJournal**: `opId, entity, before, after, ts`

**İş Kuralları** (örnek):

* **Ekstre Hesabı**: `statementMonth/Year` = (date ≤ cutoffDay ? date.MM/YYYY : nextMonth(date).MM/YYYY).
* **Ödendi Toggle**: `status` değişince **DashboardTotals** publish edilir; **Analytics** veri kaynağı invalidation.
* **Kur Dönüşümü**: Ekranda seçilen para birimi → geçmişe/geleceğe/tek satıra uygulama seçenekleri.

---

## 20) AI Entegrasyonu ve “API Ekle” Akışı (TR)

1. **Ayarlar > Yapay Zeka**: “API Ekle” butonu.
2. **Üyelik Paketleri** modalı (Free/Pro/Premium özellik farkları).
3. Model seçimi: **Gemini / Grok / OpenAI / …**
4. API anahtarı gir → şifreli **Settings.apiKeys**’e kaydet.
5. AI selamlama: “Merhaba, ben {Model}. Senin için ne yapabilirim?”.
6. **Free**: popover içinde hazır butonlar. **Pro+**: tam sohbet + eylem yetkileri (kategori oluştur/düzenle, toplu etiket).

**Güvenlik**: Anahtarlar sadece yerelde şifrelenmiş, senkron opsiyonel; ağda TLS.

---

## 21) OCR/Import Boru Hattı (TR)

* **Kaynak**: Kamera, Galeri, PDF/CSV/Excel/Word.
* **Ön-İşleme**: Perspektif/kontrast, çok dilli OCR, para birimi/dil algılama.
* **Alan Çıkarımı**: Tarih, tutar, açıklama, taksit, ekstre, hesap/kart, ana/alt kategori.
* **Akıllı Tahminler (≥5)**: kategori, hesap/kart, taksit planı; sürükle-bırak ile birleştir.
* **Onay**: Hedef **Gelir/Gider** seçimi, “tüm satırlara uygula” seçenekleri.
* **Kayıt**: **Undo/Redo** oturumda aktif; kapanınca temizlenir.

---

## 22) Kategori Zekâsı ve Kural Motoru (TR)

* **Heuristik + ML**: Anahtar kelime eşleme (örn. *manav* → Alışveriş/Meyve‑Sebze), POS/işyeri verisi, kullanıcı geçmişi.
* **Kurallar**: “Açıklamada ‘market’ geçerse → Ana: Alışveriş, Alt: Market”.
* **Öneri Paketleri**: Kullanıcının verdiği uzun liste baz alınarak **çekirdek set** + sektör bazlı ek setler; tek tıkla **Aktif/Pasif**.
* **Çatalla/Düzenle**: Öneriyi kabul et, düzenle veya yeni varyant oluştur.

---

## 23) Dışa Aktarım Watermark’ı (TR)

* **Teknik**: CSV/XLSX’e gizli **sentinel sütun** (örn. `_fx_sig`), satır başına salt+hash; dosya metadata açıklamasına imza; örüntü tabanlı sentinel değerleri.
* **Amaç**: Dışa taşınan veriler kaynak uygulamadan geldiği anlaşılabilir olsun.
* **Bilgilendirme**: Kullanıcıya açık metin politika ve devre dışı bırakma koşulları (varsa) gösterilir.

---

## 24) Tema, Renk Token’ları ve Grafik Paletleri (TR)

* **Token’lar**: `--color-primary, --color-secondary, --bg, --surface, --text, --muted, --success, --warning, --danger`
* **Temalar (≥5)**: *NeoMint*, *DeepOcean*, *SunsetCoral*, *CharcoalGold*, *IvoryForest*.
* **Hızlı Tema Değiştir**: Yan menü ve Profil’den. Grafikler tema paletine senkron.

---

## 25) Bildirim Metinleri (TR/EN)

* **Kredi Kartı Ekstresi (T‑2)**: “Hatırlatma: {kart} ekstresi {tarih}. Ödenecek: {tutar}.” / “Reminder: {card} statement {date}. Due: {amount}.”
* **Fatura**: “{servis} için son ödeme {tarih}.” / “{service} bill due {date}.”
* **Abonelik**: “{servis} yenileme {tarih}.” / “{service} renews on {date}.”
* Bildirimden **hızlı giriş** eylemleri: “Bugün {tutar} harcama ekle”.

---

## 26) Paket–Özellik Matrisi (TR)

* **Free**: CSV, ayda 2 tarama, tek cihaz, son yedekten sonra bulut kapalı, AI hazır butonlar.
* **Pro**: Sınırsız tarama, ileri analizler, çoklu cihaz sync, AI sohbet.
* **Premium**: Aile/ekip, banka bağlantıları, AI koçu, gelişmiş borç/ödeme tabloları ve uyarılar.

---

## 27) Admin Paneli (TR)

* **Ödemeler**: Stripe, iyzico vb. bağla/konfigüre et; bölgesel fiyatlandırma ve KDV.
* **Paketler**: Özellik atama, kupon/kampanya, A/B fiyat testleri.
* **Rol/Yetki**: Admin, Editör, Geliştirici; kategori/öneri kütüphanesi AI destekli düzenleme.
* **Gözlem**: Dönüşüm hunisi, OCR doğruluğu, AI kullanım grafikleri.

---

## 28) English Mirrors (Quick)

* **Button Map**, **Flutter Architecture**, **Data Model & Rules**, **AI Add Flow**, **OCR Pipeline**, **Category Intelligence**, **Export Watermark**, **Theme Tokens**, **Notifications**, **Plans**, **Admin** — mirrored in English under each section heading in the EN part above for parity.

---

## 29) Onboarding & Rehber (TR)

* **İlk Çalıştırma**: 5 adım (Dil/Para, Hızlı Ekle, OCR, Analiz, AI).
* **İç Rehber**: Her sayfada `?` mikro turlar, ilk 3 kullanımda coachmark.
* **Evrensel Arama**: Ayar ve komutlar için.

---

## 30) Güvenlik & KVKK (TR)

* Yerel AES‑256, aktarımda TLS; kişisel veriler için açık rıza ekranları; telemetri opt‑in.
* Dışa aktarım watermark politikası kullanıcıya görünür.

---

## 31) Ekler

* **C)** Paket–Özellik matrisi (detaylı tablo).
* **D)** TR/EN bildirim metin şablonları tam liste.
* **E)** Örnek i18n anahtarları.
* **F)** Kategori çekirdek seti (TR) + sektör setleri. (Uzun listenizden normalize edilmiştir; tam listeyi YAML/CSV olarak içe aktarma ekranında sunuyoruz.)

---

## 32) Adım Adım Kullanıcı Rehberi (TR)

**Amaç**: Uygulamayı ilk kez açan kullanıcının hiçbir dokunmayı boşa harcamadan hedefe ulaşması. Her adımda hangi düğmeye basılacağı, o düğmenin nerede olduğu ve ne yapacağı yazılıdır.

### 32.1 İlk Açılış

1. **Dil & Para Birimi Seçimi** (tam ekran modal): `TR/EN + TRY/EUR/USD…` → **Kaydet**.
2. **Alt Çubuk Tanıtım Coachmark’ı**: 6 ikon + **Hızlı Ekle FAB**. → **Anladım**.
3. **Senkron İzni** (opsiyonel): “Bulut yedekleme ve çoklu cihaz için aç?” → **Aç / Kapat**.
4. **AI Popover** tanıtımı: Sol üstte **AI** → “Merhaba, size nasıl yardımcı olabilirim?” → **Kapat**.

### 32.2 Kartlar & Hesaplar Ekleme

* **Ekle** (sağ alt FAB) → form açılır: *Ad, Tür, Para Birimi, Kesim Günü, Son Ödeme Günü…* → **Kaydet**.
* **İpucu**: Kesim gününe göre **ekstre ay/yıl** otomatik hesaplanır (alışveriş tarihi kesimden sonra ise **gelecek ay**).

### 32.3 Gelir Girişi (Hızlı)

* **Alt Çubuk > Gelir** → **Ekle** → alanlar görünür. `Tarih, Açıklama, Tutar, Gelir Türü, Not` doldur.
* **Tekrar Sembolü** (alan üstü): Aktif ettiğinde (açık yeşil), bir sonraki girişte aynı alan **otomatik dolar**. Kapatmak için **iki kez** dokun.
* **Kaydet** → **Geri Al** 10 adım, **İleri Al** 10 adım (oturum).

### 32.4 Gider Girişi + Taksit + Ekstre

* **Alt Çubuk > Gider** → **Ekle**.
* `Tarih, Açıklama, Tutar, Taksit Sayısı, Hesap/Kart` gir.
* **Ekstre Ay/Yıl** otomatik dolu; gerekirse kullanıcı **açar takvimi** ve değiştirir.
* **Gelecek Ödeme Matrisi**: Menüden *3/6/9/12 ay* veya **Manuel** seçim.

### 32.5 Fatura/Belge Tarama (OCR)

* **Tara** (başlık sol) → **Kamera/Galeri/Dosya**.
* Ön izleme → **AI Çıkarım** alanları → **5+ Tahmin Kartı** (kategori/hesap/taksit). Kartlardan birini **dokunarak seç**.
* **Onay Ekranı**: Hedef **Gelir** mü **Gider** mi? “**Tüm satırlara uygula**” veya tek tek düzenle → **Kaydet**.

### 32.6 Analiz

* İlk grafik: **Hesap/Kart Bazlı Harcama**; **Ödendi/Ödenmedi** filtreleri.
* **Grafik Tipi** butonu → **Pasta / Sütun / Çizgi / Alan / Yığılmış Sütun**.
* **Zaman Filtresi**: 1–3–9 ay, 1–2 yıl, **Özel Aralık** (çift takvim). Tüm tablolar senkron.

### 32.7 Net Kâr/Zarar

* Aralık seç → Net çizgisi + sapma uyarıları → **AI Tasarruf Öner** butonu ile aksiyon planı.

### 32.8 Kategoriler (Liste Yönetimi)

* **Sol Menü > Listeler & Kategoriler**.
* İlk satır **Ana Kategori**, alt satırlar **Alt**. **+ Alt Kutu** ile sınırsız ekle.
* **Sürükle-Bırak**: Altları sırala; **paket taşı** (ana + altlar birlikte).
* **AI Önerileri**: Kayıtlı setleri tek tıkla **Aktif/Pasif** yap.

---

## 33) İkon & Mikro-Kopya Kılavuzu (TR)

* **AI İkonu**: `sparkles-variant` veya `bot-2` (modern). Mikro-kopya: “Merhaba, size nasıl yardımcı olabilirim?”.
* **Izgara**: `grid-4` → “Menü”.
* **Hızlı Ekle FAB**: `plus-circle` → “Hızlı Ekle”.
* **Tara**: `camera-scan` → “Tara”. **(Öneri)**: Uzun bas → “Toplu Tara”.
* **Ödendi**: `check-circle` / **Ödenmedi**: `clock-alert`.
* **Grafik Tipi**: `chart-mixed` → “Grafik Tipi Seç”.
* **Zaman Filtresi**: `calendar-range`.
* **Geri Al/İleri Al**: `arrow-undo` / `arrow-redo`.

---

## 34) Paketlere Göre Özellik Bayrakları (TR)

* **Free**: CSV import, ayda **2** tarama, tek cihaz, son yedekten sonra bulut kapalı, AI **hazır butonlar**.
* **Pro**: Sınırsız tarama (adil kullanım), ileri analiz tabloları, çoklu cihaz senkron, tam **AI sohbet**.
* **Premium**: Aile/ekip çok kullanıcılı hesap, banka bağlantıları, **AI Tasarruf Koçu**, gelişmiş borç‑fatura uyarıları.

> Özellikler **feature flag** ile aç/kapa: `flags.ocr_unlimited`, `flags.ai_chat`, `flags.family_sharing`, `flags.bank_links`…

---

## 35) Backend API Tasarımı (TR)

* **Auth**: `POST /auth/signup`, `POST /auth/login`, `POST /auth/oauth/{google|facebook|outlook}`.
* **Accounts**: `GET/POST /accounts`, `PATCH/DELETE /accounts/{id}`.
* **Transactions**: `GET/POST /transactions`, `PATCH/DELETE /transactions/{id}`; sorgu parametreleri: `range, status, accountId, mainCat, subCat`.
* **Analytics**: `GET /analytics/summary`, `GET /analytics/by-account`, `GET /analytics/by-category`, `GET /analytics/pnl`.
* **OCR**: `POST /ocr/extract` (dosya), `POST /ocr/confirm` (kullanıcı onayı).
* **AI**: `POST /ai/query`, `POST /ai/action` (kural/kategori işlemleri).
* **Admin**: `POST /admin/payments/gateways`, `POST /admin/plans`, `POST /admin/feature-flags`.

**WebSocket/SSE**: Canlı senkron ve bildirim.

---

## 36) Veritabanı (TR)

* **transactions**: `(id PK, user_id, kind, date, desc, note, amount, currency, installments, first_inst, last_inst, stmt_month, stmt_year, account_id, main_cat, sub_cat, merchant, tags JSONB, status, created_at)`.
* **accounts**: `(id, user_id, name, type, currency, limit, cutoff_day, due_day, bank, active)`.
* **categories**: `(id, user_id, main, sub, active, sort_order)`.
* **settings**: `(user_id PK, lang, currency, theme, nav_order JSONB, api_keys JSONB, sync_enabled, last_backup)`.
* **indexler**: `(user_id, date)`, `(main_cat, sub_cat)`, `(status)`.
* **tetikleyici**: `before insert on transactions` → `stmt_month/year` hesapla.

---

## 37) Kural Motoru & Örnek DSL (TR)

```yaml
- when: desc ~ '(?i)manav|sebze|meyve'
  then:
    main: 'Alışveriş'
    sub: 'Meyve ve Sebze'
- when: desc ~ '(?i)fırın|unlu'
  then:
    main: 'Alışveriş'
    sub: 'Ekmek'
- when: merchant ~ '(?i)uber|taksi'
  then:
    main: 'Ulaşım'
    sub: 'Taksi'
- when: desc ~ '(?i)spotify|netflix'
  then:
    main: 'Abonelikler'
    sub: 'Dijital/Stream'
```

**Öneri**: Her kural için güven puanı; düşükse kullanıcı onayı iste.

---

## 38) Temalar (≥5) ve Paletler (TR)

* **NeoMint**: `#2BD9A9, #0E1C1B, #F5FFFB, #0AAE8A, #EAF7F4`
* **DeepOcean**: `#2E86DE, #0B2038, #F2F6FA, #1B4F72, #E8EEF6`
* **SunsetCoral**: `#FF6F61, #2B1B1B, #FFF5F3, #C6423A, #FBE9E7`
* **CharcoalGold**: `#D4AF37, #1C1C1C, #FAFAFA, #816A00, #EFE9D1`
* **IvoryForest**: `#2F855A, #1A202C, #F7FAFC, #276749, #E6FFFA`
  Grafik paletleri tema ana rengine türetilmiş 6‑8 tonluk dizilerden oluşur.

---

## 39) AI Asistan (TR)

* **Popover**: Hızlı butonlar (Free) — “Bu ay en pahalı 3 kategori”, “Yaklaşan ödemeler”, “Bütçe aşımı”.
* **Tam Ekran Sohbet** (Pro+): Serbest komut; **Eylemler**: kategori oluştur/düzenle, toplu etiket, kural üret.
* **API Ekle Akışı**: Ayarlar → Yapay Zeka → **API Ekle** → **Paket Seçimi** (upsell) → Anahtar kaydı → Model selamı.

---

## 40) Çoklu Dil & Para Birimi (TR)

* **İlk Çalıştırma**: Algılama + kullanıcıya onay ekranı.
* **Hızlı Değiştir** kısayolu: Profil ve Yan menü.
* **Kur Güncellemesi**: Günlük/manuel; değişikliği geçmiş/gelecek/tek satır opsiyonlarıyla uygula.

---

## 41) Bildirim & Hatırlatma (TR)

* Kredi kartı ekstresi / fatura / abonelik **T‑2 gün**.
* Bildirimden **hızlı işlem**: “Bugün 250₺ yemek ekle”.

---

## 42) Güvenlik & Uyumluluk (TR)

* Yerel **AES‑256**, aktarım **TLS**; PII en aza indir; anahtarlar şifreli.
* **Watermark**: CSV/XLSX’te sentinel sütun + metadata.
* **KVKK/GDPR**: Açık rıza akışları, silme/indirme talepleri için uç noktalar.

---

## 43) QA Senaryoları (TR)

* **Tarih–Ekstre** sınır günü testleri (ayın 28‑31’i).
* **Undo/Redo** yoğun ekleme/çıkarma.
* **OCR** düşük ışık/çapraz dil/çok sayfa PDF.
* **Tema** erişilebilirlik kontrastları.

---

# English Version — Full Product Requirements & UX Flows (EN)

## 0) Vision

A multilingual, multi-currency, AI-powered personal finance app with offline-first storage and optional cloud sync; OCR/import, smart analytics, and modular subscriptions.

## 1) Navigation & Global

* **Bottom bar (6 icons + center FAB)**: Accounts & Cards, Income, Dashboard, Expense, Analytics, Net P&L. Long-press to **reorder** (persist locally & to cloud if signed-in). FAB = **Quick Add**.
* **Top-left**: **Grid (side drawer)** + **AI icon** (popover → full screen chat).
* **Top-right**: **Profile panel** slides in (Sign In left, Sign Up right). App usable without sign-in; sync toggle in Settings.

## 2) Pages & Buttons

* **Dashboard**: Debt Paid/Pending cards; monthly summary; quick shortcuts; due alerts; FAB; Paid/Unpaid toggles update totals; global time filter (1–3–9 months, 1–2 years, custom).
* **Accounts & Cards**: Cutoff & due days; transaction’s statement month/year auto-computed; mark Paid affects totals; bulk actions; import/export (with hidden watermark).
* **Income**: Date, description, type (main/sub), amount, currency, note; **repeat icons** for fast entry; Add/Import/QR-Camera; Undo/Redo (session).
* **Expense**: Date/desc/note/amount/currency/installments/statement month-year/first-last installment/main-sub category/account/status; **future payment matrix** (3/6/9/12 months or manual); Scan/Add/Import/Undo-Redo.
* **Analytics**: Primary chart = by Account/Card with Paid/Unpaid filters; chart types (pie/column/line/area/stacked); paired charts (main vs subcategory); tables per package; export CSV/PNG (watermark); AI insight buttons.
* **Net P&L**: Net for range; trends; AI savings.
* **Lists & Categories**: Main at row 1 (hint), subs below; drag & drop; batch rename; move as a pack; AI-suggested templates; toggle Active/Inactive.

## 3) AI

* **Free**: pre-built Q&A buttons; local/buffered cloud data.
* **Pro/Premium**: full chat; actions (create categories, mass tagging, rules); **API Add** flow with membership upsell; model greets (“Hi, I’m {Model}”).
* **Extras**: background enrichment (with consent); privacy-first.

## 4) OCR & Import

* **Sources**: Camera, Gallery, PDF/CSV/Excel/Word.
* **Flow**: preview → AI extraction → **5+ smart suggestions** (category/account/installments) → confirmation (Income/Expense) → save → Undo/Redo (session-scoped).
* **Accuracy**: field confidence; highlight low confidence; currency & locale detection.
* **Template**: downloadable sample; schema check; auto-fix proposals.

## 5) Language & Currency

First-run prompt; quick switch; retro-apply currency (past/future/line-item only); manual or daily FX updates.

## 6) Notifications

T–2 day alerts for statements/bills/subscriptions; quick-add from notification; fully customizable copy; multilingual.

## 7) Plans

* **Free**: CSV only; 2 scans/month; single device; last backup only; AI limited to buttons.
* **Pro**: unlimited scans (fair use), deeper analytics, cloud sync multi-device, AI chat.
* **Premium (Family/Team)**: multi-user shared budget, bank links (regional), AI coach, advanced debt/billing tables & alerts.

## 8) Admin Panel

Payments (Stripe/iyzico), plans/features, coupons, regional pricing, roles, AI-assisted library edits, analytics.

## 9) Security & Compliance

Local AES-256 + TLS; masked sensitive fields; export **watermark** (salted hash + sentinel column + metadata); explicit user notice.

## 10) Data & Sync

Local DB (Hive/SQLite), session-scoped Undo/Redo; optional cloud with conflict resolution; core tables: Accounts, Transactions, Categories, Settings.

## 11) Onboarding & Help

5-step tour; per-page “?” micro-walkthrough; global command search.

## 12) Theming

≥5 themes; quick switch; Dark/Light/System; accessible palettes tied to charts.

## 13) Accessibility & Performance

Screen reader labels, large hit targets; list virtualization; incremental OCR for big PDFs; caching.

## 14) Testing

* **Unit**: Rule engine, statement period calculation, FX conversion, undo/redo journal.
* **Integration**: OCR → field extraction → confirmation → save flow.
* **UI**: Reorderable navigation, theme toggles, actionable notifications.
* **Security**: Encrypted storage, export watermark verification.

## 15) Sample Category Sets

* A curated core set derived from the provided long list is surfaced; users can enable with one tap, edit, and reorder subcategories. (Full list lives in the Appendix.)

## 16) Quick Button Reference

* **Every screen**: Grid menu on the top-left, AI icon beside it; profile toggle on the top-right.
* **Bottom navigation**: 6 icons + FAB; long-press to reorder.
* **Add buttons**: Single tap opens, second tap closes; **Cancel** also closes.
* **Undo/Redo**: Active throughout the session; clears when the app closes.

## 17) Button Map & Micro-Interactions

Below table summarizes button names, positions, primary actions, and long-press or secondary behaviors (mobile-first thumb zones).

| Page | Button | Position | Primary Action | Secondary/Long Press |
| --- | --- | --- | --- | --- |
| Global | **Grid (Side Menu)** | Top-left | Opens the side menu with a 0.3s animation | Remembers last opened section and focuses there |
| Global | **AI Icon** | Top-left (right of grid) | Opens popover with “Hi, how can I help?” | Long press: jump to **full-screen AI** |
| Global | **Profile** | Top-right | Slides in the profile panel from the right | Long press: “Quick Switch Account” |
| Global | **FAB — Quick Add** | Floating bottom-center | Opens add modal (Income/Expense/Transfer/Note/Scan) | Long press: Prefills the last used entry type |
| Global | **Bottom Nav (6 icons)** | Bottom fixed | Navigates to the respective screen | Long press: **Reorder / Jiggle** (drag & drop) |
| Dashboard | **Time Filter** | Top-right (content) | 1–3–9 months, 1–2 years, Custom | Long press: “Apply this filter everywhere” |
| Dashboard | **Paid Toggle** | Inline per card/row | Switches status and updates totals instantly | Double tap: “Mark similar items as paid” |
| Accounts & Cards | **Add** | Bottom-right | Opens new account/card form | Long press: “Duplicate last account” |
| Accounts & Cards | **Import** | Header right | Launches template import wizard | Long press: Download template |
| Income/Expense | **Add** | Bottom-right | Expands/collapses entry inputs | Long press: Remember current field set |
| Income/Expense | **Scan (QR/Camera/File)** | Header left | Starts OCR/parsing flow | Long press: Activate “Batch Processing” mode |
| Income/Expense | **Undo / Redo** | Above bottom bar | Session undo/redo | Long press: Show undo history |
| Analytics | **Chart Type** | Header right | Opens type picker (Pie/Bar/Line/Area/Stacked) | Long press: Dual-chart mode |
| Analytics | **AI Insights** | Header right | Ready-made questions (Free) / Chat (Pro+) | Long press: Fetch last 7 days’ insights |
| Net P&L | **AI Savings** | Header right | Presents savings suggestions | Long press: Generate rule suggestions |
| Lists & Categories | **+ Sub Card** | Beneath parent card | Adds new subcategory | Long press: Bulk add |

> **Tip**: Show a coachmark for the first three uses of every new button to accelerate learning.

## 18) Flutter Architecture, Widget Tree & State Management

* **Layers**: `presentation/` (Widgets & Routes) → `application/` (UseCases) → `infrastructure/` (Repositories, OCR adapters, payment gateways) → `domain/` (Entities, ValueObjects, Services).
* **State Management**: **Provider** with `ChangeNotifier` for lightweight screens and **ValueNotifier** for filters/toggles. Identify upgrade points to migrate to **Riverpod** if complexity grows.
* **Local Store**: **Hive** boxes for `accounts`, `transactions`, `categories`, `settings`, `undo_journal`.
* **Routing**: `go_router` with type-safe routes; deep links such as `/ai`, `/import`, `/analytics?range=YTD`.

### 18.1 Page Trees (short)

* **DashboardPage** → `SummaryCards`, `DueAlerts`, `QuickShortcuts`, `TrendMiniChart`.
* **AccountsPage** → `AccountList` (swipe edit/delete), `AddAccountFAB`.
* **IncomePage** → `EntryTable`, `AddBar`, `ScanButton`, `UndoRedoBar`.
* **ExpensePage** → `EntryTable`, `FutureMatrix`, `ScanButton`, `UndoRedoBar`.
* **AnalyticsPage** → `PrimaryChart(Account/Card)`, `ChartTypePicker`, `DualPie`, `TablesPager`.
* **NetPnLPage** → `NetChart`, `DrilldownList`, `AISuggestions`.
* **CategoriesPage** → `MainCard` + `SubList` (drag & drop), `AIProposals`.
* **AIScreen** → `ChatThread`, `ActionChips`, `ModelSelector`.

## 19) Data Model (Hive) & Business Rules

**Accounts**: `id, name, type, currency, limit, cutoffDay, dueDay, bank, active`  
**Transactions**: `id, kind(Income|Expense), date, desc, note, amount, currency, installments, firstInst, lastInst, statementMonth, statementYear, accountId, mainCat, subCat, merchant, country, tags[], method, status(Paid|Unpaid), receiptPath`  
**Categories**: `main, sub, active, sortOrder`  
**Settings**: `lang, defaultCurrency, theme, navOrder[], apiKeys{openai, gemini, grok}, sync{enabled, lastBackup}}`  
**UndoJournal**: `opId, entity, before, after, ts`

**Business Rules** (sample):

* **Statement Period**: `statementMonth/Year` = (date ≤ cutoffDay ? date.MM/YYYY : nextMonth(date).MM/YYYY).
* **Paid Toggle**: Publishing `DashboardTotals` and invalidating **Analytics** data when status flips.
* **FX Conversion**: Apply selected currency to past/future/single-line scopes.

## 20) AI Integration & “Add API” Flow

1. **Settings > AI**: Tap “Add API”.
2. Show **Membership Plans** modal (Free/Pro/Premium feature comparison).
3. Choose model: **Gemini / Grok / OpenAI / …**
4. Enter API key → encrypt into **Settings.apiKeys**.
5. Assistant greeting: “Hi, I’m {Model}. What can I do for you?”
6. **Free**: Popover quick buttons. **Pro+**: Full chat plus action rights (create/edit categories, bulk tagging, rule generation).

**Security**: Keys are encrypted locally, optional sync; transport over TLS.

## 21) OCR/Import Pipeline

* **Sources**: Camera, Gallery, PDF/CSV/Excel/Word.
* **Pre-processing**: Perspective/contrast correction, multilingual OCR, currency/language detection.
* **Field Extraction**: Date, amount, description, installments, statement period, account/card, main/sub category.
* **Smart Suggestions (≥5)**: Category, account/card, installment plan cards; drag & drop to merge/refine.
* **Confirmation**: Choose **Income** or **Expense**, apply-to-all toggles, editable fields.
* **Save**: Session-scoped **Undo/Redo**; cleared when the app closes.

## 22) Category Intelligence & Rule Engine

* **Heuristics + ML**: Keyword mapping (e.g., *greengrocer* → Shopping/Fruit & Veg), POS/vendor data, user history.
* **Rules**: “If description contains ‘market’ → Main: Shopping, Sub: Groceries.”
* **Suggestion Packs**: Core set + industry-specific bundles derived from the supplied long list; toggle Active/Inactive with one tap.
* **Fork/Edit**: Accept, tweak, or branch suggestions into new variants.

## 23) Export Watermark

* **Technique**: Hidden **sentinel column** (e.g., `_fx_sig`) with per-row salt+hash, plus metadata signatures and pattern-based sentinels in CSV/XLSX.
* **Purpose**: Trace exported files back to the source application.
* **Disclosure**: Provide transparent policy text and opt-out conditions (if any).

## 24) Theme Tokens & Chart Palettes

* **Tokens**: `--color-primary, --color-secondary, --bg, --surface, --text, --muted, --success, --warning, --danger`
* **Themes (≥5)**: *NeoMint*, *DeepOcean*, *SunsetCoral*, *CharcoalGold*, *IvoryForest*.
* **Quick Theme Switch**: Via side menu and profile; charts inherit theme palettes.

## 25) Notification Copy (TR/EN)

* **Credit Card Statement (T‑2)**: “Hatırlatma: {kart} ekstresi {tarih}. Ödenecek: {tutar}.” / “Reminder: {card} statement {date}. Due: {amount}.”
* **Bill**: “{servis} için son ödeme {tarih}.” / “{service} bill due {date}.”
* **Subscription**: “{servis} yenileme {tarih}.” / “{service} renews on {date}.”
* **Quick actions** from notifications: “Bugün {tutar} harcama ekle.”

## 26) Plan–Feature Matrix

* **Free**: CSV import, 2 scans/month, single device, cloud pauses after last backup, AI quick buttons.
* **Pro**: Unlimited scanning (fair use), advanced analytics, multi-device sync, AI chat.
* **Premium**: Family/team sharing, bank connections, AI savings coach, advanced debt/billing tables & alerts.

## 27) Admin Panel (Detailed)

* **Payments**: Connect/configure Stripe, iyzico, etc.; regional pricing and VAT.
* **Plans**: Assign features, manage coupons/campaigns, run pricing A/B tests.
* **Roles/Permissions**: Admin, Editor, Developer; AI-assisted library curation.
* **Observability**: Conversion funnel, OCR accuracy, AI usage charts.

## 28) English Mirrors (Quick)

Reference mapping between Turkish and English sections; both versions now mirror sections **0–43** for parity.

## 29) Onboarding & Guide

* **First Run**: 5-step tour (Language/Currency, Quick Add, OCR, Analytics, AI).
* **In-app Guide**: `?` icon micro-tours per screen; coachmarks for first 3 uses.
* **Universal Search**: Surface settings and commands.

## 30) Security & KVKK

* Local AES-256, TLS in transit; explicit consent screens for personal data; telemetry opt-in.
* Export watermark policy is visible to users.

## 31) Appendices

* **C)** Detailed plan–feature matrix table.
* **D)** Full TR/EN notification template library.
* **E)** Sample i18n keys.
* **F)** Normalized core & industry category sets (delivered as YAML/CSV in import UI).

## 32) Step-by-Step User Guide

**Goal**: Help first-time users reach outcomes without wasted taps; each step states the button, location, and result.

### 32.1 First Launch

1. **Language & Currency Selection** (full-screen modal): `TR/EN + TRY/EUR/USD…` → **Save**.
2. **Bottom Bar Coachmark**: 6 icons + **Quick Add FAB** → **Got it**.
3. **Sync Permission** (optional): “Enable cloud backup & multi-device?” → **Enable / Skip**.
4. **AI Popover Tour**: Tap **AI** top-left → “Hi, how can I help?” → **Close**.

### 32.2 Add Accounts & Cards

* Tap **Add** (bottom-right FAB) → form fields (Name, Type, Currency, Cutoff Day, Due Day…) → **Save**.
* **Tip**: Statement month/year auto-calculates by cutoff (after cutoff = **next month**).

### 32.3 Quick Income Entry

* **Bottom Nav > Income** → **Add** to reveal fields: Date, Description, Amount, Income Type, Note.
* **Repeat Icon** (above fields): when active (light green) the next entry autofills with last value; double tap to reset.
* **Save** → **Undo** up to 10 steps, **Redo** up to 10 steps within the session.

### 32.4 Expense Entry with Installments & Statement

* **Bottom Nav > Expense** → **Add**.
* Fill `Date, Description, Amount, Installments, Account/Card`.
* **Statement Month/Year** auto-fills; open picker to adjust if needed.
* **Future Payment Matrix**: choose 3/6/9/12 months or **Manual**.

### 32.5 Invoice/Document Scan (OCR)

* Tap **Scan** (header left) → choose **Camera/Gallery/File**.
* Preview → **AI Extraction** fields → review **5+ Suggestion Cards** (category/account/installments). Tap to apply.
* **Confirmation**: choose **Income** or **Expense**; “**Apply to all rows**” or edit individually → **Save**.

### 32.6 Analytics

* Primary chart: **Spending by Account/Card** with **Paid/Unpaid** filters.
* **Chart Type** button → **Pie / Column / Line / Area / Stacked Column**.
* **Time Filter**: 1–3–9 months, 1–2 years, **Custom** (dual calendar). Tables stay in sync.

### 32.7 Net Profit/Loss

* Choose range → view net trend & variance alerts → use **AI Suggest Savings** for action plans.

### 32.8 Categories (List Management)

* **Side Menu > Lists & Categories**.
* Top row shows **Main Category**, rows below are **Sub**. Use **+ Sub Card** for unlimited adds.
* **Drag & drop** to reorder; **Move as Pack** keeps main and subs together.
* **AI Suggestions**: toggle curated sets Active/Inactive in one tap.

## 33) Icon & Microcopy Guidelines

* **AI Icon**: `sparkles-variant` or `bot-2`; microcopy “Hi, how can I help?”
* **Grid**: `grid-4` → “Menu”.
* **Quick Add FAB**: `plus-circle` → “Quick Add”.
* **Scan**: `camera-scan` → “Scan” (long press: “Batch Scan”).
* **Paid**: `check-circle` / **Unpaid**: `clock-alert`.
* **Chart Type**: `chart-mixed` → “Choose Chart Type”.
* **Time Filter**: `calendar-range`.
* **Undo/Redo**: `arrow-undo` / `arrow-redo`.

## 34) Feature Flags by Plan

* **Free**: CSV import, **2** scans/month, single device, cloud paused after last backup, AI quick buttons.
* **Pro**: Unlimited scans (fair use), advanced analytics tables, multi-device sync, full **AI chat**.
* **Premium**: Family/team account, bank links, **AI Savings Coach**, advanced debt/invoice alerts.

> Feature toggles: `flags.ocr_unlimited`, `flags.ai_chat`, `flags.family_sharing`, `flags.bank_links`, …

## 35) Backend API Design

* **Auth**: `POST /auth/signup`, `POST /auth/login`, `POST /auth/oauth/{google|facebook|outlook}`.
* **Accounts**: `GET/POST /accounts`, `PATCH/DELETE /accounts/{id}`.
* **Transactions**: `GET/POST /transactions`, `PATCH/DELETE /transactions/{id}`; query params `range, status, accountId, mainCat, subCat`.
* **Analytics**: `GET /analytics/summary`, `GET /analytics/by-account`, `GET /analytics/by-category`, `GET /analytics/pnl`.
* **OCR**: `POST /ocr/extract` (file), `POST /ocr/confirm` (user confirmation).
* **AI**: `POST /ai/query`, `POST /ai/action` (rule/category operations).
* **Admin**: `POST /admin/payments/gateways`, `POST /admin/plans`, `POST /admin/feature-flags`.

**WebSocket/SSE**: Live sync and notifications.

## 36) Database

* **transactions**: `(id PK, user_id, kind, date, desc, note, amount, currency, installments, first_inst, last_inst, stmt_month, stmt_year, account_id, main_cat, sub_cat, merchant, tags JSONB, status, created_at)`.
* **accounts**: `(id, user_id, name, type, currency, limit, cutoff_day, due_day, bank, active)`.
* **categories**: `(id, user_id, main, sub, active, sort_order)`.
* **settings**: `(user_id PK, lang, currency, theme, nav_order JSONB, api_keys JSONB, sync_enabled, last_backup)`.
* **Indexes**: `(user_id, date)`, `(main_cat, sub_cat)`, `(status)`.
* **Trigger**: `before insert on transactions` → calculate `stmt_month/year`.

## 37) Rule Engine & Sample DSL

```yaml
- when: desc ~ '(?i)manav|sebze|meyve'
  then:
    main: 'Shopping'
    sub: 'Fruit & Veg'
- when: desc ~ '(?i)fırın|unlu'
  then:
    main: 'Shopping'
    sub: 'Bakery'
- when: merchant ~ '(?i)uber|taksi'
  then:
    main: 'Transport'
    sub: 'Taxi'
- when: desc ~ '(?i)spotify|netflix'
  then:
    main: 'Subscriptions'
    sub: 'Digital/Streaming'
```

**Tip**: Attach confidence scores; ask for user confirmation when low.

## 38) Themes (≥5) & Palettes

* **NeoMint**: `#2BD9A9, #0E1C1B, #F5FFFB, #0AAE8A, #EAF7F4`
* **DeepOcean**: `#2E86DE, #0B2038, #F2F6FA, #1B4F72, #E8EEF6`
* **SunsetCoral**: `#FF6F61, #2B1B1B, #FFF5F3, #C6423A, #FBE9E7`
* **CharcoalGold**: `#D4AF37, #1C1C1C, #FAFAFA, #816A00, #EFE9D1`
* **IvoryForest**: `#2F855A, #1A202C, #F7FAFC, #276749, #E6FFFA`
  Charts derive 6–8 tonal steps from the active theme palette.

## 39) AI Assistant

* **Popover**: Quick buttons (Free) — “Top 3 spending categories”, “Upcoming risky payments”, “Budget overruns”.
* **Full-Screen Chat** (Pro+): Free-form commands; **Actions** include creating/editing categories, bulk tagging, rule generation.
* **Add API Flow**: Settings → AI → **Add API** → **Select Plan** (upsell) → Save key → Model greeting.

## 40) Multi-language & Currency

* **First Run**: Detect and confirm language/currency.
* **Quick Switch** shortcuts: Profile and side menu.
* **FX Updates**: Daily/manual; apply changes to past/future/single entries.

## 41) Notifications & Reminders

* Credit card statements / bills / subscriptions **T‑2 days** before due.
* Quick actions from notification: “Log ₺250 food today.”

## 42) Security & Compliance

* Local **AES-256**, transport **TLS**; minimize PII; encrypted keys.
* **Watermark**: Sentinel column + metadata in CSV/XLSX.
* **KVKK/GDPR**: Consent workflows, export/delete endpoints.

## 43) QA Scenarios

* **Date vs. Statement** boundary tests (days 28–31).
* **Undo/Redo** stress with heavy add/remove cycles.
* **OCR** low-light/mixed-language/multi-page PDFs.
* **Theme** accessibility contrast audits.
