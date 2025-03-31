-- Выбор схемы
SET search_path TO race_hw;

-- вычисление средней позиции для каждого класса автомобилей
WITH class_averages AS (
    SELECT
        c.class AS car_class,
        AVG(r.position) AS avg_class_position,
        COUNT(r.race) AS total_race_count
    FROM cars c
    JOIN results r ON c.name = r.car
    GROUP BY c.class
),

-- Находим минимальное среднее положение среди всех классов
min_avg AS (
    SELECT MIN(avg_class_position) AS min_avg_position
    FROM class_averages
),

-- Выбираем классы с лучшим средним результатом
top_classes AS (
    SELECT
        ca.car_class,
        ca.avg_class_position,
        ca.total_race_count
    FROM class_averages ca
    JOIN min_avg ma ON ca.avg_class_position = ma.min_avg_position
)

-- получаем информацию о лучших автомобилях в лучших классах
SELECT
    ca.car_name,
    ca.car_class,
    ROUND(ca.average_position, 4) AS average_position,
    ca.race_count,
    cl.country,
    sc.total_race_count AS total_races
FROM (
    --средние показатели для каждого автомобиля
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
) ca
JOIN top_classes sc ON ca.car_class = sc.car_class
JOIN classes cl ON ca.car_class = cl.class
-- Сортируем сначала по средней позиции, затем по имени автомобиля
ORDER BY average_position, car_name;