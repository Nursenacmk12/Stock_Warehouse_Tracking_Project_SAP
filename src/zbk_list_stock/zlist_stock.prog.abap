*&---------------------------------------------------------------------*
*& Report ZLIST_STOCK
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZLIST_STOCK.


TYPES: BEGIN OF ty_stock_list,
         matnr    TYPE c LENGTH 10,
         matname  TYPE c LENGTH 50,
         wh_id    TYPE c LENGTH 5,
         wh_name  TYPE c LENGTH 50,
         quantity TYPE p LENGTH 13 DECIMALS 2,
       END OF ty_stock_list.

DATA: lt_stock_list TYPE TABLE OF ty_stock_list,
      ls_stock_list TYPE ty_stock_list.

SELECT a~matnr,
       b~matname,
       a~wh_id,
       c~wh_name,
       a~quantity
  INTO TABLE @lt_stock_list
  FROM zbk_stock AS a
  INNER JOIN zbk_materials AS b
    ON a~matnr = b~matnr
  INNER JOIN zbk_warehouses AS c
    ON a~wh_id = c~wh_id.

IF sy-subrc = 0.
  WRITE: / 'Material Code', 20 'Material Name', 75 'Warehouse Code',
           95 'Warehouse Name', 150 'Quantity'.
  ULINE.

  LOOP AT lt_stock_list INTO ls_stock_list.
    WRITE: / ls_stock_list-matnr,
             20 ls_stock_list-matname,
             75 ls_stock_list-wh_id,
             95 ls_stock_list-wh_name,
             150 ls_stock_list-quantity.
  ENDLOOP.
ELSE.
  WRITE: / 'Kayıt bulunamadı.'.
ENDIF.
