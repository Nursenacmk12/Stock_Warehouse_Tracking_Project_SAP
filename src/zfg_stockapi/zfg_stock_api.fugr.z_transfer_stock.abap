FUNCTION z_transfer_stock.
*"----------------------------------------------------------------------
*"----------------------------------------------------------------------

  DATA: ls_src  TYPE zbk_stock,
        ls_dest TYPE zbk_stock.

  CLEAR: ev_success, ev_doc_no, ev_error.
  ev_success = abap_false.

  IF iv_matnr IS INITIAL OR iv_src_wh IS INITIAL OR iv_dest_wh IS INITIAL OR iv_quantity <= 0.
    ev_error = 'Gecersiz parametre.'.
    RETURN.
  ENDIF.

  IF iv_src_wh = iv_dest_wh.
    ev_error = 'Kaynak ve hedef depo ayni olamaz.'.
    RETURN.
  ENDIF.

  SELECT SINGLE * FROM zbk_stock INTO ls_src
    WHERE matnr = iv_matnr AND wh_id = iv_src_wh.

  IF sy-subrc <> 0 OR ls_src-quantity < iv_quantity.
    ev_error = 'Kaynak depoda yetersiz stok.'.
    RETURN.
  ENDIF.

  ls_src-quantity = ls_src-quantity - iv_quantity.
  ls_src-update_at = sy-datum.
  UPDATE zbk_stock FROM ls_src.

  SELECT SINGLE * FROM zbk_stock INTO ls_dest
    WHERE matnr = iv_matnr AND wh_id = iv_dest_wh.

  IF sy-subrc = 0.
    ls_dest-quantity = ls_dest-quantity + iv_quantity.
    ls_dest-update_at = sy-datum.
    UPDATE zbk_stock FROM ls_dest.
  ELSE.
    CLEAR ls_dest.
    ls_dest-matnr = iv_matnr.
    ls_dest-wh_id = iv_dest_wh.
    ls_dest-quantity = iv_quantity.
    ls_dest-update_at = sy-datum.
    INSERT zbk_stock FROM ls_dest.
  ENDIF.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    ev_success = abap_true.

    IF iv_ref_no IS NOT INITIAL.
      ev_doc_no = iv_ref_no.
    ELSE.
      CONCATENATE 'TR' sy-datum sy-uzeit INTO ev_doc_no.
      SHIFT ev_doc_no LEFT DELETING LEADING space.
    ENDIF.
  ELSE.
    ROLLBACK WORK.
    ev_error = 'Transfer tamamlanamadi.'.
  ENDIF.

ENDFUNCTION.
