<h1 align="center">📦 Stock Warehouse Tracking Project SAP</h1>
<h3 align="center">SAP ABAP ile Geliştirilmiş Stok ve Depo Yönetim Sistemi</h3>

<p align="center">
  SAP ABAP kullanılarak geliştirilen, stok yönetimi, depo takibi ve depolar arası transfer süreçlerini yöneten backend odaklı proje.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/SAP-ABAP-0FAAFF?style=for-the-badge&logo=sap&logoColor=white" />
  <img src="https://img.shields.io/badge/SAP%20NetWeaver-7.52-0FAAFF?style=for-the-badge&logo=sap&logoColor=white" />
  <img src="https://img.shields.io/badge/RFC-Remote%20Function%20Modules-4CAF50?style=for-the-badge" />
  <img src="https://img.shields.io/badge/abapGit-Version%20Control-F05032?style=for-the-badge&logo=git&logoColor=white" />
  <img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge" />
</p>

---

## 🎯 Proje Hakkında

Bu proje, **SAP ABAP** kullanılarak geliştirilmiş bir **stok ve depo yönetim sistemi (SAP backend)** uygulamasıdır.  
Amaç, SAP içerisinde stok verilerini yönetmek ve bu verileri **Function Module** yapıları aracılığıyla dış sistemlere açılabilir hale getirmektir.

Sistem sayesinde ürünler, depolar ve stok hareketleri merkezi olarak yönetilebilir. Ayrıca depolar arası stok transferi gibi temel lojistik işlemler de desteklenmektedir.

---

## ✨ Proje Amacı

Bu sistem ile:

- 📦 Ürün (malzeme) yönetimi yapılır
- 🏬 Depo yönetimi gerçekleştirilir
- 📊 Stok miktarları takip edilir
- 🔄 Depolar arası stok transferi yapılır
- 🌐 SAP içindeki veriler dış sistemlere açılabilir hale getirilir

---

## 🏗️ Sistem Yapısı

Proje 3 ana bölümden oluşmaktadır:

1. **Tablolar (Data Layer)**
2. **ABAP Programları**
3. **Function Modules (API Layer)**

---

## 📊 1. Tablolar (Data Layer)

### 🔹 `ZBK_MATERIALS`
Ürün bilgilerini tutar.

```text
MATNR       → Ürün kodu
MATNAME     → Ürün adı
UNIT        → Birim
CREATED_AT  → Oluşturma tarihi

## 📊 1. Tablolar (Data Layer)

### 🔹 `ZBK_MATERIALS`

Bu tablo, sistemde tanımlı olan **ürün (malzeme) ana verilerini** tutar.  
Stok yönetimi yapılabilmesi için sistemdeki tüm ürünler bu tabloda kayıtlı olmalıdır.

#### 📌 Amaç

- Ürün bilgilerini merkezi olarak saklamak  
- Stok işlemlerinde kullanılacak ürün referansını oluşturmak  
- Diğer tablolar (özellikle `ZBK_STOCK`) ile ilişki kurmak  

#### 🧠 Kullanım Senaryosu

- Yeni ürün oluşturulurken (`Z_CREATE_PRODUCT`) bu tabloya kayıt eklenir  
- Stok işlemlerinde (`Z_STOCK_IN`, `Z_STOCK_OUT`, `Z_TRANSFER_STOCK`) ürün doğrulaması için kullanılır  
- Raporlama ve listeleme işlemlerinde ürün adı bilgisi buradan alınır  

👨‍💻 Geliştiriciler
Ahmet Seyyit Köse
Nursena Çamkömürü

