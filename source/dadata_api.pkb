CREATE OR REPLACE PACKAGE BODY dadata_api IS

  gc_address_url  CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/address';
  gc_phone_url    CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/phone';
  gc_passport_url CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/passport';
  gc_name_url     CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/name';
  gc_email_url    CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/email';
  gc_date_url     CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/birthdate';
  gc_vehicle_url  CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean/vehicle';
  --gc_composite_url CONSTANT VARCHAR2(50) := 'https://dadata.ru/api/v2/clean';

  PROCEDURE request_dadata
  (
    p_url    VARCHAR2
   ,p_data   typ_strings
   ,p_result OUT NOCOPY JSON_LIST
  ) IS
    v_headers          dadata_http_interface.t_request_headers;
    v_request_jl       JSON_LIST := JSON_LIST;
    v_request_body     CLOB;
    v_responce_body    CLOB;
    v_http_status_code PLS_INTEGER;
  BEGIN
    v_headers('Authorization') := 'Token ' || dadata_config.get_authorization_token;
    v_headers('X-Secret') := dadata_config.get_x_secret;
  
    FOR i IN 1 .. p_data.count
    LOOP
      v_request_jl.append(p_data(i));
    END LOOP;
    v_request_jl.to_clob(v_request_body);
  
    dadata_http_interface.request(p_url              => p_url
                                 ,p_headers          => v_headers
                                 ,p_body             => v_request_body
                                 ,p_responce_body    => v_responce_body
                                 ,p_http_status_code => v_http_status_code);
  
    CASE v_http_status_code
      WHEN 200 THEN
        p_result := JSON_LIST(v_responce_body);
      WHEN 400 THEN
        raise_application_error(-20400, 'Incorrect JSON');
      WHEN 401 THEN
        raise_application_error(-20401, 'API token is missing');
      WHEN 402 THEN
        raise_application_error(-20402, 'Not enough money');
      WHEN 403 THEN
        raise_application_error(-20403, 'Wrong key specified');
      WHEN 405 THEN
        raise_application_error(-20405, 'Wrong HTTP method used, POST expected');
      WHEN 413 THEN
        raise_application_error(-20413, 'Request contains more then 50 entries');
      WHEN 500 THEN
        raise_application_error(-20500, 'Dadata internal server error');
    END CASE;
  
  END request_dadata;

  FUNCTION to_num(p_str VARCHAR2) RETURN NUMBER IS
  BEGIN
    RETURN to_number(p_str
                    ,'FM99999999999999999999999D9999999999999999999'
                    ,'NLS_NUMERIC_CHARACTERS = ''.,''');
  END to_num;

  FUNCTION map_addr_json_to_rec(p_json JSON) RETURN typ_address_data IS
    v_address_data typ_address_data;
  BEGIN
  
    -- dadata искожает исходную строку, удаляя там двойные пробелы
    -- после логирования переопределяем source на то, что было исходником на самом деле
    v_address_data.source := p_json.get('source').get_string;
    v_address_data.result := p_json.get('result').get_string;
  
    v_address_data.zip      := p_json.get('postal_code').get_string;
    v_address_data.kladr_id := p_json.get('kladr_id').get_string;
    v_address_data.okato    := p_json.get('okato').get_string;
    v_address_data.oktmo    := p_json.get('oktmo').get_string;
  
    v_address_data.region           := p_json.get('region').get_string;
    v_address_data.region_type      := p_json.get('region_type').get_string;
    v_address_data.region_type_full := p_json.get('region_type_full').get_string;
    v_address_data.region_kladr_id  := p_json.get('region_kladr_id').get_string;
    v_address_data.region_fias_id   := p_json.get('region_fias_id').get_string;
    v_address_data.region_with_type := p_json.get('region_with_type').get_string;
  
    v_address_data.area           := p_json.get('area').get_string;
    v_address_data.area_type      := p_json.get('area_type').get_string;
    v_address_data.area_type_full := p_json.get('area_type_full').get_string;
    v_address_data.area_kladr_id  := p_json.get('area_kladr_id').get_string;
    v_address_data.area_fias_id   := p_json.get('area_fias_id').get_string;
    v_address_data.area_with_type := p_json.get('area_with_type').get_string;
  
    v_address_data.city           := p_json.get('city').get_string;
    v_address_data.city_type      := p_json.get('city_type').get_string;
    v_address_data.city_type_full := p_json.get('city_type_full').get_string;
    v_address_data.city_kladr_id  := p_json.get('city_kladr_id').get_string;
    v_address_data.city_fias_id   := p_json.get('city_fias_id').get_string;
    v_address_data.city_with_type := p_json.get('city_with_type').get_string;
    v_address_data.city_area      := p_json.get('city_area').get_string;
    v_address_data.city_district  := p_json.get('city_district').get_string;
  
    v_address_data.city_district_fias_id   := p_json.get('city_district_fias_id').get_string;
    v_address_data.city_district_kladr_id  := p_json.get('city_district_kladr_id').get_string;
    v_address_data.city_district_with_type := p_json.get('city_district_with_type').get_string;
    v_address_data.city_district_type      := p_json.get('city_district_type').get_string;
    v_address_data.city_district_type_full := p_json.get('city_district_type_full').get_string;
    v_address_data.city_district           := p_json.get('city_district').get_string;
  
    v_address_data.settlement           := p_json.get('settlement').get_string;
    v_address_data.settlement_type      := p_json.get('settlement_type').get_string;
    v_address_data.settlement_type_full := p_json.get('settlement_type_full').get_string;
    v_address_data.settlement_klard_id  := p_json.get('settlement_kladr_id').get_string;
    v_address_data.settlement_fias_id   := p_json.get('settlement_fias_id').get_string;
    v_address_data.settlement_with_type := p_json.get('settlement_with_type').get_string;
  
    v_address_data.street           := p_json.get('street').get_string;
    v_address_data.street_type      := p_json.get('street_type').get_string;
    v_address_data.street_type_full := p_json.get('street_type_full').get_string;
    v_address_data.street_kladr_id  := p_json.get('street_kladr_id').get_string;
    v_address_data.street_fias_id   := p_json.get('street_fias_id').get_string;
    v_address_data.street_with_type := p_json.get('street_with_type').get_string;
  
    v_address_data.house           := p_json.get('house').get_string;
    v_address_data.house_type      := p_json.get('house_type').get_string;
    v_address_data.house_type_full := p_json.get('house_type_full').get_string;
    v_address_data.house_kladr_id  := p_json.get('house_kladr_id').get_string;
    v_address_data.house_fias_id   := p_json.get('house_fias_id').get_string;
  
    v_address_data.block_type      := p_json.get('block_type').get_string;
    v_address_data.block_type_full := p_json.get('block_type_full').get_string;
    v_address_data.block           := p_json.get('block').get_string;
  
    v_address_data.flat           := p_json.get('flat').get_string;
    v_address_data.flat_type      := p_json.get('flat_type').get_string;
    v_address_data.flat_type_full := p_json.get('flat_type_full').get_string;
  
    v_address_data.flat_area          := p_json.get('flat_area').get_number;
    v_address_data.square_meter_price := to_num(p_json.get('square_meter_price').get_string);
    v_address_data.flat_price         := to_num(p_json.get('flat_price').get_number);
    v_address_data.postal_box         := p_json.get('postal_box').get_string;
    v_address_data.capital_marker     := p_json.get('capital_marker').get_string;
    v_address_data.tax_office         := p_json.get('tax_office').get_string;
    v_address_data.tax_office_legal   := p_json.get('tax_office_legal').get_string;
    v_address_data.timezone           := p_json.get('timezone').get_string;
    v_address_data.geo_lat            := to_num(p_json.get('geo_lat').get_string);
    v_address_data.geo_lon            := to_num(p_json.get('geo_lon').get_string);
    v_address_data.beltway_hit        := p_json.get('beltway_hit').get_string;
    v_address_data.beltway_distance   := to_num(p_json.get('beltway_distance').get_string);
    v_address_data.qc_geo             := p_json.get('qc_geo').get_number;
    v_address_data.qc_complete        := p_json.get('qc_complete').get_number;
    v_address_data.qc_house           := p_json.get('qc_house').get_number;
  
    v_address_data.unparsed_parts := p_json.get('unparsed_parts').get_string;
  
    v_address_data.qc := p_json.get('qc').get_number;
  
    RETURN v_address_data;
  
  END map_addr_json_to_rec;
  FUNCTION map_phone_json_to_rec(p_json JSON) RETURN typ_phone_data IS
    v_phone_data typ_phone_data;
  BEGIN
    v_phone_data.source       := p_json.get('source').get_string;
    v_phone_data.type         := p_json.get('type').get_string;
    v_phone_data.phone        := p_json.get('phone').get_string;
    v_phone_data.country_code := p_json.get('country_code').get_string;
    v_phone_data.city_code    := p_json.get('city_code').get_string;
    v_phone_data.number       := p_json.get('NUMBER').get_string;
    v_phone_data.extension    := p_json.get('extension').get_string;
    v_phone_data.provider     := p_json.get('provider').get_string;
    v_phone_data.region       := p_json.get('region').get_string;
    v_phone_data.qc_conflict  := p_json.get('qc_conflict').get_number;
    v_phone_data.qc           := p_json.get('qc').get_number;
    RETURN v_phone_data;
  END;
  FUNCTION map_passport_json_to_rec(p_json JSON) RETURN typ_passport_data IS
    v_passport_data typ_passport_data;
  BEGIN
    v_passport_data.source := p_json.get('source').get_string;
    v_passport_data.series := p_json.get('series').get_string;
    v_passport_data.number := p_json.get('number').get_string;
    v_passport_data.qc     := p_json.get('qc').get_number;
    RETURN v_passport_data;
  END;
  FUNCTION map_name_json_to_rec(p_json JSON) RETURN typ_name_data IS
    v_name_data typ_name_data;
  BEGIN
    v_name_data.source          := p_json.get('source').get_string;
    v_name_data.result          := p_json.get('series').get_string;
    v_name_data.result_genitive := p_json.get('result_genitive').get_string;
    v_name_data.result_dative   := p_json.get('result_dative').get_string;
    v_name_data.result_ablative := p_json.get('result_ablative').get_string;
    v_name_data.surname         := p_json.get('surname').get_string;
    v_name_data.name            := p_json.get('name').get_string;
    v_name_data.patronymic      := p_json.get('patronymic').get_string;
    v_name_data.gender          := p_json.get('gender').get_string;
    v_name_data.qc              := p_json.get('qc').get_number;
    RETURN v_name_data;
  END;
  FUNCTION map_email_json_to_rec(p_json JSON) RETURN typ_email_data IS
    v_email_data typ_email_data;
  BEGIN
    v_email_data.source := p_json.get('source').get_string;
    v_email_data.email  := p_json.get('email').get_string;
    v_email_data.qc     := p_json.get('qc').get_number;
    RETURN v_email_data;
  END;
  FUNCTION map_date_json_to_rec(p_json JSON) RETURN typ_date_data IS
    v_date_data typ_date_data;
  BEGIN
    v_date_data.source    := p_json.get('source').get_string;
    v_date_data.birthdate := p_json.get('birthdate').get_string;
    v_date_data.qc        := p_json.get('qc').get_number;
    RETURN v_date_data;
  END;
  FUNCTION map_vechile_json_to_rec(p_json JSON) RETURN typ_vehicle_data IS
    v_vehicle_data typ_vehicle_data;
  BEGIN
    v_vehicle_data.source := p_json.get('source').get_string;
    v_vehicle_data.result := p_json.get('result').get_string;
    v_vehicle_data.brand  := p_json.get('brand').get_string;
    v_vehicle_data.model  := p_json.get('model').get_string;
    v_vehicle_data.qc     := p_json.get('qc').get_number;
    RETURN v_vehicle_data;
  END;

  PROCEDURE recognize_addresses
  (
    p_addresses         typ_strings
   ,p_address_data_list OUT typ_address_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_address_url, p_addresses, v_responce_list);
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_address_data_list(i) := map_addr_json_to_rec(v_result_item);
    END LOOP;
  END recognize_addresses;

  PROCEDURE recognize_address
  (
    p_address      VARCHAR2
   ,p_address_data OUT typ_address_data
  ) IS
    v_list typ_address_data_list;
  BEGIN
    recognize_addresses(p_addresses => typ_strings(p_address), p_address_data_list => v_list);
    p_address_data := v_list(1);
  END;

  PROCEDURE recognize_phones
  (
    p_phones           typ_strings
   ,p_phones_data_list OUT typ_phone_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_phone_url, p_phones, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_phones_data_list(i) := map_phone_json_to_rec(v_result_item);
    END LOOP;
  END recognize_phones;

  PROCEDURE recognize_phone
  (
    p_phone      VARCHAR2
   ,p_phone_data OUT typ_phone_data
  ) IS
    v_list typ_phone_data_list;
  BEGIN
    recognize_phones(p_phones => typ_strings(p_phone), p_phones_data_list => v_list);
    p_phone_data := v_list(1);
  END;

  PROCEDURE recognize_passport
  (
    p_passports           typ_strings
   ,p_passports_data_list OUT typ_passport_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_passport_url, p_passports, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_passports_data_list(i) := map_passport_json_to_rec(v_result_item);
    END LOOP;
  END recognize_passport;
  PROCEDURE recognize_passport
  (
    p_passport      VARCHAR2
   ,p_passport_data OUT typ_passport_data
  ) IS
    v_list typ_passport_data_list;
  BEGIN
    recognize_passport(p_passports => typ_strings(p_passport), p_passports_data_list => v_list);
    p_passport_data := v_list(1);
  END;

  PROCEDURE recognize_name
  (
    p_names           typ_strings
   ,p_names_data_list OUT typ_name_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_name_url, p_names, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_names_data_list(i) := map_name_json_to_rec(v_result_item);
    END LOOP;
  END recognize_name;
  PROCEDURE recognize_name
  (
    p_name      VARCHAR2
   ,p_name_data OUT typ_name_data
  ) IS
    v_list typ_name_data_list;
  BEGIN
    recognize_name(p_names => typ_strings(p_name), p_names_data_list => v_list);
    p_name_data := v_list(1);
  END;

  PROCEDURE recognize_email
  (
    p_emails           typ_strings
   ,p_emails_data_list OUT typ_email_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_email_url, p_emails, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_emails_data_list(i) := map_email_json_to_rec(v_result_item);
    END LOOP;
  END recognize_email;
  PROCEDURE recognize_email
  (
    p_email      VARCHAR2
   ,p_email_data OUT typ_email_data
  ) IS
    v_list typ_email_data_list;
  BEGIN
    recognize_email(p_emails => typ_strings(p_email), p_emails_data_list => v_list);
    p_email_data := v_list(1);
  END;

  PROCEDURE recognize_date
  (
    p_dates           typ_strings
   ,p_dates_data_list OUT typ_date_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_date_url, p_dates, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_dates_data_list(i) := map_date_json_to_rec(v_result_item);
    END LOOP;
  END;
  PROCEDURE recognize_date
  (
    p_date      VARCHAR2
   ,p_date_data OUT typ_date_data
  ) IS
    v_list typ_date_data_list;
  BEGIN
    recognize_date(p_dates => typ_strings(p_date), p_dates_data_list => v_list);
    p_date_data := v_list(1);
  END;

  PROCEDURE recognize_vehicle
  (
    p_vehicle           typ_strings
   ,p_vehicle_data_list OUT typ_vehicle_data_list
  ) IS
    v_responce_list JSON_LIST;
    v_result_item   JSON;
  BEGIN
    -- Запрос сервиса
    request_dadata(gc_vehicle_url, p_vehicle, v_responce_list);
  
    -- тут мы делаем запрос
    --request_dadata_service(par_address_list => par_address_list, par_responce => v_responce);
    FOR i IN 1 .. v_responce_list.count
    LOOP
      v_result_item := JSON(v_responce_list.get(i));
      p_vehicle_data_list(i) := map_vechile_json_to_rec(v_result_item);
    END LOOP;
  END;
  PROCEDURE recognize_vehicle
  (
    p_vehicle      VARCHAR2
   ,p_vehicle_data OUT typ_vehicle_data
  ) IS
    v_list typ_vehicle_data_list;
  BEGIN
    recognize_vehicle(p_vehicle => typ_strings(p_vehicle), p_vehicle_data_list => v_list);
    p_vehicle_data := v_list(1);
  END;

END dadata_api;
/
