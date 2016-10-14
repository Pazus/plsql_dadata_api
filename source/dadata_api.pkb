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
    
      -- dadata искожает исходную строку, удаляя там двойные пробелы
      -- после логирования переопределяем source на то, что было исходником на самом деле
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
    -- тут мы делаем запрос
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
