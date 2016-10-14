CREATE OR REPLACE PACKAGE dadata_http_interface IS

  TYPE t_request_headers IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);

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
  );

END dadata_http_interface;
/
