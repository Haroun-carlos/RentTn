<script setup lang="ts">
import { RouterLink } from 'vue-router'
import {
  Car,
  Mail,
  Phone,
  MapPin,
  Github,
  Twitter,
  Instagram,
  Facebook,
  Shield,
  Clock,
  CreditCard,
} from 'lucide-vue-next'
</script>

<template>
  <footer class="border-t border-white/5 mt-20">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12">
        <!-- Brand -->
        <div class="space-y-4">
          <RouterLink to="/" class="flex items-center gap-2">
            <div
              class="w-9 h-9 rounded-lg flex items-center justify-center"
              style="background: linear-gradient(135deg, #3b82f6, #8b5cf6)"
            >
              <Car class="w-5 h-5 text-white" />
            </div>
            <span class="text-xl font-bold font-[var(--font-heading)]">
              <span class="gradient-text">Rent</span><span class="text-white">Tn</span>
            </span>
          </RouterLink>
          <p class="text-sm text-[var(--color-text-muted)] leading-relaxed">
            Tunisia's premier car rental platform. Find your perfect ride from our curated fleet of luxury and everyday vehicles across the country.
          </p>
          <!-- Trust Badges -->
          <div class="flex gap-4 pt-2">
            <div class="flex items-center gap-1.5 text-xs text-[var(--color-text-muted)]">
              <Shield class="w-3.5 h-3.5 text-[var(--color-accent-emerald)]" />
              <span>Insured</span>
            </div>
            <div class="flex items-center gap-1.5 text-xs text-[var(--color-text-muted)]">
              <Clock class="w-3.5 h-3.5 text-[var(--color-accent-blue)]" />
              <span>24/7</span>
            </div>
            <div class="flex items-center gap-1.5 text-xs text-[var(--color-text-muted)]">
              <CreditCard class="w-3.5 h-3.5 text-[var(--color-accent-purple)]" />
              <span>Secure</span>
            </div>
          </div>
          <div class="flex gap-3 pt-1">
            <a href="#" class="w-9 h-9 rounded-lg glass flex items-center justify-center text-[var(--color-text-muted)] hover:text-white hover:bg-white/10 transition-all">
              <Facebook class="w-4 h-4" />
            </a>
            <a href="#" class="w-9 h-9 rounded-lg glass flex items-center justify-center text-[var(--color-text-muted)] hover:text-white hover:bg-white/10 transition-all">
              <Instagram class="w-4 h-4" />
            </a>
            <a href="#" class="w-9 h-9 rounded-lg glass flex items-center justify-center text-[var(--color-text-muted)] hover:text-white hover:bg-white/10 transition-all">
              <Twitter class="w-4 h-4" />
            </a>
          </div>
        </div>

        <!-- Quick Links -->
        <div>
          <h4 class="text-sm font-semibold uppercase tracking-wider text-[var(--color-text-secondary)] mb-4">Quick Links</h4>
          <ul class="space-y-3">
            <li>
              <RouterLink to="/fleet" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Browse Fleet
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/my-bookings" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                My Bookings
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/register" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Create Account
              </RouterLink>
            </li>
            <li>
              <a href="#" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                How It Works
              </a>
            </li>
            <li>
              <a href="#" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                FAQs
              </a>
            </li>
          </ul>
        </div>

        <!-- Vehicle Types -->
        <div>
          <h4 class="text-sm font-semibold uppercase tracking-wider text-[var(--color-text-secondary)] mb-4">Vehicle Types</h4>
          <ul class="space-y-3">
            <li>
              <RouterLink to="/fleet?category=luxury" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Luxury
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/fleet?category=sports" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Sports Cars
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/fleet?category=suv" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                SUVs
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/fleet?category=electric" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Electric
              </RouterLink>
            </li>
            <li>
              <RouterLink to="/fleet?category=economy" class="text-sm text-[var(--color-text-muted)] hover:text-white transition-colors">
                Economy
              </RouterLink>
            </li>
          </ul>
        </div>

        <!-- Contact -->
        <div>
          <h4 class="text-sm font-semibold uppercase tracking-wider text-[var(--color-text-secondary)] mb-4">Contact</h4>
          <ul class="space-y-3">
            <li class="flex items-center gap-2 text-sm text-[var(--color-text-muted)]">
              <Mail class="w-4 h-4 text-[var(--color-accent-blue)]" />
              contact@renttn.com
            </li>
            <li class="flex items-center gap-2 text-sm text-[var(--color-text-muted)]">
              <Phone class="w-4 h-4 text-[var(--color-accent-blue)]" />
              +216 12 345 678
            </li>
            <li class="flex items-center gap-2 text-sm text-[var(--color-text-muted)]">
              <MapPin class="w-4 h-4 text-[var(--color-accent-blue)]" />
              Tunis, Tunisia
            </li>
          </ul>
        </div>
      </div>

      <!-- Bottom Bar -->
      <div class="border-t border-white/5 mt-12 pt-8 flex flex-col md:flex-row items-center justify-between gap-4">
        <p class="text-xs text-[var(--color-text-muted)]">
          &copy; {{ new Date().getFullYear() }} RentTn. All rights reserved.
        </p>
        <div class="flex gap-6">
          <a href="#" class="text-xs text-[var(--color-text-muted)] hover:text-white transition-colors">Privacy Policy</a>
          <a href="#" class="text-xs text-[var(--color-text-muted)] hover:text-white transition-colors">Terms of Service</a>
          <a href="#" class="text-xs text-[var(--color-text-muted)] hover:text-white transition-colors">Rental Agreement</a>
        </div>
      </div>
    </div>
  </footer>
</template>
