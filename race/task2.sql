-- Выбор схемы
SET search_path TO race_hw;

-- вычисление среднего показателя занятого места
WITH car_average AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
)

SELECT
    ca.car_name,
    ca.car_class,
    ROUND(ca.average_position, 4) AS average_position,
    ca.race_count,
    cl.country
FROM car_average ca
JOIN (
-- общий минимум средних позиций среди всех автомобилей
         SELECT
             MIN(average_position) AS min_avg_position
         FROM car_average
     ) ma ON ca.average_position = ma.min_avg_position

JOIN classes cl ON ca.car_class = cl.class
-- сортировка по имени авто
ORDER BY ca.car_name
-- получение первого авто
LIMIT 1;