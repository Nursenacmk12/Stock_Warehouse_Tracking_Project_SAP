FUNCTION z_create_product.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE  ZBK_MATERIALS-MATNR
*"     VALUE(IV_MATNAME) TYPE  ZBK_MATERIALS-MATNAME
*"     VALUE(IV_UNIT) TYPE  ZBK_MATERIALS-UNIT
*"     VALUE(IV_CATEGORY) TYPE  CHAR40 OPTIONAL
*"  EXPORTING
*"     VALUE(EV_SUCCESS) TYPE  BOOLE_D
*"     VALUE(EV_DOC_NO) TYPE  CHAR20
*"     VALUE(EV_MESSAGE) TYPE  CHAR255
*"----------------------------------------------------------------------

  DATA ls_material TYPE zbk_materials.

  CLEAR: ev_success, ev_message.

  IF iv_matnr IS INITIAL.
    ev_success = abap_false.
    ev_message = 'Ürün kodu boş olamaz.'.
    RETURN.
  ENDIF.

  SELECT SINGLE matnr
    FROM zbk_materials
    INTO @DATA(lv_existing_matnr)
    WHERE matnr = @iv_matnr.

  IF sy-subrc = 0.
    ev_success = abap_false.
    ev_message = 'Bu ürün kodu zaten mevcut.'.
    RETURN.
  ENDIF.

  ls_material-matnr      = iv_matnr.
  ls_material-matname    = iv_matname.
  ls_material-unit       = iv_unit.
  ls_material-created_at = sy-datum.

  INSERT zbk_materials FROM ls_material.

  IF sy-subrc = 0.
    COMMIT WORK.
    ev_success = abap_true.
    ev_message = 'Ürün başarıyla oluşturuldu.'.
  ELSE.
    ROLLBACK WORK.
    ev_success = abap_false.
    ev_message = 'Ürün oluşturulamadı.'.
  ENDIF.

ENDFUNCTION.
