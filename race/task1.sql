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
),

-- для каждого класса машин находит лучший средний результат
MinClassAvg AS (
    SELECT
        car_class,
        MIN(average_position) AS min_avg_position
    FROM car_average
    GROUP BY car_class
)

-- выводит информацию о машинах из каждого клсса с лучшим результатом
SELECT
    ca.car_name,
    ca.car_class,
    ROUND(ca.average_position, 4) AS average_position,
    ca.race_count
FROM car_average ca
JOIN MinClassAvg mca ON ca.car_class = mca.car_class
                     AND ca.average_position = mca.min_avg_position
-- сортировка по средней позиции
ORDER BY average_position;