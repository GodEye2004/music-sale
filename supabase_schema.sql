-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username TEXT NOT NULL,
    display_name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('buyer', 'producer')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_earnings NUMERIC DEFAULT 0,
    pending_balance NUMERIC DEFAULT 0,
    total_sales INTEGER DEFAULT 0,
    bio TEXT,
    profile_picture_url TEXT
);

-- Beats table
CREATE TABLE IF NOT EXISTS beats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    producer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    genre TEXT NOT NULL,
    bpm INTEGER NOT NULL,
    musical_key TEXT NOT NULL,
    price NUMERIC NOT NULL,
    audio_url TEXT,
    cover_url TEXT,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    likes INTEGER DEFAULT 0,
    downloads INTEGER DEFAULT 0,
    mp3_price NUMERIC,
    wav_price NUMERIC,
    stems_price NUMERIC,
    exclusive_price NUMERIC
);

-- Transactions table
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    beat_id UUID NOT NULL REFERENCES beats(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    producer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    license_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'completed',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Settlements table
CREATE TABLE IF NOT EXISTS settlements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount NUMERIC NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    bank_account TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_beats_producer ON beats(producer_id);
CREATE INDEX IF NOT EXISTS idx_beats_created ON beats(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_buyer ON transactions(buyer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_producer ON transactions(producer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_beat ON transactions(beat_id);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE beats ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE settlements ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- RLS Policies for beats table
CREATE POLICY "Anyone can view beats" ON beats
    FOR SELECT USING (true);

CREATE POLICY "Producers can insert own beats" ON beats
    FOR INSERT WITH CHECK (auth.uid() = producer_id);

CREATE POLICY "Producers can update own beats" ON beats
    FOR UPDATE USING (auth.uid() = producer_id);

CREATE POLICY "Producers can delete own beats" ON beats
    FOR DELETE USING (auth.uid() = producer_id);

-- RLS Policies for transactions
CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = buyer_id OR auth.uid() = producer_id);

CREATE POLICY "Buyers can create transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = buyer_id);

-- RLS Policies for settlements
CREATE POLICY "Producers can view own settlements" ON settlements
    FOR SELECT USING (auth.uid() = producer_id);

CREATE POLICY "Producers can create settlements" ON settlements
    FOR INSERT WITH CHECK (auth.uid() = producer_id);
