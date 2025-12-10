CREATE TABLE service_task(
    service_task_id SERAIAL PRIMARY KEY,
    booking_id SMALLINT NOT NULL,
    service_id SMALLINT NOT NULL,
    service_task_status ENUM('Pending', 'In Progress', 'Completed') DEFAULT 'Pending',
    bay_id SMALLINT NOT NULL,
    start_time SMALLINT,
    end_time SMALLINT,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES service_detail(service_id),
    FOREIGN KEY (bay_id) REFERENCES bay(bay_id)
) CREATE TABLE bay(
    bay_id SERIAL PRIMARY KEY,
    bay_last_inspection_date SMALLDATETIME,
    bay_status ENUM('Available', 'Occupied', 'Under Maintenance') DEFAULT 'Available' bay_inspection_result ENUM('Pass', 'Fail')
) CREATE TABLE staff_allocation(
    service_task_id SMALLINT NOT NULL,
    staff_id SMALLINT NOT NULL,
    allocation_role ENUM('Technician', 'Supervisor', 'Assistant') NOT NULL,
    PRIMARY KEY (service_task_id, staff_id),
    FOREIGN KEY (service_task_id) REFERENCES service_task(service_task_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
) Create TABLE service_detail(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT,
    service_duration SMALLINT NOT NULL,
    service_cost DECIMAL(10, 2) NOT NULL
) CREATE TABLE car_parts(
    service_id SMALLINT NOT NULL,
    part_id SMALLINT NOT NULL,
    part_amount SMALLINT NOT NULL,
    PRIMARY KEY (service_id, part_id),
    FOREIGN KEY (service_id) REFERENCES service_detail(service_id),
    FOREIGN KEY (part_id) REFERENCES parts_inventory(part_id)
) CREATE TABLE parts_inventory(
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_supplier_id SMALLINT NOT NULL,
    FOREIGN KEY (part_supplier_id) REFERENCES supplier(supplier_id)
) CREATE TABLE supplier(
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_contact VARCHAR(100),
    supplier_address TEXT
)


-- Query to find mechanics with a MOT pass rate greater than 75% in the last year
SELECT
    s.staff_id as "Staff ID",
    s.first_name || ' ' || s.last_name as "Staff Name",
    mot_stats.total_mots as "Total MOTs",
    mot_stats.passed_mots as "Passed MOTs",
    mot_stats.pass_rate_percentage as "MOT Pass Rate (%)"
FROM
    staff s
JOIN (
    SELECT
        mechanic_id,
        COUNT(*) as total_mots,
        SUM(CASE WHEN MOT_outcome = 'Pass' THEN 1 ELSE 0 END) as passed_mots,
        ROUND((SUM(CASE WHEN MOT_outcome = 'Pass' THEN 1 ELSE 0 END)::DECIMAL / COUNT(*)) * 100, 2) as pass_rate_percentage
    FROM
        car_mot
    WHERE
        MOT_date >= NOW() - INTERVAL '1 year'
    GROUP BY
        mechanic_id
    )  as mot_stats ON s.staff_id = mot_stats.mechanic_id -- makes mini table that tells us stats from past year
WHERE mot_stats.passed_mots::numeric / mot_stats.total_mots > 0.75 -- filter for over 75% pass rate
ORDER BY mot_stats.pass_rate_percentage DESC;


-- Create VIEW for a staff schedule for the next week
CREATE OR REPLACE VIEW staff_schedule AS
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 1) AS "Monday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 2) AS "Tuesday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 3) AS "Wednesday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 4) AS "Thursday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 5) AS "Friday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 6) AS "Saturday",
    STRING_AGG(sh.shift_start_time || ' - ' || sh.shift_end_time,', ') FILTER (WHERE EXTRACT(DOW FROM sh.shift_date) = 0) AS "Sunday"
FROM
    staff s
LEFT JOIN -- some staff may not have shifts assigned
    staff_availability sa ON s.staff_id = sa.staff_id
LEFT JOIN
    shift sh ON sa.shift_id = sh.shift_id
WHERE
    sh.shift_date >= DATE_TRUNC('week', CURRENT_DATE)
    AND sh.shift_date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
GROUP BY
    s.staff_id, s.first_name, s.last_name
ORDER BY
    s.staff_id;
