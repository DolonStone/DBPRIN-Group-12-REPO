--- ENUM TYPES ---
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

CREATE TYPE payment_status AS ENUM ('Pending', 'Completed', 'Failed', 'Refunded');

CREATE TYPE MOT_result AS ENUM ('Pass', 'Fail');

--- CORE TABLES ---
CREATE TABLE supplier(
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    supplier_phone VARCHAR(15),
    supplier_address_line_1 VARCHAR(100),
    supplier_address_line_2 VARCHAR(100),
    supplier_postcode VARCHAR(10)
);

CREATE TABLE service_detail(
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL,
    service_description TEXT,
    service_duration SMALLINT NOT NULL
);



CREATE TABLE memberships(
    membership_id SERIAL PRIMARY KEY,
    membership_tier membership_tier,
    membership_discount DECIMAL(3, 2),
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

CREATE TABLE role_detail(
    role_id SERIAL PRIMARY KEY,
    role_description TEXT NOT NULL
);

CREATE TABLE certification(
    certificate_id SERIAL PRIMARY KEY,
    certificate_description TEXT NOT NULL
);

CREATE TABLE employee_pay_band(
    emp_pay_band_id SERIAL PRIMARY KEY,
    salary DECIMAL(10, 2) NOT NULL,
    holiday_pay DECIMAL(8, 2)
);

CREATE TABLE shift_detail(
    shift_id SERIAL PRIMARY KEY,
    shift_start_time TIMESTAMP NOT NULL,
    shift_end_time TIMESTAMP NOT NULL
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

--- STAFF TABLES ---
CREATE TABLE branch_detail (
    branch_id SERIAL PRIMARY KEY,
    branch_manager_id SMALLINT,
    branch_address_line_1 VARCHAR(100),
    branch_address_line_2 VARCHAR(100),
    branch_postcode VARCHAR(10)
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    staff_last_name VARCHAR(50),
    staff_emergency_contact VARCHAR(15),
    manager_id SMALLINT,
    branch_id SMALLINT NOT NULL,
    staff_addr_line_1 VARCHAR(100),
    staff_addr_line_2 VARCHAR(100),
    staff_postcode VARCHAR(10)
);


ALTER TABLE
    staff
ADD
    CONSTRAINT fk_staff_manager FOREIGN KEY (manager_id) REFERENCES staff(staff_id);

ALTER TABLE
    staff
ADD
    CONSTRAINT fk_staff_branch FOREIGN KEY (branch_id) REFERENCES branch_detail(branch_id);

ALTER TABLE
    branch_detail
ADD
    CONSTRAINT fk_branch_manager FOREIGN KEY (branch_manager_id) REFERENCES staff(staff_id);

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

-- BOOKINGS & SERVICES ---
CREATE TABLE booking(
    booking_id SERIAL PRIMARY KEY,
    booking_date TIMESTAMP NOT NULL,
    scheduled_date TIMESTAMP NOT NULL,
    scheduled_time TIME NOT NULL,
    booking_status booking_status DEFAULT 'Pending',
    customer_id SMALLINT NOT NULL,
    vehicle_id SMALLINT NOT NULL,
    total_amount NUMERIC(10, 2),
    courtesy_car_id SMALLINT,
    branch_id SMALLINT NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer_details(customer_details_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle_details(vehicle_id),
    FOREIGN KEY (courtesy_car_id) REFERENCES courtesy_car(courtesy_car_id),
    FOREIGN KEY (branch_id) REFERENCES branch_detail(branch_id)
);

CREATE TABLE bay(
    bay_id SERIAL PRIMARY KEY,
    bay_last_inspection_date TIMESTAMP,
    bay_status bay_status DEFAULT 'Available',
    bay_inspection_result bay_inspection_result,
    branch_id SMALLINT NOT NULL,
    FOREIGN KEY (branch_id) REFERENCES branch_detail(branch_id)
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

--- PAYMENTS & FEEDBACK ---
CREATE TABLE payment(
    payment_id SERIAL PRIMARY KEY,
    booking_id SMALLINT NOT NULL,
    payment_date TIMESTAMP,
    payment_amount NUMERIC(10, 2) NOT NULL,
    payment_method payment_method,
    payment_status payment_status DEFAULT 'Pending',
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

CREATE TABLE refunds(
    refund_id SERIAL PRIMARY KEY,
    payment_id SMALLINT NOT NULL,
    refund_amount NUMERIC(10,2) NOT NULL,
    refund_date TIMESTAMP NOT NULL,
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



/*==============================================================
inserts
===============================================================*/


-- inserts for testing purposes --

insert into staff (staff_id, staff_name, staff_last_name, staff_emergency_contact, manager_id, branch_id, staff_addr_line_1, staff_addr_line_2, staff_postcode) values (1, 'John', 'Doe', '1234567890', null, 1, '123 Main St', 'Apt 4B', 'AB12 3CD'),
    (2, 'Jane', 'Smith', '0987654321', 1, 1, '456 Elm St', 'Suite 5A', 'EF45 6GH'),
    (3, 'Mike', 'Johnson', '5555555555', 1, 2, '789 Oak St', '', 'IJ78 9KL'),
    (4, 'Emily', 'Davis', '4444444444', 2, 2, '321 Pine St', 'Floor 2', 'MN12 3OP'),
    (5, 'David', 'Wilson', '3333333333', 2, 1, '654 Cedar St', '', 'QR45 6ST'),
    (6, 'Sarah', 'Brown', '2222222222', 3, 3, '987 Birch St', 'Unit 10', 'UV78 9WX'),
    (7, 'Chris', 'Taylor', '1111111111', 3, 3, '159 Spruce St', '', 'YZ12 3AB'),
    (8, 'Anna', 'Anderson', '6666666666', 4, 1, '753 Willow St', 'Apt 1C', 'CD45 6EF'),
    (9, 'James', 'Thomas', '7777777777', 4, 2, '852 Maple St', '', 'GH78 9IJ'),
    (10, 'Laura', 'Jackson', '8888888888', 5, 2, '951 Cherry St', 'Suite 3D', 'KL12 3MN');

insert into branch_detail (branch_id, branch_manager_id, branch_name, branch_address_line_1, branch_address_line_2, branch_postcode) values (1, 1, 'Central Branch', '100 Central Ave', '', 'AA11 1AA'),
    (2, 3, 'North Branch', '200 North St', 'Suite 100', 'BB22 2BB'),
    (3, 6, 'East Branch', '300 East Rd', '', 'CC33 3CC');

insert into supplier (supplier_id, supplier_name, supplier_phone, supplier_address_line_1, supplier_address_line_2, supplier_postcode) values (1, 'AutoParts Co.', '0123456789', '1 Supplier St', '', 'SP1 2PL'),
    (2, 'CarSupplies Ltd.', '0987654321', '2 Supplier Ave', 'Unit 5', 'SP3 4PL'), 
    (3, 'Vehicle Essentials', '5555555555', '3 Supplier Blvd', '', 'SP5 6PL'),  
    (4, 'PartsRUs', '4444444444', '4 Supplier Ln', 'Floor 2', 'SP7 8PL'),  
    (5, 'MotorComponents', '3333333333', '5 Supplier Dr', '', 'SP9 0PL'),
    (6, 'EngineWorks', '2222222222', '6 Supplier Ct', 'Unit 10', 'SP1 2PL'),  
    (7, 'Gearbox Inc.', '1111111111', '7 Supplier Pl', '', 'SP3 4PL'),  
    (8, 'BrakeMasters', '6666666666', '8 Supplier Rd', 'Apt 1C', 'SP5 6PL'),  
    (9, 'TireWorld', '7777777777', '9 Supplier St', '', 'SP7 8PL'),  
    (10, 'AutoFixers', '8888888888', '10 Supplier Ave', 'Suite 3D', 'SP9 0PL');

insert into service_detail (service_id, service_name, service_description, service_duration) values (1, 'Oil Change', 'Complete oil change including filter replacement.', 30),
    (2, 'Brake Inspection', 'Comprehensive brake system inspection and report.', 45),
    (3, 'Tire Rotation', 'Rotate tires to ensure even wear and extend tire life.', 20),
    (4, 'Engine Diagnostics', 'Full engine diagnostics using advanced tools.', 60),
    (5, 'Battery Replacement', 'Replace old battery with a new one.', 25),
    (6, 'Wheel Alignment', 'Adjust wheel angles for optimal driving performance.', 50),
    (7, 'Air Conditioning Service', 'Check and service the vehicle''s air conditioning system.', 40),
    (8, 'Transmission Check', 'Inspect transmission system for issues and performance.', 55),
    (9, 'Suspension Inspection', 'Evaluate suspension components for wear and damage.', 35),
    (10, 'Full Vehicle Inspection', 'Comprehensive inspection of all vehicle systems.', 90);


insert into memberships (membership_id, membership_tier, membership_discount, priority_booking, courtesy_eligibility) values (3, 'Gold', -5, false, true),
    (4, 'Platinum', -10, true, true),
    (5, 'Silver', -3, false, false),
    (6, 'Gold', -7, true, false),
    (7, 'Platinum', -12, true, true),
    (8, 'Silver', -4, false, true),
    (9, 'Gold', -6, true, false),
    (10, 'Platinum', -15, true, true);   


insert into courtesy_car (courtesy_car_id, start_date, agreed_return_date, actual_return_date, availability_status) values (1, '2024-10-01 09:00:00', '2024-10-05 17:00:00', null, true),
    (2, '2024-10-02 10:00:00', '2024-10-06 16:00:00', null, false),
    (3, '2024-10-03 11:00:00', '2024-10-07 15:00:00', null, true),
    (4, '2024-10-04 12:00:00', '2024-10-08 14:00:00', null, false),
    (5, '2024-10-05 13:00:00', '2024-10-09 13:00:00', null, true),
    (6, '2024-10-06 14:00:00', '2024-10-10 12:00:00', null, false),
    (7, '2024-10-07 15:00:00', '2024-10-11 11:00:00', null, true),
    (8, '2024-10-08 16:00:00', '2024-10-12 10:00:00', null, false),
    (9, '2024-10-09 17:00:00', '2024-10-13 09:00:00', null, true),
    (10, '2024-10-10 18:00:00', '2024-10-14 08:00:00', null, false);

insert into role_detail (role_id, role_description) values (1, 'Technician responsible for vehicle repairs and maintenance.'),
    (2, 'Supervisor overseeing service tasks and staff performance.'),
    (3, 'Assistant supporting technicians and supervisors in daily operations.'),
    (4, 'Customer Service Representative handling bookings and customer inquiries.'),
    (5, 'Quality Control Inspector ensuring service standards are met.'),
    (6, 'Inventory Manager overseeing parts and supplies.'),
    (7, 'Shift Manager coordinating staff schedules and shifts.'),
    (8, 'Training Coordinator managing staff certifications and training programs.'),
    (9, 'Safety Officer ensuring workplace safety compliance.'),
    (10, 'Administrative Assistant supporting office operations and documentation.');

insert into certification (certificate_id, certificate_description) values (1, 'Certified Automotive Technician'),
    (2, 'Brake System Specialist'),
    (3, 'Engine Repair Expert'),
    (4, 'Transmission Specialist'),
    (5, 'Electrical Systems Technician'),
    (6, 'Air Conditioning and Heating Specialist'),
    (7, 'Suspension and Steering Expert'),
    (8, 'Vehicle Diagnostics Professional'),
    (9, 'Hybrid and Electric Vehicle Technician'),
    (10, 'Customer Service Excellence Certification');

insert into employee_pay_band (emp_pay_band_id, salary, holiday_pay) values (1, 30000.00, 1500.00),
    (2, 35000.00, 1750.00),
    (3, 40000.00, 2000.00),
    (4, 45000.00, 2250.00),
    (5, 50000.00, 2500.00),
    (6, 55000.00, 2750.00),
    (7, 60000.00, 3000.00),
    (8, 65000.00, 3250.00),
    (9, 70000.00, 3500.00),
    (10, 75000.00, 3750.00);

insert into shift_detail (shift_id, shift_start_time, shift_end_time) values (1, '2024-10-01 08:00:00', '2024-10-01 16:00:00'),
    (2, '2024-10-01 16:00:00', '2024-10-02 00:00:00'),
    (3, '2024-10-02 00:00:00', '2024-10-02 08:00:00'),
    (4, '2024-10-02 08:00:00', '2024-10-02 16:00:00'),
    (5, '2024-10-02 16:00:00', '2024-10-03 00:00:00'),
    (6, '2024-10-03 00:00:00', '2024-10-03 08:00:00'),
    (7, '2024-10-03 08:00:00', '2024-10-03 16:00:00'),
    (8, '2024-10-03 16:00:00', '2024-10-04 00:00:00'),
    (9, '2024-10-04 00:00:00', '2024-10-04 08:00:00'),
    (10, '2024-10-04 08:00:00', '2024-10-04 16:00:00');


insert into parts_inventory (part_id, part_name, part_supplier_id) values (1, 'Oil Filter', 1),
    (2, 'Brake Pads', 2),
    (3, 'Tire Set', 3),
    (4, 'Engine Air Filter', 4),
    (5, 'Car Battery', 5),
    (6, 'Spark Plugs', 6),
    (7, 'Transmission Fluid', 7),
    (8, 'Suspension Kit', 8),
    (9, 'AC Compressor', 9),
    (10, 'Fuel Pump', 10);  


insert into vehicle_details (vehicle_id, vehicle_vin, vehicle_reg) values (1, '1HGCM82633A123456', 'AB12CDE'),
    (2, '1J4GL48KX4W123456', 'FG34HIJ'),
    (3, '2T1BURHE5JC123456', 'KL56MNO'),
    (4, '3FA6P0H72HR123456', 'PQ78RST'),
    (5, '5NPE24AF8FH123456', 'UV90WXY'),
    (6, '1C4RJFBG0FC123456', 'ZA12BCD'),
    (7, '19XFC2F59GE123456', 'EF34GHI'),
    (8, '1FTFW1E50JFA12345', 'JK56LMN'),
    (9, '2G1FB1E34E9123456', 'OP78QRS'),
    (10, '1GNEK13ZX3R123456', 'TU90VWX');

---------------------------------------------------------------
-- QUERY: MOT PASS RATE > 90% ---
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

--- COMPARES EFFICIENCY ACROSS DIFFERENT ALLOCATION ROLES ---
SELECT
    sa.allocation_role AS "Role Name",
    COUNT(DISTINCT sa.staff_id) AS "Number of staff In Role",
    COUNT(DISTINCT sa.service_task_id) AS "Total Tasks Done By Role",
    AVG(st.end_time - st.start_time) AS "Avg Task Duration (mins)",
    COUNT(
        DISTINCT CASE
            WHEN st.service_task_status = 'Completed' THEN sa.service_task_id
        END
    ) AS completed_tasks,
    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN st.service_task_status = 'Completed' THEN sa.service_task_id
            END
        ) :: NUMERIC / NULLIF(COUNT(DISTINCT sa.service_task_id), 0) * 100,
        2
    ) AS completion_rate_percentage,
    COALESCE(SUM(sd.service_cost), 0) AS total_revenue_by_role,
    ROUND(
        COALESCE(SUM(sd.service_cost), 0) / NULLIF(COUNT(DISTINCT sa.staff_id), 0),
        2
    ) AS avg_revenue_per_staff,
    ROUND(
        COUNT(DISTINCT sa.service_task_id) :: NUMERIC / NULLIF(COUNT(DISTINCT sa.staff_id), 0),
        2
    ) AS avg_tasks_per_staff
FROM
    staff_allocation sa
    INNER JOIN service_task st ON sa.service_task_id = st.service_task_id
    INNER JOIN service_detail sd ON st.service_id = sd.service_id
GROUP BY
    sa.allocation_role
ORDER BY
    total_revenue_by_role DESC;

-- All branch information -- 
SELECT
    bd.branch_id AS "Branch ID",
    s.staff_name || ' ' || s.staff_last_name AS "Branch Manager Name",
    sm.staff_members AS "Staff Members at Branch",
    bay_stats.usable_bay_percentage AS "Percentage of current usable bays (%)",
    income.total_income AS "Total Income from Bookings (minus refunds)"
FROM
    branch_detail bd
    LEFT JOIN staff s ON bd.branch_manager_id = s.staff_id
    LEFT JOIN (
        SELECT
            branch_id,
            STRING_AGG(staff_name || ' ' || staff_last_name, ', ') AS staff_members
        FROM
            staff
        GROUP BY
            branch_id
    ) sm ON sm.branch_id = bd.branch_id -- STAFF MEMBERS
    LEFT JOIN (
        SELECT
            branch_id,
            COUNT(*) AS total_bays,
            COALESCE(
                ROUND(
                    SUM(
                        CASE
                            WHEN bay_inspection_result = 'Pass' THEN 1
                            ELSE 0
                        END
                    ) :: DECIMAL / NULLIF(COUNT(*), 0) * 100,
                    2
                ),
                0
            ) AS usable_bay_percentage
        FROM
            bay
        GROUP BY
            branch_id
    ) bay_stats ON bay_stats.branch_id = bd.branch_id -- BAY USABILITY
    LEFT JOIN (
        SELECT
            bk.branch_id,
            COALESCE(SUM(p.payment_amount), 0) - COALESCE(SUM(r.refund_amount), 0) AS total_income
        FROM
            booking bk
            LEFT JOIN payment p ON p.booking_id = bk.booking_id
            LEFT JOIN refunds r ON r.payment_id = p.payment_id
        GROUP BY
            bk.branch_id
    ) income ON income.branch_id = bd.branch_id -- INCOME FROM BOOKINGS
ORDER BY
    bd.branch_id;


-- VIEW: STAFF SCHEDULE (NEXT WEEK) ---
CREATE
OR REPLACE VIEW staff_schedule SECURITY DEFINER AS
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

-- CREATING ROLES FOR DIFFERENT STAFF TYPES ---
CREATE ROLE manager LOGIN PASSWORD 'managerpass1!';

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO manager;

GRANT USAGE,
SELECT
,
UPDATE
,
INSERT
,
    DELETE ON ALL SEQUENCES IN SCHEMA public TO manager;

CREATE ROLE mechanic LOGIN PASSWORD 'mechanicpass1!';

GRANT USAGE ON SCHEMA public TO mechanic;

REVOKE ALL ON ALL TABLES IN SCHEMA public
FROM
    mechanic;

GRANT
SELECT
    ON staff_schedule TO mechanic;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT
SELECT
    ON VIEWS TO mechanic;

CREATE ROLE receptionist LOGIN PASSWORD 'receptionistpass1!';

GRANT
SELECT
,
INSERT
,
UPDATE
    ON booking,
    customer_details,
    vehicle_details TO receptionist;

GRANT USAGE,
SELECT
    ON ALL SEQUENCES IN SCHEMA public TO receptionist;


-- OPTIMIZATION - INDEX CREATION ---

-- TRANSACTION 1: Booking Creation & Assignment ---

CREATE INDEX idx_booking_scheduled_date ON booking(scheduled_date);
CREATE INDEX idx_booking_status ON booking(booking_status);
CREATE INDEX idx_booking_customer ON booking(customer_id);
CREATE INDEX idx_service_task_booking ON service_task(booking_id);
CREATE INDEX idx_bay_status ON bay(bay_status);
CREATE INDEX idx_service_task_composite ON service_task(booking_id, service_task_status);


-- TRANSACTION 2: Payment Processing & Revenue ---

CREATE INDEX idx_payment_booking ON payment(booking_id);
CREATE INDEX idx_payment_date ON payment(payment_date);
CREATE INDEX idx_payment_status ON payment(payment_status);
CREATE INDEX idx_refunds_payment ON refunds(payment_id);


-- TRANSACTION 3: Staff Performance & Allocation ---

CREATE INDEX idx_staff_allocation_staff ON staff_allocation(staff_id);
CREATE INDEX idx_staff_allocation_task ON staff_allocation(service_task_id);
CREATE INDEX idx_service_task_status ON service_task(service_task_status);
CREATE INDEX idx_staff_branch ON staff(branch_id);
CREATE INDEX idx_staff_manager ON staff(manager_id);


-- ADDITIONAL PERFORMANCE INDEXES ---

CREATE INDEX idx_mot_expiry ON car_mot(mot_expiry) 
WHERE mot_result = 'Pass';
CREATE INDEX idx_vehicle_reg ON vehicle_details(vehicle_reg);
CREATE INDEX idx_service_task_bay ON service_task(bay_id);
CREATE INDEX idx_parts_supplier ON parts_inventory(part_supplier_id);
CREATE INDEX idx_staff_cert ON staff_certification(staff_id, certificate_id);
CREATE INDEX idx_staff_role ON staff_role(staff_id, role_id);
CREATE INDEX idx_staff_availability ON staff_availability(staff_id, shift_id);

