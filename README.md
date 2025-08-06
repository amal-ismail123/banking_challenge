# Banking Database Schema

## Global Fields

```SQL
    is_active BOOLEAN DEFAULT 1
```

Enables soft deletion to maintain data integrity and transaction history.

```SQL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

Standard audit fields for tracking record creation and modifications.

## 1) Users Table

```SQL
CREATE TABLE IF NOT EXISTS USERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    phone TEXT,
    date_of_birth DATE,
    address TEXT,
    is_admin BOOLEAN NOT NULL DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

- **Basic customer profile** with optional address and date of birth
- **Simple role system**: `is_admin` boolean where `0 = customer`, `1 = admin`
- **Essential contact info**: Email (required for login) and phone (optional)
- **Streamlined fields**: No complex address breakdown for hackathon speed

## 2) Account Types Table

```SQL
CREATE TABLE IF NOT EXISTS ACCOUNT_TYPES (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    minimum_balance DECIMAL(10,2) DEFAULT 0,
    monthly_fee DECIMAL(8,2) DEFAULT 0,
    interest_rate DECIMAL(5,4) DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

- **Flexible account products**: Easy to add new account types
- **Business rules**: Minimum balance, fees, and interest rates per type
- **Examples**:
  - Basic Checking: $0 minimum, $5 monthly fee
  - Savings: $100 minimum, $0 fee, 1.5% interest
  - Premium: $1000 minimum, $0 fee, 2.0% interest

## 3) Accounts Table

```SQL
CREATE TABLE IF NOT EXISTS ACCOUNTS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    account_type_id INTEGER NOT NULL,
    account_number TEXT UNIQUE NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    status TEXT CHECK(status IN ('active', 'frozen', 'closed')) DEFAULT 'active',
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (account_type_id) REFERENCES ACCOUNT_TYPES(id)
);
```

- **Single balance field**: Simplified for hackathon (no available balance complexity)
- **Account lifecycle**: Active, frozen, or closed status
- **Links to account types**: Inherits rules from account type configuration
- **Unique account numbers**: TEXT format to preserve formatting

## 4) Transactions Table

```SQL
CREATE TABLE IF NOT EXISTS TRANSACTIONS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_id INTEGER NOT NULL,
    transaction_type TEXT CHECK(transaction_type IN ('deposit', 'withdrawal', 'transfer', 'fee')) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    balance_after DECIMAL(15,2) NOT NULL,
    description TEXT NOT NULL,
    recipient_account_id INTEGER,
    reference_number TEXT UNIQUE,
    transaction_method TEXT CHECK(transaction_method IN ('atm', 'online', 'mobile', 'branch')) NOT NULL DEFAULT 'online',
    status TEXT CHECK(status IN ('pending', 'completed', 'failed')) DEFAULT 'completed',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(id),
    FOREIGN KEY (recipient_account_id) REFERENCES ACCOUNTS(id)
);
```

- **Core transaction types**: Deposit, withdrawal, transfer, and fees
- **Balance tracking**: Running balance after each transaction
- **Transfer support**: Recipient account for money transfers
- **Transaction methods**: Track how transactions were initiated
- **Reference numbers**: Unique identifiers for tracking and disputes

## 5) Cards Table

```SQL
CREATE TABLE IF NOT EXISTS CARDS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    card_number TEXT UNIQUE NOT NULL,
    is_credit BOOLEAN NOT NULL DEFAULT 0,
    expiry_date DATE NOT NULL,
    cvv TEXT NOT NULL,
    credit_limit DECIMAL(10,2),
    status TEXT CHECK(status IN ('active', 'blocked', 'expired')) DEFAULT 'active',
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (account_id) REFERENCES ACCOUNTS(id)
);
```

- **Card type as boolean**: `is_credit` field where `0 = debit card`, `1 = credit card`
- **Credit limits**: Only applies to credit cards (nullable for debit)
- **Card lifecycle**: Active, blocked, or expired status
- **Security fields**: CVV stored as text to handle different formats

### Boolean Field Conventions (IS CREDIT & IS ADMIN)

For fields with only two possible values, we use boolean fields for better performance and simpler queries:

- **`is_credit`**: `0` for debit cards, `1` for credit cards
  - Query debit cards: `WHERE is_credit = 0`
  - Query credit cards: `WHERE is_credit = 1`
  - More efficient than string comparisons
  - Uses less storage space
  - Eliminates typos in string values

- **`is_admin`**: `0` for customers, `1` for admin users
  - Query customers: `WHERE is_admin = 0`
  - Query admins: `WHERE is_admin = 1`
  - Simpler role-based access control
  - Faster permission checks

## 6) Loans Table

```SQL
CREATE TABLE IF NOT EXISTS LOANS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    loan_type TEXT CHECK(loan_type IN ('personal', 'auto', 'mortgage')) NOT NULL,
    principal_amount DECIMAL(15,2) NOT NULL,
    current_balance DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,4) NOT NULL,
    monthly_payment DECIMAL(10,2) NOT NULL,
    status TEXT CHECK(status IN ('pending', 'approved', 'active', 'paid_off')) DEFAULT 'pending',
    next_payment_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id)
);
```

- **Three loan types**: Personal, auto, and mortgage
- **Simple loan tracking**: Principal, current balance, and payment info
- **Payment management**: Monthly payment amount and next due date
- **Loan lifecycle**: From pending application to paid off

## 7) Beneficiaries Table

```SQL
CREATE TABLE IF NOT EXISTS BENEFICIARIES (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    account_number TEXT NOT NULL,
    bank_name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id)
);
```

- **Saved transfer recipients**: Store frequently used transfer destinations
- **Simplified structure**: Name, account number, and bank name only
- **Quick transfers**: Easy selection for repeat transfers
- **User-specific**: Each user maintains their own beneficiary list

## Performance Indexes

- **`idx_users_email`**: Fast user authentication and login
- **`idx_accounts_user`**: Quick retrieval of user's accounts
- **`idx_accounts_number`**: Direct account lookup for transfers
- **`idx_transactions_account`**: Fast transaction history queries
- **`idx_transactions_date`**: Time-based transaction reports
- **`idx_loans_user`**: Quick access to user's loan information
- **`idx_cards_user`**: Retrieve user's cards quickly
- **`idx_cards_number`**: Card validation and processing

## How to set up (USING SQLITE3)

```bash
chmod +x SCRIPT.sh
./SCRIPT.sh
```