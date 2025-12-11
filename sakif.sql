CREATE TYPE staff_status AS ENUM ('ACTIVE', 'ON_LEAVE', 'INACTIVE');
CREATE TYPE employment_type AS ENUM ('FULL_TIME', 'PART_TIME', 'CONTRACT', 'TEMPORARY');
CREATE TYPE shift_status AS ENUM ('PLANNED', 'CONFIRMED', 'COMPLETED', 'CANCELLED');
CREATE TYPE mot_result AS ENUM ('PASS', 'FAIL', 'ADVISORY');

CREATE TABLE branch (
    branch_id BIGSERIAL PRIMARY KEY,
    branch_code VARCHAR(10) UNIQUE NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    email_address VARCHAR(120),
    address_line_1 VARCHAR(120),
    address_line_2 VARCHAR(120),
    city VARCHAR(80),
    postcode VARCHAR(15),
    opened_on DATE DEFAULT CURRENT_DATE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE employee_pay_band (
    pay_band_id SMALLSERIAL PRIMARY KEY,
    band_code VARCHAR(10) UNIQUE NOT NULL,
    band_title VARCHAR(60) NOT NULL,
    hourly_rate NUMERIC(8,2) NOT NULL,
    overtime_hourly_rate NUMERIC(8,2),
    min_hours_per_week SMALLINT,
    max_hours_per_week SMALLINT
);

CREATE TABLE staff (
    staff_id BIGSERIAL PRIMARY KEY,
    branch_id BIGINT NOT NULL REFERENCES branch(branch_id),
    pay_band_id SMALLINT REFERENCES employee_pay_band(pay_band_id),
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email_address VARCHAR(120) UNIQUE,
    phone_number VARCHAR(20),
    employment_type employment_type NOT NULL DEFAULT 'FULL_TIME',
    status staff_status NOT NULL DEFAULT 'ACTIVE',
    hired_on DATE DEFAULT CURRENT_DATE,
    terminated_on DATE
);

CREATE TABLE role (
    role_id SMALLSERIAL PRIMARY KEY,
    role_code VARCHAR(30) UNIQUE NOT NULL,
    role_name VARCHAR(80) NOT NULL,
    role_desc TEXT
);

CREATE TABLE staff_role (
    staff_role_id BIGSERIAL PRIMARY KEY,
    staff_id BIGINT NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE,
    role_id SMALLINT NOT NULL REFERENCES role(role_id),
    is_primary BOOLEAN DEFAULT FALSE,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    UNIQUE(staff_id, role_id, valid_from)
);

CREATE TABLE certification (
    certification_id SMALLSERIAL PRIMARY KEY,
    cert_code VARCHAR(30) UNIQUE NOT NULL,
    cert_name VARCHAR(120) NOT NULL,
    issuer VARCHAR(120),
    valid_for_months SMALLINT,
    description TEXT
);

CREATE TABLE staff_certification (
    staff_cert_id BIGSERIAL PRIMARY KEY,
    staff_id BIGINT NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE,
    certification_id SMALLINT NOT NULL REFERENCES certification(certification_id),
    awarded_on DATE NOT NULL,
    expires_on DATE,
    certificate_number VARCHAR(60),
    notes TEXT,
    UNIQUE(staff_id, certification_id, awarded_on)
);

CREATE TABLE staff_availability (
    staff_availability_id BIGSERIAL PRIMARY KEY,
    staff_id BIGINT NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE,
    day_of_week SMALLINT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    effective_from DATE DEFAULT CURRENT_DATE,
    effective_to DATE
);

CREATE TABLE shift (
    shift_id BIGSERIAL PRIMARY KEY,
    staff_id BIGINT NOT NULL REFERENCES staff(staff_id) ON DELETE CASCADE,
    branch_id BIGINT NOT NULL REFERENCES branch(branch_id),
    shift_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status shift_status DEFAULT 'PLANNED',
    generated_from_availability BOOLEAN DEFAULT FALSE
);

CREATE TABLE car_mot (
    mot_id BIGSERIAL PRIMARY KEY,
    vehicle_id BIGINT NOT NULL REFERENCES vehicle(vehicle_id),
    booking_id BIGINT REFERENCES booking(booking_id),
    inspector_id BIGINT REFERENCES staff(staff_id),
    mot_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE,
    odometer_reading INTEGER,
    result mot_result NOT NULL,
    advisory_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
