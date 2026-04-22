import { computed } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import { useAuthStore } from '@/stores/authStore'
import type { Booking } from '@/types/database'
import { ref } from 'vue'

export function useBookings() {
  const bookings = ref<Booking[]>([])
  const loading = ref(true)
  const error = ref<string | null>(null)

  async function fetchUserBookings() {
    const authStore = useAuthStore()
    if (!authStore.user) return

    loading.value = true
    error.value = null

    try {
      const { data, error: fetchError } = await supabase
        .from('bookings')
        .select(`
          *,
          cars (*),
          pickup_location:locations!bookings_pickup_location_id_fkey(*),
          dropoff_location:locations!bookings_dropoff_location_id_fkey(*)
        `)
        .eq('user_id', authStore.user.id)
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError
      bookings.value = data || []
    } catch (e: any) {
      error.value = e.message || 'Failed to load bookings'
    } finally {
      loading.value = false
    }
  }

  async function cancelBooking(bookingId: string) {
    try {
      const { error: updateError } = await supabase
        .from('bookings')
        .update({ status: 'cancelled' })
        .eq('id', bookingId)

      if (updateError) throw updateError

      // Update local state
      const index = bookings.value.findIndex((b) => b.id === bookingId)
      if (index !== -1) {
        bookings.value[index] = { ...bookings.value[index], status: 'cancelled' }
      }
    } catch (e: any) {
      error.value = e.message || 'Failed to cancel booking'
      throw e
    }
  }

  const activeBookings = computed(() =>
    bookings.value.filter((b) => ['pending', 'confirmed', 'active'].includes(b.status))
  )

  const pastBookings = computed(() =>
    bookings.value.filter((b) => ['completed', 'cancelled'].includes(b.status))
  )

  return {
    bookings,
    loading,
    error,
    activeBookings,
    pastBookings,
    fetchUserBookings,
    cancelBooking,
  }
}
