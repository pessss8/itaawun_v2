// supabase.js — shared config, include this in every HTML page
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm'

const SUPABASE_URL = 'https://fyahebgkacjsxmiwteny.supabase.co'
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5YWhlYmdrYWNqc3htaXd0ZW55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyNTg3NDEsImV4cCI6MjA4NTgzNDc0MX0.eIAWIPzB6EjW7rPKHLSsc2ryUBQ7yicRK1I-SxXg_2Y'

export const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)