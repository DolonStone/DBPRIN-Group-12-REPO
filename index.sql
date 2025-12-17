-- OPTIMIZATION - INDEX CREATION --------
-- CarCare Hub Database Performance Enhancement.



-- TRANSACTION 1: Booking Creation & Assignment --------

-- Index for booking date lookups (availability checking)
CREATE INDEX idx_booking_scheduled_date ON booking(scheduled_date);

-- Index for booking status filtering
CREATE INDEX idx_booking_status ON booking(booking_status);

-- Index for customer booking history
CREATE INDEX idx_booking_customer ON booking(customer_id);

-- Index for service task booking lookups
CREATE INDEX idx_service_task_booking ON service_task(booking_id);

-- Composite index for booking queries filtering by both booking and status
CREATE INDEX idx_service_task_composite ON service_task(booking_id, service_task_status);


-- TRANSACTION 2: Payment Processing & Revenue --------

-- Index for payment booking lookups
CREATE INDEX idx_payment_booking ON payment(booking_id);

-- Index for payment date range queries (financial reports)
CREATE INDEX idx_payment_date ON payment(payment_date);

-- Index for payment status filtering
CREATE INDEX idx_payment_status ON payment(payment_status);

-- Index for refund payment lookups
CREATE INDEX idx_refunds_payment ON refunds(payment_id);


-- TRANSACTION 3: Bay Assignment & Workshop Scheduling -------

-- Index for finding available bays quickly
CREATE INDEX idx_bay_status ON bay(bay_status);

-- Index for bay inspection compliance checks
CREATE INDEX idx_bay_inspection ON bay(bay_last_inspection_date);

-- Index for service task bay lookups
CREATE INDEX idx_service_task_bay ON service_task(bay_id);

-- Composite index for bay allocation queries
CREATE INDEX idx_service_task_status_bay ON service_task(bay_id, service_task_status);

-- Composite index for staff allocation
CREATE INDEX idx_staff_allocation_composite ON staff_allocation(service_task_id, staff_id);

-- Index for staff allocation by staff member
CREATE INDEX idx_staff_allocation_staff ON staff_allocation(staff_id);

-- Index for staff by branch (for bay assignment by location)
CREATE INDEX idx_staff_branch ON staff(branch_id);


