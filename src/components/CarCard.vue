<script setup lang="ts">
import { RouterLink } from 'vue-router'
import {
  Users,
  Fuel,
  Gauge,
  MapPin,
  ArrowRight,
} from 'lucide-vue-next'
import type { Car } from '@/types/database'
import { formatTnd } from '@/lib/currency'

interface Props {
  car: Car
  highlighted?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  highlighted: false,
})

function formatCategory(category: string): string {
  return category.charAt(0).toUpperCase() + category.slice(1)
}

function formatFuelType(fuel: string): string {
  return fuel.charAt(0).toUpperCase() + fuel.slice(1)
}
</script>

<template>
  <div
    class="group glass glass-hover rounded-2xl overflow-hidden transition-all duration-500 hover:shadow-2xl hover:shadow-blue-500/10 hover:-translate-y-1"
    :class="{ 'ring-2 ring-emerald-500/50 animate-pulse-glow': highlighted }"
  >
    <!-- Image Container -->
    <div class="relative aspect-[16/10] overflow-hidden">
      <img
        :src="car.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800'"
        :alt="`${car.make} ${car.model}`"
        class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
      />
      <!-- Overlay gradient -->
      <div class="absolute inset-0 bg-gradient-to-t from-[var(--color-navy-950)] via-transparent to-transparent opacity-60"></div>

      <!-- Availability Badge -->
      <div class="absolute top-3 right-3">
        <span
          :class="car.availability ? 'badge-available' : 'badge-unavailable'"
          class="badge text-xs"
        >
          <span class="w-1.5 h-1.5 rounded-full" :class="car.availability ? 'bg-emerald-400' : 'bg-rose-400'"></span>
          {{ car.availability ? 'Available' : 'Reserved' }}
        </span>
      </div>

      <!-- Category Badge -->
      <div class="absolute top-3 left-3">
        <span class="badge badge-category text-xs">
          {{ formatCategory(car.category) }}
        </span>
      </div>

      <!-- Price on image -->
      <div class="absolute bottom-3 left-3">
        <div class="glass rounded-lg px-3 py-1.5">
          <span class="text-xl font-bold text-white">{{ formatTnd(car.price_per_day) }}</span>
          <span class="text-xs text-[var(--color-text-muted)]">/day</span>
        </div>
      </div>
    </div>

    <!-- Content -->
    <div class="p-5 space-y-4">
      <!-- Title -->
      <div>
        <h3 class="text-lg font-bold font-[var(--font-heading)] text-white group-hover:gradient-text transition-all duration-300">
          {{ car.make }} {{ car.model }}
        </h3>
        <p class="text-xs text-[var(--color-text-muted)] mt-0.5">{{ car.year }}</p>
      </div>

      <!-- Specs Row -->
      <div class="flex items-center gap-4 text-xs text-[var(--color-text-muted)]">
        <div class="flex items-center gap-1">
          <Users class="w-3.5 h-3.5 text-[var(--color-accent-blue)]" />
          <span>{{ car.seats }} seats</span>
        </div>
        <div class="flex items-center gap-1">
          <Gauge class="w-3.5 h-3.5 text-[var(--color-accent-blue)]" />
          <span class="capitalize">{{ car.transmission }}</span>
        </div>
        <div class="flex items-center gap-1">
          <Fuel class="w-3.5 h-3.5 text-[var(--color-accent-blue)]" />
          <span>{{ formatFuelType(car.fuel_type) }}</span>
        </div>
      </div>

      <!-- Location -->
      <div v-if="car.locations" class="flex items-center gap-1 text-xs text-[var(--color-text-muted)]">
        <MapPin class="w-3.5 h-3.5 text-[var(--color-accent-purple)]" />
        <span>{{ car.locations.name }}</span>
      </div>

      <!-- Features Tags -->
      <div v-if="car.features && car.features.length" class="flex flex-wrap gap-1.5">
        <span
          v-for="feature in car.features.slice(0, 3)"
          :key="feature"
          class="px-2 py-0.5 rounded-md text-xs bg-white/5 text-[var(--color-text-muted)] border border-white/5"
        >
          {{ feature }}
        </span>
      </div>

      <!-- Action -->
      <RouterLink
        :to="`/car/${car.id}`"
        class="btn-primary w-full text-sm py-2.5 rounded-xl"
        :class="{ 'opacity-50 pointer-events-none': !car.availability }"
      >
        <span>{{ car.availability ? 'View Details' : 'Currently Reserved' }}</span>
        <ArrowRight v-if="car.availability" class="w-4 h-4" />
      </RouterLink>
    </div>
  </div>
</template>
