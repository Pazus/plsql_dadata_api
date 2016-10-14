CREATE OR REPLACE PACKAGE dadata_api IS

  TYPE typ_strings IS TABLE OF VARCHAR2(4000);

  SUBTYPE typ_kladr_code IS VARCHAR2(19 CHAR);
  SUBTYPE typ_fias_id IS VARCHAR2(36 CHAR);
  SUBTYPE typ_name_with_type IS VARCHAR2(131 CHAR);
  SUBTYPE typ_qc IS PLS_INTEGER;

  TYPE typ_address_data IS RECORD(
     SOURCE  VARCHAR2(4000) --Исходный адрес одной строкой
    ,RESULT  VARCHAR2(4000) --Стандартизованный адрес одной строкой
    ,zip     VARCHAR2(9) --Индекс
    ,country VARCHAR2(120 CHAR) -- Страна
    
    ,region_fias_id   typ_fias_id -- Код ФИАС региона
    ,region_kladr_id  typ_kladr_code --Код КЛАДР региона
    ,region_with_type typ_name_with_type --Регион с типом
    ,region_type      VARCHAR2(50) --Тип региона (сокращенный)
    ,region_type_full VARCHAR2(255) -- Тип региона
    ,region           VARCHAR2(1000) --Регион
    
    ,area_fias_id   typ_fias_id --Код ФИАС района в регионе
    ,area_kladr_id  typ_kladr_code --Код КЛАДР района в регионе
    ,area_with_type typ_name_with_type --Район в регионе с типом
    ,area_type      VARCHAR2(50) --Тип района в регионе (сокращенный)
    ,area_type_full VARCHAR2(255) --Тип района в регионе
    ,area           VARCHAR2(1000) --Район в регионе
    
    ,city_fias_id   typ_fias_id --Код ФИАС города
    ,city_kladr_id  typ_kladr_code --Код КЛАДР города
    ,city_with_type typ_name_with_type --Город с типом
    ,city_type      VARCHAR2(50) --Тип города (сокращенный)
    ,city_type_full VARCHAR2(255) --Тип города
    ,city           VARCHAR2(1000) --Город
    
    ,city_area               VARCHAR2(1000) --Административный округ (только для Москвы)
    ,city_district_fias_id   typ_fias_id --Код ФИАС района города (не заполняется)
    ,city_district_kladr_id  typ_kladr_code --Код КЛАДР района города (не заполняется)
    ,city_district_with_type typ_name_with_type --Район города с типом
    ,city_district_type      VARCHAR2(50) --Тип района города (сокращенный)
    ,city_district_type_full VARCHAR2(255) --Тип района города
    ,city_district           VARCHAR2(1000) --Район города
    
    ,settlement_fias_id   typ_fias_id --Код ФИАС нас. пункта
    ,settlement_klard_id  typ_kladr_code --Код КЛАДР нас. пункта
    ,settlement_with_type typ_name_with_type --Населенный пункт с типом
    ,settlement_type      VARCHAR2(50) --Тип населенного пункта (сокращенный)
    ,settlement_type_full VARCHAR2(255) --Тип населенного пункта
    ,settlement           VARCHAR2(1000) --Населенный пункт
    
    ,street_fias_id   typ_fias_id --Код ФИАС улицы
    ,street_kladr_id  typ_kladr_code --Код КЛАДР улицы
    ,street_with_type typ_name_with_type --Улица с типом
    ,street_type      VARCHAR2(50) --Тип улицы (сокращенный)
    ,street_type_full VARCHAR2(255) --Тип улицы
    ,street           VARCHAR2(1000) --Улица
    
    ,house_fias_id   typ_fias_id --Код ФИАС дома
    ,house_kladr_id  typ_kladr_code --Код КЛАДР дома
    ,house_type      VARCHAR2(50) --Тип дома (сокращенный)
    ,house_type_full VARCHAR2(255) --Тип дома
    ,house           VARCHAR2(1000) --Дом
    
    ,block_type      VARCHAR2(50) --Тип корпуса/строения (сокращенный)
    ,block_type_full VARCHAR2(255) --Тип корпуса/строения
    ,BLOCK           VARCHAR2(255) --Корпус/строение
    
    ,flat_type          VARCHAR2(50) --Тип квартиры (сокращенный)
    ,flat_type_full     VARCHAR2(255) --Тип квартиры
    ,flat               VARCHAR2(1000) --Квартира
    ,flat_area          NUMBER --Площадь квартиры
    ,square_meter_price NUMBER --Рыночная стоимость м?
    ,flat_price         NUMBER --Рыночная стоимость квартиры
    ,postal_box         VARCHAR2(255) --Абонентский ящик
    
    ,fias_id        typ_fias_id --Код ФИАС
    ,fial_level     INTEGER --Уровень детализации, до которого адрес найден в ФИАС
    ,kladr_id       typ_kladr_code --Код КЛАДР
    ,capital_marker INTEGER(1) --Статус центра
    ,okato          VARCHAR2(11) --Код ОКАТО
    ,oktmo          VARCHAR2(11) --Код ОКТМО
    
    ,tax_office       INTEGER --Код ИФНС для физических лиц
    ,tax_office_legal INTEGER --Код ИФНС для организаций (не заполняется)
    ,timezone         VARCHAR2(25) --Часовой пояс
    ,geo_lat          NUMBER --Координаты: широта
    ,geo_lon          NUMBER --Координаты: долгота
    ,beltway_hit      VARCHAR2(10) --Внутри кольцевой?
    ,beltway_distance NUMBER --Расстояние от кольцевой в км.
    ,qc_geo           PLS_INTEGER --Код точности координат
    ,qc_complete      PLS_INTEGER --Код пригодности к рассылке
    ,qc_house         PLS_INTEGER --Признак наличия дома в ФИАС
    ,qc               PLS_INTEGER --Код проверки адреса
    ,unparsed_parts   VARCHAR2(4000) --Нераспознанная часть адреса. Для адреса
    );
  TYPE typ_address_data_list IS TABLE OF typ_address_data INDEX BY PLS_INTEGER;

  TYPE typ_phone_data IS RECORD(
     SOURCE       VARCHAR2(100 CHAR) -- Исходный телефон одной строкой
    ,TYPE         VARCHAR2(50 CHAR) -- Тип телефона
    ,phone        VARCHAR2(50 CHAR) -- Стандартизованный телефон одной строкой
    ,country_code VARCHAR2(5 CHAR) -- Код страны
    ,city_code    VARCHAR2(5 CHAR) -- Код города / DEF-код
    ,NUMBER       VARCHAR2(10 CHAR) -- Локальный номер телефона
    ,extension    VARCHAR2(10 CHAR) -- Добавочный номер
    ,provider     VARCHAR2(100 CHAR) -- Оператор связи 
    ,region       VARCHAR2(100 CHAR) -- Регион
    ,timezone     VARCHAR2(10 CHAR) -- Часовой пояс
    ,qc_conflict  INTEGER -- Признак конфликта телефона с адресом
    ,qc           typ_qc -- од проверки
    );
  TYPE typ_phone_data_list IS TABLE OF typ_phone_data INDEX BY PLS_INTEGER;

  TYPE typ_passport_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- Исходная серия и номер одной строкой
    ,series VARCHAR2(20 CHAR) -- Серия
    ,NUMBER VARCHAR2(20 CHAR) -- Номер
    ,qc     INTEGER --  Код проверки
    );
  TYPE typ_passport_data_list IS TABLE OF typ_passport_data INDEX BY PLS_INTEGER;

  TYPE typ_name_data IS RECORD(
     SOURCE          VARCHAR2(100 CHAR) -- Исходное ФИО одной строкой
    ,RESULT          VARCHAR2(150 CHAR) -- Стандартизованное ФИО одной строкой
    ,result_genitive VARCHAR2(150 CHAR) -- ФИО в родительном падеже (кого?)
    ,result_dative   VARCHAR2(150 CHAR) -- ФИО в дательном падеже (кому?)
    ,result_ablative VARCHAR2(150 CHAR) -- ФИО в творительном падеже (кем?)
    ,surname         VARCHAR2(50 CHAR) -- Фамилия
    ,NAME            VARCHAR2(50 CHAR) -- Имя
    ,patronymic      VARCHAR2(50 CHAR) -- Отчество
    ,gender          VARCHAR2(10 CHAR) -- Пол
    ,qc              typ_qc -- Код проверки
    );
  TYPE typ_name_data_list IS TABLE OF typ_name_data INDEX BY PLS_INTEGER;

  TYPE typ_email_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- Исходный email
    ,email  VARCHAR2(100 CHAR) -- Исходный email
    ,qc     typ_qc -- Код проверки
    );
  TYPE typ_email_data_list IS TABLE OF typ_email_data INDEX BY PLS_INTEGER;

  TYPE typ_date_data IS RECORD(
     SOURCE    VARCHAR2(100 CHAR) -- Исходная дата
    ,birthdate VARCHAR2(100 CHAR) -- Стандартизованная дата
    ,qc        typ_qc -- Код проверки
    );
  TYPE typ_date_data_list IS TABLE OF typ_date_data INDEX BY PLS_INTEGER;

  TYPE typ_auto_data IS RECORD(
     SOURCE VARCHAR2(100 CHAR) -- Исходное значение
    ,RESULT VARCHAR2(100 CHAR) -- Стандартизованное значение
    ,brand  VARCHAR2(50 CHAR) -- Марка
    ,model  VARCHAR2(50 CHAR) -- Модель
    ,qc     typ_qc -- Код проверки
    );
  TYPE typ_auto_data_list IS TABLE OF typ_auto_data INDEX BY PLS_INTEGER;

  -- Код проверки (qc) — нужно ли вручную проверить распознанный адрес:
  gc_addr_qc_ok     CONSTANT typ_qc := 0; -- Адрес распознан уверенно
  gc_addr_qc_assume CONSTANT typ_qc := 1; -- Адрес распознан с допущениями или не распознан, Нужно проверить вручную
  gc_addr_qc_trash  CONSTANT typ_qc := 2; -- Адрес пустой или заведомо «мусорный»

  -- Код проверки (qc) — нужно ли вручную проверить распознанный телефон:
  gc_phone_qc_ok       CONSTANT typ_qc := 0; -- Телефон распознан уверенно
  gc_phone_qc_assume   CONSTANT typ_qc := 1; -- Телефон распознан с допущениями или не распознан (Нужно проверить вручную)
  gc_phone_qc_trash    CONSTANT typ_qc := 2; -- Телефон пустой или заведомо «мусорный»
  gc_phone_qc_multiple CONSTANT typ_qc := 3; -- Обнаружено несколько телефонов, распознан первый (Нужно проверить вручную)

  -- Код проверки (qc) — требуется ли вручную проверить распознанное значение:
  gc_name_qc_ok     CONSTANT typ_qc := 0; -- Исходное значение распознано уверенно
  gc_name_qc_assume CONSTANT typ_qc := 1; -- Исходное значение распознано с допущениями или не распознано (Нужно проверить вручную)
  gc_name_qc_trash  CONSTANT typ_qc := 2; -- Исходное значение пустое или заведомо «мусорное»

  --Код проверки (qc) — подходит ли email для маркетинговой рассылки:
  gc_email_qc_ok      CONSTANT typ_qc := 0; -- Корректное значение. Соответствует общепринятым правилам, реальное существование адреса не проверяется
  gc_email_qc_trash   CONSTANT typ_qc := 2; -- Пустое или заведомо «мусорное» значение
  gc_email_qc_onetime CONSTANT typ_qc := 3; -- «Одноразовый» адрес. Домены 10minutemail.com, getairmail.com, temp-mail.ru и аналогичные
  -- Далее требуется ручная проверка:
  gc_email_qc_incorrect CONSTANT typ_qc := 1; -- Некорректное значение Не соответствует общепринятым правилам
  gc_email_qc_misspells CONSTANT typ_qc := 4; -- Исправлены опечатки

  -- Код проверки (qc) — требуется ли вручную проверить распознанное значение:
  gc_date_qc_ok     CONSTANT typ_qc := 0; -- Исходное значение распознано уверенно
  gc_date_qc_assume CONSTANT typ_qc := 1; -- Исходное значение распознано с допущениями или не распознано (Нужно проверить вручную)
  gc_date_qc_trash  CONSTANT typ_qc := 2; -- Исходное значение пустое или заведомо «мусорное»

  -- Код проверки (qc) — требуется ли вручную проверить распознанное значение:
  gc_auto_qc_ok     CONSTANT typ_qc := 0; -- Исходное значение распознано уверенно
  gc_auto_qc_assume CONSTANT typ_qc := 1; -- Исходное значение распознано с допущениями или не распознано (Нужно проверить вручную)
  gc_auto_qc_trash  CONSTANT typ_qc := 2; -- Исходное значение пустое или заведомо «мусорное»

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
