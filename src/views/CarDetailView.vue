<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { supabase } from '@/lib/supabaseClient'
import { useBookingStore } from '@/stores/bookingStore'
import { useAuthStore } from '@/stores/authStore'
import { storeToRefs } from 'pinia'
import type { Car } from '@/types/database'
import BookingSummary from '@/components/BookingSummary.vue'
import { formatTnd } from '@/lib/currency'
import {
  ArrowLeft,
  Users,
  Fuel,
  Gauge,
  MapPin,
  Calendar,
  Check,
  ArrowRight,
  Shield,
  Star,
} from 'lucide-vue-next'

const route = useRoute()
const router = useRouter()
const bookingStore = useBookingStore()
const authStore = useAuthStore()
const { isAuthenticated } = storeToRefs(authStore)

const car = ref<Car | null>(null)
const loading = ref(true)

onMounted(async () => {
  try {
    const { data, error } = await supabase
      .from('cars')
      .select('*, locations(*)')
      .eq('id', route.params.id)
      .single()

    if (error) throw error
    car.value = data
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
})

function startBooking() {
  if (!car.value) return
  if (!isAuthenticated.value) {
    router.push({ name: 'login', query: { redirect: `/car/${car.value.id}` } })
    return
  }
  bookingStore.setCar(car.value)
  router.push({ name: 'booking' })
}

function formatCategory(category: string): string {
  return category.charAt(0).toUpperCase() + category.slice(1)
}
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Back button -->
      <button
        @click="router.back()"
        class="flex items-center gap-2 text-sm text-[var(--color-text-muted)] hover:text-white transition-colors mb-8"
      >
        <ArrowLeft class="w-4 h-4" />
        Back to Fleet
      </button>

      <!-- Loading -->
      <div v-if="loading" class="space-y-6">
        <div class="skeleton aspect-[21/9] rounded-2xl"></div>
        <div class="skeleton h-8 w-1/2 rounded"></div>
        <div class="skeleton h-4 w-3/4 rounded"></div>
      </div>

      <!-- Not found -->
      <div v-else-if="!car" class="glass rounded-2xl p-16 text-center">
        <h2 class="text-xl font-bold mb-2">Vehicle not found</h2>
        <p class="text-sm text-[var(--color-text-muted)] mb-4">This vehicle may no longer be available.</p>
        <button @click="router.push('/fleet')" class="btn-primary text-sm">
          <span>Browse Fleet</span>
        </button>
      </div>

      <!-- Car Detail -->
      <div v-else class="space-y-8">
        <!-- Image -->
        <div class="relative rounded-2xl overflow-hidden aspect-[21/9]">
          <img
            :src="car.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=1200'"
            :alt="`${car.make} ${car.model}`"
            class="w-full h-full object-cover"
          />
          <div class="absolute inset-0 bg-gradient-to-t from-[var(--color-navy-950)] via-transparent to-transparent opacity-40"></div>

          <!-- Badges -->
          <div class="absolute top-4 left-4 flex gap-2">
            <span class="badge badge-category">{{ formatCategory(car.category) }}</span>
            <span :class="car.availability ? 'badge-available' : 'badge-unavailable'" class="badge">
              <span class="w-1.5 h-1.5 rounded-full" :class="car.availability ? 'bg-emerald-400' : 'bg-rose-400'"></span>
              {{ car.availability ? 'Available' : 'Reserved' }}
            </span>
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Main Info -->
          <div class="lg:col-span-2 space-y-6">
            <div>
              <h1 class="text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
                {{ car.make }} {{ car.model }}
              </h1>
              <p class="text-[var(--color-text-muted)] mt-1">{{ car.year }}</p>
            </div>

            <p class="text-[var(--color-text-secondary)] leading-relaxed">{{ car.description }}</p>

            <!-- Specs Grid -->
            <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
              <div class="glass p-4 rounded-xl text-center">
                <Users class="w-5 h-5 text-[var(--color-accent-blue)] mx-auto mb-2" />
                <p class="text-sm font-semibold">{{ car.seats }}</p>
                <p class="text-xs text-[var(--color-text-muted)]">Seats</p>
              </div>
              <div class="glass p-4 rounded-xl text-center">
                <Gauge class="w-5 h-5 text-[var(--color-accent-purple)] mx-auto mb-2" />
                <p class="text-sm font-semibold capitalize">{{ car.transmission }}</p>
                <p class="text-xs text-[var(--color-text-muted)]">Transmission</p>
              </div>
              <div class="glass p-4 rounded-xl text-center">
                <Fuel class="w-5 h-5 text-[var(--color-accent-cyan)] mx-auto mb-2" />
                <p class="text-sm font-semibold capitalize">{{ car.fuel_type }}</p>
                <p class="text-xs text-[var(--color-text-muted)]">Fuel Type</p>
              </div>
              <div class="glass p-4 rounded-xl text-center">
                <MapPin class="w-5 h-5 text-[var(--color-accent-emerald)] mx-auto mb-2" />
                <p class="text-sm font-semibold">{{ car.locations?.city || 'N/A' }}</p>
                <p class="text-xs text-[var(--color-text-muted)]">Location</p>
              </div>
            </div>

            <!-- Features -->
            <div v-if="car.features && car.features.length">
              <h3 class="text-lg font-semibold mb-3">Features & Highlights</h3>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-2">
                <div
                  v-for="feature in car.features"
                  :key="feature"
                  class="flex items-center gap-2 text-sm text-[var(--color-text-secondary)]"
                >
                  <Check class="w-4 h-4 text-[var(--color-accent-emerald)]" />
                  {{ feature }}
                </div>
              </div>
            </div>

            <!-- Trust badges -->
            <div class="flex flex-wrap gap-4 pt-4 border-t border-white/5">
              <div class="flex items-center gap-2 text-xs text-[var(--color-text-muted)]">
                <Shield class="w-4 h-4 text-[var(--color-accent-blue)]" />
                Fully insured
              </div>
              <div class="flex items-center gap-2 text-xs text-[var(--color-text-muted)]">
                <Star class="w-4 h-4 text-amber-400" />
                4.9 average rating
              </div>
              <div class="flex items-center gap-2 text-xs text-[var(--color-text-muted)]">
                <Calendar class="w-4 h-4 text-[var(--color-accent-purple)]" />
                Free cancellation
              </div>
            </div>
          </div>

          <!-- Booking Sidebar -->
          <div class="lg:col-span-1">
            <div class="glass-strong rounded-2xl p-6 sticky top-24 space-y-6">
              <div>
                <p class="text-sm text-[var(--color-text-muted)]">Price per day</p>
                <p class="text-3xl font-bold gradient-text">{{ formatTnd(car.price_per_day) }}</p>
              </div>

              <div v-if="car.locations" class="flex items-center gap-2 text-sm text-[var(--color-text-secondary)]">
                <MapPin class="w-4 h-4 text-[var(--color-accent-blue)]" />
                {{ car.locations.name }}
              </div>

              <button
                @click="startBooking"
                :disabled="!car.availability"
                class="btn-primary w-full py-3 text-base"
                :class="{ 'opacity-50 pointer-events-none': !car.availability }"
              >
                <span>{{ car.availability ? 'Book This Vehicle' : 'Currently Reserved' }}</span>
                <ArrowRight v-if="car.availability" class="w-5 h-5" />
              </button>

              <p v-if="!isAuthenticated" class="text-xs text-[var(--color-text-muted)] text-center">
                You'll need to sign in to complete booking
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <BookingSummary />
  </div>
</template>
