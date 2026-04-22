<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/authStore'
import {
  Car,
  Menu,
  X,
  User,
  LogOut,
  CalendarDays,
  ChevronDown,
  MapPin,
  Phone,
  Tag,
  HelpCircle,
  Info,
} from 'lucide-vue-next'

const authStore = useAuthStore()
const { isAuthenticated, displayName } = storeToRefs(authStore)
const router = useRouter()

const mobileMenuOpen = ref(false)
const profileDropdownOpen = ref(false)

function toggleMobileMenu() {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

function closeMobileMenu() {
  mobileMenuOpen.value = false
}

function toggleProfileDropdown() {
  profileDropdownOpen.value = !profileDropdownOpen.value
}

async function handleSignOut() {
  await authStore.signOut()
  profileDropdownOpen.value = false
  mobileMenuOpen.value = false
  router.push({ name: 'home' })
}

const navLinks = [
  { name: 'Fleet', to: '/fleet', icon: Car },
  { name: 'Locations', to: '/locations', icon: MapPin },
  { name: 'Deals', to: '/deals', icon: Tag },
  { name: 'My Bookings', to: '/my-bookings', requiresAuth: true, icon: CalendarDays },
]
</script>

<template>
  <header
    class="fixed top-0 left-0 right-0 z-50 border-b border-white/5"
    style="background: rgba(2, 6, 23, 0.85); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px)"
  >
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Top bar — phone + help (desktop only) -->
      <div class="hidden lg:flex items-center justify-between py-1.5 border-b border-white/5 text-xs text-[var(--color-text-muted)]">
        <div class="flex items-center gap-4">
          <a href="tel:+21612345678" class="flex items-center gap-1 hover:text-white transition-colors">
            <Phone class="w-3 h-3" />
            +216 29640034
          </a>
          <span class="text-white/10">|</span>
          <div class="flex items-center gap-1">
            <MapPin class="w-3 h-3" />
            Tunis, Tunisia
          </div>
        </div>
        <div class="flex items-center gap-4">
          <a href="#" class="flex items-center gap-1 hover:text-white transition-colors">
            <HelpCircle class="w-3 h-3" />
            Help Center
          </a>
          <span class="text-white/10">|</span>
          <a href="#" class="flex items-center gap-1 hover:text-white transition-colors">
            <Info class="w-3 h-3" />
            About Us
          </a>
        </div>
      </div>

      <!-- Main nav -->
      <div class="flex items-center justify-between h-16">
        <!-- Logo -->
        <RouterLink to="/" class="flex items-center gap-2.5 group" @click="closeMobileMenu">
          <div
            class="w-10 h-10 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/20 group-hover:shadow-blue-500/40 transition-shadow duration-300"
            style="background: linear-gradient(135deg, #3b82f6, #8b5cf6)"
          >
            <Car class="w-5 h-5 text-white" />
          </div>
          <span class="text-xl font-bold font-[var(--font-heading)]">
            <span class="gradient-text">Rent</span><span class="text-white">Tn</span>
          </span>
        </RouterLink>

        <!-- Desktop Navigation -->
        <nav class="hidden md:flex items-center gap-0.5">
          <template v-for="link in navLinks" :key="link.name">
            <RouterLink
              v-if="!link.requiresAuth || isAuthenticated"
              :to="link.to"
              class="flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all duration-200"
              active-class="!text-white !bg-white/10"
            >
              <component :is="link.icon" class="w-4 h-4" />
              {{ link.name }}
            </RouterLink>
          </template>
        </nav>

        <!-- Desktop Auth + CTA -->
        <div class="hidden md:flex items-center gap-3">
          <template v-if="isAuthenticated">
            <!-- Profile Dropdown -->
            <div class="relative">
              <button
                @click="toggleProfileDropdown"
                class="flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all duration-200"
              >
                <div class="w-7 h-7 rounded-full bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center">
                  <User class="w-4 h-4 text-white" />
                </div>
                <span>{{ displayName }}</span>
                <ChevronDown class="w-3 h-3 transition-transform duration-200" :class="{ 'rotate-180': profileDropdownOpen }" />
              </button>

              <Transition name="page">
                <div
                  v-if="profileDropdownOpen"
                  class="absolute right-0 mt-2 w-48 glass-strong rounded-xl overflow-hidden shadow-xl"
                >
                  <RouterLink
                    to="/profile"
                    class="flex items-center gap-2 px-4 py-3 text-sm text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all"
                    @click="profileDropdownOpen = false"
                  >
                    <User class="w-4 h-4" />
                    Profile
                  </RouterLink>
                  <RouterLink
                    to="/my-bookings"
                    class="flex items-center gap-2 px-4 py-3 text-sm text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all"
                    @click="profileDropdownOpen = false"
                  >
                    <CalendarDays class="w-4 h-4" />
                    My Bookings
                  </RouterLink>
                  <button
                    @click="handleSignOut"
                    class="flex items-center gap-2 w-full px-4 py-3 text-sm text-[var(--color-accent-rose)] hover:bg-white/5 transition-all border-t border-white/5"
                  >
                    <LogOut class="w-4 h-4" />
                    Sign Out
                  </button>
                </div>
              </Transition>
            </div>
          </template>

          <template v-else>
            <RouterLink
              to="/login"
              class="px-4 py-2 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all duration-200"
            >
              Sign In
            </RouterLink>
            <RouterLink to="/register" class="btn-primary text-sm px-5 py-2.5 rounded-xl">
              <span>Get Started</span>
            </RouterLink>
          </template>
        </div>

        <!-- Mobile Menu Button -->
        <button
          class="md:hidden p-2 rounded-lg hover:bg-white/5 transition-colors"
          @click="toggleMobileMenu"
        >
          <Menu v-if="!mobileMenuOpen" class="w-5 h-5" />
          <X v-else class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- Mobile Menu -->
    <Transition name="page">
      <div v-if="mobileMenuOpen" class="md:hidden border-t border-white/5" style="background: rgba(2, 6, 23, 0.95)">
        <div class="px-4 py-4 space-y-1">
          <template v-for="link in navLinks" :key="link.name">
            <RouterLink
              v-if="!link.requiresAuth || isAuthenticated"
              :to="link.to"
              class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all"
              @click="closeMobileMenu"
            >
              <component :is="link.icon" class="w-4 h-4" />
              {{ link.name }}
            </RouterLink>
          </template>

          <!-- Mobile phone -->
          <a href="tel:+21612345678" class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all">
            <Phone class="w-4 h-4" />
            +216 12 345 678
          </a>

          <div class="border-t border-white/5 pt-3 mt-3">
            <template v-if="isAuthenticated">
              <RouterLink
                to="/profile"
                class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all"
                @click="closeMobileMenu"
              >
                <User class="w-4 h-4" />
                Profile
              </RouterLink>
              <button
                @click="handleSignOut"
                class="flex items-center gap-3 w-full px-4 py-3 rounded-lg text-sm font-medium text-[var(--color-accent-rose)] hover:bg-white/5 transition-all"
              >
                <LogOut class="w-4 h-4" />
                Sign Out
              </button>
            </template>
            <template v-else>
              <RouterLink
                to="/login"
                class="flex items-center gap-3 px-4 py-3 rounded-lg text-sm font-medium text-[var(--color-text-secondary)] hover:text-white hover:bg-white/5 transition-all"
                @click="closeMobileMenu"
              >
                Sign In
              </RouterLink>
              <RouterLink
                to="/register"
                class="block mt-2 btn-primary text-sm text-center rounded-xl"
                @click="closeMobileMenu"
              >
                <span>Get Started</span>
              </RouterLink>
            </template>
          </div>
        </div>
      </div>
    </Transition>
  </header>

  <!-- Spacer for fixed header -->
  <div class="h-16 lg:h-[88px]"></div>
</template>
