CREATE TABLE витрина_перевозчики AS
SELECT 
    trips."_IDRRef" AS "ИД_рейса",
    trips."_Fld6222" AS "Название_перевозчика",
    trips."_Date_Departure"::timestamp AS "Дата_выезда",
    trips."_Fld6227"::numeric AS "Расстояние_км",
    
    -- МЕТРИКА 1: Коэффициент загрузки кузова, % (порейсово)
    ROUND((warehouse."_Fld7110"::numeric * 1.0 / trucks."_Fld5110"::numeric) * 100, 2) AS "Загрузка_кузова_процент",
    
    -- МЕТРИКА 2: Факт опоздания (1 - опоздал, 0 - вовремя)
    CASE 
        WHEN trips."_Fld6225"::timestamp > trips."_Fld6224"::timestamp THEN 1 
        ELSE 0 
    END AS "Fact_opozdaniya",

    -- МЕТРИКА 3: Lead Time (Переводим текст в TIMESTAMP, находим разницу в часах)
    ROUND(
        (EXTRACT(EPOCH FROM (trips."_Fld6225"::timestamp - trips."_Date_Departure"::timestamp)) / 3600)::numeric, 
        1
    ) AS "Время_в_пути_часов",

    -- МЕТРИКА 4: Стоимость тонно-километра, руб.
    ROUND(
        trips."_Fld6226"::numeric * 1.0 / NULLIF((warehouse."_Fld7110"::numeric / 1000.0) * trips."_Fld6227"::numeric, 0), 
        2
    ) AS "Стоимость_тонно_километра"

FROM "_document120" AS trips
LEFT JOIN "_reference92" AS trucks ON trips."_Fld6223" = trucks."_IDRRef"
LEFT JOIN "_document144" AS warehouse ON trips."_IDRRef" = warehouse."_IDRRef";