<script setup lang="ts">
import { RouterLink } from 'vue-router'
import { ref, onMounted } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Car } from '@/types/database'
import CarCard from '@/components/CarCard.vue'
import {
  ArrowRight,
  Shield,
  Zap,
  Clock,
  Star,
  MapPin,
  Sparkles,
  ChevronRight,
  CheckCircle,
  Headphones,
  CreditCard,
  Car as CarIcon,
} from 'lucide-vue-next'

const featuredCars = ref<Car[]>([])
const loadingCars = ref(true)

onMounted(async () => {
  try {
    const { data } = await supabase
      .from('cars')
      .select('*, locations(*)')
      .eq('availability', true)
      .order('price_per_day', { ascending: false })
      .limit(4)
    featuredCars.value = data || []
  } catch (e) {
    console.error(e)
  } finally {
    loadingCars.value = false
  }
})

const features = [
  {
    icon: Shield,
    title: 'Fully Insured',
    description: 'Every rental comes with comprehensive insurance coverage for your total peace of mind on Tunisian roads.',
    color: '#3b82f6',
  },
  {
    icon: Zap,
    title: 'Instant Booking',
    description: 'Book your ride in seconds with our streamlined real-time reservation system. No paperwork needed.',
    color: '#8b5cf6',
  },
  {
    icon: Clock,
    title: '24/7 Support',
    description: 'Round-the-clock assistance wherever your journey takes you across Tunisia.',
    color: '#06b6d4',
  },
  {
    icon: CreditCard,
    title: 'Flexible Payment',
    description: 'Pay online or on pickup. Multiple payment options for your convenience.',
    color: '#10b981',
  },
  {
    icon: MapPin,
    title: 'Multiple Locations',
    description: 'Pick up and drop off at our locations across Tunis, Sousse, Monastir, and more.',
    color: '#f59e0b',
  },
  {
    icon: Headphones,
    title: 'Concierge Service',
    description: 'Airport delivery, hotel pickup, and personalized assistance for premium rentals.',
    color: '#f43f5e',
  },
]

const testimonials = [
  {
    name: 'Yassine B.',
    role: 'Business Traveler',
    content: 'RentTn made my business trips across Tunisia seamless. The BMW M4 was immaculate and the booking took under a minute.',
    rating: 5,
  },
  {
    name: 'Sarah M.',
    role: 'Tourist from France',
    content: 'Rented the Jeep Wrangler for exploring Saharan villages. Incredible experience from start to finish!',
    rating: 5,
  },
  {
    name: 'Ahmed K.',
    role: 'Wedding Planner',
    content: 'The Mercedes S-Class was perfect for our wedding fleet. Love the real-time availability feature. Highly recommend!',
    rating: 5,
  },
]

const stats = [
  { value: '200+', label: 'Premium Vehicles' },
  { value: '15K+', label: 'Happy Customers' },
  { value: '12+', label: 'City Locations' },
  { value: '4.9', label: 'Average Rating' },
]

const howItWorks = [
  { step: '01', title: 'Choose Your Car', description: 'Browse our fleet and find the perfect ride for your trip.' },
  { step: '02', title: 'Pick Dates & Location', description: 'Select pickup/dropoff dates and your nearest location.' },
  { step: '03', title: 'Confirm & Drive', description: 'Complete booking in seconds and hit the road.' },
]
</script>

<template>
  <div>
    <!-- ============================== -->
    <!-- HERO SECTION — Animated Car BG -->
    <!-- ============================== -->
    <section class="relative min-h-[100vh] flex items-center overflow-hidden">
      <!-- Animated car background image -->
      <div class="absolute inset-0 z-0">
        <img
          src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=1920&q=80"
          alt="Luxury car"
          class="w-full h-full object-cover"
          style="animation: slowZoom 20s ease-in-out infinite alternate"
        />
        <!-- Dark overlay -->
        <div class="absolute inset-0 bg-gradient-to-r from-[var(--color-navy-950)] via-[var(--color-navy-950)]/90 to-[var(--color-navy-950)]/60"></div>
        <div class="absolute inset-0 bg-gradient-to-t from-[var(--color-navy-950)] via-transparent to-[var(--color-navy-950)]/40"></div>
      </div>

      <!-- Animated light rays -->
      <div class="absolute inset-0 overflow-hidden pointer-events-none z-1">
        <div class="absolute -top-40 right-1/4 w-[500px] h-[500px] bg-blue-500/8 rounded-full blur-3xl" style="animation: float 6s ease-in-out infinite"></div>
        <div class="absolute bottom-0 left-1/3 w-[400px] h-[400px] bg-purple-500/8 rounded-full blur-3xl" style="animation: float 8s ease-in-out infinite reverse"></div>
        <div class="absolute top-1/3 right-10 w-[300px] h-[300px] bg-cyan-500/5 rounded-full blur-3xl" style="animation: float 7s ease-in-out infinite 2s"></div>
      </div>

      <!-- Animated road lines -->
      <div class="absolute bottom-0 left-0 right-0 h-32 overflow-hidden z-1 opacity-20">
        <div class="absolute bottom-8 left-0 right-0 flex justify-center gap-16">
          <div class="w-24 h-1 bg-amber-400 rounded-full" style="animation: roadLine 2s linear infinite"></div>
          <div class="w-24 h-1 bg-amber-400 rounded-full" style="animation: roadLine 2s linear infinite 0.4s"></div>
          <div class="w-24 h-1 bg-amber-400 rounded-full" style="animation: roadLine 2s linear infinite 0.8s"></div>
          <div class="w-24 h-1 bg-amber-400 rounded-full" style="animation: roadLine 2s linear infinite 1.2s"></div>
          <div class="w-24 h-1 bg-amber-400 rounded-full" style="animation: roadLine 2s linear infinite 1.6s"></div>
        </div>
      </div>

      <!-- Animated particles -->
      <div class="absolute inset-0 pointer-events-none z-1">
        <div class="absolute top-[20%] left-[10%] w-1 h-1 bg-blue-400 rounded-full opacity-40" style="animation: particle 4s ease-in-out infinite"></div>
        <div class="absolute top-[40%] left-[80%] w-1.5 h-1.5 bg-purple-400 rounded-full opacity-30" style="animation: particle 5s ease-in-out infinite 1s"></div>
        <div class="absolute top-[60%] left-[25%] w-1 h-1 bg-cyan-400 rounded-full opacity-40" style="animation: particle 3.5s ease-in-out infinite 0.5s"></div>
        <div class="absolute top-[30%] left-[60%] w-1 h-1 bg-blue-300 rounded-full opacity-25" style="animation: particle 6s ease-in-out infinite 2s"></div>
        <div class="absolute top-[70%] left-[70%] w-0.5 h-0.5 bg-white rounded-full opacity-20" style="animation: particle 4.5s ease-in-out infinite 1.5s"></div>
      </div>

      <!-- Content -->
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 relative z-10">
        <div class="max-w-3xl">
          <!-- Badge -->
          <div class="animate-fade-in mb-6">
            <span class="inline-flex items-center gap-2 px-4 py-1.5 glass rounded-full text-sm text-[var(--color-accent-blue)] border border-blue-500/20">
              <Sparkles class="w-4 h-4" />
              Tunisia's #1 Car Rental Platform
            </span>
          </div>

          <!-- Headline -->
          <h1 class="text-5xl sm:text-6xl lg:text-7xl font-bold font-[var(--font-heading)] leading-[1.1] animate-slide-up">
            Rent The Car
            <br />
            <span class="gradient-text">You Deserve</span>
          </h1>

          <!-- Subtitle -->
          <p class="mt-6 text-lg sm:text-xl text-[var(--color-text-secondary)] max-w-xl animate-slide-up delay-100" style="opacity: 0">
            From everyday rides to exotic supercars — explore Tunisia your way with real-time availability, instant booking, and premium service.
          </p>

          <!-- CTA Buttons -->
          <div class="mt-8 flex flex-wrap gap-4 animate-slide-up delay-200" style="opacity: 0">
            <RouterLink to="/fleet" class="btn-primary text-base px-7 py-3.5 rounded-xl shadow-lg shadow-blue-500/25">
              <span>Browse Fleet</span>
              <ArrowRight class="w-5 h-5" />
            </RouterLink>
            <RouterLink to="/register" class="btn-secondary text-base px-7 py-3.5 rounded-xl">
              <span>Create Account</span>
              <ChevronRight class="w-4 h-4" />
            </RouterLink>
          </div>

          <!-- Quick trust -->
          <div class="mt-8 flex flex-wrap gap-5 animate-slide-up delay-300" style="opacity: 0">
            <div class="flex items-center gap-1.5 text-sm text-[var(--color-text-muted)]">
              <CheckCircle class="w-4 h-4 text-[var(--color-accent-emerald)]" />
              <span>No hidden fees</span>
            </div>
            <div class="flex items-center gap-1.5 text-sm text-[var(--color-text-muted)]">
              <CheckCircle class="w-4 h-4 text-[var(--color-accent-emerald)]" />
              <span>Free cancellation</span>
            </div>
            <div class="flex items-center gap-1.5 text-sm text-[var(--color-text-muted)]">
              <CheckCircle class="w-4 h-4 text-[var(--color-accent-emerald)]" />
              <span>Airport delivery</span>
            </div>
          </div>

          <!-- Stats -->
          <div class="mt-16 grid grid-cols-2 md:grid-cols-4 gap-6 animate-slide-up delay-400" style="opacity: 0">
            <div v-for="stat in stats" :key="stat.label" class="glass rounded-xl p-4 text-center">
              <p class="text-2xl sm:text-3xl font-bold gradient-text">{{ stat.value }}</p>
              <p class="text-xs text-[var(--color-text-muted)] mt-1">{{ stat.label }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Scroll indicator -->
      <div class="absolute bottom-8 left-1/2 -translate-x-1/2 z-10 animate-bounce">
        <div class="w-6 h-10 border-2 border-white/20 rounded-full flex justify-center pt-2">
          <div class="w-1 h-2.5 bg-white/40 rounded-full" style="animation: scrollDot 1.5s ease-in-out infinite"></div>
        </div>
      </div>
    </section>

    <!-- How It Works Section -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-2xl mx-auto mb-16">
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-emerald)]">Simple Process</span>
          <h2 class="mt-3 text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
            How It <span class="gradient-text">Works</span>
          </h2>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div
            v-for="(item, i) in howItWorks"
            :key="item.step"
            class="relative text-center"
          >
            <!-- Step Number -->
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl mb-5 text-2xl font-bold gradient-text glass border border-blue-500/20">
              {{ item.step }}
            </div>
            <!-- Connector line -->
            <div v-if="i < howItWorks.length - 1" class="hidden md:block absolute top-8 left-[60%] w-[80%] h-px bg-gradient-to-r from-blue-500/30 to-transparent"></div>
            <h3 class="text-lg font-semibold font-[var(--font-heading)] mb-2">{{ item.title }}</h3>
            <p class="text-sm text-[var(--color-text-muted)] leading-relaxed max-w-xs mx-auto">{{ item.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-2xl mx-auto mb-16">
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-blue)]">Why RentTn</span>
          <h2 class="mt-3 text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
            A <span class="gradient-text">Premium</span> Experience
          </h2>
          <p class="mt-4 text-[var(--color-text-secondary)]">
            We've reimagined car rental from the ground up, delivering a seamless experience at every step.
          </p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="(feature, i) in features"
            :key="feature.title"
            class="glass glass-hover p-8 rounded-2xl transition-all duration-300 hover:-translate-y-1"
          >
            <div
              class="w-12 h-12 rounded-xl flex items-center justify-center mb-5"
              :style="{ background: `${feature.color}15`, border: `1px solid ${feature.color}30` }"
            >
              <component :is="feature.icon" class="w-6 h-6" :style="{ color: feature.color }" />
            </div>
            <h3 class="text-lg font-semibold font-[var(--font-heading)] mb-2">{{ feature.title }}</h3>
            <p class="text-sm text-[var(--color-text-muted)] leading-relaxed">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Featured Cars -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-end justify-between mb-12">
          <div>
            <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-purple)]">Our Fleet</span>
            <h2 class="mt-3 text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
              Featured <span class="gradient-text">Vehicles</span>
            </h2>
          </div>
          <RouterLink to="/fleet" class="btn-secondary text-sm hidden sm:inline-flex rounded-xl">
            <span>View All</span>
            <ArrowRight class="w-4 h-4" />
          </RouterLink>
        </div>

        <!-- Loading skeletons -->
        <div v-if="loadingCars" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="i in 4" :key="i" class="glass rounded-2xl overflow-hidden">
            <div class="skeleton aspect-[16/10]"></div>
            <div class="p-5 space-y-3">
              <div class="skeleton h-5 w-3/4 rounded"></div>
              <div class="skeleton h-3 w-1/2 rounded"></div>
              <div class="skeleton h-8 w-full rounded-lg"></div>
            </div>
          </div>
        </div>

        <!-- Cars grid -->
        <div v-else class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <CarCard
            v-for="car in featuredCars"
            :key="car.id"
            :car="car"
          />
        </div>

        <div class="text-center mt-8 sm:hidden">
          <RouterLink to="/fleet" class="btn-primary text-sm rounded-xl">
            <span>View Full Fleet</span>
            <ArrowRight class="w-4 h-4" />
          </RouterLink>
        </div>
      </div>
    </section>

    <!-- Testimonials -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center max-w-2xl mx-auto mb-16">
          <span class="text-sm font-semibold uppercase tracking-wider text-[var(--color-accent-cyan)]">Testimonials</span>
          <h2 class="mt-3 text-3xl sm:text-4xl font-bold font-[var(--font-heading)]">
            Loved By <span class="gradient-text">Drivers</span>
          </h2>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div
            v-for="testimonial in testimonials"
            :key="testimonial.name"
            class="glass glass-hover p-6 rounded-2xl transition-all duration-300 hover:-translate-y-1"
          >
            <!-- Stars -->
            <div class="flex gap-1 mb-4">
              <Star
                v-for="i in testimonial.rating"
                :key="i"
                class="w-4 h-4 fill-amber-400 text-amber-400"
              />
            </div>
            <p class="text-sm text-[var(--color-text-secondary)] leading-relaxed mb-4">
              "{{ testimonial.content }}"
            </p>
            <div class="flex items-center gap-3">
              <div class="w-9 h-9 rounded-full bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center text-xs font-bold">
                {{ testimonial.name.split(' ').map(n => n[0]).join('') }}
              </div>
              <div>
                <p class="text-sm font-semibold">{{ testimonial.name }}</p>
                <p class="text-xs text-[var(--color-text-muted)]">{{ testimonial.role }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-24 relative">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="glass rounded-3xl p-12 md:p-16 text-center relative overflow-hidden">
          <!-- Background decoration -->
          <div class="absolute -top-20 -right-20 w-60 h-60 bg-blue-500/10 rounded-full blur-3xl"></div>
          <div class="absolute -bottom-20 -left-20 w-60 h-60 bg-purple-500/10 rounded-full blur-3xl"></div>

          <div class="relative z-10">
            <h2 class="text-3xl sm:text-4xl font-bold font-[var(--font-heading)] mb-4">
              Ready to <span class="gradient-text">Hit The Road?</span>
            </h2>
            <p class="text-[var(--color-text-secondary)] max-w-lg mx-auto mb-8">
              Join thousands of satisfied drivers across Tunisia. Book your dream car in minutes with our real-time platform.
            </p>
            <div class="flex flex-wrap justify-center gap-4">
              <RouterLink to="/fleet" class="btn-primary text-base px-8 py-3 rounded-xl">
                <span>Browse Fleet</span>
                <ArrowRight class="w-5 h-5" />
              </RouterLink>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@keyframes slowZoom {
  0% { transform: scale(1); }
  100% { transform: scale(1.12); }
}

@keyframes roadLine {
  0% { transform: translateX(100vw); opacity: 0; }
  10% { opacity: 1; }
  90% { opacity: 1; }
  100% { transform: translateX(-100vw); opacity: 0; }
}

@keyframes particle {
  0%, 100% { transform: translateY(0) translateX(0); opacity: 0.2; }
  25% { transform: translateY(-20px) translateX(10px); opacity: 0.5; }
  50% { transform: translateY(-40px) translateX(-5px); opacity: 0.3; }
  75% { transform: translateY(-20px) translateX(15px); opacity: 0.5; }
}

@keyframes scrollDot {
  0%, 100% { transform: translateY(0); opacity: 0.3; }
  50% { transform: translateY(6px); opacity: 1; }
}
</style>
