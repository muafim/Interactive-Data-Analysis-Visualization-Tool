export interface TransportationRecord {
  gender: string; umur: number; transportasi: string; jenisKendaraan: string;
  jarak: number; waktu: number; biaya: number; performaKendaraan: string; tingkatMobilitas: number;
}
export type TestResult = { variable: string; statistic: number; pValue: number; degreesOfFreedom?: number }
export type KendallResult = { variable: string; tau: number; pValue: number }
export interface AnalysisSummary {
  sample: { raw: number; cleaned: number; removed: number };
  quality: { missingByField: Record<string, number>; missingTotal: number; normalizedLabels: number;
    normalization: { from: string; to: string; field: string }; outliers: { sourceRow: number; variable: string; value: number; lower: number; upper: number }[] };
  descriptive: Record<'raw' | 'cleaned', Record<string, { mean: number; median: number; min: number; max: number; q1: number; q3: number }>>;
  distributions: { transportation: Record<string, number>; vehicle: Record<string, number> };
  groupCost: Record<string, { n: number; median: number }>;
  shapiro: TestResult[]; kruskal: TestResult[]; kendall: KendallResult[];
  cramersV: { variables: string[]; values: (number | null)[][] };
  pca: { explainedVariance: number[] }; alpha: number;
}
