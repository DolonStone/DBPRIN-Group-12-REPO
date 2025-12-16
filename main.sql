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
    'Klarna'
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
    refund_amount NUMERIC(10, 2) NOT NULL,
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
WHERE
    mot_result = 'Pass';

CREATE INDEX idx_vehicle_reg ON vehicle_details(vehicle_reg);

CREATE INDEX idx_service_task_bay ON service_task(bay_id);

CREATE INDEX idx_parts_supplier ON parts_inventory(part_supplier_id);

CREATE INDEX idx_staff_cert ON staff_certification(staff_id, certificate_id);

CREATE INDEX idx_staff_role ON staff_role(staff_id, role_id);

CREATE INDEX idx_staff_availability ON staff_availability(staff_id, shift_id);

-- creating ROLEs for different staff types ---

CREATE ROLE manager LOGIN PASSWORD 'managerpass1!';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO manager;
GRANT USAGE, SELECT, UPDATE, INSERT, DELETE ON ALL SEQUENCES IN SCHEMA public TO manager;

CREATE ROLE receptionist LOGIN PASSWORD 'receptionpass1!';
GRANT SELECT, INSERT, UPDATE ON TABLE booking, customer_details, vehicle_details TO receptionist;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO receptionist;

CREATE ROLE mechanic LOGIN PASSWORD 'mechanicpass1!';
REVOKE ALL ON SCHEMA public FROM mechanic;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM mechanic;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM mechanic;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM mechanic;
GRANT USAGE ON SCHEMA public TO mechanic;
GRANT SELECT ON staff_schedule TO mechanic;

TRUNCATE TABLE refunds,
payment,
booking_feedback,
car_mot,
car_parts,
staff_allocation,
service_task,
bay,
booking,
staff_availability,
staff_certification,
staff_role,
staff,
branch_detail,
vehicle_details,
customer_details,
parts_inventory,
shift_detail,
employee_pay_band,
certification,
role_detail,
memberships,
service_detail,
supplier RESTART IDENTITY CASCADE;

BEGIN;


-- INSERT SAMPLE DATA ---

INSERT INTO supplier (supplier_name,supplier_phone,supplier_address_line_1,supplier_address_line_2,supplier_postcode) VALUES
('AutoParts Co.','0123456789','123 Main St','Suite 100','AB12 3CD'),
('CarSupplies Ltd.','0987654321','456 Elm St',NULL,'EF45 6GH'),
('MotorWorld','0111222333','789 High St',NULL,'ZZ11 2ZZ'),
('QuickFix','0222333444','12 Repair Rd','Unit 3','YY22 3YY');

INSERT INTO service_detail (service_name,service_description,service_duration) VALUES
('Oil Change','Complete oil change',30),
('Brake Inspection','Brake system check',45),
('Tire Rotation','Rotate tires',20),
('Battery Check','Battery health check',15);

INSERT INTO memberships (membership_tier,membership_discount,priority_booking,courtesy_eligibility) VALUES
('Silver',0.05,FALSE,FALSE),
('Gold',0.10,TRUE,TRUE),
('Platinum',0.15,TRUE,TRUE),
('Silver',0.05,FALSE,FALSE);

INSERT INTO role_detail (role_description) VALUES
('Technician'),
('Supervisor'),
('Assistant'),
('Manager'),
('Receptionist'),
('Technician');

INSERT INTO certification (certificate_description) VALUES
('ASE Certified'),
('Brake Specialist'),
('Engine Specialist'),
('Electrical Systems');

INSERT INTO shift_detail (shift_start_time,shift_end_time) VALUES
('2025-06-03 08:00','2025-06-03 16:00'),
('2025-06-04 08:00','2025-06-04 16:00'),
('2025-06-05 08:00','2025-06-05 16:00'),
('2025-06-06 08:00','2025-06-06 16:00');
INSERT INTO shift_detail (shift_start_time, shift_end_time)
VALUES
('2025-12-08 08:00:00', '2025-12-08 16:00:00'),
('2025-12-08 16:00:00', '2025-12-09 00:00:00'),
('2025-12-09 08:00:00', '2025-12-09 16:00:00'),
('2025-12-09 16:00:00', '2025-12-10 00:00:00'),
('2025-12-10 08:00:00', '2025-12-10 16:00:00'),
('2025-12-10 16:00:00', '2025-12-11 00:00:00'),
('2025-12-11 08:00:00', '2025-12-11 16:00:00'),
('2025-12-11 16:00:00', '2025-12-12 00:00:00'),
('2025-12-12 08:00:00', '2025-12-12 16:00:00'),
('2025-12-12 16:00:00', '2025-12-13 00:00:00'),
('2025-12-13 08:00:00', '2025-12-13 16:00:00'),
('2025-12-13 16:00:00', '2025-12-14 00:00:00'),
('2025-12-14 08:00:00', '2025-12-14 16:00:00'),
('2025-12-14 16:00:00', '2025-12-15 00:00:00');
INSERT INTO shift_detail (shift_start_time, shift_end_time)
VALUES
('2025-12-15 08:00:00', '2025-12-15 16:00:00'),
('2025-12-15 16:00:00', '2025-12-16 00:00:00'),
('2025-12-16 08:00:00', '2025-12-16 16:00:00'),
('2025-12-16 16:00:00', '2025-12-17 00:00:00'),
('2025-12-17 08:00:00', '2025-12-17 16:00:00'),
('2025-12-17 16:00:00', '2025-12-18 00:00:00'),
('2025-12-18 08:00:00', '2025-12-18 16:00:00'),
('2025-12-18 16:00:00', '2025-12-19 00:00:00'),
('2025-12-19 08:00:00', '2025-12-19 16:00:00'),
('2025-12-19 16:00:00', '2025-12-20 00:00:00'),
('2025-12-20 08:00:00', '2025-12-20 16:00:00'),
('2025-12-20 16:00:00', '2025-12-21 00:00:00'),
('2025-12-21 08:00:00', '2025-12-21 16:00:00'),
('2025-12-21 16:00:00', '2025-12-22 00:00:00');
INSERT INTO shift_detail (shift_start_time, shift_end_time)
VALUES
('2025-12-22 08:00:00', '2025-12-22 16:00:00'),
('2025-12-22 16:00:00', '2025-12-23 00:00:00'),
('2025-12-23 08:00:00', '2025-12-23 16:00:00'),
('2025-12-23 16:00:00', '2025-12-24 00:00:00'),
('2025-12-24 08:00:00', '2025-12-24 16:00:00'),
('2025-12-24 16:00:00', '2025-12-25 00:00:00'),
('2025-12-25 08:00:00', '2025-12-25 16:00:00'),
('2025-12-25 16:00:00', '2025-12-26 00:00:00'),
('2025-12-26 08:00:00', '2025-12-26 16:00:00'),
('2025-12-26 16:00:00', '2025-12-27 00:00:00'),
('2025-12-27 08:00:00', '2025-12-27 16:00:00'),
('2025-12-27 16:00:00', '2025-12-28 00:00:00'),
('2025-12-28 08:00:00', '2025-12-28 16:00:00'),
('2025-12-28 16:00:00', '2025-12-29 00:00:00');

INSERT INTO branch_detail (branch_manager_id,branch_address_line_1,branch_address_line_2,branch_postcode) VALUES
(NULL,'100 Branch St','Suite 10','AA11 1AA'),
(NULL,'200 Service Rd',NULL,'BB22 2BB'),
(NULL,'300 Garage Way',NULL,'CC33 3CC'),
(NULL,'400 Auto Ave','Unit 5','DD44 4DD');

INSERT INTO staff (staff_name,staff_last_name,staff_emergency_contact,manager_id,branch_id,staff_addr_line_1,staff_addr_line_2,staff_postcode) VALUES
('Alice','Johnson','07111222333',NULL,1,'10 Staff St',NULL,'AA11 1AA'),
('Bob','Smith','07222333444',1,1,'20 Worker Rd','Apt 2','AA11 1AA'),
('Charlie','Brown','07333444555',1,2,'30 Employee Ln',NULL,'BB22 2BB'),
('Diana','White','07444555666',1,2,'40 Mechanic St',NULL,'BB22 2BB');

UPDATE branch_detail SET branch_manager_id=1 WHERE branch_id=1;
UPDATE branch_detail SET branch_manager_id=3 WHERE branch_id=2;

INSERT INTO staff_role (staff_id,role_id) VALUES
(1,4),(2,1),(3,4),(4,1);

INSERT INTO staff_certification (staff_id,certificate_id) VALUES
(2,1),(2,2),(4,1),(4,3);

INSERT INTO staff_availability (staff_id,shift_id) VALUES
(2,1),(2,2),(4,3),(4,4);
INSERT INTO staff_availability (staff_id, shift_id)
VALUES
(1, 1), (2, 2), (3, 3),
(1, 4), (2, 5), (3, 6),
(1, 7), (2, 8), (3, 9),
(1, 10), (2, 11), (3, 12),
(1, 13), (2, 14);
INSERT INTO staff_availability (staff_id, shift_id)
VALUES
(1, 15), (2, 16), (3, 17),
(1, 18), (2, 19), (3, 20),
(1, 21), (2, 22), (3, 23),
(1, 24), (2, 25), (3, 26),
(1, 27), (2, 28);
INSERT INTO staff_availability (staff_id, shift_id)
VALUES
(1, 29), (2, 30), (3, 31),
(1, 32), (2, 33), (3, 34),
(1, 35), (2, 36), (3, 37),
(1, 38), (2, 39), (3, 40),
(1, 41), (2, 42);
INSERT INTO customer_details (customer_phone,customer_email,membership_id) VALUES
('07123456789','john.doe@example.com',2),
('07234567890','jane.smith@example.com',3),
('07345678901','paul.green@example.com',1),
('07456789012','emma.blue@example.com',2);

INSERT INTO vehicle_details (vehicle_vin,vehicle_reg) VALUES
('1HGCM82633A123456','AB12CDE'),
('1FAFP404X1F123456','EF34GHI'),
('WVWZZZ1JZXW000001','JK56LMN'),
('YS3DD78N4X7055321','OP78QRS');

INSERT INTO parts_inventory (part_name,part_supplier_id) VALUES
('Oil Filter',1),
('Brake Pads',2),
('Car Battery',3),
('Air Filter',4);

INSERT INTO bay (bay_last_inspection_date,bay_status,bay_inspection_result,branch_id) VALUES
('2025-05-01','Available','Pass',1),
('2025-05-02','Available','Pass',1),
('2025-05-03','Occupied','Pass',2),
('2025-05-04','Available','Pass',2);

INSERT INTO booking (booking_date,scheduled_date,scheduled_time,booking_status,customer_id,vehicle_id,total_amount,courtesy_car_id,branch_id) VALUES
('2025-06-01 10:00','2025-06-10','09:00','Confirmed',1,1,150.00,NULL,1),
('2025-06-02 11:30','2025-06-12','10:30','Confirmed',2,2,200.00,NULL,1),
('2025-06-03 09:15','2025-06-15','11:00','Completed',3,3,120.00,NULL,2),
('2025-06-04 14:45','2025-06-18','13:30','Completed',4,4,180.00,NULL,2);

INSERT INTO service_task (booking_id,service_id,service_task_status,bay_id,start_time,end_time) VALUES
(1,1,'Completed',1,0,30),
(1,2,'Completed',1,30,75),
(2,3,'Completed',2,0,20),
(2,4,'Completed',2,20,35),
(3,1,'Completed',3,0,30),
(4,2,'Completed',4,0,45);

INSERT INTO staff_allocation (service_task_id,staff_id,allocation_role) VALUES
(1,2,'Technician'),
(2,2,'Technician'),
(3,4,'Technician'),
(4,4,'Technician'),
(5,2,'Technician'),
(6,4,'Technician');

INSERT INTO payment (booking_id,payment_date,payment_amount,payment_method,payment_status) VALUES
(1,'2025-06-01 10:30',150.00,'Credit Card','Completed'),
(2,'2025-06-02 12:00',200.00,'Debit Card','Completed'),
(3,'2025-06-03 10:00',120.00,'Cash','Completed'),
(4,'2025-06-04 15:00',180.00,'Online Transfer','Completed');

INSERT INTO refunds (payment_id,refund_amount,refund_date,reason) VALUES
(1,50.00,'2025-06-20 10:00','Partial Refund'),
(2,20.00,'2025-06-22 11:00','Service Delay');

INSERT INTO booking_feedback (booking_id,feedback) VALUES
(1,'Great service'),
(2,'Quick and professional'),
(3,'Very satisfied'),
(4,'Will return again');

INSERT INTO car_mot (mechanic_id,vehicle_id,mot_date,mot_expiry,mot_result) VALUES
(2,1,'2025-05-15','2025-05-15','Pass'),
(2,2,'2025-05-16','2025-05-16','Pass'),
(4,3,'2025-05-17','2025-05-17','Pass'),
(4,4,'2025-05-18','2025-05-18','Pass');

COMMIT;



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
            COALESCE(SUM(DISTINCT p.payment_amount), 0) - COALESCE(SUM(DISTINCT r.refund_amount), 0) AS total_income
        FROM
            booking bk
            LEFT JOIN payment p ON p.booking_id = bk.booking_id
            LEFT JOIN refunds r ON r.payment_id = p.payment_id
        GROUP BY
            bk.branch_id
    ) income ON income.branch_id = bd.branch_id -- INCOME FROM BOOKINGS
ORDER BY
    bd.branch_id;
--- INDENTIFIES REFUND PATTERNS ---
SELECT
   r.refund_id AS "Refund ID",
   b.booking_id AS "Booking ID",
   r.refund_amount AS "Refund Amount",
   r.refund_date AS "Refund Date",
   r.reason AS "Refund Reason",
   sd.service_name AS "Service Name",
   s.staff_name || ' ' || s.staff_last_name AS "Staff Involved",
   p.payment_method AS "Payment Method",
   ROUND((r.refund_amount::NUMERIC / NULLIF(p.payment_amount, 0)) * 100, 2) AS "Refund Percentage",
   CASE
       WHEN r.refund_amount = p.payment_amount THEN 'Full Refund'
       WHEN r.refund_amount > p.payment_amount * 0.5 THEN 'Major Refund'
       ELSE 'Partial Refund'
   END AS "Refund Severity"
FROM
   refunds r
   INNER JOIN payment p ON r.payment_id = p.payment_id
   INNER JOIN booking b ON p.booking_id = b.booking_id
   LEFT JOIN service_task st ON b.booking_id = st.booking_id
   LEFT JOIN service_detail sd ON st.service_id = sd.service_id
   LEFT JOIN staff_allocation sa ON st.service_task_id = sa.service_task_id
   LEFT JOIN staff s ON sa.staff_id = s.staff_id
ORDER BY
   r.refund_date DESC,
   r.refund_amount DESC;

-- VIEW: STAFF SCHEDULE (NEXT WEEK) ---
CREATE OR REPLACE VIEW staff_schedule AS
SELECT
    s.staff_id,
    s.staff_name || ' ' || s.staff_last_name AS staff_name,
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 1) AS "Monday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 2) AS "Tuesday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 3) AS "Wednesday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 4) AS "Thursday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 5) AS "Friday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 6) AS "Saturday",
    STRING_AGG(
        sh.shift_start_time::time || ' - ' || sh.shift_end_time::time,
        ', '
    ) FILTER (WHERE EXTRACT(DOW FROM sh.shift_start_time) = 0) AS "Sunday"
FROM
    staff s
    LEFT JOIN staff_availability sa ON s.staff_id = sa.staff_id
    LEFT JOIN shift_detail sh ON sa.shift_id = sh.shift_id
WHERE
    s.branch_id = 1
    AND sh.shift_start_time >= DATE_TRUNC('week', CURRENT_DATE)
    AND sh.shift_end_time < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '7 days'
GROUP BY
    s.staff_id,
    s.staff_name,
    s.staff_last_name
ORDER BY
    s.staff_id;


