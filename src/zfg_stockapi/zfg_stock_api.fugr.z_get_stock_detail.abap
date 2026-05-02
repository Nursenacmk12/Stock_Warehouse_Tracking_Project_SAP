FUNCTION z_get_stock_detail.
*"----------------------------------------------------------------------
*" Açıklama:
*" Belirli bir ürünün belirli bir depodaki stok kaydını getirir.
*"
*" Kullanım Amacı:
*" - Ürün ve depo bazlı stok detayını sorgulamak
*" - Backend tarafında stok detay ekranına veri sağlamak
*"
*" Giriş:
*" IV_MATNR : Ürün kodu
*" IV_WH_ID : Depo kodu
*"
*" Çıkış:
*" ES_STOCK : Bulunan stok kaydı
*" EV_FOUND : Kayıt bulunduysa abap_true, bulunamadıysa abap_false
*"----------------------------------------------------------------------

  DATA ls_stock TYPE zbk_stock.

  CLEAR: es_stock, ev_found.

  SELECT SINGLE matnr wh_id quantity update_at
    FROM zbk_stock
    INTO ls_stock
    WHERE matnr = iv_matnr
      AND wh_id = iv_wh_id.

  IF sy-subrc = 0.
    es_stock = ls_stock.
    ev_found = abap_true.
  ELSE.
    CLEAR es_stock.
    ev_found = abap_false.
  ENDIF.

ENDFUNCTION.
