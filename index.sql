-- OPTIMIZATION - INDEX CREATION ---

-- TRANSACTION 1: Booking Creation & Assignment ---

-- Index for booking date lookups (availability checking)
CREATE INDEX idx_booking_scheduled_date ON booking(scheduled_date);

-- Index for booking status filtering
CREATE INDEX idx_booking_status ON booking(booking_status);

-- Index for customer booking history
CREATE INDEX idx_booking_customer ON booking(customer_id);

-- Index for service task booking lookups
CREATE INDEX idx_service_task_booking ON service_task(booking_id);

-- Index for finding available bays
CREATE INDEX idx_bay_status ON bay(bay_status);

-- Composite index for booking queries filtering by both booking and status
CREATE INDEX idx_service_task_composite ON service_task(booking_id, service_task_status);


-- TRANSACTION 2: Payment Processing & Revenue ---

-- Index for payment booking lookups
CREATE INDEX idx_payment_booking ON payment(booking_id);

-- Index for payment date range queries (financial reports)
CREATE INDEX idx_payment_date ON payment(payment_date);

-- Index for payment status filtering
CREATE INDEX idx_payment_status ON payment(payment_status);

-- Index for refund payment lookups
CREATE INDEX idx_refunds_payment ON refunds(payment_id);


-- TRANSACTION 3: Staff Performance & Allocation ---


-- Index for staff allocation by staff member
CREATE INDEX idx_staff_allocation_staff ON staff_allocation(staff_id);

-- Index for staff allocation by task
CREATE INDEX idx_staff_allocation_task ON staff_allocation(service_task_id);

-- Index for service task status filtering
CREATE INDEX idx_service_task_status ON service_task(service_task_status);

-- Index for staff by branch
CREATE INDEX idx_staff_branch ON staff(branch_id);

-- Index for manager hierarchy queries
CREATE INDEX idx_staff_manager ON staff(manager_id);


-- ADDITIONAL PERFORMANCE INDEXES ---

-- Partial index for active MOT records (reduces index size)
CREATE INDEX idx_mot_expiry ON car_mot(mot_expiry) 
WHERE mot_result = 'Pass';

-- Index for vehicle lookups
CREATE INDEX idx_vehicle_reg ON vehicle_details(vehicle_reg);

-- Index for service task bay allocation
CREATE INDEX idx_service_task_bay ON service_task(bay_id);

-- Index for parts supplier lookups
CREATE INDEX idx_parts_supplier ON parts_inventory(part_supplier_id);

-- Index for staff certifications
CREATE INDEX idx_staff_cert ON staff_certification(staff_id, certificate_id);

-- Index for staff roles
CREATE INDEX idx_staff_role ON staff_role(staff_id, role_id);

-- Index for staff availability
CREATE INDEX idx_staff_availability ON staff_availability(staff_id, shift_id);
