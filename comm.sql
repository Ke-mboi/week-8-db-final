

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db
  DEFAULT CHARACTER SET = utf8mb4
  DEFAULT COLLATE = utf8mb4_unicode_ci;

USE ecommerce_db;

-- ##########################
-- Table: users (customers + admins)
-- ##########################
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(30),
    role ENUM('customer','admin','seller') NOT NULL DEFAULT 'customer',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ##########################
-- Table: addresses
-- ##########################
CREATE TABLE addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    label VARCHAR(50), -- e.g., "Home", "Shop"
    street VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    county VARCHAR(100),
    postal_code VARCHAR(30),
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ##########################
-- Table: suppliers
-- ##########################
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_name VARCHAR(100),
    contact_email VARCHAR(255),
    phone VARCHAR(30),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (name)
) ENGINE=InnoDB;

-- ##########################
-- Table: categories
-- ##########################
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_id INT DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ##########################
-- Table: products
-- ##########################
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    short_description VARCHAR(500),
    description TEXT,
    supplier_id INT,
    price DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    cost_price DECIMAL(12,2) DEFAULT 0 CHECK (cost_price >= 0),
    currency CHAR(3) NOT NULL DEFAULT 'KES',
    weight_kg DECIMAL(8,3) DEFAULT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ##########################
-- Table: product_images
-- ##########################
CREATE TABLE product_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    url VARCHAR(1000) NOT NULL,
    alt_text VARCHAR(255),
    display_order INT NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ##########################
-- Table: product_categories (many-to-many)
-- ##########################
CREATE TABLE product_categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ##########################
-- Table: inventory (stock levels per product, per location optional)
-- ##########################
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    location VARCHAR(150) DEFAULT 'Main Warehouse',
    qty_available INT NOT NULL DEFAULT 0 CHECK (qty_available >= 0),
    qty_reserved INT NOT NULL DEFAULT 0 CHECK (qty_reserved >= 0),
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    UNIQUE (product_id, location)
) ENGINE=InnoDB;

-- ##########################
-- Table: orders
-- ##########################
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    address_id INT, -- shipping address
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending','confirmed','processing','shipped','delivered','cancelled','refunded') NOT NULL DEFAULT 'pending',
    subtotal DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
    shipping DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (shipping >= 0),
    tax DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (tax >= 0),
    total DECIMAL(12,2) NOT NULL CHECK (total >= 0),
    payment_id INT DEFAULT NULL,
    notes TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (address_id) REFERENCES addresses(address_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ##########################
-- Table: order_items (many-to-many: orders <-> products)
-- ##########################
CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0), -- price at time of order
    discount DECIMAL(12,2) DEFAULT 0 CHECK (discount >= 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ##########################
-- Table: payments
-- ##########################
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNIQUE, -- one payment per order in this model
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    method ENUM('mpesa','card','bank_transfer','cash_on_delivery','other') NOT NULL DEFAULT 'mpesa',
    provider_reference VARCHAR(255),
    status ENUM('initiated','completed','failed','refunded') NOT NULL DEFAULT 'initiated',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ##########################
-- Table: reviews
-- ##########################
CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    body TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE (product_id, user_id) -- one review per user per product
) ENGINE=InnoDB;

-- ##########################
-- Table: carts (optional)
-- ##########################
CREATE TABLE carts (
    cart_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (cart_id, product_id),
    FOREIGN KEY (cart_id) REFERENCES carts(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ##########################
-- Example seed inserts (small)
-- ##########################
INSERT INTO users (username, email, password_hash, first_name, last_name, role)
VALUES
('elvis', 'elvis@example.com', 'HASHED_PASSWORD', 'Elvis', 'Kemboi', 'admin'),
('janef', 'jane.farmer@example.com', 'HASHED_PASSWORD', 'Jane', 'Farmer', 'customer');

INSERT INTO suppliers (name, contact_name, contact_email)
VALUES ('Green Farms Ltd', 'Alice Green', 'alice@greenfarms.example'),
       ('AgroSupply Co', 'Bob Buyer', 'bob@agrosupply.example');

INSERT INTO categories (name, description)
VALUES ('Grains','Cereals and grains'), ('Vegetables','Fresh vegetables'), ('Fruits','Fresh fruits');

INSERT INTO products (sku, name, short_description, supplier_id, price, cost_price)
VALUES
('SKU-0001','Maize Flour 2kg','Packaged maize flour', 1, 250.00, 150.00),
('SKU-0002','Fresh Tomatoes 1kg','Locally farmed tomatoes', 1, 80.00, 40.00),
('SKU-0003','Rice 5kg','Long grain rice', 2, 600.00, 400.00);

INSERT INTO product_categories (product_id, category_id)
VALUES (1,1), (3,1), (2,2);

INSERT INTO inventory (product_id, location, qty_available)
VALUES (1, 'Main Warehouse', 120),
       (2, 'Main Warehouse', 350),
       (3, 'Main Warehouse', 80);

-- Sample order
INSERT INTO orders (user_id, address_id, subtotal, shipping, tax, total, status)
VALUES (2, NULL, 330.00, 30.00, 0.00, 360.00, 'pending');

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 1, 250.00), (1, 2, 1, 80.00);

-- ##########################
-- Helpful recommended indexes (beyond PK/FK)
-- ##########################
CREATE INDEX idx_products_sku_name ON products(sku, name);
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_inventory_product ON inventory(product_id);

