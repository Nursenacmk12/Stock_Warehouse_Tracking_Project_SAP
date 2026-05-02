FUNCTION z_get_warehouse_list.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      ET_WAREHOUSES STRUCTURE  ZBK_WAREHOUSES
*"----------------------------------------------------------------------

  DATA: lt_warehouses TYPE TABLE OF zbk_warehouses,
        ls_warehouse  TYPE zbk_warehouses.

  SELECT wh_id
         wh_name
         location
         created_at
    FROM zbk_warehouses
    INTO TABLE lt_warehouses.

  LOOP AT lt_warehouses INTO ls_warehouse.
    APPEND ls_warehouse TO et_warehouses.
  ENDLOOP.

ENDFUNCTION.
