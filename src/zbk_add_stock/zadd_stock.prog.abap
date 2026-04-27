*&---------------------------------------------------------------------*
*& Report ZADD_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZADD_STOCK.
 DATA : ls_stock TYPE zbk_stock.

 PARAMETERS:
 P_matnr TYPE c LENGTH 10,
 P_whid TYPE c LENGTH 5,
 P_qty TYPE p LENGTH 13 DECIMALS 2.

 START-OF-SELECTION.
 ls_stock-matnr = p_matnr.
 ls_stock-wh_id = p_whid .
 ls_stock-quantity = p_qty.
 ls_stock-update_at = sy-datum.

 INSERT zbk_stock FROM ls_stock.

 IF sy-subrc = 0.
   WRITE: / 'Stok başarıyla eklendi.'.
 ELSE.
   WRITE:/ 'Stok eklenemedi'.

 ENDIF.
