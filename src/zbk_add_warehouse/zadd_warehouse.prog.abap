*&---------------------------------------------------------------------*
*& Report ZADD_WAREHOUSE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZADD_WAREHOUSE.


DATA: ls_warehouse TYPE zbk_warehouses.

PARAMETERS:
  p_whid TYPE c LENGTH 5,
  p_name TYPE c LENGTH 50,
  p_loc  TYPE c LENGTH 50.

START-OF-SELECTION.

  ls_warehouse-wh_id      = p_whid.
  ls_warehouse-wh_name    = p_name.
  ls_warehouse-location   = p_loc.
  ls_warehouse-created_at = sy-datum.

  INSERT zbk_warehouses FROM ls_warehouse.

  IF sy-subrc = 0.
    WRITE: / 'Warehouse başarıyla eklendi'.
  ELSE.
    WRITE: / 'Warehouse eklenemedi'.
  ENDIF.
