import type { TransportationRecord } from '../types/transportation'
export const modes: { key: string; label: string; color: string }[] = [
  { key: 'Kendaraan pribadi', label: 'Private vehicle', color: '#2563EB' },
  { key: 'Ojek online', label: 'Ride hailing', color: '#D97706' },
  { key: 'Kendaraan umum', label: 'Public transport', color: '#0F766E' },
]
export const modeLabel = (key: string) => modes.find(m => m.key === key)?.label ?? key
export const modeColor = (key: string) => modes.find(m => m.key === key)?.color ?? '#667085'
export const labels: Record<string, string> = { umur: 'Age', jarak: 'Distance', waktu: 'Travel time', biaya: 'Transportation cost', tingkat_mobilitas: 'Mobility level', gender: 'Gender', transportasi: 'Transportation mode', jenis_kendaraan: 'Vehicle type', performa_kendaraan: 'Vehicle performance' }
export const currency = (n: number) => `Rp${new Intl.NumberFormat('id-ID', { maximumFractionDigits: 0 }).format(n)}`
export const number = (n: number, digits = 1) => new Intl.NumberFormat('en-US', { maximumFractionDigits: digits }).format(n)
export const percent = (n: number) => `${number(n * 100)}%`
export const pValue = (n: number) => n < .001 ? 'p < 0.001' : `p = ${n.toFixed(4)}`
export const median = (items: number[]) => { if (!items.length) return 0; const sorted = [...items].sort((a, b) => a - b); const mid = Math.floor(sorted.length / 2); return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2 }
export const mean = (items: number[]) => items.length ? items.reduce((a, b) => a + b, 0) / items.length : 0
export const quantile = (items: number[], q: number) => { if (!items.length) return 0; const a = [...items].sort((x, y) => x - y); const h = (a.length - 1) * q, lo = Math.floor(h); return a[lo] + (a[Math.ceil(h)] - a[lo]) * (h - lo) }
export const box = (items: number[]) => [Math.min(...items), quantile(items, .25), median(items), quantile(items, .75), Math.max(...items)]
export const groups = (records: TransportationRecord[], field: keyof TransportationRecord) => { const counts = new Map<string, number>(); records.forEach(r => counts.set(String(r[field]), (counts.get(String(r[field])) ?? 0) + 1)); return [...counts].sort((a, b) => b[1] - a[1]) }
export const histogram = (items: number[], bins = 12) => { if (!items.length) return []; const min = Math.min(...items), max = Math.max(...items); const width = (max - min || 1) / bins; return Array.from({ length: bins }, (_, i) => ({ low: min + i * width, high: min + (i + 1) * width, count: items.filter(x => Math.min(bins - 1, Math.floor((x - min) / width)) === i).length })) }
