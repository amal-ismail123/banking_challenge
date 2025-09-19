echo "🏦 Setting up Banking Database..."

# Remove existing database if it exists
if [ -f "banking.db" ]; then
    echo "Removing existing database..."
    rm banking.db
fi

# Create database and run schema
echo "Creating database schema..."
sqlite3 banking.db < DATABASE.sql

# Seed the database
echo "Seeding database with sample data..."
sqlite3 banking.db << 'EOF'

-- =============================================================================
-- SEED DATA FOR BANKING DATABASE
-- =============================================================================

-- Insert Account Types
INSERT INTO ACCOUNT_TYPES (name, description, minimum_balance, monthly_fee, interest_rate) VALUES
('Basic Checking', 'Basic checking account with no frills', 0.00, 5.00, 0.0000),
('Premium Checking', 'Premium checking with benefits', 1000.00, 0.00, 0.0050),
('Savings', 'Standard savings account', 100.00, 0.00, 0.0150),
('High Yield Savings', 'High interest savings account', 2500.00, 0.00, 0.0250),
('Business Checking', 'Business checking account', 500.00, 15.00, 0.0000);

-- Insert Users (mix of customers and admin)
INSERT INTO USERS (first_name, last_name, email, password, phone, date_of_birth, address, is_admin) VALUES
('John', 'Doe', 'john.doe@email.com', 'hashed_password_123', '+1-555-0101', '1990-05-15', '123 Main St, New York, NY 10001', 0),
('Jane', 'Smith', 'jane.smith@email.com', 'hashed_password_456', '+1-555-0102', '1985-08-22', '456 Oak Ave, Los Angeles, CA 90210', 0),
('Mike', 'Johnson', 'mike.johnson@email.com', 'hashed_password_789', '+1-555-0103', '1992-12-03', '789 Pine Rd, Chicago, IL 60601', 0),
('Sarah', 'Wilson', 'sarah.wilson@email.com', 'hashed_password_321', '+1-555-0104', '1988-03-18', '321 Elm St, Houston, TX 77001', 0),
('Admin', 'User', 'admin@bank.com', 'admin_password_999', '+1-555-0001', '1980-01-01', '1 Bank Plaza, New York, NY 10005', 1),
('David', 'Brown', 'david.brown@email.com', 'hashed_password_654', '+1-555-0105', '1995-07-09', '654 Maple Dr, Phoenix, AZ 85001', 0),
('Lisa', 'Davis', 'lisa.davis@email.com', 'hashed_password_987', '+1-555-0106', '1987-11-25', '987 Cedar Ln, Philadelphia, PA 19101', 0);

-- Insert Accounts
INSERT INTO ACCOUNTS (user_id, account_type_id, account_number, balance, status) VALUES
(1, 1, 'CHK-1001-2023', 2500.75, 'active'),
(1, 3, 'SAV-1001-2023', 15000.00, 'active'),
(2, 2, 'CHK-1002-2023', 5000.50, 'active'),
(2, 4, 'SAV-1002-2023', 25000.00, 'active'),
(3, 1, 'CHK-1003-2023', 1200.25, 'active'),
(3, 3, 'SAV-1003-2023', 8500.00, 'active'),
(4, 2, 'CHK-1004-2023', 3750.80, 'active'),
(4, 3, 'SAV-1004-2023', 12000.00, 'frozen'),
(6, 1, 'CHK-1006-2023', 890.45, 'active'),
(7, 5, 'BUS-1007-2023', 45000.00, 'active');

-- Insert Transactions
INSERT INTO TRANSACTIONS (account_id, transaction_type, amount, balance_after, description, transaction_method, status) VALUES
(1, 'deposit', 1000.00, 2500.75, 'Salary deposit', 'online', 'completed'),
(1, 'withdrawal', 50.00, 2450.75, 'ATM withdrawal', 'atm', 'completed'),
(1, 'fee', 5.00, 2445.75, 'Monthly maintenance fee', 'online', 'completed'),
(2, 'deposit', 15000.00, 15000.00, 'Initial deposit', 'branch', 'completed'),
(3, 'deposit', 2000.00, 5000.50, 'Paycheck deposit', 'online', 'completed'),
(3, 'withdrawal', 200.00, 4800.50, 'Cash withdrawal', 'atm', 'completed'),
(5, 'deposit', 500.00, 1200.25, 'Check deposit', 'mobile', 'completed'),
(5, 'withdrawal', 100.00, 1100.25, 'Grocery shopping', 'online', 'completed'),
(7, 'deposit', 3000.00, 3750.80, 'Freelance payment', 'online', 'completed'),
(10, 'deposit', 45000.00, 45000.00, 'Business capital', 'branch', 'completed');

-- Insert transfer transactions
INSERT INTO TRANSACTIONS (account_id, transaction_type, amount, balance_after, description, recipient_account_id, reference_number, transaction_method, status) VALUES
(1, 'transfer', 500.00, 2000.75, 'Transfer to savings', 2, 'TXN-20231201-001', 'online', 'completed'),
(2, 'transfer', 500.00, 15500.00, 'Transfer from checking', 1, 'TXN-20231201-001', 'online', 'completed');

-- Insert Cards
INSERT INTO CARDS (user_id, account_id, card_number, is_credit, expiry_date, cvv, credit_limit, status) VALUES
(1, 1, '4532-1234-5678-9012', 0, '2026-12-31', '123', NULL, 'active'),
(1, 1, '5555-4444-3333-2222', 1, '2027-06-30', '456', 5000.00, 'active'),
(2, 3, '4111-1111-1111-1111', 0, '2025-09-30', '789', NULL, 'active'),
(2, 3, '3782-822463-10005', 1, '2026-03-31', '321', 10000.00, 'active'),
(3, 5, '6011-1111-1111-1117', 0, '2025-12-31', '654', NULL, 'active'),
(4, 7, '4000-0000-0000-0002', 0, '2026-08-31', '987', NULL, 'blocked'),
(6, 9, '5200-8282-8282-8210', 0, '2025-11-30', '147', NULL, 'active'),
(7, 10, '4242-4242-4242-4242', 0, '2027-01-31', '258', NULL, 'active');

-- Insert Loans
INSERT INTO LOANS (user_id, loan_type, principal_amount, current_balance, interest_rate, monthly_payment, status, next_payment_date) VALUES
(1, 'auto', 25000.00, 18500.00, 0.0450, 485.50, 'active', '2024-01-15'),
(2, 'mortgage', 350000.00, 325000.00, 0.0375, 1850.00, 'active', '2024-01-01'),
(3, 'personal', 10000.00, 7500.00, 0.0850, 245.75, 'active', '2024-01-10'),
(4, 'auto', 35000.00, 35000.00, 0.0425, 650.00, 'approved', '2024-01-20'),
(6, 'personal', 5000.00, 0.00, 0.0750, 0.00, 'paid_off', NULL),
(7, 'mortgage', 280000.00, 280000.00, 0.0400, 1450.00, 'pending', NULL);

-- Insert Beneficiaries
INSERT INTO BENEFICIARIES (user_id, name, account_number, bank_name) VALUES
(1, 'Jane Smith', 'CHK-1002-2023', 'Same Bank'),
(1, 'Emergency Fund', 'SAV-9999-2023', 'Emergency Credit Union'),
(2, 'John Doe', 'CHK-1001-2023', 'Same Bank'),
(2, 'Utility Company', 'BUS-5555-2023', 'City Power & Light'),
(3, 'Mom - Mary Johnson', 'SAV-7777-2023', 'First National Bank'),
(3, 'Rent Payment', 'BUS-3333-2023', 'Property Management LLC'),
(4, 'Investment Account', 'INV-8888-2023', 'Brokerage Firm'),
(6, 'College Fund', 'SAV-4444-2023', 'Education Savings Bank'),
(7, 'Business Partner', 'BUS-6666-2023', 'Commercial Bank');

EOF

echo "✅ Database setup complete!"
echo ""
echo "📊 Database Statistics:"
sqlite3 banking.db << 'EOF'
SELECT 'Users: ' || COUNT(*) FROM USERS;
SELECT 'Account Types: ' || COUNT(*) FROM ACCOUNT_TYPES;
SELECT 'Accounts: ' || COUNT(*) FROM ACCOUNTS;
SELECT 'Transactions: ' || COUNT(*) FROM TRANSACTIONS;
SELECT 'Cards: ' || COUNT(*) FROM CARDS;
SELECT 'Loans: ' || COUNT(*) FROM LOANS;
SELECT 'Beneficiaries: ' || COUNT(*) FROM BENEFICIARIES;
EOF

echo ""
echo "🎯 Sample Queries:"
echo "View all users: sqlite3 banking.db 'SELECT first_name, last_name, email, is_admin FROM USERS;'"
echo "View account balances: sqlite3 banking.db 'SELECT u.first_name, u.last_name, at.name, a.account_number, a.balance FROM ACCOUNTS a JOIN USERS u ON a.user_id = u.id JOIN ACCOUNT_TYPES at ON a.account_type_id = at.id;'"
echo "View recent transactions: sqlite3 banking.db 'SELECT * FROM TRANSACTIONS ORDER BY created_at DESC LIMIT 5;'"
echo ""
echo "🏦 Banking database is ready for your use!"

