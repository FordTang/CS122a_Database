-- This file demonstrates an example that how your script file should look like.
-- Refer to the "Final Note" section of HW 7 to properly use this template.
-- When you create your script, remove this header (3 lines). Your script should start with "use deliber;".

use deliber;

-- 1-a
CREATE TABLE Bank_Account_History (
	did integer,
    bank_account_number VARCHAR(20),
    bank_account_routing_number VARCHAR(20),
    operation_datetime DATETIME,
    primary key(did, bank_account_number, bank_account_routing_number),
    foreign key(did)
    references drivers(did));

-- 1-b
INSERT INTO Bank_Account_History (did, bank_account_number, bank_account_routing_number, operation_datetime)
select did, bank_account_number, bank_account_routing_number, now()
from drivers;

-- 1-c
DELIMITER //
CREATE TRIGGER DRIVER_INSERT_TRIGGER
after insert on drivers
for each row
	begin
		insert into bank_account_history(did, bank_account_number, bank_account_routing_number, operation_datetime)
        values (did, bank_account_number, bank_account_routing_number, now());
	end
//
DELIMITER ;

-- 1-d
DELIMITER //
CREATE TRIGGER DRIVER_UPDATE_TRIGGER
after update on drivers
for each row
	begin
		insert into bank_account_history(did, bank_account_number, bank_account_routing_number, operation_datetime)
        values (did, bank_account_number, bank_account_routing_number, now());
	end
//
DELIMITER ;

-- 2-a
CREATE TABLE Credit_cards_new (
card_number VARCHAR(20),
expr_date CHAR(6),
cid INTEGER,
PRIMARY	KEY	(card_number),
foreign key (cid)
references customers(cid) on delete cascade); 

-- 2-b
ALTER TABLE credit_cards
add foreign key (cid)
references customers(cid) on delete cascade;

-- 3-a
CREATE VIEW Orders_Status_view (oid, order_customer, order_restaurant, order_initialized_datetime, order_being_prepared_datetime, order_being_delivered_datetime, order_delivered_datetime)
as select orders.oid, users.name as order_customer, restaurants.name as order_restaurant, ots1.order_status_datetime as order_initialized_datetime, ots2.order_status_datetime as order_being_prepared_datetime, ots3.order_status_datetime as order_being_delivered_datetime, ots4.order_status_datetime as order_delivered_datetime
from orders left join users on orders.cid = users.id 
left join restaurants on orders.rid = restaurants.rid 
left join orders_track_status ots1 on orders.oid = ots1.oid
left join orders_track_status ots2 on orders.oid = ots2.oid
left join orders_track_status ots3 on orders.oid = ots3.oid
left join orders_track_status ots4 on orders.oid = ots4.oid
where ots1.order_status_code = 1 and
ots2.order_status_code = 2 and
ots3.order_status_code = 3 and
ots4.order_status_code = 4;

-- 3-b
SELECT * FROM Orders_Status_view WHERE oid = 15;

-- 4
GRANT select on orders_status_view to deliberuser with grant option;

-- 5-a-i
EXPLAIN SELECT id,	name	FROM	Users	WHERE	name	LIKE	"Ja%";

-- 5-a-ii
EXPLAIN SELECT id,	name	FROM	Users	WHERE	name	LIKE	"%an";

-- 5-a-iii
EXPLAIN SELECT oid,	total_amount	FROM	Orders	WHERE	total_amount	>	100;

-- 5-b
CREATE INDEX ix_Users_name
on users(name);

-- 5-c
CREATE INDEX ix_Orders_total_amount
on orders(total_amount);

-- 5-d-i
EXPLAIN SELECT id,	name	FROM	Users	WHERE	name	LIKE	"Ja%";

-- 5-d-ii
EXPLAIN SELECT id,	name	FROM	Users	WHERE	name	LIKE	"%an";

-- 5-d-iii
EXPLAIN SELECT oid,	total_amount	FROM	Orders	WHERE	total_amount	>	100;

-- 5-e
-- 5a does not use indexing while 5d does, which makes the query faster.
