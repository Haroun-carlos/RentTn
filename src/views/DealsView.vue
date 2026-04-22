<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Car } from '@/types/database'
import CarCard from '@/components/CarCard.vue'
import { Tag, Sparkles } from 'lucide-vue-next'

const loading = ref(true)
const error = ref<string | null>(null)
const cars = ref<Car[]>([])

const dealCars = computed(() => {
  return cars.value
    .filter((car) => car.availability && (car.deal_active || (car.deal_discount_percent || 0) > 0))
    .sort((a, b) => {
      const aDiscount = a.deal_discount_percent || 0
      const bDiscount = b.deal_discount_percent || 0
      if (bDiscount !== aDiscount) return bDiscount - aDiscount
      return a.price_per_day - b.price_per_day
    })
    .slice(0, 12)
})

const maxSavings = computed(() => {
  if (dealCars.value.length === 0) return 0
  return Math.max(...dealCars.value.map((car) => car.deal_discount_percent || 0))
})

function originalPrice(pricePerDay: number, discount: number): string {
  if (discount <= 0 || discount >= 100) {
    return new Intl.NumberFormat('fr-TN', {
      style: 'currency',
      currency: 'TND',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(pricePerDay)
  }

  const beforeDiscount = pricePerDay / (1 - discount / 100)
  return new Intl.NumberFormat('fr-TN', {
    style: 'currency',
    currency: 'TND',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(beforeDiscount)
}

async function fetchDeals() {
  loading.value = true
  error.value = null

  try {
    const { data, error: fetchError } = await supabase
      .from('cars')
      .select('*, locations(*)')
      .eq('availability', true)
      .order('price_per_day', { ascending: true })

    if (fetchError) throw fetchError
    cars.value = data || []
  } catch (e: any) {
    error.value = e.message || 'Failed to load deals'
  } finally {
    loading.value = false
  }
}

onMounted(fetchDeals)
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="mb-8">
        <div class="flex items-center gap-2 mb-3">
          <Tag class="w-5 h-5 text-[var(--color-accent-emerald)]" />
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-emerald)]">Special Deals</span>
        </div>
        <h1 class="text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
          Best Rates This <span class="gradient-text">Week</span>
        </h1>
        <p class="mt-2 text-[var(--color-text-secondary)]">
          Hand-picked offers on available cars. Book now before prices change.
        </p>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <div class="glass rounded-xl p-4">
          <p class="text-xs text-[var(--color-text-muted)]">Available deals</p>
          <p class="text-2xl font-bold mt-1">{{ dealCars.length }}</p>
        </div>
        <div class="glass rounded-xl p-4">
          <p class="text-xs text-[var(--color-text-muted)]">Max savings</p>
          <p class="text-2xl font-bold mt-1 text-[var(--color-accent-emerald)]">{{ maxSavings }}%</p>
        </div>
        <div class="glass rounded-xl p-4">
          <p class="text-xs text-[var(--color-text-muted)]">Updated</p>
          <p class="text-2xl font-bold mt-1">Live</p>
        </div>
        <div class="glass rounded-xl p-4">
          <p class="text-xs text-[var(--color-text-muted)]">Tip</p>
          <p class="text-sm mt-1 text-[var(--color-text-secondary)]">Reserve early for weekends</p>
        </div>
      </div>

      <div v-if="error" class="glass rounded-2xl p-8 text-center">
        <p class="text-[var(--color-accent-rose)]">{{ error }}</p>
      </div>

      <div v-else-if="loading" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="i in 6" :key="i" class="glass rounded-2xl overflow-hidden">
          <div class="skeleton aspect-[16/10]"></div>
          <div class="p-5 space-y-3">
            <div class="skeleton h-5 w-3/4 rounded"></div>
            <div class="skeleton h-4 w-2/3 rounded"></div>
            <div class="skeleton h-10 w-full rounded-xl"></div>
          </div>
        </div>
      </div>

      <div v-else-if="dealCars.length === 0" class="glass rounded-2xl p-16 text-center">
        <Sparkles class="w-12 h-12 text-[var(--color-text-muted)] mx-auto mb-4" />
        <h3 class="text-lg font-semibold mb-2">No deals available right now</h3>
        <p class="text-sm text-[var(--color-text-muted)]">Check again soon for new promotions.</p>
      </div>

      <div v-else>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="car in dealCars" :key="car.id" class="relative">
            <div class="absolute top-3 right-3 z-10 badge badge-available">
              <Tag class="w-3 h-3" />
              -{{ car.deal_discount_percent || 0 }}%
            </div>
            <div class="absolute top-12 right-3 z-10 text-[11px] px-2 py-1 rounded-md bg-black/50 border border-white/10 text-[var(--color-text-muted)]">
              was {{ originalPrice(car.price_per_day, car.deal_discount_percent || 0) }}
            </div>
            <CarCard :car="car" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
