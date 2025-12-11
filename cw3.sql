CREATE TABLE booking (
    booking_ID SERIAL PRIMARY KEY,
    booking_date SMALLDATETIME,
    Scheduled_Date SMALLDATETIME,
    Scheduled_Time SMALLINT,
    Status ENUM('Pending', 'Confirmed', 'Cancelled', 'Completed'),
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

CREATE TABLE Meberships
(
    Membership_ID SERIAL PRIMARY KEY,
    Membership_tier ENUM('Silver', 'Gold', 'Platinum'),
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

CREATE TABLE payment (
    payment_ID SERIAL PRIMARY KEY,
    booking_ID SMALLINT,
    payment_date DATETIME,
    payment_amount SMALLINT,
    payment_method ENUM('Credit Card', 'Debit Card', 'Cash', 'Online Transfer', 'KLANA'),
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

CREATE car_mot (
    MOT_ID SERIAL PRIMARY KEY,
    mechanic_ID SMALLINT,
    MOT_date SMALLDATETIME,
    MOT_expirary SMALLDATETIME,
    MOT_result ENUM('Pass', 'Fail'),
);