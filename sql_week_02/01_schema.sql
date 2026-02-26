CREATE TABLE IF NOT EXISTS returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    return_reason VARCHAR(100) NOT NULL,
    return_status VARCHAR(50) NOT NULL,
    refund_amount DECIMAL(10, 2) DEFAULT 0.00,
    returned_at TIMESTAMP NOT NULL,
    processed_at TIMESTAMP NULL,

    CONSTRAINT fk_returns_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items(order_item_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_returns_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_returns_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_returns_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS promotions (
    promo_id INT PRIMARY KEY AUTO_INCREMENT,
    promo_code VARCHAR(50) NOT NULL UNIQUE,
    promo_name VARCHAR(100) NOT NULL,
    discount_type VARCHAR(20) NOT NULL,
    discount_value DECIMAL(10, 2) NOT NULL CHECK (discount_value >= 0),
    min_order_value DECIMAL(10, 2) DEFAULT 0.00,
    usage_limit INT NULL,
    times_used INT DEFAULT 0,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW() NOT NULL
);


CREATE TABLE IF NOT EXISTS order_promotions (
    order_promo_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    promo_id INT NOT NULL,
    discount_applied DECIMAL(10, 2) NOT NULL CHECK (discount_applied >= 0),
    applied_at TIMESTAMP DEFAULT NOW() NOT NULL,

    CONSTRAINT fk_order_promotions_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_order_promotions_promotion
        FOREIGN KEY (promo_id)
        REFERENCES promotions(promo_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS product_inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL UNIQUE,
    stock_quantity INT NOT NULL DEFAULT 0,
    reserved_quantity INT NOT NULL DEFAULT 0,
    restock_threshold INT NOT NULL,
    restock_quantity INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL CHECK (unit_cost >= 0),
    last_restocked_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT NOW() NOT NULL,

    CONSTRAINT fk_product_inventory_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);