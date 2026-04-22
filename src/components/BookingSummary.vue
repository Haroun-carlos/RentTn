<script setup lang="ts">
import { computed } from 'vue'
import { storeToRefs } from 'pinia'
import { useBookingStore } from '@/stores/bookingStore'
import { useRouter } from 'vue-router'
import {
  Calendar,
  MapPin,
  DollarSign,
  ArrowRight,
  X,
} from 'lucide-vue-next'
import { formatTnd } from '@/lib/currency'

const bookingStore = useBookingStore()
const router = useRouter()
const {
  selectedCar,
  startDate,
  endDate,
  numberOfDays,
  totalPrice,
  currentStep,
  bookingComplete,
} = storeToRefs(bookingStore)

const isVisible = computed(() => selectedCar.value !== null && !bookingComplete.value)

function goToBooking() {
  router.push({ name: 'booking' })
}

function dismiss() {
  bookingStore.reset()
}
</script>

<template>
  <Transition name="page">
    <div
      v-if="isVisible"
      class="fixed bottom-0 left-0 right-0 z-40 md:hidden"
    >
      <div class="glass-strong mx-3 mb-3 rounded-2xl p-4 shadow-2xl shadow-black/50 border border-white/10">
        <div class="flex items-center justify-between mb-3">
          <div class="flex items-center gap-2">
            <img
              :src="selectedCar!.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200'"
              :alt="selectedCar!.make"
              class="w-10 h-10 rounded-lg object-cover"
            />
            <div>
              <p class="text-sm font-semibold text-white">{{ selectedCar!.make }} {{ selectedCar!.model }}</p>
              <p class="text-xs text-[var(--color-text-muted)]">{{ formatTnd(selectedCar!.price_per_day) }}/day</p>
            </div>
          </div>
          <button @click="dismiss" class="p-1 hover:bg-white/10 rounded-lg transition-colors">
            <X class="w-4 h-4 text-[var(--color-text-muted)]" />
          </button>
        </div>

        <!-- Quick summary -->
        <div v-if="startDate && endDate" class="flex items-center gap-4 text-xs text-[var(--color-text-muted)] mb-3">
          <div class="flex items-center gap-1">
            <Calendar class="w-3 h-3" />
            <span>{{ numberOfDays }} day{{ numberOfDays !== 1 ? 's' : '' }}</span>
          </div>
          <div class="flex items-center gap-1">
            <DollarSign class="w-3 h-3" />
            <span class="text-white font-semibold">{{ formatTnd(totalPrice) }}</span>
          </div>
        </div>

        <button @click="goToBooking" class="btn-primary w-full text-sm py-2.5 rounded-xl">
          <span>Continue Booking</span>
          <ArrowRight class="w-4 h-4" />
        </button>
      </div>
    </div>
  </Transition>
</template>
