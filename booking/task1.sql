-- Выбор схемы
SET search_path TO booking_hw;

SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(b.id_booking) AS booking_count,
    STRING_AGG(DISTINCT h.name, ', ') AS hotels,
    ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS avg_stay_duration
    -- обединение таблиц
FROM booking b
JOIN customer c ON b.id_customer = c.id_customer
JOIN room r ON b.id_room = r.id_room
JOIN hotel h ON r.id_hotel = h.id_hotel
-- группировка по клиентам
GROUP BY c.id_customer
-- фильтры для группировки
HAVING COUNT(DISTINCT h.id_hotel) > 1  AND COUNT(b.id_booking) >= 3
-- сортировка по количеству бронирований
ORDER BY booking_count DESC;