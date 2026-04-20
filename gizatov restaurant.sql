CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_time TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);