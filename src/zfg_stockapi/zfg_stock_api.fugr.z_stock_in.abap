FUNCTION z_stock_in.
*"----------------------------------------------------------------------

*"----------------------------------------------------------------------

  DATA ls_stock TYPE zbk_stock.

  CLEAR: ev_success, ev_doc_no, ev_error.
  ev_success = abap_false.

  IF iv_matnr IS INITIAL OR iv_wh_id IS INITIAL OR iv_quantity <= 0.
    ev_error = 'Gecersiz parametre.'.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zbk_stock INTO ls_stock
    WHERE matnr = iv_matnr AND wh_id = iv_wh_id.

  IF sy-subrc = 0.
    ls_stock-quantity = ls_stock-quantity + iv_quantity.
    ls_stock-update_at = sy-datum.
    UPDATE zbk_stock FROM ls_stock.
  ELSE.
    CLEAR ls_stock.
    ls_stock-matnr = iv_matnr.
    ls_stock-wh_id = iv_wh_id.
    ls_stock-quantity = iv_quantity.
    ls_stock-update_at = sy-datum.
    INSERT zbk_stock FROM ls_stock.
  ENDIF.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    ev_success = abap_true.
    IF iv_ref_no IS NOT INITIAL.
      ev_doc_no = iv_ref_no.
    ELSE.
      CONCATENATE 'IN' sy-datum sy-uzeit INTO ev_doc_no.
      SHIFT ev_doc_no LEFT DELETING LEADING space.
    ENDIF.
  ELSE.
    ev_error = 'Stok girisi kaydedilemedi.'.
  ENDIF.

ENDFUNCTION.
