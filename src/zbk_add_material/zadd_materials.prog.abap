*&---------------------------------------------------------------------*
*& Report ZADD_MATERIALS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZADD_MATERIALS.
DATA: ls_material TYPE zbk_materials.

PARAMETERS:
 p_matnr TYPE c LENGTH 10,
 p_name  TYPE c LENGTH 50,
 p_unit  TYPE c LENGTH 5.

START-OF-SELECTION.

  ls_material-matnr = p_matnr.
  ls_material-matname = p_name.
  ls_material-unit = p_unit.
  ls_material-created_at = sy-datum.

  INSERT zbk_materials FROM ls_material.

  IF sy-subrc = 0.
     WRITE: 'Material başarıyla eklendi'.
  ELSE.
     WRITE: 'Material eklenemedi'.
  ENDIF.
