-- Lab 5: Database Constraints

-- Part 1: CHECK Constraints
CREATE TABLE employees_check (
    employee_id INT,
    first_name TEXT,
    last_name TEXT,
    age INT CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id INT,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

CREATE TABLE bookings (
    booking_id INT,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INT CHECK (num_guests BETWEEN 1 and 10),
    CONSTRAINT valid_dates CHECK (check_out_date > check_in_date)
);

-- Part 2: NOT NULL Constraints
CREATE TABLE customers (
    customer_id INT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE inventory (
    item_id INT NOT NULL,
    item_name TEXT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Part 3: UNIQUE Constraints
CREATE TABLE users (
    user_id INT,
    username TEXT CONSTRAINT unique_username UNIQUE,
    email TEXT CONSTRAINT unique_email UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE course_enrollments (
    enrollment_id INT,
    student_id INT,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_student_course UNIQUE (student_id, course_code, semester)
);

-- Part 4: PRIMARY KEY Constraints
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

CREATE TABLE student_courses (
    student_id INT,
    course_id INT,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Part 5: FOREIGN KEY Constraints
CREATE TABLE employees_dept (
    emp_id INT PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INT REFERENCES departments(dept_id),
    hire_date DATE
);

CREATE TABLE authors (
    author_id INT PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INT PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INT REFERENCES authors(author_id),
    publisher_id INT REFERENCES publishers(publisher_id),
    publication_year INT,
    isbn TEXT UNIQUE
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INT PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES products_fk(product_id),
    quantity INT CHECK (quantity > 0)
);

-- Part 6: Practical Application (E-commerce Database Design)
CREATE TABLE e_customers (
    customer_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE e_products (
    product_id INT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE e_orders (
    order_id INT PRIMARY KEY,
    customer_id INT REFERENCES e_customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE e_order_details (
    order_detail_id INT PRIMARY KEY,
    order_id INT REFERENCES e_orders(order_id) ON DELETE CASCADE,
    product_id INT REFERENCES e_products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);