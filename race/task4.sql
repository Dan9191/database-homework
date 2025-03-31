-- выбор схемы для выполнения скрипта
SET search_path TO race_hw;

-- средние показателей для каждого автомобиля
WITH car_average AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.name, c.class
),

-- вычисление средних показателей для каждого класса автомобилей
class_average AS (
    SELECT
        c.class AS car_class,
        AVG(r.position) AS avg_class_position,
        COUNT(DISTINCT c.name) AS car_count
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.class
)

-- выбор автомобилф лучше среднего по классу
SELECT
    ca.car_name,
    ca.car_class,
    ROUND(ca.average_position, 4) AS average_position,
    ca.race_count,
    cl.country AS car_country
FROM car_average ca
JOIN class_average cla ON ca.car_class = cla.car_class
JOIN classes cl ON ca.car_class = cl.class
WHERE ca.average_position < cla.avg_class_position
  AND cla.car_count > 1
ORDER BY ca.car_class, ca.average_position;