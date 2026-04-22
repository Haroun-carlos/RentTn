<script setup lang="ts">
import { ref } from 'vue'
import { RouterLink, useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/authStore'
import {
  Mail,
  Lock,
  Eye,
  EyeOff,
  LogIn,
  Car,
} from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const email = ref('')
const password = ref('')
const showPassword = ref(false)
const loading = ref(false)
const error = ref<string | null>(null)

async function handleLogin() {
  if (!email.value || !password.value) {
    error.value = 'Please fill in all fields'
    return
  }

  loading.value = true
  error.value = null

  try {
    await authStore.signIn(email.value, password.value)
    const redirect = route.query.redirect as string
    router.push(redirect || '/')
  } catch (e: any) {
    const message = e?.message || 'Invalid email or password'
    if (message.toLowerCase().includes('invalid login credentials')) {
      error.value = 'Wrong email or password. If you just registered, try using the same email exactly and check for extra spaces.'
      return
    }
    error.value = message
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-[80vh] flex items-center justify-center px-4 py-12">
    <!-- Background orbs -->
    <div class="absolute inset-0 overflow-hidden pointer-events-none">
      <div class="absolute top-1/4 left-1/4 w-72 h-72 bg-blue-500/10 rounded-full blur-3xl"></div>
      <div class="absolute bottom-1/4 right-1/4 w-72 h-72 bg-purple-500/10 rounded-full blur-3xl"></div>
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
        <h1 class="mt-4 text-2xl font-bold font-[var(--font-heading)]">Welcome Back</h1>
        <p class="mt-1 text-sm text-[var(--color-text-muted)]">Sign in to your account to continue</p>
      </div>

      <!-- Form -->
      <div class="glass-strong rounded-2xl p-8">
        <form @submit.prevent="handleLogin" class="space-y-5">
          <!-- Error -->
          <div v-if="error" class="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-sm text-[var(--color-accent-rose)]">
            {{ error }}
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
                placeholder="Enter your password"
                class="input-glass"
                style="padding-left: 2.75rem; padding-right: 2.75rem"
                autocomplete="current-password"
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

          <!-- Submit -->
          <button
            type="submit"
            :disabled="loading"
            class="btn-primary w-full py-3 rounded-xl"
          >
            <span v-if="loading">Signing in...</span>
            <template v-else>
              <span>Sign In</span>
              <LogIn class="w-4 h-4" />
            </template>
          </button>
        </form>

        <!-- Divider -->
        <div class="my-6 flex items-center gap-3">
          <div class="flex-1 border-t border-white/5"></div>
          <span class="text-xs text-[var(--color-text-muted)]">or</span>
          <div class="flex-1 border-t border-white/5"></div>
        </div>

        <!-- Register link -->
        <p class="text-center text-sm text-[var(--color-text-muted)]">
          Don't have an account?
          <RouterLink to="/register" class="text-[var(--color-accent-blue)] hover:underline font-medium">
            Create one
          </RouterLink>
        </p>
      </div>
    </div>
  </div>
</template>
