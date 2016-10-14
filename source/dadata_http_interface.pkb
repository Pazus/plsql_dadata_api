CREATE OR REPLACE PACKAGE BODY dadata_http_interface IS

  -- Интефейс для вызова стороннего сервиса
  -- Реализация сервиса не должна вызывать ошибку, если вернется статус-код HTTP, отличный от 200
  -- В заголовках передаются Content-type, Authorization, X-Secret
  PROCEDURE request
  (
    p_url              VARCHAR2
   ,p_headers          t_request_headers
   ,p_body             CLOB
   ,p_responce_body    OUT NOCOPY CLOB
   ,p_http_status_code OUT PLS_INTEGER
  ) IS
    v_req        utl_http.req;
    v_res        utl_http.resp;
    v_h_ind      VARCHAR2(255);
    v_amt        NUMBER := 32767;
    v_offset     NUMBER := 1;
    v_send_str   VARCHAR2(32767);
    v_answer_str VARCHAR2(32767);
  BEGIN
    v_req := utl_http.begin_request(p_url, 'POST', ' HTTP/1.1');
  
    v_h_ind := p_headers.first;
    WHILE v_h_ind IS NOT NULL
    LOOP
      utl_http.set_header(v_req, v_h_ind, p_headers(v_h_ind));
      v_h_ind := p_headers.next(v_h_ind);
    END LOOP;
  
    LOOP
      -- Чтение из CLOB данных и передача
      dbms_lob.read(lob_loc => p_body, amount => v_amt, offset => v_offset, buffer => v_send_str);
      utl_http.write_text(v_req, v_send_str);
      v_offset := v_offset + v_amt;
      EXIT WHEN v_amt < 32767;
    END LOOP;
  
    BEGIN
      v_res := utl_http.get_response(v_req);
    
      p_http_status_code := v_res.status_code;
      dbms_lob.createtemporary(p_responce_body, TRUE);
    
      LOOP
        utl_http.read_text(v_res, v_answer_str, 32767);
        dbms_lob.writeappend(p_responce_body, length(v_answer_str), v_answer_str);
      END LOOP;
    EXCEPTION
      WHEN utl_http.end_of_body THEN
        NULL;
      WHEN utl_http.http_client_error
           OR utl_http.http_server_error THEN
        p_http_status_code := v_res.status_code;
    END;
  
    utl_http.end_response(v_res);
  
  END;
END dadata_http_interface;
/
