-- Выбор схемы
SET search_path TO race_hw;

-- Вычисление средних позиций для каждого автомобиля
WITH car_averages AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),

-- Выбор автомобилей с плохими результатами (средняя позиция > 3.0)
cars_low_position AS (
    SELECT
        ca.car_name,
        ca.car_class,
        ca.average_position,
        ca.race_count
    FROM car_averages ca
    WHERE ca.average_position > 3.0
),

-- количество гонок для каждого класса
class_race_counts AS (
    SELECT
        c.class AS car_class,
        COUNT(r.race) AS total_race_count  -- Общее число гонок в классе
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),

-- количества плохих автомобилей в каждом классе
class_last_counts AS (
    SELECT
        lpc.car_class,
        COUNT(lpc.car_name) AS low_position_count
    FROM cars_low_position lpc
    GROUP BY lpc.car_class
)

-- данные проблемных автомобилей
SELECT
    lpc.car_name,
    lpc.car_class,
    ROUND(lpc.average_position, 4) AS average_position,
    lpc.race_count,
    cl.country,
    crc.total_race_count,
    clpc.low_position_count
FROM cars_low_position lpc
JOIN class_last_counts clpc ON lpc.car_class = clpc.car_class
JOIN Classes cl ON lpc.car_class = cl.class
JOIN class_race_counts crc ON lpc.car_class = crc.car_class
ORDER BY clpc.low_position_count DESC;