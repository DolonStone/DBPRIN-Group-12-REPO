
CREATE TYPE allocation_role AS ENUM ('Technician', 'Supervisor', 'Assistant');


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
    salary DECIMAL(10,2) NOT NULL,
    holiday_pay DECIMAL(8,2)
);

CREATE TABLE shift_detail(
    shift_id SERIAL PRIMARY KEY,
    shift_date DATE NOT NULL,
    shift_start_time TIME NOT NULL,
    shift_end_time TIME NOT NULL
);

CREATE TABLE staff(
    staff_id SERIAL PRIMARY KEY,
    staff_name VARCHAR(100) NOT NULL,
    staff_emergency_contact VARCHAR(15),
    manager_id SMALLINT,
    branch_id SMALLINT NOT NULL,
    staff_last_name VARCHAR(50),
    staff_date VARCHAR(50),
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
    staff_id SERIAL PRIMARY KEY,
    shift_id SMALLINT NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    FOREIGN KEY (shift_id) REFERENCES shift_detail(shift_id)
);

CREATE TABLE staff_allocation(
    service_task_id SMALLINT NOT NULL,
    staff_id SMALLINT NOT NULL,
    allocation_role  NOT NULL,
    PRIMARY KEY (service_task_id, staff_id),
    FOREIGN KEY (service_task_id) REFERENCES service_task(service_task_id),
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);
