-- ============================================
-- RentTn Database Schema
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. PROFILES TABLE
-- Extends auth.users with additional user data
-- Automatically populated via trigger on sign-up
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  phone TEXT,
  avatar_url TEXT,
  driver_license_number TEXT,
  date_of_birth DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. LOCATIONS TABLE
CREATE TABLE public.locations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'Tunisia',
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. CARS TABLE
CREATE TABLE public.cars (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('economy', 'compact', 'sedan', 'suv', 'luxury', 'sports', 'electric')),
  price_per_day NUMERIC(10, 2) NOT NULL,
  deal_discount_percent NUMERIC(5, 2) DEFAULT 0 CHECK (deal_discount_percent >= 0 AND deal_discount_percent <= 90),
  deal_active BOOLEAN DEFAULT false,
  image_url TEXT,
  description TEXT,
  seats INTEGER DEFAULT 5,
  transmission TEXT DEFAULT 'automatic' CHECK (transmission IN ('automatic', 'manual')),
  fuel_type TEXT DEFAULT 'gasoline' CHECK (fuel_type IN ('gasoline', 'diesel', 'electric', 'hybrid')),
  availability BOOLEAN DEFAULT true,
  location_id UUID REFERENCES public.locations(id),
  features TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT cars_make_model_year_unique UNIQUE (make, model, year)
);

-- 4. BOOKINGS TABLE
CREATE TABLE public.bookings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  car_id UUID REFERENCES public.cars(id) ON DELETE CASCADE NOT NULL,
  pickup_location_id UUID REFERENCES public.locations(id),
  dropoff_location_id UUID REFERENCES public.locations(id),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  total_price NUMERIC(10, 2) NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'active', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT valid_dates CHECK (end_date > start_date)
);

-- ============================================
-- INDEXES for performance
-- ============================================
CREATE INDEX idx_cars_category ON public.cars(category);
CREATE INDEX idx_cars_availability ON public.cars(availability);
CREATE INDEX idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX idx_bookings_car_id ON public.bookings(car_id);
CREATE INDEX idx_bookings_dates ON public.bookings(start_date, end_date);

-- ============================================
-- AUTO-UPDATE updated_at TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cars_updated_at
  BEFORE UPDATE ON public.cars
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
  BEFORE UPDATE ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- AUTO-CREATE PROFILE ON SIGN-UP
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, avatar_url)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'full_name',
    NEW.raw_user_meta_data ->> 'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- AUTO-TOGGLE CAR AVAILABILITY ON BOOKING
-- ============================================
CREATE OR REPLACE FUNCTION public.toggle_car_availability()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status IN ('confirmed', 'active') THEN
    UPDATE public.cars SET availability = false WHERE id = NEW.car_id;
  END IF;
  IF NEW.status IN ('completed', 'cancelled') THEN
    UPDATE public.cars SET availability = true WHERE id = NEW.car_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_booking_status_change
  AFTER INSERT OR UPDATE OF status ON public.bookings
  FOR EACH ROW EXECUTE FUNCTION public.toggle_car_availability();

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cars ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.locations ENABLE ROW LEVEL SECURITY;

-- PROFILES: Users can only read/update their own
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- CARS: Everyone (including anon) can view cars
CREATE POLICY "Anyone can view cars"
  ON public.cars FOR SELECT
  TO anon, authenticated
  USING (true);

-- BOOKINGS: Users can only manage their own
CREATE POLICY "Users can view their own bookings"
  ON public.bookings FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own bookings"
  ON public.bookings FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings"
  ON public.bookings FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- LOCATIONS: Everyone can view active locations
CREATE POLICY "Anyone can view locations"
  ON public.locations FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

-- ============================================
-- ENABLE REALTIME
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.cars;
ALTER PUBLICATION supabase_realtime ADD TABLE public.bookings;

-- Add deal columns for existing databases (safe to re-run)
ALTER TABLE public.cars
  ADD COLUMN IF NOT EXISTS deal_discount_percent NUMERIC(5, 2) DEFAULT 0;

ALTER TABLE public.cars
  ADD COLUMN IF NOT EXISTS deal_active BOOLEAN DEFAULT false;

-- ============================================
-- SEED DATA
-- ============================================

-- Locations (Tunisia)
INSERT INTO public.locations (name, address, city, country) VALUES
  ('RentTn Tunis Centre', '15 Avenue Habib Bourguiba', 'Tunis', 'Tunisia'),
  ('RentTn Tunis-Carthage Airport', 'Aéroport International de Tunis-Carthage', 'Tunis', 'Tunisia'),
  ('RentTn Sousse', '22 Boulevard de la Corniche', 'Sousse', 'Tunisia'),
  ('RentTn Monastir', 'Rue de l''Aéroport, Monastir', 'Monastir', 'Tunisia'),
  ('RentTn Hammamet', '8 Avenue des Nations Unies', 'Hammamet', 'Tunisia'),
  ('RentTn Djerba', 'Zone Touristique Midoun', 'Djerba', 'Tunisia');

-- Cars
INSERT INTO public.cars (make, model, year, category, price_per_day, seats, transmission, fuel_type, description, features, image_url, location_id) VALUES
  ('Tesla', 'Model 3', 2025, 'electric', 289.00, 5, 'automatic', 'electric', 'The quintessential electric sedan. Zero emissions, maximum thrill.', ARRAY['Autopilot', 'Premium Audio', 'Glass Roof'], 'https://upload.wikimedia.org/wikipedia/commons/9/91/2019_Tesla_Model_3_Performance_AWD_Front.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis Centre')),
  ('BMW', 'M4 Competition', 2025, 'sports', 650.00, 4, 'automatic', 'gasoline', 'Track-bred performance meets everyday luxury.', ARRAY['M Sport Exhaust', 'Carbon Fiber Trim', 'Head-Up Display'], 'https://upload.wikimedia.org/wikipedia/commons/e/e2/2021_BMW_M4_Competition_Automatic_3.0_Front.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis Centre')),
  ('Mercedes-Benz', 'S-Class', 2025, 'luxury', 780.00, 5, 'automatic', 'hybrid', 'The benchmark of automotive luxury.', ARRAY['Burmester Audio', 'Massage Seats', 'MBUX AR Navigation'], 'https://upload.wikimedia.org/wikipedia/commons/5/55/Mercedes-Benz_W223_IMG_6663.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis-Carthage Airport')),
  ('Toyota', 'Camry', 2025, 'sedan', 165.00, 5, 'automatic', 'gasoline', 'Reliable, efficient, and comfortable for any journey.', ARRAY['Apple CarPlay', 'Safety Sense', 'Wireless Charging'], 'https://upload.wikimedia.org/wikipedia/commons/a/ac/2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis-Carthage Airport')),
  ('Jeep', 'Wrangler', 2025, 'suv', 340.00, 5, 'automatic', 'gasoline', 'Born to explore. Go anywhere capability.', ARRAY['4x4', 'Removable Top', 'Trail Rated'], 'https://upload.wikimedia.org/wikipedia/commons/b/b9/2018_Jeep_Wrangler_Sahara_Unlimited_Multijet_2.1_Front.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Sousse')),
  ('Porsche', '911 Carrera', 2025, 'sports', 1100.00, 2, 'automatic', 'gasoline', 'An icon reimagined. Pure driving perfection.', ARRAY['Sport Chrono', 'PASM', 'Bose Surround'], 'https://upload.wikimedia.org/wikipedia/commons/a/a2/Porsche_911_No_1000000%2C_70_Years_Porsche_Sports_Car%2C_Berlin_%281X7A3888%29.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Hammamet')),
  ('Honda', 'Civic', 2025, 'compact', 135.00, 5, 'automatic', 'gasoline', 'Smart, stylish, and fun to drive.', ARRAY['Honda Sensing', 'Wireless CarPlay', 'LED Headlights'], 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Sousse')),
  ('Rivian', 'R1S', 2025, 'suv', 520.00, 7, 'automatic', 'electric', 'Adventure-ready electric SUV with 3-row seating.', ARRAY['Quad Motor AWD', 'Camp Mode', 'Gear Guard'], 'https://upload.wikimedia.org/wikipedia/commons/8/89/2023_Rivian_R1S_Adventure%2C_front_1.29.23.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Hammamet')),
  ('Hyundai', 'Tucson', 2025, 'suv', 210.00, 5, 'automatic', 'gasoline', 'Modern design meets practical versatility. Perfect for family trips across Tunisia.', ARRAY['Smart Cruise', 'Panoramic Roof', 'Blind Spot Monitor'], 'https://upload.wikimedia.org/wikipedia/commons/c/c6/2022_Hyundai_Tucson_Preferred%2C_Front_Right%2C_05-24-2021.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis Centre')),
  ('Hyundai', 'i10', 2025, 'economy', 95.00, 4, 'manual', 'gasoline', 'The perfect city car. Compact, fuel-efficient, and easy to park anywhere.', ARRAY['Bluetooth', 'USB Charging', 'Air Conditioning'], 'https://upload.wikimedia.org/wikipedia/commons/4/44/Hyundai_i10_1.0_Intro_%28III%29_%E2%80%93_f_03012021.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Monastir')),
  ('Toyota', 'Corolla', 2025, 'sedan', 150.00, 5, 'automatic', 'hybrid', 'The world''s best-selling car. Legendary reliability meets modern hybrid tech.', ARRAY['Toyota Safety Sense', 'Hybrid Engine', 'Apple CarPlay'], 'https://upload.wikimedia.org/wikipedia/commons/f/fe/Toyota_Corolla_Hybrid_%28E210%29_IMG_4338.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Tunis-Carthage Airport')),
  ('Toyota', 'Yaris', 2024, 'economy', 110.00, 5, 'automatic', 'gasoline', 'Compact and nimble. Ideal for navigating Tunisian cities and coastal roads.', ARRAY['Parking Sensors', 'Touchscreen Display', 'AC'], 'https://upload.wikimedia.org/wikipedia/commons/3/3e/2020_Toyota_Yaris_Design_HEV_CVT_1.5_Front.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Djerba')),
  ('Kia', 'Sportage', 2025, 'suv', 230.00, 5, 'automatic', 'diesel', 'Bold styling with cutting-edge tech. Great for exploring the Tunisian countryside.', ARRAY['Smart Key', 'Rear Camera', 'Lane Keep Assist'], 'https://upload.wikimedia.org/wikipedia/commons/5/5d/2025_Kia_Sportage_S_front_only.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Sousse')),
  ('Dacia', 'Duster', 2025, 'suv', 130.00, 5, 'manual', 'diesel', 'Rugged, affordable, and ready for adventure. Tunisia''s favourite SUV.', ARRAY['4WD Option', 'Roof Rails', 'Multiview Camera'], 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Dacia_Duster_TCe_130_Extreme_%28III%29_%E2%80%93_f_13102024.jpg', (SELECT id FROM public.locations WHERE name = 'RentTn Djerba'))
ON CONFLICT (make, model, year)
DO UPDATE SET
  category = EXCLUDED.category,
  price_per_day = EXCLUDED.price_per_day,
  seats = EXCLUDED.seats,
  transmission = EXCLUDED.transmission,
  fuel_type = EXCLUDED.fuel_type,
  description = EXCLUDED.description,
  features = EXCLUDED.features,
  image_url = EXCLUDED.image_url,
  location_id = EXCLUDED.location_id,
  updated_at = now();

-- Update existing rows if the table was already seeded before
UPDATE public.cars
SET
  price_per_day = CASE
    WHEN make = 'Tesla' AND model = 'Model 3' THEN 289.00
    WHEN make = 'BMW' AND model = 'M4 Competition' THEN 650.00
    WHEN make = 'Mercedes-Benz' AND model = 'S-Class' THEN 780.00
    WHEN make = 'Toyota' AND model = 'Camry' THEN 165.00
    WHEN make = 'Jeep' AND model = 'Wrangler' THEN 340.00
    WHEN make = 'Porsche' AND model = '911 Carrera' THEN 1100.00
    WHEN make = 'Honda' AND model = 'Civic' THEN 135.00
    WHEN make = 'Rivian' AND model = 'R1S' THEN 520.00
    WHEN make = 'Hyundai' AND model = 'Tucson' THEN 210.00
    WHEN make = 'Hyundai' AND model = 'i10' THEN 95.00
    WHEN make = 'Toyota' AND model = 'Corolla' THEN 150.00
    WHEN make = 'Toyota' AND model = 'Yaris' THEN 110.00
    WHEN make = 'Kia' AND model = 'Sportage' THEN 230.00
    WHEN make = 'Dacia' AND model = 'Duster' THEN 130.00
    ELSE price_per_day
  END,
  deal_discount_percent = CASE
    WHEN make = 'Hyundai' AND model = 'i10' THEN 18.00
    WHEN make = 'Toyota' AND model = 'Yaris' THEN 15.00
    WHEN make = 'Toyota' AND model = 'Corolla' THEN 12.00
    WHEN make = 'Dacia' AND model = 'Duster' THEN 10.00
    WHEN make = 'Kia' AND model = 'Sportage' THEN 10.00
    WHEN make = 'Hyundai' AND model = 'Tucson' THEN 8.00
    WHEN make = 'Honda' AND model = 'Civic' THEN 7.00
    ELSE 0
  END,
  deal_active = CASE
    WHEN make = 'Hyundai' AND model = 'i10' THEN true
    WHEN make = 'Toyota' AND model = 'Yaris' THEN true
    WHEN make = 'Toyota' AND model = 'Corolla' THEN true
    WHEN make = 'Dacia' AND model = 'Duster' THEN true
    WHEN make = 'Kia' AND model = 'Sportage' THEN true
    WHEN make = 'Hyundai' AND model = 'Tucson' THEN true
    WHEN make = 'Honda' AND model = 'Civic' THEN true
    ELSE false
  END,
  image_url = CASE
    WHEN make = 'Tesla' AND model = 'Model 3' THEN 'https://upload.wikimedia.org/wikipedia/commons/9/91/2019_Tesla_Model_3_Performance_AWD_Front.jpg'
    WHEN make = 'BMW' AND model = 'M4 Competition' THEN 'https://upload.wikimedia.org/wikipedia/commons/e/e2/2021_BMW_M4_Competition_Automatic_3.0_Front.jpg'
    WHEN make = 'Mercedes-Benz' AND model = 'S-Class' THEN 'https://upload.wikimedia.org/wikipedia/commons/5/55/Mercedes-Benz_W223_IMG_6663.jpg'
    WHEN make = 'Toyota' AND model = 'Camry' THEN 'https://upload.wikimedia.org/wikipedia/commons/a/ac/2018_Toyota_Camry_%28ASV70R%29_Ascent_sedan_%282018-08-27%29_01.jpg'
    WHEN make = 'Jeep' AND model = 'Wrangler' THEN 'https://upload.wikimedia.org/wikipedia/commons/b/b9/2018_Jeep_Wrangler_Sahara_Unlimited_Multijet_2.1_Front.jpg'
    WHEN make = 'Porsche' AND model = '911 Carrera' THEN 'https://upload.wikimedia.org/wikipedia/commons/a/a2/Porsche_911_No_1000000%2C_70_Years_Porsche_Sports_Car%2C_Berlin_%281X7A3888%29.jpg'
    WHEN make = 'Honda' AND model = 'Civic' THEN 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Honda_Civic_e-HEV_Sport_%28XI%29_%E2%80%93_f_30062024.jpg'
    WHEN make = 'Rivian' AND model = 'R1S' THEN 'https://upload.wikimedia.org/wikipedia/commons/8/89/2023_Rivian_R1S_Adventure%2C_front_1.29.23.jpg'
    WHEN make = 'Hyundai' AND model = 'Tucson' THEN 'https://upload.wikimedia.org/wikipedia/commons/c/c6/2022_Hyundai_Tucson_Preferred%2C_Front_Right%2C_05-24-2021.jpg'
    WHEN make = 'Hyundai' AND model = 'i10' THEN 'https://upload.wikimedia.org/wikipedia/commons/4/44/Hyundai_i10_1.0_Intro_%28III%29_%E2%80%93_f_03012021.jpg'
    WHEN make = 'Toyota' AND model = 'Corolla' THEN 'https://upload.wikimedia.org/wikipedia/commons/f/fe/Toyota_Corolla_Hybrid_%28E210%29_IMG_4338.jpg'
    WHEN make = 'Toyota' AND model = 'Yaris' THEN 'https://upload.wikimedia.org/wikipedia/commons/3/3e/2020_Toyota_Yaris_Design_HEV_CVT_1.5_Front.jpg'
    WHEN make = 'Kia' AND model = 'Sportage' THEN 'https://upload.wikimedia.org/wikipedia/commons/5/5d/2025_Kia_Sportage_S_front_only.jpg'
    WHEN make = 'Dacia' AND model = 'Duster' THEN 'https://upload.wikimedia.org/wikipedia/commons/a/ab/Dacia_Duster_TCe_130_Extreme_%28III%29_%E2%80%93_f_13102024.jpg'
    ELSE image_url
  END;

-- Remove duplicate cars and keep one row per make/model/year
WITH ranked_cars AS (
  SELECT
    id,
    make,
    model,
    year,
    ROW_NUMBER() OVER (PARTITION BY make, model, year ORDER BY created_at ASC, id ASC) AS rn,
    FIRST_VALUE(id) OVER (PARTITION BY make, model, year ORDER BY created_at ASC, id ASC) AS keeper_id
  FROM public.cars
),
duplicate_cars AS (
  SELECT id, keeper_id
  FROM ranked_cars
  WHERE rn > 1
)
UPDATE public.bookings b
SET car_id = d.keeper_id
FROM duplicate_cars d
WHERE b.car_id = d.id;

DELETE FROM public.cars c
USING (
  SELECT id
  FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (PARTITION BY make, model, year ORDER BY created_at ASC, id ASC) AS rn
    FROM public.cars
  ) t
  WHERE t.rn > 1
) d
WHERE c.id = d.id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_cars_make_model_year_unique
ON public.cars (make, model, year);

