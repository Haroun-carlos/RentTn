<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { useBookings } from '@/composables/useBookings'
import {
  CalendarDays,
  Car,
  MapPin,
  Clock,
  XCircle,
  ArrowRight,
} from 'lucide-vue-next'
import { formatTnd } from '@/lib/currency'

const {
  bookings,
  loading,
  error,
  activeBookings,
  pastBookings,
  fetchUserBookings,
  cancelBooking,
} = useBookings()

onMounted(() => {
  fetchUserBookings()
})

function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('en-US', { dateStyle: 'medium' })
}

function getStatusBadgeClass(status: string): string {
  const map: Record<string, string> = {
    pending: 'badge-pending',
    confirmed: 'badge-confirmed',
    active: 'badge-active',
    completed: 'badge-completed',
    cancelled: 'badge-cancelled',
  }
  return map[status] || 'badge-category'
}

async function handleCancel(bookingId: string) {
  if (!confirm('Are you sure you want to cancel this booking?')) return
  try {
    await cancelBooking(bookingId)
  } catch (e) {
    // error handled in composable
  }
}
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="mb-8">
        <div class="flex items-center gap-2 mb-3">
          <CalendarDays class="w-5 h-5 text-[var(--color-accent-blue)]" />
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-blue)]">My Bookings</span>
        </div>
        <h1 class="text-3xl font-bold font-[var(--font-heading)]">
          Booking <span class="gradient-text">History</span>
        </h1>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="space-y-4">
        <div v-for="i in 3" :key="i" class="glass rounded-2xl p-6">
          <div class="flex gap-4">
            <div class="skeleton w-20 h-20 rounded-xl"></div>
            <div class="flex-1 space-y-2">
              <div class="skeleton h-5 w-1/3 rounded"></div>
              <div class="skeleton h-3 w-1/2 rounded"></div>
              <div class="skeleton h-3 w-1/4 rounded"></div>
            </div>
          </div>
        </div>
      </div>

      <!-- Error -->
      <div v-else-if="error" class="glass rounded-2xl p-8 text-center">
        <p class="text-[var(--color-accent-rose)]">{{ error }}</p>
      </div>

      <!-- Empty -->
      <div v-else-if="bookings.length === 0" class="glass rounded-2xl p-16 text-center">
        <Car class="w-12 h-12 text-[var(--color-text-muted)] mx-auto mb-4" />
        <h3 class="text-lg font-semibold mb-2">No bookings yet</h3>
        <p class="text-sm text-[var(--color-text-muted)] mb-6">Browse our fleet and book your first ride!</p>
        <RouterLink to="/fleet" class="btn-primary text-sm">
          <span>Browse Fleet</span>
          <ArrowRight class="w-4 h-4" />
        </RouterLink>
      </div>

      <!-- Bookings List -->
      <div v-else class="space-y-8">
        <!-- Active Bookings -->
        <div v-if="activeBookings.length > 0">
          <h2 class="text-lg font-semibold mb-4 flex items-center gap-2">
            <Clock class="w-4 h-4 text-[var(--color-accent-emerald)]" />
            Active Bookings
          </h2>
          <div class="space-y-4">
            <div
              v-for="booking in activeBookings"
              :key="booking.id"
              class="glass glass-hover rounded-2xl p-5 transition-all duration-300"
            >
              <div class="flex flex-col sm:flex-row gap-4">
                <!-- Car Image -->
                <img
                  :src="booking.cars?.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200'"
                  :alt="booking.cars?.make"
                  class="w-full sm:w-24 h-32 sm:h-24 rounded-xl object-cover"
                />

                <!-- Details -->
                <div class="flex-1 space-y-2">
                  <div class="flex items-start justify-between">
                    <div>
                      <h3 class="font-semibold">{{ booking.cars?.make }} {{ booking.cars?.model }}</h3>
                      <p class="text-xs text-[var(--color-text-muted)]">{{ booking.cars?.year }}</p>
                    </div>
                    <span :class="getStatusBadgeClass(booking.status)" class="badge text-xs capitalize">
                      {{ booking.status }}
                    </span>
                  </div>

                  <div class="flex flex-wrap gap-4 text-xs text-[var(--color-text-muted)]">
                    <div class="flex items-center gap-1">
                      <CalendarDays class="w-3 h-3" />
                      <span>{{ formatDate(booking.start_date) }} → {{ formatDate(booking.end_date) }}</span>
                    </div>
                    <div class="flex items-center gap-1">
                      <MapPin class="w-3 h-3" />
                      <span>{{ booking.pickup_location?.name || 'N/A' }}</span>
                    </div>
                  </div>

                  <div class="flex items-center justify-between pt-2">
                    <p class="text-lg font-bold gradient-text">{{ formatTnd(booking.total_price) }}</p>
                    <button
                      v-if="booking.status !== 'cancelled'"
                      @click="handleCancel(booking.id)"
                      class="flex items-center gap-1 text-xs text-[var(--color-accent-rose)] hover:underline"
                    >
                      <XCircle class="w-3 h-3" />
                      Cancel
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Past Bookings -->
        <div v-if="pastBookings.length > 0">
          <h2 class="text-lg font-semibold mb-4 text-[var(--color-text-muted)]">Past Bookings</h2>
          <div class="space-y-4">
            <div
              v-for="booking in pastBookings"
              :key="booking.id"
              class="glass rounded-2xl p-5 opacity-60"
            >
              <div class="flex flex-col sm:flex-row gap-4">
                <img
                  :src="booking.cars?.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200'"
                  :alt="booking.cars?.make"
                  class="w-full sm:w-24 h-32 sm:h-24 rounded-xl object-cover"
                />
                <div class="flex-1 space-y-2">
                  <div class="flex items-start justify-between">
                    <div>
                      <h3 class="font-semibold">{{ booking.cars?.make }} {{ booking.cars?.model }}</h3>
                      <p class="text-xs text-[var(--color-text-muted)]">{{ booking.cars?.year }}</p>
                    </div>
                    <span :class="getStatusBadgeClass(booking.status)" class="badge text-xs capitalize">
                      {{ booking.status }}
                    </span>
                  </div>
                  <div class="flex flex-wrap gap-4 text-xs text-[var(--color-text-muted)]">
                    <div class="flex items-center gap-1">
                      <CalendarDays class="w-3 h-3" />
                      <span>{{ formatDate(booking.start_date) }} → {{ formatDate(booking.end_date) }}</span>
                    </div>
                  </div>
                  <p class="text-lg font-bold text-[var(--color-text-muted)]">{{ formatTnd(booking.total_price) }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
