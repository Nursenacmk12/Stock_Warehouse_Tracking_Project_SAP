FUNCTION z_api_get_stock_list.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  ZBK_STOCK-MATNR OPTIONAL
*"     VALUE(IV_WH_ID) TYPE  ZBK_STOCK-WH_ID OPTIONAL
*"  TABLES
*"      ET_STOCK STRUCTURE  ZBK_STOCK
*"----------------------------------------------------------------------

  DATA: lt_stock TYPE TABLE OF zbk_stock,
        ls_stock TYPE zbk_stock.

  SELECT matnr wh_id quantity update_at
    FROM zbk_stock
    INTO TABLE lt_stock.

  IF iv_matnr IS NOT INITIAL.
    DELETE lt_stock WHERE matnr <> iv_matnr.
  ENDIF.

  IF iv_wh_id IS NOT INITIAL.
    DELETE lt_stock WHERE wh_id <> iv_wh_id.
  ENDIF.

  LOOP AT lt_stock INTO ls_stock.
    APPEND ls_stock TO et_stock.
  ENDLOOP.

ENDFUNCTION.
