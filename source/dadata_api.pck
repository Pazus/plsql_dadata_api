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
CREATE OR REPLACE PACKAGE BODY dadata_api IS

  gc_address_url   CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/address';
  gc_phone_url     CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/phone';
  gc_passport_url  CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/passport';
  gc_name_url      CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/name';
  gc_email_url     CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/email';
  gc_date_url      CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/birthdate';
  gc_vehicle_url   CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/vehicle';
  gc_composite_url CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean';

  FUNCTION to_num(p_str VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN to_number(p_str
                    ,'FM99999999999999999999999D9999999999999999999'
                    ,'NLS_NUMERIC_CHARACTERS = ''.,''');
  END to_num;

  PROCEDURE recognize_addresses
  (
    p_addresses         typ_strings
   ,p_address_data_list OUT typ_address_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  
    FUNCTION get_result_node_as_rec(par_result_json JSON) RETURN typ_address_data IS
      v_address_data_out typ_address_data;
    BEGIN
    
      -- dadata �������� �������� ������, ������ ��� ������� �������
      -- ����� ����������� �������������� source �� ��, ��� ���� ���������� �� ����� ����
      v_address_data_out.source := par_result_json.get('source').get_string;
      v_address_data_out.result := par_result_json.get('result').get_string;
    
      v_address_data_out.zip      := par_result_json.get('postal_code').get_string;
      v_address_data_out.kladr_id := par_result_json.get('kladr_id').get_string;
      v_address_data_out.okato    := par_result_json.get('okato').get_string;
      v_address_data_out.oktmo    := par_result_json.get('oktmo').get_string;
    
      v_address_data_out.region           := par_result_json.get('region').get_string;
      v_address_data_out.region_type      := par_result_json.get('region_type').get_string;
      v_address_data_out.region_type_full := par_result_json.get('region_type_full').get_string;
      v_address_data_out.region_kladr_id  := par_result_json.get('region_kladr_id').get_string;
      v_address_data_out.region_fias_id   := par_result_json.get('region_fias_id').get_string;
      v_address_data_out.region_with_type := par_result_json.get('region_with_type').get_string;
    
      v_address_data_out.area           := par_result_json.get('area').get_string;
      v_address_data_out.area_type      := par_result_json.get('area_type').get_string;
      v_address_data_out.area_type_full := par_result_json.get('area_type_full').get_string;
      v_address_data_out.area_kladr_id  := par_result_json.get('area_kladr_id').get_string;
      v_address_data_out.area_fias_id   := par_result_json.get('area_fias_id').get_string;
      v_address_data_out.area_with_type := par_result_json.get('area_with_type').get_string;
    
      v_address_data_out.city           := par_result_json.get('city').get_string;
      v_address_data_out.city_type      := par_result_json.get('city_type').get_string;
      v_address_data_out.city_type_full := par_result_json.get('city_type_full').get_string;
      v_address_data_out.city_kladr_id  := par_result_json.get('city_kladr_id').get_string;
      v_address_data_out.city_fias_id   := par_result_json.get('city_fias_id').get_string;
      v_address_data_out.city_with_type := par_result_json.get('city_with_type').get_string;
      v_address_data_out.city_area      := par_result_json.get('city_area').get_string;
      v_address_data_out.city_district  := par_result_json.get('city_district').get_string;
    
      v_address_data_out.settlement           := par_result_json.get('settlement').get_string;
      v_address_data_out.settlement_type      := par_result_json.get('settlement_type').get_string;
      v_address_data_out.settlement_type_full := par_result_json.get('settlement_type_full').get_string;
      v_address_data_out.settlement_klard_id  := par_result_json.get('settlement_kladr_id').get_string;
      v_address_data_out.settlement_fias_id   := par_result_json.get('settlement_fias_id').get_string;
      v_address_data_out.settlement_with_type := par_result_json.get('settlement_with_type').get_string;
    
      v_address_data_out.street           := par_result_json.get('street').get_string;
      v_address_data_out.street_type      := par_result_json.get('street_type').get_string;
      v_address_data_out.street_type_full := par_result_json.get('street_type_full').get_string;
      v_address_data_out.street_kladr_id  := par_result_json.get('street_kladr_id').get_string;
      v_address_data_out.street_fias_id   := par_result_json.get('street_fias_id').get_string;
      v_address_data_out.street_with_type := par_result_json.get('street_with_type').get_string;
    
      v_address_data_out.house           := par_result_json.get('house').get_string;
      v_address_data_out.house_type      := par_result_json.get('house_type').get_string;
      v_address_data_out.house_type_full := par_result_json.get('house_type_full').get_string;
      v_address_data_out.house_kladr_id  := par_result_json.get('house_kladr_id').get_string;
      v_address_data_out.house_fias_id   := par_result_json.get('house_fias_id').get_string;
    
      v_address_data_out.block_type      := par_result_json.get('block_type').get_string;
      v_address_data_out.block_type_full := par_result_json.get('block_type_full').get_string;
      v_address_data_out.block           := par_result_json.get('block').get_string;
    
      v_address_data_out.flat           := par_result_json.get('flat').get_string;
      v_address_data_out.flat_type      := par_result_json.get('flat_type').get_string;
      v_address_data_out.flat_type_full := par_result_json.get('flat_type_full').get_string;
    
      v_address_data_out.flat_area          := par_result_json.get('flat_area').get_number;
      v_address_data_out.square_meter_price := to_num(par_result_json.get('square_meter_price')
                                                      .get_string);
      v_address_data_out.flat_price         := to_num(par_result_json.get('flat_price').get_number);
      v_address_data_out.postal_box         := par_result_json.get('postal_box').get_string;
      v_address_data_out.capital_marker     := par_result_json.get('capital_marker').get_string;
      v_address_data_out.tax_office         := par_result_json.get('tax_office').get_string;
      v_address_data_out.tax_office_legal   := par_result_json.get('tax_office_legal').get_string;
      v_address_data_out.timezone           := par_result_json.get('timezone').get_string;
      v_address_data_out.geo_lat            := to_num(par_result_json.get('geo_lat').get_string);
      v_address_data_out.geo_lon            := to_num(par_result_json.get('geo_lon').get_string);
      v_address_data_out.beltway_hit        := par_result_json.get('beltway_hit').get_string;
      v_address_data_out.beltway_distance   := to_num(par_result_json.get('beltway_distance')
                                                      .get_string);
      v_address_data_out.qc_geo             := par_result_json.get('qc_geo').get_number;
      v_address_data_out.qc_complete        := par_result_json.get('qc_complete').get_number;
      v_address_data_out.qc_house           := par_result_json.get('qc_house').get_number;
    
      v_address_data_out.unparsed_parts := par_result_json.get('unparsed_parts').get_string;
    
      v_address_data_out.qc := par_result_json.get('qc').get_number;
    
      RETURN v_address_data_out;
    
    END get_result_node_as_rec;
  BEGIN
    -- ��� �� ������ ������
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_address_data_list(i) := get_result_node_as_rec(v_result_item);
    END LOOP;
  END recognize_addresses;

  PROCEDURE recognize_phones
  (
    p_phones           typ_strings
   ,p_phones_data_list OUT typ_phone_data_list
  ) IS
  BEGIN
    NULL;
  END recognize_phones;

  PROCEDURE recognize_passport
  (
    p_passports           typ_strings
   ,p_passports_data_list OUT typ_passport_data_list
  ) IS
  BEGIN
    NULL;
  END recognize_passport;

  PROCEDURE recognize_name
  (
    p_names           typ_strings
   ,p_names_data_list OUT typ_name_data_list
  ) IS
  BEGIN
    NULL;
  END recognize_name;

  PROCEDURE recognize_date
  (
    p_dates           typ_strings
   ,p_dates_data_list OUT typ_date_data_list
  ) IS
  BEGIN
    NULL;
  END;

END dadata_api;
/
