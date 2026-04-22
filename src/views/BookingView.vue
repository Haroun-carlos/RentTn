<script setup lang="ts">
import { onMounted, watch } from 'vue'
import { storeToRefs } from 'pinia'
import { useRouter } from 'vue-router'
import { useBookingStore } from '@/stores/bookingStore'
import {
  Calendar,
  MapPin,
  CreditCard,
  Check,
  ArrowRight,
  ArrowLeft,
  Car,
  Clock,
  DollarSign,
  CheckCircle,
  PartyPopper,
} from 'lucide-vue-next'
import { formatTnd } from '@/lib/currency'

const router = useRouter()
const bookingStore = useBookingStore()
const {
  selectedCar,
  startDate,
  endDate,
  pickupLocationId,
  dropoffLocationId,
  locations,
  currentStep,
  numberOfDays,
  totalPrice,
  isValid,
  minStartDate,
  minEndDate,
  submitting,
  error,
  bookingComplete,
  completedBooking,
} = storeToRefs(bookingStore)

onMounted(() => {
  if (!selectedCar.value) {
    router.push({ name: 'fleet' })
    return
  }
  bookingStore.fetchLocations()
})

// Auto-set dropoff to pickup if not set
watch(pickupLocationId, (val) => {
  if (val && !dropoffLocationId.value) {
    dropoffLocationId.value = val
  }
})

async function handleConfirm() {
  try {
    await bookingStore.submitBooking()
  } catch (e) {
    // error is set in store
  }
}

function goToMyBookings() {
  bookingStore.reset()
  router.push({ name: 'my-bookings' })
}

function bookAnother() {
  bookingStore.reset()
  router.push({ name: 'fleet' })
}

const steps = [
  { num: 1, label: 'Dates & Location', icon: Calendar },
  { num: 2, label: 'Review', icon: CreditCard },
  { num: 3, label: 'Confirmation', icon: Check },
]
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="mb-8">
        <button
          @click="router.back()"
          class="flex items-center gap-2 text-sm text-[var(--color-text-muted)] hover:text-white transition-colors mb-4"
        >
          <ArrowLeft class="w-4 h-4" />
          Back
        </button>
        <h1 class="text-3xl font-bold font-[var(--font-heading)]">
          Book Your <span class="gradient-text">Ride</span>
        </h1>
      </div>

      <!-- Steps Indicator -->
      <div class="flex items-center justify-between mb-10">
        <template v-for="(step, i) in steps" :key="step.num">
          <div class="flex items-center gap-2">
            <div
              class="w-9 h-9 rounded-full flex items-center justify-center text-sm font-semibold transition-all duration-300"
              :class="
                currentStep >= step.num
                  ? 'bg-gradient-to-r from-blue-500 to-purple-500 text-white'
                  : 'glass text-[var(--color-text-muted)]'
              "
            >
              <Check v-if="currentStep > step.num" class="w-4 h-4" />
              <span v-else>{{ step.num }}</span>
            </div>
            <span
              class="text-sm hidden sm:inline transition-colors"
              :class="currentStep >= step.num ? 'text-white font-medium' : 'text-[var(--color-text-muted)]'"
            >
              {{ step.label }}
            </span>
          </div>
          <div
            v-if="i < steps.length - 1"
            class="flex-1 h-px mx-4 transition-colors duration-300"
            :class="currentStep > step.num ? 'bg-blue-500' : 'bg-white/10'"
          ></div>
        </template>
      </div>

      <!-- Selected Car Summary -->
      <div v-if="selectedCar && !bookingComplete" class="glass rounded-xl p-4 mb-8 flex items-center gap-4">
        <img
          :src="selectedCar.image_url || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=200'"
          :alt="selectedCar.make"
          class="w-16 h-16 rounded-lg object-cover"
        />
        <div class="flex-1">
          <p class="font-semibold">{{ selectedCar.make }} {{ selectedCar.model }}</p>
          <p class="text-xs text-[var(--color-text-muted)]">{{ selectedCar.year }} · {{ selectedCar.category }}</p>
        </div>
        <div class="text-right">
          <p class="text-lg font-bold gradient-text">{{ formatTnd(selectedCar.price_per_day) }}</p>
          <p class="text-xs text-[var(--color-text-muted)]">/day</p>
        </div>
      </div>

      <!-- Step 1: Dates & Location -->
      <div v-if="currentStep === 1 && !bookingComplete" class="glass-strong rounded-2xl p-8 space-y-6 animate-fade-in">
        <h2 class="text-xl font-semibold font-[var(--font-heading)] flex items-center gap-2">
          <Calendar class="w-5 h-5 text-[var(--color-accent-blue)]" />
          Select Dates & Location
        </h2>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <!-- Start Date -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Pickup Date</label>
            <input
              v-model="startDate"
              type="date"
              :min="minStartDate"
              class="input-glass"
            />
          </div>

          <!-- End Date -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Return Date</label>
            <input
              v-model="endDate"
              type="date"
              :min="minEndDate"
              class="input-glass"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <!-- Pickup Location -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Pickup Location</label>
            <select v-model="pickupLocationId" class="input-glass">
              <option value="">Select location</option>
              <option v-for="loc in locations" :key="loc.id" :value="loc.id">
                {{ loc.name }} — {{ loc.city }}
              </option>
            </select>
          </div>

          <!-- Dropoff Location -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Dropoff Location</label>
            <select v-model="dropoffLocationId" class="input-glass">
              <option value="">Same as pickup</option>
              <option v-for="loc in locations" :key="loc.id" :value="loc.id">
                {{ loc.name }} — {{ loc.city }}
              </option>
            </select>
          </div>
        </div>

        <!-- Price Preview -->
        <div v-if="numberOfDays > 0" class="glass rounded-xl p-4 flex items-center justify-between">
          <div class="flex items-center gap-4 text-sm">
            <div class="flex items-center gap-1 text-[var(--color-text-muted)]">
              <Clock class="w-4 h-4" />
              <span>{{ numberOfDays }} day{{ numberOfDays !== 1 ? 's' : '' }}</span>
            </div>
            <span class="text-[var(--color-text-muted)]">×</span>
            <span class="text-[var(--color-text-muted)]">{{ formatTnd(selectedCar?.price_per_day || 0) }}/day</span>
          </div>
          <p class="text-xl font-bold gradient-text">{{ formatTnd(totalPrice) }}</p>
        </div>

        <div class="flex justify-end">
          <button
            @click="bookingStore.nextStep()"
            :disabled="!startDate || !endDate || !pickupLocationId || numberOfDays <= 0"
            class="btn-primary px-6 py-3"
            :class="{ 'opacity-50 pointer-events-none': !startDate || !endDate || !pickupLocationId || numberOfDays <= 0 }"
          >
            <span>Review Booking</span>
            <ArrowRight class="w-4 h-4" />
          </button>
        </div>
      </div>

      <!-- Step 2: Review -->
      <div v-if="currentStep === 2 && !bookingComplete" class="glass-strong rounded-2xl p-8 space-y-6 animate-fade-in">
        <h2 class="text-xl font-semibold font-[var(--font-heading)] flex items-center gap-2">
          <CreditCard class="w-5 h-5 text-[var(--color-accent-purple)]" />
          Review Your Booking
        </h2>

        <!-- Details Grid -->
        <div class="space-y-4">
          <div class="glass rounded-xl p-4 space-y-3">
            <div class="flex justify-between text-sm">
              <span class="text-[var(--color-text-muted)]">Vehicle</span>
              <span class="font-medium">{{ selectedCar?.make }} {{ selectedCar?.model }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-[var(--color-text-muted)]">Pickup Date</span>
              <span class="font-medium">{{ new Date(startDate).toLocaleDateString('en-US', { dateStyle: 'long' }) }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-[var(--color-text-muted)]">Return Date</span>
              <span class="font-medium">{{ new Date(endDate).toLocaleDateString('en-US', { dateStyle: 'long' }) }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-[var(--color-text-muted)]">Duration</span>
              <span class="font-medium">{{ numberOfDays }} day{{ numberOfDays !== 1 ? 's' : '' }}</span>
            </div>
            <div class="flex justify-between text-sm">
              <span class="text-[var(--color-text-muted)]">Rate</span>
              <span class="font-medium">{{ formatTnd(selectedCar?.price_per_day || 0) }} / day</span>
            </div>
          </div>

          <!-- Total -->
          <div class="glass rounded-xl p-4 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <DollarSign class="w-5 h-5 text-[var(--color-accent-emerald)]" />
              <span class="font-semibold">Total Price</span>
            </div>
            <p class="text-2xl font-bold gradient-text">{{ formatTnd(totalPrice) }}</p>
          </div>
        </div>

        <!-- Error -->
        <div v-if="error" class="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-sm text-[var(--color-accent-rose)]">
          {{ error }}
        </div>

        <div class="flex justify-between gap-4">
          <button @click="bookingStore.prevStep()" class="btn-secondary px-6 py-3">
            <ArrowLeft class="w-4 h-4" />
            <span>Back</span>
          </button>
          <button
            @click="handleConfirm"
            :disabled="submitting"
            class="btn-primary px-6 py-3"
          >
            <span v-if="submitting">Confirming...</span>
            <template v-else>
              <span>Confirm Booking</span>
              <CheckCircle class="w-4 h-4" />
            </template>
          </button>
        </div>
      </div>

      <!-- Step 3: Confirmation -->
      <div v-if="bookingComplete" class="glass-strong rounded-2xl p-8 text-center space-y-6 animate-scale-in">
        <div class="w-20 h-20 rounded-full bg-emerald-500/15 flex items-center justify-center mx-auto">
          <PartyPopper class="w-10 h-10 text-[var(--color-accent-emerald)]" />
        </div>

        <div>
          <h2 class="text-2xl font-bold font-[var(--font-heading)]">Booking Confirmed!</h2>
          <p class="mt-2 text-[var(--color-text-secondary)]">
            Your {{ selectedCar?.make }} {{ selectedCar?.model }} is reserved and waiting for you.
          </p>
        </div>

        <div class="glass rounded-xl p-4 text-left space-y-3 max-w-sm mx-auto">
          <div class="flex justify-between text-sm">
            <span class="text-[var(--color-text-muted)]">Booking ID</span>
            <span class="font-mono text-xs">{{ completedBooking?.id?.slice(0, 8) }}...</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-[var(--color-text-muted)]">Status</span>
            <span class="badge badge-confirmed text-xs">Confirmed</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-[var(--color-text-muted)]">Total Paid</span>
            <span class="font-bold gradient-text">{{ formatTnd(totalPrice) }}</span>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row gap-3 justify-center">
          <button @click="goToMyBookings" class="btn-primary px-6 py-3">
            <span>View My Bookings</span>
          </button>
          <button @click="bookAnother" class="btn-secondary px-6 py-3">
            <span>Book Another</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
