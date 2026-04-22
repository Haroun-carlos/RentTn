<script setup lang="ts">
import { ref, watch } from 'vue'
import {
  Search,
  SlidersHorizontal,
  X,
} from 'lucide-vue-next'
import type { CarFilters, CarCategory, Transmission, FuelType } from '@/types/database'

const emit = defineEmits<{
  (e: 'update:filters', filters: Partial<CarFilters>): void
  (e: 'clear'): void
}>()

const searchQuery = ref('')
const selectedCategory = ref<CarCategory | ''>('')
const selectedTransmission = ref<Transmission | ''>('')
const selectedFuelType = ref<FuelType | ''>('')
const showFilters = ref(false)
let searchTimeout: ReturnType<typeof setTimeout> | null = null

const categories: { value: CarCategory | ''; label: string }[] = [
  { value: '', label: 'All Categories' },
  { value: 'economy', label: 'Economy' },
  { value: 'compact', label: 'Compact' },
  { value: 'sedan', label: 'Sedan' },
  { value: 'suv', label: 'SUV' },
  { value: 'luxury', label: 'Luxury' },
  { value: 'sports', label: 'Sports' },
  { value: 'electric', label: 'Electric' },
]

const transmissions: { value: Transmission | ''; label: string }[] = [
  { value: '', label: 'Any' },
  { value: 'automatic', label: 'Automatic' },
  { value: 'manual', label: 'Manual' },
]

const fuelTypes: { value: FuelType | ''; label: string }[] = [
  { value: '', label: 'Any' },
  { value: 'gasoline', label: 'Gasoline' },
  { value: 'diesel', label: 'Diesel' },
  { value: 'electric', label: 'Electric' },
  { value: 'hybrid', label: 'Hybrid' },
]

// Debounced search
watch(searchQuery, (val) => {
  if (searchTimeout) clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    emit('update:filters', { search: val })
  }, 300)
})

function onCategoryChange() {
  emit('update:filters', { category: selectedCategory.value })
}

function onTransmissionChange() {
  emit('update:filters', { transmission: selectedTransmission.value })
}

function onFuelTypeChange() {
  emit('update:filters', { fuel_type: selectedFuelType.value })
}

function clearAll() {
  searchQuery.value = ''
  selectedCategory.value = ''
  selectedTransmission.value = ''
  selectedFuelType.value = ''
  emit('clear')
}

const hasActiveFilters = () => {
  return searchQuery.value || selectedCategory.value || selectedTransmission.value || selectedFuelType.value
}
</script>

<template>
  <div class="space-y-4">
    <!-- Search + Toggle -->
    <div class="flex gap-3">
      <div class="flex-1 relative">
        <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)]" />
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search by make, model, or description..."
          class="input-glass pl-10 pr-4"
        />
      </div>
      <button
        @click="showFilters = !showFilters"
        class="btn-secondary px-3 flex items-center gap-2"
        :class="{ '!border-[var(--color-accent-blue)] !text-[var(--color-accent-blue)]': showFilters || hasActiveFilters() }"
      >
        <SlidersHorizontal class="w-4 h-4" />
        <span class="hidden sm:inline">Filters</span>
      </button>
      <button
        v-if="hasActiveFilters()"
        @click="clearAll"
        class="btn-secondary px-3 flex items-center gap-2 text-[var(--color-accent-rose)]"
      >
        <X class="w-4 h-4" />
        <span class="hidden sm:inline">Clear</span>
      </button>
    </div>

    <!-- Filter Panel -->
    <Transition name="page">
      <div v-if="showFilters" class="glass rounded-xl p-4 animate-fade-in">
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <!-- Category -->
          <div>
            <label class="block text-xs font-medium text-[var(--color-text-muted)] mb-1.5 uppercase tracking-wider">Category</label>
            <select
              v-model="selectedCategory"
              @change="onCategoryChange"
              class="input-glass text-sm"
            >
              <option v-for="cat in categories" :key="cat.value" :value="cat.value">
                {{ cat.label }}
              </option>
            </select>
          </div>

          <!-- Transmission -->
          <div>
            <label class="block text-xs font-medium text-[var(--color-text-muted)] mb-1.5 uppercase tracking-wider">Transmission</label>
            <select
              v-model="selectedTransmission"
              @change="onTransmissionChange"
              class="input-glass text-sm"
            >
              <option v-for="t in transmissions" :key="t.value" :value="t.value">
                {{ t.label }}
              </option>
            </select>
          </div>

          <!-- Fuel Type -->
          <div>
            <label class="block text-xs font-medium text-[var(--color-text-muted)] mb-1.5 uppercase tracking-wider">Fuel Type</label>
            <select
              v-model="selectedFuelType"
              @change="onFuelTypeChange"
              class="input-glass text-sm"
            >
              <option v-for="f in fuelTypes" :key="f.value" :value="f.value">
                {{ f.label }}
              </option>
            </select>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>
