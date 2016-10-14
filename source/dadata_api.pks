CREATE OR REPLACE PACKAGE dadata_api IS

  TYPE typ_strings IS TABLE OF VARCHAR2(4000);

  SUBTYPE typ_kladr_code IS VARCHAR2(19 CHAR);
  SUBTYPE typ_fias_id IS VARCHAR2(36 CHAR);
  SUBTYPE typ_name_with_type IS VARCHAR2(131 CHAR);
  SUBTYPE typ_qc IS PLS_INTEGER;

  TYPE typ_address_data IS RECORD(
     SOURCE  VARCHAR2(4000) --�������� ����� ����� �������
    ,RESULT  VARCHAR2(4000) --����������������� ����� ����� �������
    ,zip     VARCHAR2(9) --������
    ,country VARCHAR2(120 CHAR) -- ������
    
    ,region_fias_id   typ_fias_id -- ��� ���� �������
    ,region_kladr_id  typ_kladr_code --��� ����� �������
    ,region_with_type typ_name_with_type --������ � �����
    ,region_type      VARCHAR2(50) --��� ������� (�����������)
    ,region_type_full VARCHAR2(255) -- ��� �������
    ,region           VARCHAR2(1000) --������
    
    ,area_fias_id   typ_fias_id --��� ���� ������ � �������
    ,area_kladr_id  typ_kladr_code --��� ����� ������ � �������
    ,area_with_type typ_name_with_type --����� � ������� � �����
    ,area_type      VARCHAR2(50) --��� ������ � ������� (�����������)
    ,area_type_full VARCHAR2(255) --��� ������ � �������
    ,area           VARCHAR2(1000) --����� � �������
    
    ,city_fias_id   typ_fias_id --��� ���� ������
    ,city_kladr_id  typ_kladr_code --��� ����� ������
    ,city_with_type typ_name_with_type --����� � �����
    ,city_type      VARCHAR2(50) --��� ������ (�����������)
    ,city_type_full VARCHAR2(255) --��� ������
    ,city           VARCHAR2(1000) --�����
    
    ,city_area               VARCHAR2(1000) --���������������� ����� (������ ��� ������)
    ,city_district_fias_id   typ_fias_id --��� ���� ������ ������ (�� �����������)
    ,city_district_kladr_id  typ_kladr_code --��� ����� ������ ������ (�� �����������)
    ,city_district_with_type typ_name_with_type --����� ������ � �����
    ,city_district_type      VARCHAR2(50) --��� ������ ������ (�����������)
    ,city_district_type_full VARCHAR2(255) --��� ������ ������
    ,city_district           VARCHAR2(1000) --����� ������
    
    ,settlement_fias_id   typ_fias_id --��� ���� ���. ������
    ,settlement_klard_id  typ_kladr_code --��� ����� ���. ������
    ,settlement_with_type typ_name_with_type --���������� ����� � �����
    ,settlement_type      VARCHAR2(50) --��� ����������� ������ (�����������)
    ,settlement_type_full VARCHAR2(255) --��� ����������� ������
    ,settlement           VARCHAR2(1000) --���������� �����
    
    ,street_fias_id   typ_fias_id --��� ���� �����
    ,street_kladr_id  typ_kladr_code --��� ����� �����
    ,street_with_type typ_name_with_type --����� � �����
    ,street_type      VARCHAR2(50) --��� ����� (�����������)
    ,street_type_full VARCHAR2(255) --��� �����
    ,street           VARCHAR2(1000) --�����
    
    ,house_fias_id   typ_fias_id --��� ���� ����
    ,house_kladr_id  typ_kladr_code --��� ����� ����
    ,house_type      VARCHAR2(50) --��� ���� (�����������)
    ,house_type_full VARCHAR2(255) --��� ����
    ,house           VARCHAR2(1000) --���
    
    ,block_type      VARCHAR2(50) --��� �������/�������� (�����������)
    ,block_type_full VARCHAR2(255) --��� �������/��������
    ,BLOCK           VARCHAR2(255) --������/��������
    
    ,flat_type          VARCHAR2(50) --��� �������� (�����������)
    ,flat_type_full     VARCHAR2(255) --��� ��������
    ,flat               VARCHAR2(1000) --��������
    ,flat_area          NUMBER --������� ��������
    ,square_meter_price NUMBER --�������� ��������� �?
    ,flat_price         NUMBER --�������� ��������� ��������
    ,postal_box         VARCHAR2(255) --����������� ����
    
    ,fias_id        typ_fias_id --��� ����
    ,fial_level     INTEGER --������� �����������, �� �������� ����� ������ � ����
    ,kladr_id       typ_kladr_code --��� �����
    ,capital_marker INTEGER(1) --������ ������
    ,okato          VARCHAR2(11) --��� �����
    ,oktmo          VARCHAR2(11) --��� �����
    
    ,tax_office       INTEGER --��� ���� ��� ���������� ���
    ,tax_office_legal INTEGER --��� ���� ��� ����������� (�� �����������)
    ,timezone         VARCHAR2(25) --������� ����
    ,geo_lat          NUMBER --����������: ������
    ,geo_lon          NUMBER --����������: �������
    ,beltway_hit      VARCHAR2(10) --������ ���������?
    ,beltway_distance NUMBER --���������� �� ��������� � ��.
    ,qc_geo           PLS_INTEGER --��� �������� ���������
    ,qc_complete      PLS_INTEGER --��� ����������� � ��������
    ,qc_house         PLS_INTEGER --������� ������� ���� � ����
    ,qc               PLS_INTEGER --��� �������� ������
    ,unparsed_parts   VARCHAR2(4000) --�������������� ����� ������. ��� ������
    );
  TYPE typ_address_data_list IS TABLE OF typ_address_data INDEX BY PLS_INTEGER;

  TYPE typ_phone_data IS RECORD(
     SOURCE       VARCHAR2(100 CHAR) -- �������� ������� ����� �������
    ,TYPE         VARCHAR2(50 CHAR) -- ��� ��������
    ,phone        VARCHAR2(50 CHAR) -- ����������������� ������� ����� �������
    ,country_code VARCHAR2(5 CHAR) -- ��� ������
    ,city_code    VARCHAR2(5 CHAR) -- ��� ������ / DEF-���
    ,NUMBER       VARCHAR2(10 CHAR) -- ��������� ����� ��������
    ,extension    VARCHAR2(10 CHAR) -- ���������� �����
    ,provider     VARCHAR2(100 CHAR) -- �������� ����� 
    ,region       VARCHAR2(100 CHAR) -- ������
    ,timezone     VARCHAR2(10 CHAR) -- ������� ����
    ,qc_conflict  INTEGER -- ������� ��������� �������� � �������
    ,qc           typ_qc -- �� ��������
    );
  TYPE typ_phone_data_list IS TABLE OF typ_phone_data INDEX BY PLS_INTEGER;

  TYPE typ_passport_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- �������� ����� � ����� ����� �������
    ,series VARCHAR2(20 CHAR) -- �����
    ,NUMBER VARCHAR2(20 CHAR) -- �����
    ,qc     INTEGER --  ��� ��������
    );
  TYPE typ_passport_data_list IS TABLE OF typ_passport_data INDEX BY PLS_INTEGER;

  TYPE typ_name_data IS RECORD(
     SOURCE          VARCHAR2(100 CHAR) -- �������� ��� ����� �������
    ,RESULT          VARCHAR2(150 CHAR) -- ����������������� ��� ����� �������
    ,result_genitive VARCHAR2(150 CHAR) -- ��� � ����������� ������ (����?)
    ,result_dative   VARCHAR2(150 CHAR) -- ��� � ��������� ������ (����?)
    ,result_ablative VARCHAR2(150 CHAR) -- ��� � ������������ ������ (���?)
    ,surname         VARCHAR2(50 CHAR) -- �������
    ,NAME            VARCHAR2(50 CHAR) -- ���
    ,patronymic      VARCHAR2(50 CHAR) -- ��������
    ,gender          VARCHAR2(10 CHAR) -- ���
    ,qc              typ_qc -- ��� ��������
    );
  TYPE typ_name_data_list IS TABLE OF typ_name_data INDEX BY PLS_INTEGER;

  TYPE typ_email_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- �������� email
    ,email  VARCHAR2(100 CHAR) -- �������� email
    ,qc     typ_qc -- ��� ��������
    );
  TYPE typ_email_data_list IS TABLE OF typ_email_data INDEX BY PLS_INTEGER;

  TYPE typ_date_data IS RECORD(
     SOURCE    VARCHAR2(100 CHAR) -- �������� ����
    ,birthdate VARCHAR2(100 CHAR) -- ����������������� ����
    ,qc        typ_qc -- ��� ��������
    );
  TYPE typ_date_data_list IS TABLE OF typ_date_data INDEX BY PLS_INTEGER;

  TYPE typ_auto_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- �������� ��������
    ,RESULT VARCHAR2(100 CHAR) -- ����������������� ��������
    ,brand  VARCHAR2(50 CHAR) -- �����
    ,model  VARCHAR2(50 CHAR) -- ������
    ,qc     typ_qc -- ��� ��������
    );
  TYPE typ_auto_data_list IS TABLE OF typ_auto_data INDEX BY PLS_INTEGER;

  -- ��� �������� (qc) � ����� �� ������� ��������� ������������ �����:
  gc_addr_qc_ok     CONSTANT typ_qc := 0; -- ����� ��������� ��������
  gc_addr_qc_assume CONSTANT typ_qc := 1; -- ����� ��������� � ����������� ��� �� ���������, ����� ��������� �������
  gc_addr_qc_trash  CONSTANT typ_qc := 2; -- ����� ������ ��� �������� ���������

  -- ��� �������� (qc) � ����� �� ������� ��������� ������������ �������:
  gc_phone_qc_ok       CONSTANT typ_qc := 0; -- ������� ��������� ��������
  gc_phone_qc_assume   CONSTANT typ_qc := 1; -- ������� ��������� � ����������� ��� �� ��������� (����� ��������� �������)
  gc_phone_qc_trash    CONSTANT typ_qc := 2; -- ������� ������ ��� �������� ���������
  gc_phone_qc_multiple CONSTANT typ_qc := 3; -- ���������� ��������� ���������, ��������� ������ (����� ��������� �������)

  -- ��� �������� (qc) � ��������� �� ������� ��������� ������������ ��������:
  gc_name_qc_ok     CONSTANT typ_qc := 0; -- �������� �������� ���������� ��������
  gc_name_qc_assume CONSTANT typ_qc := 1; -- �������� �������� ���������� � ����������� ��� �� ���������� (����� ��������� �������)
  gc_name_qc_trash  CONSTANT typ_qc := 2; -- �������� �������� ������ ��� �������� ���������

  --��� �������� (qc) � �������� �� email ��� ������������� ��������:
  gc_email_qc_ok      CONSTANT typ_qc := 0; -- ���������� ��������. ������������� ������������ ��������, �������� ������������� ������ �� �����������
  gc_email_qc_trash   CONSTANT typ_qc := 2; -- ������ ��� �������� ��������� ��������
  gc_email_qc_onetime CONSTANT typ_qc := 3; -- ������������ �����. ������ 10minutemail.com, getairmail.com, temp-mail.ru � �����������
  -- ����� ��������� ������ ��������:
  gc_email_qc_incorrect CONSTANT typ_qc := 1; -- ������������ �������� �� ������������� ������������ ��������
  gc_email_qc_misspells CONSTANT typ_qc := 4; -- ���������� ��������

  -- ��� �������� (qc) � ��������� �� ������� ��������� ������������ ��������:
  gc_date_qc_ok     CONSTANT typ_qc := 0; -- �������� �������� ���������� ��������
  gc_date_qc_assume CONSTANT typ_qc := 1; -- �������� �������� ���������� � ����������� ��� �� ���������� (����� ��������� �������)
  gc_date_qc_trash  CONSTANT typ_qc := 2; -- �������� �������� ������ ��� �������� ���������

  -- ��� �������� (qc) � ��������� �� ������� ��������� ������������ ��������:
  gc_auto_qc_ok     CONSTANT typ_qc := 0; -- �������� �������� ���������� ��������
  gc_auto_qc_assume CONSTANT typ_qc := 1; -- �������� �������� ���������� � ����������� ��� �� ���������� (����� ��������� �������)
  gc_auto_qc_trash  CONSTANT typ_qc := 2; -- �������� �������� ������ ��� �������� ���������

  gc_structure_asis     CONSTANT VARCHAR2(5) := 'AS_IS';
  gc_structure_name     CONSTANT VARCHAR2(4) := 'NAME';
  gc_structure_address  CONSTANT VARCHAR2(7) := 'ADDRESS';
  gc_structure_phone    CONSTANT VARCHAR2(5) := 'PHONE';
  gc_structure_passport CONSTANT VARCHAR2(8) := 'PASSPORT';
  gc_structure_email    CONSTANT VARCHAR2(5) := 'EMAIL';
  gc_structure_vehicle  CONSTANT VARCHAR2(7) := 'VEHICLE';
  gc_structure_ignore   CONSTANT VARCHAR2(6) := 'IGNORE';

  -- ����������

  --������������ ������:
  --  ���������� JSON.
  --  ����������� ������������ ��������� structure ��� data.
  --  � structure ������ ���������������� ���.
  --  ���������� ����� � ������� ����� ���������� � structure.  
  ex_incorrect_request EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_incorrect_request, -20400);

  -- � ������� ����������� API-���� ��� ��������� ����
  ex_api_token_or_key_missing EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_api_token_or_key_missing, -20401);

  -- ������������ ������� ��� ��������� �������, ��������� ������
  ex_not_enough_money EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_not_enough_money, -20402);

  -- � ������� ������ �������������� ����
  ex_wrong_key EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_wrong_key, -20403);

  -- ������ ������ � �������, �������� �� POST
  ex_wrong_method EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_wrong_method, -20405);

  -- ������ �������� ����� 50 �������
  ex_too_many_rows EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_too_many_rows, -20413);

  -- ��������� ���������� ������ ������� �� ����� ���������
  ex_internal_error EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_internal_error, -20500);

  PROCEDURE recognize_addresses
  (
    p_addresses         typ_strings
   ,p_address_data_list OUT typ_address_data_list
  );

  PROCEDURE recognize_phones
  (
    p_phones           typ_strings
   ,p_phones_data_list OUT typ_phone_data_list
  );

  PROCEDURE recognize_passport
  (
    p_passports           typ_strings
   ,p_passports_data_list OUT typ_passport_data_list
  );

  PROCEDURE recognize_name
  (
    p_names           typ_strings
   ,p_names_data_list OUT typ_name_data_list
  );

  PROCEDURE recognize_date
  (
    p_dates           typ_strings
   ,p_dates_data_list OUT typ_date_data_list
  );

END dadata_api;
/
