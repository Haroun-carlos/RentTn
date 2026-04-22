<script setup lang="ts">
import { useRealtimeCars } from '@/composables/useRealtimeCars'
import CarCard from '@/components/CarCard.vue'
import CarSearch from '@/components/CarSearch.vue'
import BookingSummary from '@/components/BookingSummary.vue'
import {
  Car,
  Wifi,
} from 'lucide-vue-next'
import type { CarFilters } from '@/types/database'

const {
  cars,
  loading,
  error,
  updateFilters,
  clearFilters,
  isRecentlyUpdated,
} = useRealtimeCars()

function onUpdateFilters(filters: Partial<CarFilters>) {
  updateFilters(filters)
}
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="mb-8">
        <div class="flex items-center gap-2 mb-3">
          <Car class="w-5 h-5 text-[var(--color-accent-blue)]" />
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-blue)]">Our Fleet</span>
        </div>
        <div class="flex items-end justify-between">
          <div>
            <h1 class="text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
              Browse <span class="gradient-text">Vehicles</span>
            </h1>
            <p class="mt-2 text-[var(--color-text-secondary)]">
              Real-time availability. Book instantly.
            </p>
          </div>
          <div class="hidden sm:flex items-center gap-2 text-xs text-[var(--color-accent-emerald)]">
            <Wifi class="w-3.5 h-3.5" />
            <span>Live updates</span>
          </div>
        </div>
      </div>

      <!-- Search & Filters -->
      <div class="mb-8">
        <CarSearch
          @update:filters="onUpdateFilters"
          @clear="clearFilters"
        />
      </div>

      <!-- Error State -->
      <div v-if="error" class="glass rounded-2xl p-8 text-center">
        <p class="text-[var(--color-accent-rose)]">{{ error }}</p>
        <button @click="clearFilters" class="btn-primary mt-4 text-sm">
          <span>Try Again</span>
        </button>
      </div>

      <!-- Loading State -->
      <div v-else-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 6" :key="i" class="glass rounded-2xl overflow-hidden">
          <div class="skeleton aspect-[16/10]"></div>
          <div class="p-5 space-y-3">
            <div class="skeleton h-5 w-3/4 rounded"></div>
            <div class="skeleton h-3 w-1/2 rounded"></div>
            <div class="flex gap-3">
              <div class="skeleton h-3 w-16 rounded"></div>
              <div class="skeleton h-3 w-16 rounded"></div>
              <div class="skeleton h-3 w-16 rounded"></div>
            </div>
            <div class="skeleton h-10 w-full rounded-xl"></div>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="cars.length === 0" class="glass rounded-2xl p-16 text-center">
        <Car class="w-12 h-12 text-[var(--color-text-muted)] mx-auto mb-4" />
        <h3 class="text-lg font-semibold mb-2">No vehicles found</h3>
        <p class="text-sm text-[var(--color-text-muted)] mb-4">Try adjusting your search or filters.</p>
        <button @click="clearFilters" class="btn-secondary text-sm">
          <span>Clear Filters</span>
        </button>
      </div>

      <!-- Cars Grid -->
      <div v-else>
        <p class="text-sm text-[var(--color-text-muted)] mb-4">{{ cars.length }} vehicle{{ cars.length !== 1 ? 's' : '' }} found</p>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <CarCard
            v-for="car in cars"
            :key="car.id"
            :car="car"
            :highlighted="isRecentlyUpdated(car.id)"
          />
        </div>
      </div>
    </div>

    <!-- Mobile Booking Summary -->
    <BookingSummary />
  </div>
</template>
