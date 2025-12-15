-- =========================
-- ENUM TYPES
-- =========================
CREATE TYPE service_task_status AS ENUM ('Pending', 'In Progress', 'Completed');

CREATE TYPE bay_status AS ENUM ('Available', 'Occupied', 'Under Maintenance');

CREATE TYPE bay_inspection_result AS ENUM ('Pass', 'Fail');

CREATE TYPE allocation_role AS ENUM ('Technician', 'Supervisor', 'Assistant');

CREATE TYPE booking_status AS ENUM ('Pending', 'Confirmed', 'Cancelled', 'Completed');

CREATE TYPE membership_tier AS ENUM ('Silver', 'Gold', 'Platinum');

CREATE TYPE payment_method AS ENUM (
    'Credit Card',
    'Debit Card',
    'Cash',
    'Online Transfer',
    'KLANA'
);

CREATE TYPE MOT_result AS ENUM ('Pass', 'Fail');

-- =========================
-- CORE TABLES
-- =========================
CREATE TABLE supplier(
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_contact VARCHAR(100),
    supplier_address TEXT
);

CREATE TABLE service_detail(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT,
    service_duration SMALLINT NOT NULL,
    service_cost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE bay(
    bay_id SERIAL PRIMARY KEY,
    bay_last_inspection_date TIMESTAMP,
    bay_status bay_status DEFAULT 'Available',
    bay_inspection_result bay_inspection_result
);

CREATE TABLE memberships(
    membership_id SERIAL PRIMARY KEY,
    membership_tier membership_tier,
    membership_discount SMALLINT,
    priority_booking BOOLEAN,
    courtesy_eligibility BOOLEAN
);

CREATE TABLE courtesy_car(
    courtesy_car_id SERIAL PRIMARY KEY,
    start_date TIMESTAMP,
    agreed_return_date TIMESTAMP,
    actual_return_date TIMESTAMP,
    availability_status BOOLEAN
);

CREATE TABLE branch_detail(
    branch_id SERIAL PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    capacity SMALLINT NOT NULL
);

CREATE TABLE role_detail(
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL
);

CREATE TABLE certification(
    certificate_id SERIAL PRIMARY KEY,
    certificate_name VARCHAR(100) NOT NULL,
    certificate_issuer TEXT
);

CREATE TABLE employee_pay_band(
    emp_pay_band_id SERIAL PRIMARY KEY,
    salary DECIMAL(10, 2) NOT NULL,
    holiday_pay DECIMAL(8, 2)
);

CREATE TABLE shift_detail(
    shift_id SERIAL PRIMARY KEY,
    shift_date DATE NOT NULL,
    shift_start_time TIME NOT NULL,
    shift_end_time TIME NOT NULL
);

CREATE TABLE parts_inventory(
    part_id SERIAL PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_supplier_id SMALLINT NOT NULL,
    FOREIGN KEY (part_supplier_id) REFERENCES supplier(supplier_id)
);

CREATE TABLE customer_details(
    customer_details_id SERIAL PRIMARY KEY,
    customer_phone VARCHAR(15),
    customer_email VARCHAR(50),
    membership_id SMALLINT,
    FOREIGN KEY (membership_id) REFERENCES memberships(membership_id)
);

CREATE TABLE vehicle_details(
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_vin VARCHAR(17),
    vehicle_reg VARCHAR(7)
);

-- =========================
-- STAFF TABLES
-- =========================
CREATE TABLE staff(
    staff_id SERIAL PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    staff_last_name VARCHAR(50),
    staff_emergency_contact VARCHAR(15),
    manager_id SMALLINT,
    branch_id SMALLINT NOT NULL,
    staff_address VARCHAR(50),
    FOREIGN KEY (manager_id) REFERENCES staff(staff_id),
    FOREIGN KEY (branch_id) REFERENCES branch_detail(branch_id)
);

CREATE TABLE staff_role(
    staff_id SMALLINT NOT NULL,
    role_id SMALLINT NOT NULL,
    PRIMARY KEY (staff_id, role_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (role_id) REFERENCES role_detail(role_id)
);

CREATE TABLE staff_certification(
    staff_id SMALLINT NOT NULL,
    certificate_id SMALLINT NOT NULL,
    PRIMARY KEY (staff_id, certificate_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (certificate_id) REFERENCES certification(certificate_id)
);

CREATE TABLE staff_availability(
    staff_id SMALLINT NOT NULL,
    shift_id SMALLINT NOT NULL,
    PRIMARY KEY (staff_id, shift_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (shift_id) REFERENCES shift_detail(shift_id)
);

-- =========================
-- BOOKINGS & SERVICES
-- =========================
CREATE TABLE booking(
    booking_id SERIAL PRIMARY KEY,
    booking_date TIMESTAMP,
    scheduled_date TIMESTAMP,
    scheduled_time SMALLINT,
    booking_status booking_status DEFAULT 'Pending',
    customer_id SMALLINT,
    vehicle_id SMALLINT,
    total_amount SMALLINT,
    courtesy_car_id SMALLINT,
    FOREIGN KEY (customer_id) REFERENCES customer_details(customer_details_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle_details(vehicle_id),
    FOREIGN KEY (courtesy_car_id) REFERENCES courtesy_car(courtesy_car_id)
);

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

CREATE TABLE staff_allocation(
    service_task_id SMALLINT NOT NULL,
    staff_id SMALLINT NOT NULL,
    allocation_role allocation_role NOT NULL,
    PRIMARY KEY (service_task_id, staff_id),
    FOREIGN KEY (service_task_id) REFERENCES service_task(service_task_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE car_parts(
    service_id SMALLINT NOT NULL,
    part_id SMALLINT NOT NULL,
    part_amount SMALLINT NOT NULL,
    PRIMARY KEY (service_id, part_id),
    FOREIGN KEY (service_id) REFERENCES service_detail(service_id),
    FOREIGN KEY (part_id) REFERENCES parts_inventory(part_id)
);

-- =========================
-- PAYMENTS & FEEDBACK
-- =========================
CREATE TABLE payment(
    payment_id SERIAL PRIMARY KEY,
    booking_id SMALLINT,
    payment_date TIMESTAMP,
    payment_amount SMALLINT,
    payment_method payment_method,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

CREATE TABLE refunds(
    refund_id SERIAL PRIMARY KEY,
    payment_id INT,
    refund_amount INT,
    refund_date TIMESTAMP,
    reason TEXT,
    FOREIGN KEY (payment_id) REFERENCES payment(payment_id)
);

CREATE TABLE booking_feedback(
    feedback_id SERIAL PRIMARY KEY,
    booking_id SMALLINT,
    feedback TEXT,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

CREATE TABLE car_mot(
    mot_id SERIAL PRIMARY KEY,
    mechanic_id SMALLINT,
    vehicle_id SMALLINT,
    mot_date TIMESTAMP,
    mot_expiry TIMESTAMP,
    mot_result MOT_result,
    FOREIGN KEY (mechanic_id) REFERENCES staff(staff_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle_details(vehicle_id)
);

-- =========================
-- QUERY: MOT PASS RATE > 90%
-- =========================
SELECT
    s.staff_id AS "Staff ID",
    s.staff_name || ' ' || s.staff_last_name AS "Staff Name",
    mot_stats.total_mots AS "Total MOTs",
    mot_stats.passed_mots AS "Passed MOTs",
    mot_stats.pass_rate_percentage AS "MOT Pass Rate (%)"
FROM
    staff s
    JOIN (
        SELECT
            mechanic_id,
            COUNT(*) AS total_mots,
            SUM(
                CASE
                    WHEN mot_result = 'Pass' THEN 1
                    ELSE 0
                END
            ) AS passed_mots,
            ROUND(
                (
                    SUM(
                        CASE
                            WHEN mot_result = 'Pass' THEN 1
                            ELSE 0
                        END
                    ) :: DECIMAL / COUNT(*)
                ) * 100,
                2
            ) AS pass_rate_percentage
        FROM
            car_mot
        WHERE
            mot_date >= NOW() - INTERVAL '1 year'
        GROUP BY
            mechanic_id
    ) mot_stats ON s.staff_id = mot_stats.mechanic_id
WHERE
    mot_stats.passed_mots :: DECIMAL / mot_stats.total_mots > 0.90
ORDER BY
    mot_stats.pass_rate_percentage DESC;

-- =========================
-- VIEW: STAFF SCHEDULE (NEXT WEEK)
-- =========================
CREATE
OR REPLACE VIEW staff_schedule AS
SELECT
    s.staff_id,
    s.staff_name || ' ' || s.staff_last_name AS staff_name,
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
    LEFT JOIN staff_availability sa ON s.staff_id = sa.staff_id
    LEFT JOIN shift_detail sh ON sa.shift_id = sh.shift_id
WHERE
    s.branch_id = 1
    AND sh.shift_date >= DATE_TRUNC('week', CURRENT_DATE)
    AND sh.shift_date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
GROUP BY
    s.staff_id,
    s.staff_name,
    s.staff_last_name
ORDER BY
    s.staff_id;