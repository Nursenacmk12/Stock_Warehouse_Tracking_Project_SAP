class ZCL_STOCK_HTTP_HANDLER definition
  public
  final
  create public .

public section.

  interfaces IF_HTTP_EXTENSION .
protected section.
private section.
ENDCLASS.



CLASS ZCL_STOCK_HTTP_HANDLER IMPLEMENTATION.


METHOD if_http_extension~handle_request.

  DATA lv_method TYPE string.
  DATA lv_uri    TYPE string.
  DATA lv_body   TYPE string.
  DATA lv_json   TYPE string.
  DATA lv_today  TYPE sy-datum.
  DATA lv_docno  TYPE string.

  lv_today = sy-datum.

  lv_method = server->request->get_header_field( name = '~request_method' ).
  lv_uri    = server->request->get_header_field( name = '~request_uri' ).
  lv_body   = server->request->get_cdata( ).

  TRANSLATE lv_method TO UPPER CASE.
  TRANSLATE lv_uri TO LOWER CASE.

  server->response->set_header_field(
    name  = 'Content-Type'
    value = 'application/json; charset=utf-8'
  ).

  "============================================================
  " JSON TYPE DEFINITIONS
  "============================================================

  TYPES: BEGIN OF ty_stock_json,
           matnr      TYPE zbk_stock-matnr,
           wh_id      TYPE zbk_stock-wh_id,
           quantity   TYPE zbk_stock-quantity,
           updated_at TYPE zbk_stock-update_at,
         END OF ty_stock_json.

  TYPES: BEGIN OF ty_product_json,
           matnr      TYPE zbk_materials-matnr,
           mat_name   TYPE zbk_materials-matname,
           unit       TYPE zbk_materials-unit,
           created_at TYPE zbk_materials-created_at,
         END OF ty_product_json.

  TYPES: BEGIN OF ty_product_in,
           matnr    TYPE zbk_materials-matnr,
           mat_name TYPE zbk_materials-matname,
           matname  TYPE zbk_materials-matname,
           name     TYPE zbk_materials-matname,
           unit     TYPE zbk_materials-unit,
         END OF ty_product_in.

  TYPES: BEGIN OF ty_stock_move_in,
           matnr    TYPE zbk_stock-matnr,
           wh_id    TYPE zbk_stock-wh_id,
           whid     TYPE zbk_stock-wh_id,
           quantity TYPE zbk_stock-quantity,
         END OF ty_stock_move_in.

  TYPES: BEGIN OF ty_transfer_in,
           matnr        TYPE zbk_stock-matnr,
           source_wh_id TYPE zbk_stock-wh_id,
           target_wh_id TYPE zbk_stock-wh_id,
           from_wh_id   TYPE zbk_stock-wh_id,
           to_wh_id     TYPE zbk_stock-wh_id,
           quantity     TYPE zbk_stock-quantity,
         END OF ty_transfer_in.

  TYPES: BEGIN OF ty_warehouse_json,
         wh_id      TYPE zbk_warehouses-wh_id,
         wh_name    TYPE zbk_warehouses-wh_name,
         location   TYPE zbk_warehouses-location,
         created_at TYPE zbk_warehouses-created_at,
       END OF ty_warehouse_json.

  DATA lt_warehouses TYPE STANDARD TABLE OF ty_warehouse_json.

  DATA lt_stock    TYPE STANDARD TABLE OF ty_stock_json.
  DATA lt_products TYPE STANDARD TABLE OF ty_product_json.

  DATA ls_product_in TYPE ty_product_in.
  DATA ls_move_in    TYPE ty_stock_move_in.
  DATA ls_transfer   TYPE ty_transfer_in.

  DATA ls_material TYPE zbk_materials.
  DATA ls_stock    TYPE zbk_stock.

  DATA lv_matnr       TYPE zbk_stock-matnr.
  DATA lv_wh_id       TYPE zbk_stock-wh_id.
  DATA lv_source_wh   TYPE zbk_stock-wh_id.
  DATA lv_target_wh   TYPE zbk_stock-wh_id.
  DATA lv_quantity    TYPE zbk_stock-quantity.
  DATA lv_old_qty     TYPE zbk_stock-quantity.
  DATA lv_new_qty     TYPE zbk_stock-quantity.
  DATA lv_matname     TYPE zbk_materials-matname.

  "============================================================
  " POST /stock/transfer
  "============================================================
  IF lv_uri CS '/stock/transfer' AND lv_method = 'POST'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_body
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_transfer
    ).

    lv_matnr     = ls_transfer-matnr.
    lv_source_wh = ls_transfer-source_wh_id.
    lv_target_wh = ls_transfer-target_wh_id.
    lv_quantity  = ls_transfer-quantity.

    IF lv_source_wh IS INITIAL.
      lv_source_wh = ls_transfer-from_wh_id.
    ENDIF.

    IF lv_target_wh IS INITIAL.
      lv_target_wh = ls_transfer-to_wh_id.
    ENDIF.

    IF lv_matnr IS INITIAL OR lv_source_wh IS INITIAL OR lv_target_wh IS INITIAL OR lv_quantity <= 0.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Eksik veya hatali transfer parametresi."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    SELECT SINGLE quantity
      FROM zbk_stock
      INTO @lv_old_qty
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_source_wh.

    IF sy-subrc <> 0 OR lv_old_qty < lv_quantity.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Kaynak depoda yeterli stok yok."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    lv_new_qty = lv_old_qty - lv_quantity.

    UPDATE zbk_stock
      SET quantity  = @lv_new_qty,
          update_at = @lv_today
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_source_wh.

    CLEAR lv_old_qty.

    SELECT SINGLE quantity
      FROM zbk_stock
      INTO @lv_old_qty
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_target_wh.

    IF sy-subrc = 0.

      lv_new_qty = lv_old_qty + lv_quantity.

      UPDATE zbk_stock
        SET quantity  = @lv_new_qty,
            update_at = @lv_today
        WHERE matnr = @lv_matnr
          AND wh_id = @lv_target_wh.

    ELSE.

      CLEAR ls_stock.
      ls_stock-matnr     = lv_matnr.
      ls_stock-wh_id     = lv_target_wh.
      ls_stock-quantity  = lv_quantity.
      ls_stock-update_at = lv_today.

      INSERT zbk_stock FROM @ls_stock.

    ENDIF.

    COMMIT WORK AND WAIT.

    CONCATENATE 'DOC' sy-datum sy-uzeit INTO lv_docno.
    CONCATENATE '{"success":true,"sapDocNo":"' lv_docno '","errorMessage":null}' INTO lv_json.

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " POST /stock/in
  "============================================================
  IF lv_uri CS '/stock/in' AND lv_method = 'POST'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_body
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_move_in
    ).

    lv_matnr    = ls_move_in-matnr.
    lv_wh_id    = ls_move_in-wh_id.
    lv_quantity = ls_move_in-quantity.

    IF lv_wh_id IS INITIAL.
      lv_wh_id = ls_move_in-whid.
    ENDIF.

    IF lv_matnr IS INITIAL OR lv_wh_id IS INITIAL OR lv_quantity <= 0.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Eksik veya hatali stok giris parametresi."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    SELECT SINGLE quantity
      FROM zbk_stock
      INTO @lv_old_qty
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_wh_id.

    IF sy-subrc = 0.

      lv_new_qty = lv_old_qty + lv_quantity.

      UPDATE zbk_stock
        SET quantity  = @lv_new_qty,
            update_at = @lv_today
        WHERE matnr = @lv_matnr
          AND wh_id = @lv_wh_id.

    ELSE.

      CLEAR ls_stock.
      ls_stock-matnr     = lv_matnr.
      ls_stock-wh_id     = lv_wh_id.
      ls_stock-quantity  = lv_quantity.
      ls_stock-update_at = lv_today.

      INSERT zbk_stock FROM @ls_stock.

    ENDIF.

    COMMIT WORK AND WAIT.

    CONCATENATE 'DOC' sy-datum sy-uzeit INTO lv_docno.
    CONCATENATE '{"success":true,"sapDocNo":"' lv_docno '","errorMessage":null}' INTO lv_json.

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " POST /stock/out
  "============================================================
  IF lv_uri CS '/stock/out' AND lv_method = 'POST'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_body
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_move_in
    ).

    lv_matnr    = ls_move_in-matnr.
    lv_wh_id    = ls_move_in-wh_id.
    lv_quantity = ls_move_in-quantity.

    IF lv_wh_id IS INITIAL.
      lv_wh_id = ls_move_in-whid.
    ENDIF.

    IF lv_matnr IS INITIAL OR lv_wh_id IS INITIAL OR lv_quantity <= 0.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Eksik veya hatali stok cikis parametresi."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    SELECT SINGLE quantity
      FROM zbk_stock
      INTO @lv_old_qty
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_wh_id.

    IF sy-subrc <> 0 OR lv_old_qty < lv_quantity.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Yeterli stok yok."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    lv_new_qty = lv_old_qty - lv_quantity.

    UPDATE zbk_stock
      SET quantity  = @lv_new_qty,
          update_at = @lv_today
      WHERE matnr = @lv_matnr
        AND wh_id = @lv_wh_id.

    COMMIT WORK AND WAIT.

    CONCATENATE 'DOC' sy-datum sy-uzeit INTO lv_docno.
    CONCATENATE '{"success":true,"sapDocNo":"' lv_docno '","errorMessage":null}' INTO lv_json.

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " GET /warehouses
  "============================================================
  IF lv_uri CS '/warehouses' AND lv_method = 'GET'.

    SELECT wh_id,
           wh_name,
           location,
           created_at
      FROM zbk_warehouses
      INTO TABLE @lt_warehouses.

    lv_json = /ui2/cl_json=>serialize(
      data        = lt_warehouses
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.


  "============================================================
  " GET /products
  "============================================================
  IF lv_uri CS '/products' AND lv_method = 'GET'.

    SELECT matnr,
           matname AS mat_name,
           unit,
           created_at
      FROM zbk_materials
      INTO TABLE @lt_products.

    lv_json = /ui2/cl_json=>serialize(
      data        = lt_products
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " POST /products
  "============================================================
  IF lv_uri CS '/products' AND lv_method = 'POST'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json        = lv_body
        pretty_name = /ui2/cl_json=>pretty_mode-camel_case
      CHANGING
        data        = ls_product_in
    ).

    lv_matnr   = ls_product_in-matnr.
    lv_matname = ls_product_in-mat_name.

    IF lv_matname IS INITIAL.
      lv_matname = ls_product_in-matname.
    ENDIF.

    IF lv_matname IS INITIAL.
      lv_matname = ls_product_in-name.
    ENDIF.

    IF lv_matnr IS INITIAL OR lv_matname IS INITIAL OR ls_product_in-unit IS INITIAL.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Eksik urun parametresi."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    CLEAR ls_material.
    ls_material-matnr      = lv_matnr.
    ls_material-matname    = lv_matname.
    ls_material-unit       = ls_product_in-unit.
    ls_material-created_at = lv_today.

    INSERT zbk_materials FROM @ls_material.

    IF sy-subrc <> 0.

      lv_json = '{"success":false,"sapDocNo":null,"errorMessage":"Urun eklenemedi. Kayit zaten var olabilir."}'.

      server->response->set_status(
        code   = 400
        reason = 'Bad Request'
      ).

      server->response->set_cdata( lv_json ).
      RETURN.

    ENDIF.

    COMMIT WORK AND WAIT.

    CONCATENATE 'DOC' sy-datum sy-uzeit INTO lv_docno.
    CONCATENATE '{"success":true,"sapDocNo":"' lv_docno '","errorMessage":null}' INTO lv_json.

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " GET /stock
  "============================================================
  IF lv_uri CS '/stock' AND lv_method = 'GET'.

    lv_matnr = server->request->get_form_field( name = 'matnr' ).
    lv_wh_id = server->request->get_form_field( name = 'whId' ).

    IF lv_wh_id IS INITIAL.
      lv_wh_id = server->request->get_form_field( name = 'wh_id' ).
    ENDIF.

    IF lv_matnr IS INITIAL AND lv_wh_id IS INITIAL.

      SELECT matnr,
             wh_id,
             quantity,
             update_at AS updated_at
        FROM zbk_stock
        INTO TABLE @lt_stock.

    ELSEIF lv_matnr IS NOT INITIAL AND lv_wh_id IS INITIAL.

      SELECT matnr,
             wh_id,
             quantity,
             update_at AS updated_at
        FROM zbk_stock
        WHERE matnr = @lv_matnr
        INTO TABLE @lt_stock.

    ELSEIF lv_matnr IS INITIAL AND lv_wh_id IS NOT INITIAL.

      SELECT matnr,
             wh_id,
             quantity,
             update_at AS updated_at
        FROM zbk_stock
        WHERE wh_id = @lv_wh_id
        INTO TABLE @lt_stock.

    ELSE.

      SELECT matnr,
             wh_id,
             quantity,
             update_at AS updated_at
        FROM zbk_stock
        WHERE matnr = @lv_matnr
          AND wh_id = @lv_wh_id
        INTO TABLE @lt_stock.

    ENDIF.

    lv_json = /ui2/cl_json=>serialize(
      data        = lt_stock
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    server->response->set_status(
      code   = 200
      reason = 'OK'
    ).

    server->response->set_cdata( lv_json ).
    RETURN.

  ENDIF.

  "============================================================
  " UNKNOWN ENDPOINT
  "============================================================
  lv_json = '{"success":false,"errorMessage":"Endpoint bulunamadi."}'.

  server->response->set_status(
    code   = 404
    reason = 'Not Found'
  ).

  server->response->set_cdata( lv_json ).

ENDMETHOD.
ENDCLASS.
