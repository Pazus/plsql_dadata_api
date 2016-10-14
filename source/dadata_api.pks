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

  gc_structure_asis     CONSTANT VARCHAR2(5) := 'AS_IS';
  gc_structure_name     CONSTANT VARCHAR2(4) := 'NAME';
  gc_structure_address  CONSTANT VARCHAR2(7) := 'ADDRESS';
  gc_structure_phone    CONSTANT VARCHAR2(5) := 'PHONE';
  gc_structure_passport CONSTANT VARCHAR2(8) := 'PASSPORT';
  gc_structure_email    CONSTANT VARCHAR2(5) := 'EMAIL';
  gc_structure_vehicle  CONSTANT VARCHAR2(7) := 'VEHICLE';
  gc_structure_ignore   CONSTANT VARCHAR2(6) := 'IGNORE';

  -- Исключения

  --Некорректный запрос:
  --  Невалидный JSON.
  --  Отсутствуют обязательные параметры structure или data.
  --  В structure указан неподдерживаемый тип.
  --  Количество полей в записях более указанного в structure.  
  ex_incorrect_request EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_incorrect_request, -20400);

  -- В запросе отсутствует API-ключ или секретный ключ
  ex_api_token_or_key_missing EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_api_token_or_key_missing, -20401);

  -- Недостаточно средств для обработки запроса, пополните баланс
  ex_not_enough_money EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_not_enough_money, -20402);

  -- В запросе указан несуществующий ключ
  ex_wrong_key EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_wrong_key, -20403);

  -- Запрос сделан с методом, отличным от POST
  ex_wrong_method EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_wrong_method, -20405);

  -- Запрос содержит более 50 записей
  ex_too_many_rows EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_too_many_rows, -20413);

  -- Произошла внутренняя ошибка сервиса во время обработки
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
