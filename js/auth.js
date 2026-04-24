// Format raw Malaysian phone input to E.164 (+601XXXXXXXX)
function formatMyPhone(raw) {
  let digits = raw.replace(/\D/g, '')
  if (digits.startsWith('60')) digits = digits.slice(2)
  if (digits.startsWith('0')) digits = digits.slice(1)
  return '+60' + digits
}

// Validate Malaysian mobile number (01X-XXXXXXX, 8–9 digits after 01)
function isValidMyPhone(e164) {
  return /^\+601\d{8,9}$/.test(e164)
}

// Redirect to login if no active session; returns session or null
async function requireAuth() {
  const { data: { session } } = await db.auth.getSession()
  if (!session) {
    window.location.href = 'login.html'
    return null
  }
  return session
}

// Get current user's public profile (NEVER queries users table directly)
async function getMyProfile(userId) {
  const { data, error } = await db
    .from('public_profiles')
    .select('*')
    .eq('id', userId)
    .single()
  if (error) console.error('getMyProfile:', error.message)
  return data
}

// Get current user's own full row (allowed — RLS: users_select_own)
async function getMyFullUser(userId) {
  const { data, error } = await db
    .from('users')
    .select('id, full_name, role, institution_id, phone, matric_card_url, matric_verified, avatar_url, is_international')
    .eq('id', userId)
    .single()
  if (error) console.error('getMyFullUser:', error.message)
  return data
}

// Check whether live_gigs feature flag is ON for the pilot institution
async function isLiveGigsEnabled() {
  const { data } = await db
    .from('feature_flags')
    .select('enabled')
    .eq('institution_id', INSTITUTION_ID)
    .eq('feature_name', 'live_gigs')
    .single()
  return data?.enabled === true
}

// Show a toast notification (requires #toast element on page)
function showToast(msg, type = 'info') {
  const toast = document.getElementById('toast')
  if (!toast) return
  toast.textContent = msg
  toast.className = 'toast toast-' + type
  toast.style.display = 'block'
  clearTimeout(toast._timer)
  toast._timer = setTimeout(() => { toast.style.display = 'none' }, 3500)
}
