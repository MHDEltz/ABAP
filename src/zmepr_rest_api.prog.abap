**&---------------------------------------------------------------------*
**& Report ZMEPR_REST_API
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
REPORT zmepr_rest_api NO STANDARD PAGE HEADING.

INCLUDE zmepr_rest_api_top.

LOOP AT s_iata REFERENCE INTO DATA(lrf_iata) WHERE option = 'EQ'.

  lv_index = lv_index + 1.

  CLEAR: o_client, ls_airport.

  CONCATENATE 'https://airport-info.p.rapidapi.com/airport?iata=' lrf_iata->low INTO lv_url.

  cl_http_client=>create_by_url( EXPORTING url = lv_url
                                 IMPORTING client = o_client
                                 EXCEPTIONS argument_not_found = 1
                                            plugin_not_active = 2
                                            internal_error = 30
                                            OTHERS = 4 ).
  IF sy-subrc <> 0.
    o_client->close( ).
  ENDIF.

  IF o_client IS BOUND.

    o_client->request->set_method( if_http_request=>co_request_method_get ).

    o_client->request->set_header_field( name = 'X-RapidAPI-Key'  value = '649c2ce2damsh6b9ec278fea7b1dp13bdbbjsn60a25018a1cd').
    o_client->request->set_header_field( name = 'X-RapidAPI-Host' value = 'airport-info.p.rapidapi.com').

    o_client->send( timeout = if_http_client=>co_timeout_default ).

    DO.

      o_client->receive( ).

      o_client->response->get_status( IMPORTING code = lv_http_status
                                                reason = lv_status_text ).
      IF lv_http_status <> 429.

        EXIT.

      ENDIF.

      WAIT UP TO 10 SECONDS.

    ENDDO.

    IF lv_http_status = 200.

      DATA(lv_result) = o_client->response->get_cdata( ).

      IF lines( s_iata ) = 1.
        CONCATENATE '[' lv_result ']' INTO lv_results.
      ELSE.

        IF lv_index = 1.
          CONCATENATE '[' lv_result INTO lv_results.
        ELSEIF lv_index <> 1 AND lv_index <> lines( s_iata ).
          CONCATENATE lv_results ',' lv_result INTO lv_results.
        ELSEIF lv_index = lines( s_iata ).
          CONCATENATE lv_results ',' lv_result ']' INTO lv_results.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDIF.

  o_client->close( ).

ENDLOOP.

/ui2/cl_json=>deserialize(
        EXPORTING
          json             = lv_results
          pretty_name      = /ui2/cl_json=>pretty_mode-camel_case
        CHANGING
          data             = lt_airports
      ).

LOOP AT lt_airports ASSIGNING FIELD-SYMBOL(<fs_airports>) WHERE id IS INITIAL.

  READ TABLE s_iata REFERENCE INTO DATA(lrf_iata_aux) INDEX sy-tabix.

  <fs_airports>-id = lrf_iata_aux->low.
  <fs_airports>-name = 'Não Existente'.

ENDLOOP.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table   = lo_salv
  CHANGING
    t_table        = lt_airports
).

lo_functions = lo_salv->get_functions( ).
lo_functions->set_all( abap_true ).
lo_columns = lo_salv->get_columns( ).

TRY.

    lo_column = lo_columns->get_column( 'ID' ).
    lo_column->set_short_text( 'id' ).
    lo_column->set_medium_text( 'id' ).
    lo_column->set_long_text( 'id' ).

    lo_column = lo_columns->get_column( 'IATA' ).
    lo_column->set_short_text( 'iata' ).
    lo_column->set_medium_text( 'iata' ).
    lo_column->set_long_text( 'iata' ).

    lo_column = lo_columns->get_column( 'ICAO' ).
    lo_column->set_short_text( 'icao' ).
    lo_column->set_medium_text( 'icao' ).
    lo_column->set_long_text( 'icao' ).

    lo_column = lo_columns->get_column( 'NAME' ).
    lo_column->set_short_text( 'name' ).
    lo_column->set_medium_text( 'name' ).
    lo_column->set_long_text( 'name' ).

    lo_column = lo_columns->get_column( 'LOCATION' ).
    lo_column->set_short_text( 'location' ).
    lo_column->set_medium_text( 'location' ).
    lo_column->set_long_text( 'location' ).

    lo_column = lo_columns->get_column( 'STREET_NUMBER' ).
    lo_column->set_short_text( 'strt nmbr' ).
    lo_column->set_medium_text( 'street number' ).
    lo_column->set_long_text( 'street number' ).

    lo_column = lo_columns->get_column( 'STREET' ).
    lo_column->set_short_text( 'street' ).
    lo_column->set_medium_text( 'street' ).
    lo_column->set_long_text( 'street' ).

    lo_column = lo_columns->get_column( 'CITY' ).
    lo_column->set_short_text( 'city' ).
    lo_column->set_medium_text( 'city' ).
    lo_column->set_long_text( 'city' ).

    lo_column = lo_columns->get_column( 'COUNTY' ).
    lo_column->set_short_text( 'county' ).
    lo_column->set_medium_text( 'county' ).
    lo_column->set_long_text( 'county' ).

    lo_column = lo_columns->get_column( 'STATE' ).
    lo_column->set_short_text( 'state' ).
    lo_column->set_medium_text( 'state' ).
    lo_column->set_long_text( 'state' ).

    lo_column = lo_columns->get_column( 'COUNTRY_ISO' ).
    lo_column->set_short_text( 'cntr iso' ).
    lo_column->set_medium_text( 'country_iso' ).
    lo_column->set_long_text( 'country_iso' ).

    lo_column = lo_columns->get_column( 'COUNTRY' ).
    lo_column->set_short_text( 'country' ).
    lo_column->set_medium_text( 'country' ).
    lo_column->set_long_text( 'country' ).

    lo_column = lo_columns->get_column( 'POSTAL_CODE' ).
    lo_column->set_short_text( 'PC' ).
    lo_column->set_medium_text( 'postal code' ).
    lo_column->set_long_text( 'postal code' ).

    lo_column = lo_columns->get_column( 'PHONE' ).
    lo_column->set_short_text( 'phone' ).
    lo_column->set_medium_text( 'phone' ).
    lo_column->set_long_text( 'phone' ).

    lo_column = lo_columns->get_column( 'LATITUDE' ).
    lo_column->set_short_text( 'latitude' ).
    lo_column->set_medium_text( 'latitude' ).
    lo_column->set_long_text( 'latitude' ).

    lo_column = lo_columns->get_column( 'LONGITUDE' ).
    lo_column->set_short_text( 'longitude' ).
    lo_column->set_medium_text( 'longitude' ).
    lo_column->set_long_text( 'longitude' ).

    lo_column = lo_columns->get_column( 'UCT' ).
    lo_column->set_short_text( 'uct' ).
    lo_column->set_medium_text( 'uct' ).
    lo_column->set_long_text( 'uct' ).

    lo_column = lo_columns->get_column( 'WEBSITE' ).
    lo_column->set_short_text( 'website' ).
    lo_column->set_medium_text( 'website' ).
    lo_column->set_long_text( 'website' ).

  CATCH cx_salv_not_found INTO lv_not_found.

ENDTRY.

lo_salv->display( ).
