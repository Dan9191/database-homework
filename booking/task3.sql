-- Выбор схемы
SET search_path TO booking_hw;

-- Категоризация отелей
WITH categories AS (
    SELECT
        h.id_hotel,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            WHEN AVG(r.price) > 300 THEN 'Дорогой'
        END AS hotel_category
    FROM hotel h
    JOIN room r ON h.id_hotel = r.id_hotel
    GROUP BY h.id_hotel
),
--Анализ предпочтений клиентов.
preferences AS (
    SELECT
        b.id_customer,
        MAX(CASE
            WHEN hc.hotel_category = 'Дорогой' THEN 'Дорогой'
            WHEN hc.hotel_category = 'Средний' THEN 'Средний'
            WHEN hc.hotel_category = 'Дешевый' THEN 'Дешевый'
            ELSE NULL
        END) AS preferred_hotel_type,
        STRING_AGG(DISTINCT h.name, ', ') AS visited_hotels
    FROM booking b
    JOIN room r ON b.id_room = r.id_room
    JOIN hotel h ON r.id_hotel = h.id_hotel
    JOIN categories hc ON h.id_hotel = hc.id_hotel
    GROUP BY b.id_customer
)

-- выведот для каждого клиента информации
SELECT
    cp.id_customer,
	c.name,
    cp.preferred_hotel_type,
    cp.visited_hotels
FROM preferences cp
JOIN customer c ON cp.id_customer = c.id_customer
-- сортировка по категории отелей + алфавитный порядок имени
ORDER BY
    CASE cp.preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END,
    c.name DESC;