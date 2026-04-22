<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Location, Car } from '@/types/database'
import { MapPin, Car as CarIcon, Phone } from 'lucide-vue-next'

interface LocationWithStats extends Location {
  totalCars: number
  availableCars: number
}

const loading = ref(true)
const error = ref<string | null>(null)
const locations = ref<LocationWithStats[]>([])

function buildPhoneByCity(city: string): string {
  const map: Record<string, string> = {
    Tunis: '+216 71 234 500',
    Sousse: '+216 73 234 500',
    Monastir: '+216 73 520 500',
    Hammamet: '+216 72 234 500',
    Djerba: '+216 75 234 500',
  }
  return map[city] || '+216 12 345 678'
}

async function fetchLocationsWithStats() {
  loading.value = true
  error.value = null

  try {
    const [{ data: locationsData, error: locationsError }, { data: carsData, error: carsError }] = await Promise.all([
      supabase.from('locations').select('*').eq('is_active', true).order('city', { ascending: true }),
      supabase.from('cars').select('location_id, availability'),
    ])

    if (locationsError) throw locationsError
    if (carsError) throw carsError

    const rawLocations = (locationsData || []) as Location[]
    const rawCars = (carsData || []) as Pick<Car, 'location_id' | 'availability'>[]

    locations.value = rawLocations.map((location) => {
      const carsAtLocation = rawCars.filter((car) => car.location_id === location.id)
      const availableCars = carsAtLocation.filter((car) => car.availability).length

      return {
        ...location,
        totalCars: carsAtLocation.length,
        availableCars,
      }
    })
  } catch (e: any) {
    error.value = e.message || 'Failed to load locations'
  } finally {
    loading.value = false
  }
}

onMounted(fetchLocationsWithStats)
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="mb-8">
        <div class="flex items-center gap-2 mb-3">
          <MapPin class="w-5 h-5 text-[var(--color-accent-blue)]" />
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-blue)]">Our Locations</span>
        </div>
        <h1 class="text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
          Pickup Points Across <span class="gradient-text">Tunisia</span>
        </h1>
        <p class="mt-2 text-[var(--color-text-secondary)]">
          Choose the nearest branch and start your booking in minutes.
        </p>
      </div>

      <div v-if="error" class="glass rounded-2xl p-8 text-center">
        <p class="text-[var(--color-accent-rose)]">{{ error }}</p>
      </div>

      <div v-else-if="loading" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <div v-for="i in 6" :key="i" class="glass rounded-2xl p-6 space-y-3">
          <div class="skeleton h-5 w-2/3 rounded"></div>
          <div class="skeleton h-4 w-full rounded"></div>
          <div class="skeleton h-4 w-4/5 rounded"></div>
          <div class="skeleton h-8 w-1/2 rounded"></div>
        </div>
      </div>

      <div v-else class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
        <article
          v-for="location in locations"
          :key="location.id"
          class="glass glass-hover rounded-2xl p-6 transition-all duration-300"
        >
          <div class="flex items-start justify-between gap-4">
            <div>
              <h2 class="text-xl font-semibold font-[var(--font-heading)] text-white">{{ location.name }}</h2>
              <p class="mt-1 text-sm text-[var(--color-text-secondary)]">{{ location.city }}, {{ location.country }}</p>
            </div>
            <span class="badge badge-category">{{ location.city }}</span>
          </div>

          <p class="mt-4 text-sm text-[var(--color-text-muted)] leading-relaxed">{{ location.address }}</p>

          <div class="mt-5 pt-5 border-t border-white/5 space-y-3">
            <div class="flex items-center justify-between text-sm">
              <span class="text-[var(--color-text-muted)] flex items-center gap-1.5">
                <CarIcon class="w-4 h-4" />
                Fleet at branch
              </span>
              <span class="font-semibold text-white">{{ location.availableCars }} / {{ location.totalCars }}</span>
            </div>

            <div class="flex items-center justify-between text-sm">
              <span class="text-[var(--color-text-muted)] flex items-center gap-1.5">
                <Phone class="w-4 h-4" />
                Contact
              </span>
              <a :href="`tel:${buildPhoneByCity(location.city)}`" class="text-[var(--color-accent-blue)] hover:underline">
                {{ buildPhoneByCity(location.city) }}
              </a>
            </div>
          </div>
        </article>
      </div>
    </div>
  </div>
</template>
