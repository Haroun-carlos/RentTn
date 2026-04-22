<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { storeToRefs } from 'pinia'
import { useAuthStore } from '@/stores/authStore'
import {
  User,
  Mail,
  Phone,
  CreditCard,
  Calendar,
  Save,
  Check,
} from 'lucide-vue-next'

const authStore = useAuthStore()
const { user, profile, loading } = storeToRefs(authStore)

const form = ref({
  full_name: '',
  phone: '',
  driver_license_number: '',
  date_of_birth: '',
})
const saving = ref(false)
const saved = ref(false)
const error = ref<string | null>(null)

onMounted(() => {
  if (profile.value) {
    form.value.full_name = profile.value.full_name || ''
    form.value.phone = profile.value.phone || ''
    form.value.driver_license_number = profile.value.driver_license_number || ''
    form.value.date_of_birth = profile.value.date_of_birth || ''
  }
})

async function handleSave() {
  saving.value = true
  error.value = null
  saved.value = false

  try {
    await authStore.updateProfile(form.value)
    saved.value = true
    setTimeout(() => { saved.value = false }, 3000)
  } catch (e: any) {
    error.value = e.message || 'Failed to update profile'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="min-h-screen">
    <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="mb-8">
        <h1 class="text-3xl font-bold font-[var(--font-heading)]">
          My <span class="gradient-text">Profile</span>
        </h1>
        <p class="mt-2 text-[var(--color-text-secondary)]">Manage your personal information</p>
      </div>

      <div class="glass-strong rounded-2xl p-8">
        <!-- Avatar -->
        <div class="flex items-center gap-4 mb-8 pb-8 border-b border-white/5">
          <div class="w-16 h-16 rounded-2xl bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center">
            <User class="w-8 h-8 text-white" />
          </div>
          <div>
            <p class="font-semibold text-lg">{{ profile?.full_name || 'User' }}</p>
            <p class="text-sm text-[var(--color-text-muted)]">{{ user?.email }}</p>
          </div>
        </div>

        <form @submit.prevent="handleSave" class="space-y-5">
          <!-- Error -->
          <div v-if="error" class="p-3 rounded-lg bg-rose-500/10 border border-rose-500/20 text-sm text-[var(--color-accent-rose)]">
            {{ error }}
          </div>

          <!-- Success -->
          <div v-if="saved" class="p-3 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-sm text-[var(--color-accent-emerald)] flex items-center gap-2">
            <Check class="w-4 h-4" />
            Profile updated successfully
          </div>

          <!-- Full Name -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Full Name</label>
            <div class="relative">
              <User class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input v-model="form.full_name" type="text" placeholder="John Doe" class="input-glass" style="padding-left: 2.75rem" />
            </div>
          </div>

          <!-- Phone -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Phone Number</label>
            <div class="relative">
              <Phone class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input v-model="form.phone" type="tel" placeholder="+216 12 345 678" class="input-glass" style="padding-left: 2.75rem" />
            </div>
          </div>

          <!-- Driver License -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Driver's License Number</label>
            <div class="relative">
              <CreditCard class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input v-model="form.driver_license_number" type="text" placeholder="DL-123456789" class="input-glass" style="padding-left: 2.75rem" />
            </div>
          </div>

          <!-- Date of Birth -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Date of Birth</label>
            <div class="relative">
              <Calendar class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input v-model="form.date_of_birth" type="date" class="input-glass" style="padding-left: 2.75rem" />
            </div>
          </div>

          <!-- Email (read-only) -->
          <div>
            <label class="block text-sm font-medium text-[var(--color-text-secondary)] mb-1.5">Email</label>
            <div class="relative">
              <Mail class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-[var(--color-text-muted)] pointer-events-none" />
              <input :value="user?.email" type="email" class="input-glass opacity-50 cursor-not-allowed" style="padding-left: 2.75rem" disabled />
            </div>
            <p class="text-xs text-[var(--color-text-muted)] mt-1">Email cannot be changed</p>
          </div>

          <button type="submit" :disabled="saving" class="btn-primary w-full py-3 mt-2">
            <span v-if="saving">Saving...</span>
            <template v-else>
              <Save class="w-4 h-4" />
              <span>Save Changes</span>
            </template>
          </button>
        </form>
      </div>
    </div>
  </div>
</template>
