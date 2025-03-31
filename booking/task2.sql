-- Выбор схемы
SET search_path TO booking_hw;

-- клиенты с частыми бронированиями в разных отелях
WITH customer_bookings AS (
    SELECT
        c.id_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price) AS total_spent
    FROM booking b
    JOIN customer c ON b.id_customer = c.id_customer
    JOIN room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.id_customer, c.name
    HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT h.ID_hotel) > 1
),

-- клиенты, потратившие более 500 долларов
spent_more_500 AS (
    SELECT
        c.id_customer,
        c.name,
        SUM(r.price) AS total_spent,
        COUNT(b.ID_booking) AS total_bookings
    FROM booking b
    JOIN customer c ON b.id_customer = c.id_customer
    JOIN room r ON b.ID_room = r.ID_room
    GROUP BY c.id_customer, c.name
    HAVING SUM(r.price) > 500
)

-- пересечение двух групп клиентов
SELECT
    cb.id_customer,
    cb.name,
    cb.total_bookings,
    cb.total_spent,
    cb.unique_hotels
FROM customer_bookings cb
JOIN spent_more_500 csm ON cb.id_customer = csm.id_customer
-- сортировка по возрастанию суммы расходов
ORDER BY cb.total_spent ASC;