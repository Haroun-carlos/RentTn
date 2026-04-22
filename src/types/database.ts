// ============================================
// RentTn TypeScript Interfaces
// Mirrors the PostgreSQL schema exactly
// ============================================

export interface Profile {
  id: string
  full_name: string | null
  phone: string | null
  avatar_url: string | null
  driver_license_number: string | null
  date_of_birth: string | null
  created_at: string
  updated_at: string
}

export interface Location {
  id: string
  name: string
  address: string
  city: string
  country: string
  latitude: number | null
  longitude: number | null
  is_active: boolean
  created_at: string
}

export type CarCategory = 'economy' | 'compact' | 'sedan' | 'suv' | 'luxury' | 'sports' | 'electric'
export type Transmission = 'automatic' | 'manual'
export type FuelType = 'gasoline' | 'diesel' | 'electric' | 'hybrid'

export interface Car {
  id: string
  make: string
  model: string
  year: number
  category: CarCategory
  price_per_day: number
  deal_discount_percent?: number
  deal_active?: boolean
  image_url: string | null
  description: string | null
  seats: number
  transmission: Transmission
  fuel_type: FuelType
  availability: boolean
  location_id: string | null
  features: string[]
  created_at: string
  updated_at: string
  // Joined data
  locations?: Location
}

export type BookingStatus = 'pending' | 'confirmed' | 'active' | 'completed' | 'cancelled'

export interface Booking {
  id: string
  user_id: string
  car_id: string
  pickup_location_id: string | null
  dropoff_location_id: string | null
  start_date: string
  end_date: string
  total_price: number
  status: BookingStatus
  created_at: string
  updated_at: string
  // Joined data
  cars?: Car
  pickup_location?: Location
  dropoff_location?: Location
}

// Filter types for the search
export interface CarFilters {
  search: string
  category: CarCategory | ''
  transmission: Transmission | ''
  fuel_type: FuelType | ''
  min_price: number | null
  max_price: number | null
}
