<h1 align="center">📦 Stock Warehouse Tracking — SAP ABAP</h1>

<h3 align="center">SAP ABAP ile Geliştirilmiş Stok ve Depo Yönetim Sistemi</h3>

<p align="center">
  SAP ABAP kullanılarak geliştirilen; stok yönetimi, depo takibi ve depolar arası transfer süreçlerini kapsayan backend odaklı bir kurumsal uygulamadır.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP-0FAAFF?style=for-the-badge&logo=sap&logoColor=white" />
  <img src="https://img.shields.io/badge/SAP%20NetWeaver-7.52-0FAAFF?style=for-the-badge&logo=sap&logoColor=white" />
  <img src="https://img.shields.io/badge/RFC-Remote%20Function%20Modules-4CAF50?style=for-the-badge" />
  <img src="https://img.shields.io/badge/abapGit-Versiyon%20Kontrol-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/Durum-Aktif-success?style=for-the-badge" />
</p>

---

## 🎯 Proje Hakkında

Bu proje, **SAP ABAP** kullanılarak geliştirilmiş bir **stok ve depo yönetim sistemi** uygulamasıdır. Temel amaç; SAP içerisinde stok verilerini merkezi olarak yönetmek ve bu verileri **Function Module** yapıları aracılığıyla dış sistemlere açık hâle getirmektir.

Sistem sayesinde ürünler, depolar ve stok hareketleri tek bir noktadan yönetilebilir. Bunun yanı sıra depolar arası stok transferi gibi temel lojistik işlemler de atomik ve tutarlı biçimde desteklenmektedir.

---

## ✨ Temel Özellikler

| # | Özellik | Açıklama |
|---|---------|----------|
| 1 | 📦 Ürün Yönetimi | Malzeme tanımlama ve güncelleme |
| 2 | 🏬 Depo Yönetimi | Fiziksel depo ekleme ve takibi |
| 3 | 📊 Stok Takibi | Anlık stok miktarı görüntüleme ve raporlama |
| 4 | 🔄 Stok Transferi | Depolar arası atomik virman işlemi |
| 5 | 🌐 RFC Entegrasyonu | Dış sistemlere veri açma (Node.js, Python, .NET vb.) |

---

## 🏗️ Sistem Mimarisi

Proje, aşağıdaki 3 ana katmandan oluşmaktadır:

```
┌──────────────────────────────────────────┐
│          API Layer (Function Modules)     │  ← RFC ile dış dünya
├──────────────────────────────────────────┤
│          Business Logic (ABAP Programs)   │  ← SAP içi yönetim
├──────────────────────────────────────────┤
│          Data Layer (Custom Tables)       │  ← Kalıcı veri saklama
└──────────────────────────────────────────┘
```

---

## 📊 Veri Katmanı — Tablolar

### 🔹 `ZBK_MATERIALS` — Ürün Bilgileri

| Alan | Tip | Açıklama |
|------|-----|----------|
| **MATNR** | PK | Ürün Kodu |
| **MATNAME** | CHAR | Ürün Adı |
| **UNIT** | UNIT | Birim (AD, KG vb.) |
| **CREATED_AT** | DATS | Oluşturma Tarihi |

### 🔹 `ZBK_WAREHOUSES` — Depo Bilgileri

| Alan | Tip | Açıklama |
|------|-----|----------|
| **WH_ID** | PK | Depo Kodu |
| **WH_NAME** | CHAR | Depo Adı |
| **LOCATION** | CHAR | Lokasyon |
| **CREATED_AT** | DATS | Oluşturma Tarihi |

### 🔹 `ZBK_STOCK` — Stok Durumu

| Alan | Tip | Açıklama |
|------|-----|----------|
| **MATNR** | FK | Ürün Kodu |
| **WH_ID** | FK | Depo Kodu |
| **QUANTITY** | QUAN | Stok Miktarı |
| **UPDATED_AT** | DATS | Son Güncelleme Tarihi |

---

## ⚙️ İş Katmanı — ABAP Programları

| Program | Açıklama |
|---------|----------|
| `ZADD_MATERIAL` | Yeni ürün / malzeme tanımlaması |
| `ZADD_WAREHOUSE` | Sisteme yeni fiziksel depo ekleme |
| `ZADD_STOCK` | Manuel stok girişi veya düzeltme |
| `ZLIST_STOCK` | Mevcut stok durumunu raporlama |

---

## 🌐 API Katmanı — Function Modules

Tüm modüller **`ZFG_STOCK_API`** Function Group altında toplanmış olup **Remote-Enabled** olarak tanımlanmıştır.

| Function Module | Açıklama |
|-----------------|----------|
| `Z_API_GET_STOCK_LIST` | Filtreleme seçenekleriyle stok listesi döner |
| `Z_GET_WAREHOUSE_LIST` | Tanımlı tüm depoları listeler |
| `Z_GET_STOCK_DETAIL` | Belirli ürün ve deponun detay bilgisini verir |
| `Z_CREATE_PRODUCT` | Dış sistemden SAP'ye ürün aktarımı sağlar |
| `Z_STOCK_IN` | Depoya mal girişi işlemini tetikler |
| `Z_STOCK_OUT` | Depodan mal çıkışı işlemini tetikler |
| `Z_TRANSFER_STOCK` | İki depo arası atomik stok transferi yapar |

---

## 🧠 İş Mantığı

```
Stok Girişi:
  ├─ Kayıt var → Mevcut miktara ekle
  └─ Kayıt yok → Yeni stok kaydı oluştur

Stok Çıkışı:
  ├─ Yeterli stok var → Miktarı düş
  └─ Yetersiz stok    → Hata mesajı döndür (işlem iptal)

Stok Transferi (Atomik):
  ├─ Kaynak depodan eksilt
  └─ Hedef depoya ekle
     └─ (COMMIT / ROLLBACK birlikte uygulanır)
```

---

## 📁 Proje Dizin Yapısı

```
src/
 ├── zbk_tblmaterials      → Ürün tablosu
 ├── zbk_tblwarehouses     → Depo tablosu
 ├── zbk_tblstock          → Stok tablosu
 ├── zbk_add_material      → Ürün ekleme programı
 ├── zbk_add_warehouse     → Depo ekleme programı
 ├── zbk_add_stock         → Stok giriş programı
 ├── zbk_list_stock        → Stok listeleme raporu
 └── zfg_stock_api/        → Function Group (API katmanı)
      ├── z_api_get_stock_list
      ├── z_get_warehouse_list
      ├── z_get_stock_detail
      ├── z_create_product
      ├── z_stock_in
      ├── z_stock_out
      └── z_transfer_stock
```

---

## 🛠️ Kullanılan Teknolojiler

| Teknoloji | Versiyon / Açıklama |
|-----------|---------------------|
| SAP NetWeaver AS ABAP | 7.52 |
| ABAP Objects | Nesne yönelimli yapılar |
| RFC (Remote Function Call) | Dış sistem entegrasyonu |
| abapGit | Git tabanlı versiyon kontrolü |

---

## 🚀 Projenin Güçlü Yönleri

- ✅ **Katmanlı mimari** — Database → Business Logic → API
- ✅ **Dış sistem entegrasyonu** — RFC ile Node.js, Python, .NET bağlanabilir
- ✅ **Atomik işlemler** — Transfer ve çıkış işlemlerinde veri tutarlılığı garantilenir
- ✅ **Temiz kod yapısı** — Okunabilir ve sürdürülebilir ABAP standartları
- ✅ **abapGit desteği** — Kolay taşınabilirlik ve versiyon takibi

---

## 🔮 Gelecek Geliştirmeler

- [ ] OData servisi ile SAP Fiori arayüz entegrasyonu
- [ ] Stok hareket loglarının tutulması (audit trail)
- [ ] Minimum stok eşiği ve uyarı mekanizması
- [ ] Birim test (ABAP Unit) kapsamının genişletilmesi

---

## 👨‍💻 Geliştiriciler

| İsim | Rol |
|------|-----|
| **Ahmet Seyyit Köse** | ABAP Geliştirici |
| **Nursena Çamkömürü** | ABAP Geliştirici |

---

## 📄 Lisans

Bu proje; eğitim, öğrenme ve portfolyo amaçlı olarak paylaşılmıştır. Ticari kullanım için geliştiricilerle iletişime geçiniz.
