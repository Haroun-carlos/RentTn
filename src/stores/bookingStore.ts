import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Car, Location, Booking } from '@/types/database'

export const useBookingStore = defineStore('booking', () => {
  // State
  const selectedCar = ref<Car | null>(null)
  const startDate = ref<string>('')
  const endDate = ref<string>('')
  const pickupLocationId = ref<string>('')
  const dropoffLocationId = ref<string>('')
  const locations = ref<Location[]>([])
  const currentStep = ref(1)
  const submitting = ref(false)
  const error = ref<string | null>(null)
  const bookingComplete = ref(false)
  const completedBooking = ref<Booking | null>(null)

  // Getters
  const numberOfDays = computed(() => {
    if (!startDate.value || !endDate.value) return 0
    const start = new Date(startDate.value)
    const end = new Date(endDate.value)
    const diff = end.getTime() - start.getTime()
    return Math.max(0, Math.ceil(diff / (1000 * 60 * 60 * 24)))
  })

  const totalPrice = computed(() => {
    if (!selectedCar.value || numberOfDays.value <= 0) return 0
    return parseFloat((selectedCar.value.price_per_day * numberOfDays.value).toFixed(2))
  })

  const isValid = computed(() => {
    return (
      selectedCar.value !== null &&
      startDate.value !== '' &&
      endDate.value !== '' &&
      numberOfDays.value > 0 &&
      pickupLocationId.value !== ''
    )
  })

  const minStartDate = computed(() => {
    const today = new Date()
    return today.toISOString().split('T')[0]
  })

  const minEndDate = computed(() => {
    if (!startDate.value) return minStartDate.value
    const start = new Date(startDate.value)
    start.setDate(start.getDate() + 1)
    return start.toISOString().split('T')[0]
  })

  // Actions
  function setCar(car: Car) {
    selectedCar.value = car
    currentStep.value = 1
    bookingComplete.value = false
    completedBooking.value = null
    error.value = null
  }

  function setDates(start: string, end: string) {
    startDate.value = start
    endDate.value = end
  }

  function nextStep() {
    if (currentStep.value < 3) {
      currentStep.value++
    }
  }

  function prevStep() {
    if (currentStep.value > 1) {
      currentStep.value--
    }
  }

  function goToStep(step: number) {
    if (step >= 1 && step <= 3) {
      currentStep.value = step
    }
  }

  async function fetchLocations() {
    try {
      const { data, error: fetchError } = await supabase
        .from('locations')
        .select('*')
        .eq('is_active', true)
        .order('city')

      if (fetchError) throw fetchError
      locations.value = data || []
    } catch (e: any) {
      console.error('Error fetching locations:', e.message)
    }
  }

  async function submitBooking() {
    if (!selectedCar.value || !isValid.value) return

    submitting.value = true
    error.value = null

    try {
      const {
        data: { user: sessionUser },
        error: userError,
      } = await supabase.auth.getUser()

      if (userError) throw userError
      if (!sessionUser) throw new Error('Your session expired. Please sign in again.')

      const bookingData = {
        user_id: sessionUser.id,
        car_id: selectedCar.value.id,
        pickup_location_id: pickupLocationId.value || null,
        dropoff_location_id: dropoffLocationId.value || pickupLocationId.value || null,
        start_date: startDate.value,
        end_date: endDate.value,
        total_price: totalPrice.value,
        status: 'confirmed' as const,
      }

      const { data, error: insertError } = await supabase
        .from('bookings')
        .insert(bookingData)
        .select(`
          *,
          cars (*),
          pickup_location:locations!bookings_pickup_location_id_fkey(*),
          dropoff_location:locations!bookings_dropoff_location_id_fkey(*)
        `)
        .single()

      if (insertError) throw insertError

      completedBooking.value = data
      bookingComplete.value = true
      currentStep.value = 3
    } catch (e: any) {
      error.value = e.message || 'Failed to create booking'
      throw e
    } finally {
      submitting.value = false
    }
  }

  function reset() {
    selectedCar.value = null
    startDate.value = ''
    endDate.value = ''
    pickupLocationId.value = ''
    dropoffLocationId.value = ''
    currentStep.value = 1
    submitting.value = false
    error.value = null
    bookingComplete.value = false
    completedBooking.value = null
  }

  return {
    selectedCar,
    startDate,
    endDate,
    pickupLocationId,
    dropoffLocationId,
    locations,
    currentStep,
    submitting,
    error,
    bookingComplete,
    completedBooking,
    numberOfDays,
    totalPrice,
    isValid,
    minStartDate,
    minEndDate,
    setCar,
    setDates,
    nextStep,
    prevStep,
    goToStep,
    fetchLocations,
    submitBooking,
    reset,
  }
})
