import { ref, onUnmounted } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Car, CarFilters } from '@/types/database'

export function useRealtimeCars() {
  const cars = ref<Car[]>([])
  const loading = ref(true)
  const error = ref<string | null>(null)
  const recentlyUpdated = ref<Set<string>>(new Set())

  const filters = ref<CarFilters>({
    search: '',
    category: '',
    transmission: '',
    fuel_type: '',
    min_price: null,
    max_price: null,
  })

  // Fetch cars with filters
  async function fetchCars() {
    loading.value = true
    error.value = null

    try {
      let query = supabase
        .from('cars')
        .select('*, locations(*)')
        .order('price_per_day', { ascending: true })

      // Apply search filter
      if (filters.value.search) {
        query = query.or(
          `make.ilike.%${filters.value.search}%,model.ilike.%${filters.value.search}%,description.ilike.%${filters.value.search}%`
        )
      }

      // Apply category filter
      if (filters.value.category) {
        query = query.eq('category', filters.value.category)
      }

      // Apply transmission filter
      if (filters.value.transmission) {
        query = query.eq('transmission', filters.value.transmission)
      }

      // Apply fuel type filter
      if (filters.value.fuel_type) {
        query = query.eq('fuel_type', filters.value.fuel_type)
      }

      // Apply price range
      if (filters.value.min_price !== null) {
        query = query.gte('price_per_day', filters.value.min_price)
      }
      if (filters.value.max_price !== null) {
        query = query.lte('price_per_day', filters.value.max_price)
      }

      const { data, error: fetchError } = await query

      if (fetchError) throw fetchError
      cars.value = data || []
    } catch (e: any) {
      error.value = e.message || 'Failed to load cars'
      console.error('Error fetching cars:', e.message)
    } finally {
      loading.value = false
    }
  }

  // Set up realtime subscription
  const channel = supabase
    .channel('cars-realtime')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'cars' },
      (payload) => {
        const { eventType, new: newRecord, old: oldRecord } = payload

        if (eventType === 'INSERT') {
          cars.value.push(newRecord as Car)
          highlightCar(newRecord.id as string)
        }

        if (eventType === 'UPDATE') {
          const index = cars.value.findIndex((c) => c.id === (oldRecord as Car).id)
          if (index !== -1) {
            cars.value[index] = { ...cars.value[index], ...newRecord as Car }
            highlightCar((newRecord as Car).id)
          }
        }

        if (eventType === 'DELETE') {
          cars.value = cars.value.filter((c) => c.id !== (oldRecord as Car).id)
        }
      }
    )
    .subscribe()

  // Highlight recently updated cars
  function highlightCar(carId: string) {
    recentlyUpdated.value.add(carId)
    setTimeout(() => {
      recentlyUpdated.value.delete(carId)
    }, 3000)
  }

  function isRecentlyUpdated(carId: string) {
    return recentlyUpdated.value.has(carId)
  }

  // Update filters and re-fetch
  function updateFilters(newFilters: Partial<CarFilters>) {
    filters.value = { ...filters.value, ...newFilters }
    fetchCars()
  }

  function clearFilters() {
    filters.value = {
      search: '',
      category: '',
      transmission: '',
      fuel_type: '',
      min_price: null,
      max_price: null,
    }
    fetchCars()
  }

  // Cleanup on unmount
  onUnmounted(() => {
    supabase.removeChannel(channel)
  })

  // Fetch initial data
  fetchCars()

  return {
    cars,
    loading,
    error,
    filters,
    fetchCars,
    updateFilters,
    clearFilters,
    isRecentlyUpdated,
  }
}
