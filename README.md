# Stock_Warehouse_Tracking_Project_SAP

# 📦 SAP ABAP - Stock & Warehouse Management

Bu proje, SAP ABAP kullanılarak geliştirilmiş **stok ve depo yönetim sistemi (SAP backend)** uygulamasıdır.
Amaç, SAP içerisinde stok verisini yönetmek ve bu veriyi function module’lar aracılığıyla dış sistemlere açılabilir hale getirmektir.
---
## 🎯 Proje Amacı

Bu sistem ile:

* Ürün (malzeme) yönetimi yapılır
* Depo yönetimi yapılır
* Stok miktarları takip edilir
* Depolar arası stok transferi gerçekleştirilir
---
## 🏗️ Sistem Yapısı

Proje 3 ana bölümden oluşur:
---
### 📊 1. Tablolar (Data Layer)

#### 🔹 `ZBK_MATERIALS`

Ürün bilgilerini tutar.
```text
MATNR       → Ürün kodu
MATNAME     → Ürün adı
UNIT        → Birim
CREATED_AT  → Oluşturma tarihi
```
---
#### 🔹 `ZBK_WAREHOUSES`

Depo bilgilerini tutar.

```text
WH_ID       → Depo kodu
WH_NAME     → Depo adı
LOCATION    → Lokasyon
CREATED_AT  → Oluşturma tarihi
```
---
#### 🔹 `ZBK_STOCK`
Stok miktarını tutar.

```text
MATNR       → Ürün kodu
WH_ID       → Depo kodu
QUANTITY    → Stok miktarı
UPDATE_AT   → Güncelleme tarihi
```
---
### ⚙️ 2. ABAP Programları

#### 🔹 `ZADD_MATERIAL`

Yeni ürün ekler.

#### 🔹 `ZADD_WAREHOUSE`

Yeni depo ekler.

#### 🔹 `ZADD_STOCK`

Stok kaydı oluşturur.

#### 🔹 `ZLIST_STOCK`

Stokları listeler.

---

### 🌐 3. Function Modules (API Layer)

Tüm function module’lar aşağıdaki function group altında toplanmıştır:

```text
ZFG_STOCK_API
```
---

#### 🔹 `Z_API_GET_STOCK_LIST`

Stok listesini getirir (filtre destekli)

---

#### 🔹 `Z_GET_WAREHOUSE_LIST`

Tüm depoları listeler
---
#### 🔹 `Z_GET_STOCK_DETAIL`
Tek ürün + depo için stok detayını getirir---

#### 🔹 `Z_CREATE_PRODUCT`
Yeni ürün oluşturur
---
#### 🔹 `Z_STOCK_IN`
Stok girişi yapar
---
#### 🔹 `Z_STOCK_OUT`

Stok çıkışı yapar

---

#### 🔹 `Z_TRANSFER_STOCK`

Depolar arası stok transferi yapar

---

## 🧠 İş Mantığı

### ➕ Stok Girişi

* Mevcut kayıt varsa artırılır
* Yoksa yeni kayıt oluşturulur

---

### ➖ Stok Çıkışı

* Yeterli stok varsa düşülür
* Yetersizse işlem iptal edilir

---

### 🔄 Stok Transferi

* Kaynak depodan düşülür
* Hedef depoya eklenir

---

## 📁 Proje Yapısı (abapGit)

```text
src/
 ├── tbl_materials
 ├── zbk_tblwarehouses
 ├── zbk_tblstock
 ├── zbk_add_material
 ├── zbk_add_warehouse
 ├── zbk_add_stock
 ├── zbk_list_stock
 └── zfg_stockapi
```

---

## 🛠️ Kullanılan Teknolojiler

* SAP NetWeaver AS ABAP 7.52
* ABAP
* RFC (Remote Function Modules)
* abapGit

---

## 📌 Notlar

* Tüm function module’lar **Remote-Enabled Module** olarak tanımlanmıştır
* Sistem, dış backend sistemlere veri sağlamak için uygundur
* SAP içinde tamamen bağımsız çalışabilir

---

## 👨‍💻 Geliştiriciler

Ahmet Seyyit Köse
Nursena Çamkömürü
