-- Выбор схемы
SET search_path TO booking_hw;

-- Основной запрос для определения предпочтений клиентов по категориям отелей
WITH HotelCategories AS (
    -- CTE для классификации отелей по средней цене номера
    SELECT
        h.ID_hotel,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            WHEN AVG(r.price) > 300 THEN 'Дорогой'
            ELSE 'Не определен'
        END AS hotel_category,
        -- Добавляем среднюю цену для информации
        ROUND(AVG(r.price), 2) AS avg_price
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel
),
CustomerPreferences AS (
    -- CTE для определения предпочтений клиентов на основе бронирований
    SELECT
        b.ID_customer,
        -- Определяем предпочитаемый тип отеля (максимальная категория из забронированных)
        MAX(CASE
            WHEN hc.hotel_category = 'Дорогой' THEN 'Дорогой'
            WHEN hc.hotel_category = 'Средний' THEN 'Средний'
            WHEN hc.hotel_category = 'Дешевый' THEN 'Дешевый'
            ELSE NULL
        END) AS preferred_hotel_type,
        -- Список всех отелей, где клиент бронировал номера
        STRING_AGG(DISTINCT h.name, ', ' ORDER BY h.name) AS visited_hotels,
        -- Добавляем количество посещенных отелей
        COUNT(DISTINCT h.ID_hotel) AS hotels_visited_count
    FROM Booking b
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN HotelCategories hc ON h.ID_hotel = hc.ID_hotel
    GROUP BY b.ID_customer
)

-- Итоговый запрос с информацией о клиентах и их предпочтениях
SELECT
    cp.ID_customer,
    c.name AS customer_name,
    cp.preferred_hotel_type AS preferred_category,
    cp.visited_hotels AS hotels_visited,
    cp.hotels_visited_count,
    -- Добавляем информацию о клиенте
    c.email,
    c.registration_date
FROM CustomerPreferences cp
JOIN Customer c ON cp.ID_customer = c.ID_customer
-- Сортируем по категории отеля (дешевые -> средние -> дорогие)
ORDER BY
    CASE cp.preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
        ELSE 4
    END,
    c.name;  -- Дополнительная сортировка по имени клиента