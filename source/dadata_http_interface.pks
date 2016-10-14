CREATE OR REPLACE PACKAGE dadata_http_interface IS

  TYPE t_request_headers IS TABLE OF VARCHAR2(255) INDEX BY VARCHAR2(255);

  -- �������� ��� ������ ���������� �������
  -- ���������� ������� �� ������ �������� ������, ���� �������� ������-��� HTTP, �������� �� 200
  -- � ���������� ���������� Content-type, Authorization, X-Secret
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
