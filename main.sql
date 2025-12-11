CREATE TYPE service_task_status AS ENUM ('Pending', 'In Progress', 'Completed');

CREATE TABLE service_task(
    service_task_id SERIAL PRIMARY KEY,
    booking_id SMALLINT NOT NULL,
    service_id SMALLINT NOT NULL,
    service_task_status service_task_status DEFAULT 'Pending',
    bay_id SMALLINT NOT NULL,
    start_time SMALLINT,
    end_time SMALLINT,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (service_id) REFERENCES service_detail(service_id),
    FOREIGN KEY (bay_id) REFERENCES bay(bay_id)
);

CREATE TYPE bay_status AS ENUM ('Available', 'Occupied', 'Under Maintenance');
CREATE TYPE bay_inspection_result AS ENUM ('Pass', 'Fail');

CREATE TABLE bay(
    bay_id SERIAL PRIMARY KEY,
    bay_last_inspection_date SMALLDATETIME,
    bay_status bay_status DEFAULT 'Available',
    bay_inspection_result bay_inspection_result
);

CREATE TYPE allocation_role AS ENUM ('Technician', 'Supervisor', 'Assistant');

CREATE TABLE staff_allocation(
    service_task_id SMALLINT NOT NULL,
    staff_id SMALLINT NOT NULL,
    allocation_role allocation_role NOT NULL,
    PRIMARY KEY (service_task_id, staff_id),
    FOREIGN KEY (service_task_id) REFERENCES service_task(service_task_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

Create TABLE service_detail(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT,
    service_duration SMALLINT NOT NULL,
    service_cost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE car_parts(
    service_id SMALLINT NOT NULL,
    part_id SMALLINT NOT NULL,
    part_amount SMALLINT NOT NULL,
    PRIMARY KEY (service_id, part_id),
    FOREIGN KEY (service_id) REFERENCES service_detail(service_id),
    FOREIGN KEY (part_id) REFERENCES parts_inventory(part_id)
);

CREATE TABLE parts_inventory(
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_supplier_id SMALLINT NOT NULL,
    FOREIGN KEY (part_supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE supplier(
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_contact VARCHAR(100),
    supplier_address TEXT
);

CREATE TYPE booking_status AS ENUM ('Pending', 'Confirmed', 'Cancelled', 'Completed');

CREATE TABLE booking (
    booking_ID SERIAL PRIMARY KEY,
    booking_date DATETIME,
    Scheduled_Date DATETIME,
    Scheduled_Time SMALLINT,
    booking_status booking_status DEFAULT 'Pending',
    Customer_ID SMALLINT,
    Vehicle_ID SMALLINT,
    Total_Amount SMALLINT,
    courtesy_car_ID SMALLINT,
    FOREIGN KEY (Customer_ID) REFERENCES customer(Customer_ID),
    FOREIGN KEY (Vehicle_ID) REFERENCES vehicle(Vehicle_ID),
    FOREIGN KEY (courtesy_car_ID) REFERENCES courtesy_car(courtesy_car_ID)
);

CREATE TABLE booking_feedback (
    feedback_ID SERIAL PRIMARY KEY,
    booking_ID SMALLINT,
    feedback TEXT,
    FOREIGN KEY (booking_ID) REFERENCES booking(booking_ID)
);

CREATE TABLE customer_details (
    Customer__ID SERIAL PRIMARY KEY,
    Customer_phone VARCHAR(15),
    Customer_email VARCHAR(50),
    FOREIGN KEY (Membership_ID) REFERENCES customer(Customer_ID)
);

CREATE TYPE membership_tier AS ENUM ('Silver', 'Gold', 'Platinum');

CREATE TABLE memberships (
    Membership_ID SERIAL PRIMARY KEY,
    Membership_tier membership_tier,
    Membership_discount SMALLINT,
    Priority_booking BOOLEAN,
    courtesy_elligibility BOOLEAN
);

CREATE TABLE courtesy_car (
    courtesy_car_ID SERIAL PRIMARY KEY,
    start_date SMALLDATETIME,
    agreed_return_date SMALLDATETIME,
    actual_return_date SMALLDATETIME,
    Availability_status BOOLEAN
);

CREATE TYPE payment_method AS ENUM (
    'Credit Card',
    'Debit Card',
    'Cash',
    'Online Transfer',
    'KLANA'
);

CREATE TABLE payment (
    payment_ID SERIAL PRIMARY KEY,
    booking_ID SMALLINT,
    payment_date DATETIME,
    payment_amount SMALLINT,
    payment_method payment_method,
    FOREIGN KEY (booking_ID) REFERENCES booking(booking_ID)
);

CREATE TABLE refunds (
    refund_ID SERIAL PRIMARY KEY,
    payment_ID INT,
    refund_amount INT,
    refund_date DATETIME,
    reason TEXT,
    FOREIGN KEY (payment_ID) REFERENCES payment(payment_ID)
);

CREATE TABLE vehicle_details (
    Vehicle_ID SERIAL PRIMARY KEY,
    Vehicle_VIN VARCHAR(17),
    Vehicle_reg VARCHAR(7),
);

CREATE TYPE MOT_result AS ENUM ('Pass', 'Fail');

CREATE car_mot (
    MOT_ID SERIAL PRIMARY KEY,
    mechanic_ID SMALLINT,
    MOT_date SMALLDATETIME,
    MOT_expirary SMALLDATETIME,
    MOT_result MOT_result,
);

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
            SUM(
                CASE
                    WHEN MOT_outcome = 'Pass' THEN 1
                    ELSE 0
                END
            ) as passed_mots,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN MOT_outcome = 'Pass' THEN 1
                            ELSE 0
                        END
                    ) :: DECIMAL / COUNT(*)
                ) * 100,
                2
            ) as pass_rate_percentage
        FROM
            car_mot
        WHERE
            MOT_date >= NOW() - INTERVAL '1 year'
        GROUP BY
            mechanic_id
    ) as mot_stats ON s.staff_id = mot_stats.mechanic_id -- makes mini table that tells us stats from past year
WHERE
    mot_stats.passed_mots :: numeric / mot_stats.total_mots > 0.9 -- filter for over 75% pass rate
ORDER BY
    mot_stats.pass_rate_percentage DESC;

-- Create VIEW for a staff schedule for the next week
CREATE
OR REPLACE VIEW staff_schedule AS
SELECT
    s.staff_id,
    s.first_name || ' ' || s.last_name AS staff_name,
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 1
    ) AS "Monday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 2
    ) AS "Tuesday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 3
    ) AS "Wednesday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 4
    ) AS "Thursday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 5
    ) AS "Friday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 6
    ) AS "Saturday",
    STRING_AGG(
        sh.shift_start_time || ' - ' || sh.shift_end_time,
        ', '
    ) FILTER (
        WHERE
            EXTRACT(
                DOW
                FROM
                    sh.shift_date
            ) = 0
    ) AS "Sunday"
FROM
    staff s
    LEFT JOIN -- some staff may not have shifts assigned
    staff_availability sa ON s.staff_id = sa.staff_id
    LEFT JOIN shift sh ON sa.shift_id = sh.shift_id
WHERE
    sh.shift_date >= DATE_TRUNC('week', CURRENT_DATE)
    AND sh.shift_date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
GROUP BY
    s.staff_id,
    s.first_name,
    s.last_name
ORDER BY
    s.staff_id;