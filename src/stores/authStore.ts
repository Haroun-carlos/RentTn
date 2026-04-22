import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/lib/supabaseClient'
import type { Profile } from '@/types/database'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  // State
  const user = ref<User | null>(null)
  const profile = ref<Profile | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const initialized = ref(false)

  // Getters
  const isAuthenticated = computed(() => !!user.value)
  const displayName = computed(() => {
    if (profile.value?.full_name) return profile.value.full_name
    if (user.value?.email) return user.value.email.split('@')[0]
    return 'User'
  })
  const avatarUrl = computed(() => profile.value?.avatar_url || null)

  // Actions
  async function signUp(email: string, password: string, fullName: string) {
    loading.value = true
    error.value = null
    try {
      const normalizedEmail = email.trim().toLowerCase()
      const normalizedFullName = fullName.trim()

      const { data, error: authError } = await supabase.auth.signUp({
        email: normalizedEmail,
        password,
        options: {
          data: {
            full_name: normalizedFullName,
          },
        },
      })
      if (authError) throw authError

      // Supabase can return a "successful" sign-up for an existing email.
      // In that case identities is empty and password is not updated.
      if (data.user && Array.isArray(data.user.identities) && data.user.identities.length === 0) {
        throw new Error('This email is already registered. Please sign in instead.')
      }

      user.value = data.user
      if (data.user) {
        await fetchProfile()
      }
    } catch (e: any) {
      error.value = e.message || 'An error occurred during sign up'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function signIn(email: string, password: string) {
    loading.value = true
    error.value = null
    try {
      const normalizedEmail = email.trim().toLowerCase()

      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email: normalizedEmail,
        password,
      })
      if (authError) throw authError
      user.value = data.user
      await fetchProfile()
    } catch (e: any) {
      error.value = e.message || 'An error occurred during sign in'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function signOut() {
    loading.value = true
    try {
      const { error: authError } = await supabase.auth.signOut()
      if (authError) throw authError
      user.value = null
      profile.value = null
    } catch (e: any) {
      error.value = e.message || 'An error occurred during sign out'
    } finally {
      loading.value = false
    }
  }

  async function fetchProfile() {
    if (!user.value) return
    try {
      const { data, error: fetchError } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.value.id)
        .single()

      if (fetchError && fetchError.code !== 'PGRST116') throw fetchError
      profile.value = data
    } catch (e: any) {
      console.error('Error fetching profile:', e.message)
    }
  }

  async function updateProfile(updates: Partial<Profile>) {
    if (!user.value) return
    loading.value = true
    error.value = null
    try {
      const { data, error: updateError } = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', user.value.id)
        .select()
        .single()

      if (updateError) throw updateError
      profile.value = data
    } catch (e: any) {
      error.value = e.message || 'An error occurred updating profile'
      throw e
    } finally {
      loading.value = false
    }
  }

  async function initAuth() {
    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (session?.user) {
        user.value = session.user
        await fetchProfile()
      }

      supabase.auth.onAuthStateChange(async (event, session) => {
        user.value = session?.user ?? null
        if (session?.user) {
          await fetchProfile()
        } else {
          profile.value = null
        }
      })
    } catch (e: any) {
      console.error('Error initializing auth:', e.message)
    } finally {
      initialized.value = true
    }
  }

  function clearError() {
    error.value = null
  }

  return {
    user,
    profile,
    loading,
    error,
    initialized,
    isAuthenticated,
    displayName,
    avatarUrl,
    signUp,
    signIn,
    signOut,
    fetchProfile,
    updateProfile,
    initAuth,
    clearError,
  }
})
