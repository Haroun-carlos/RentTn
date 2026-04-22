<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import {
  Mail,
  Lock,
  User,
  Eye,
  EyeOff,
  UserPlus,
  Car,
} from 'lucide-vue-next'

const router = useRouter()
const authStore = useAuthStore()

const fullName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const showPassword = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)
const success = ref(false)

async function handleRegister() {
  error.value = null

  if (!fullName.value || !email.value || !password.value || !confirmPassword.value) {
    error.value = 'Please fill in all fields'
    return
  }

  if (password.value.length < 6) {
    error.value = 'Password must be at least 6 characters'
    return
  }

  if (password.value !== confirmPassword.value) {
    error.value = 'Passwords do not match'
    return
  }

  loading.value = true

  try {
    await authStore.signUp(email.value, password.value, fullName.value)
    success.value = true
  } catch (e: any) {
    error.value = e.message || 'An error occurred during registration'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-[80vh] flex items-center justify-center px-4 py-12">
    <!-- Background orbs -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute top-1/3 right-1/4 w-72 h-72 bg-purple-500/10 rounded-full blur-3xl"></div>
      <div class="absolute bottom-1/4 left-1/3 w-72 h-72 bg-blue-500/10 rounded-full blur-3xl"></div>
    </div>

    <div class="w-full max-w-md relative z-10 animate-scale-in">
      <!-- Logo -->
      <div class="text-center mb-8">
        <RouterLink to="/" class="inline-flex items-center gap-2">
          <div
            class="w-10 h-10 rounded-lg flex items-center justify-center"
            style="background: linear-gradient(135deg, #3b82f6, #8b5cf6)"
          >
            <Car class="w-6 h-6 text-white" />
          </div>
          <span class="text-2xl font-bold font-[var(--font-heading)]">
            <span class="gradient-text">Rent</span><span class="text-white">Tn</span>
          </span>
        </RouterLink>
        <h1 class="mt-4 text-2xl font-bold font-[var(--font-heading)]">Create Account</h1>
        <p class="mt-1 text-sm text-[var(--color-text-muted)]">Join RentTn and hit the road</p>
      </div>

      <div class="glass-strong rounded-2xl p-8">
        <!-- Success message -->
        <div v-if="success" class="text-center space-y-4">
          <div class="w-16 h-16 rounded-full bg-emerald-500/15 flex items-center justify-center mx-auto">
            <UserPlus class="w-8 h-8 text-[var(--color-accent-emerald)]" />
          </div>
          <h3 class="text-lg font-semibold">Account Created!</h3>
          <p class="text-sm text-[var(--color-text-muted)]">
            Check your email for a confirmation link, then sign in to get started.
          </p>
          <RouterLink to="/login" class="btn-primary w-full py-3 rounded-xl">
            <span>Go to Sign In</span>
          </RouterLink>
        </div>

        <!-- Registration form -->
        <form v-else @submit.prevent="handleRegister" class="space-y-5">
          <!-- Error -->
          <div v-if="error" class="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-sm text-[var(--color-accent-rose)]">
            {{ error }}
          </div>

          <!-- Name -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Full Name</label>
            <div class="relative">
              <User class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input
                v-model="fullName"
                type="text"
                placeholder="John Doe"
                class="input-glass"
                style="padding-left: 2.75rem"
                autocomplete="name"
              />
            </div>
          </div>

          <!-- Email -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Email</label>
            <div class="relative">
              <Mail class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input
                v-model="email"
                type="email"
                placeholder="you@example.com"
                class="input-glass"
                style="padding-left: 2.75rem"
                autocomplete="email"
              />
            </div>
          </div>

          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Password</label>
            <div class="relative">
              <Lock class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Min. 6 characters"
                class="input-glass"
                style="padding-left: 2.75rem; padding-right: 2.75rem"
                autocomplete="new-password"
              />
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute right-3.5 top-1/2 -translate-y-1/2 text-[var(--color-text-muted)] hover:text-white transition-colors"
              >
                <EyeOff v-if="showPassword" class="w-4 h-4" />
                <Eye v-else class="w-4 h-4" />
              </button>
            </div>
          </div>

          <!-- Confirm Password -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Confirm Password</label>
            <div class="relative">
              <Lock class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input
                v-model="confirmPassword"
                :type="showPassword ? 'text' : 'password'"
                placeholder="Repeat your password"
                class="input-glass"
                style="padding-left: 2.75rem"
                autocomplete="new-password"
              />
            </div>
          </div>

          <!-- Submit -->
          <button
            type="submit"
            :disabled="loading"
            class="btn-primary w-full py-3 rounded-xl"
          >
            <span v-if="loading">Creating account...</span>
            <template v-else>
              <span>Create Account</span>
              <UserPlus class="w-4 h-4" />
            </template>
          </button>
        </form>

        <div v-if="!success" class="mt-6">
          <div class="flex items-center gap-3 mb-4">
            <div class="flex-1 border-t border-white/5"></div>
            <span class="text-xs text-[var(--color-text-muted)]">or</span>
            <div class="flex-1 border-t border-white/5"></div>
          </div>
          <p class="text-center text-sm text-[var(--color-text-muted)]">
            Already have an account?
            <RouterLink to="/login" class="text-[var(--color-accent-blue)] hover:underline font-medium">
              Sign in
            </RouterLink>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>
