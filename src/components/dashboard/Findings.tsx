import type { AnalysisSummary, TransportationRecord } from '../../types/transportation'
import { currency, labels, number, pValue, percent } from '../../utils/analytics'
import { Panel } from './Charts'

export function StatisticalResults({ summary }: { summary: AnalysisSummary }) {
  return <div className="grid-two">
    <Panel title="Normality testing" note={`Shapiro–Wilk · full cleaned dataset, n = ${summary.sample.cleaned} · α = 0.05`}>
      <div className="table-scroll"><table><thead><tr><th>Variable</th><th>W</th><th>p-value</th><th>Interpretation</th></tr></thead><tbody>{summary.shapiro.map(t => <tr key={t.variable}><td>{labels[t.variable]}</td><td>{number(t.statistic, 3)}</td><td>{pValue(t.pValue)}</td><td>{t.pValue < summary.alpha ? 'Deviates from normality' : 'Not significant'}</td></tr>)}</tbody></table></div>
      <p className="chart-insight">{summary.shapiro.every(t => t.pValue < summary.alpha) ? 'Every tested numeric variable deviates significantly from normality; non-parametric methods are used below.' : 'Normality differs by variable; interpret each test individually.'}</p>
    </Panel>
    <Panel title="Spending differences across groups" note={`Kruskal–Wallis · full cleaned dataset, n = ${summary.sample.cleaned} · α = 0.05`}>
      <div className="table-scroll"><table><thead><tr><th>Grouping</th><th>H</th><th>p-value</th><th>Result</th></tr></thead><tbody>{summary.kruskal.map(t => <tr key={t.variable}><td>{labels[t.variable]}</td><td>{number(t.statistic, 2)}</td><td>{pValue(t.pValue)}</td><td><span className={t.pValue < summary.alpha ? 'significant' : ''}>{t.pValue < summary.alpha ? 'Significant' : 'Not significant'}</span></td></tr>)}</tbody></table></div>
      <p className="chart-insight">The omnibus test detects a difference across transportation modes; it does not identify which pair differs. No post-hoc pairwise claim is made.</p>
    </Panel>
  </div>
}
export function KeyInsights({ summary }: { summary: AnalysisSummary }) {
  const privateCount = summary.distributions.transportation['Kendaraan pribadi'] ?? 0
  const motor = summary.distributions.vehicle.Motor ?? 0
  const ride = summary.groupCost['Ojek online'], personal = summary.groupCost['Kendaraan pribadi'], publicGroup = summary.groupCost['Kendaraan umum']
  const modeTest = summary.kruskal.find(t => t.variable === 'transportasi')!
  const age = summary.kendall.find(t => t.variable === 'umur')!
  const other = summary.kendall.filter(t => t.variable !== 'umur')
  const insights = [
    `${percent(privateCount / summary.sample.raw)} of respondents used private vehicles; ${percent(motor / summary.sample.raw)} recorded motorcycles.`,
    `Observed median cost was ${currency(ride.median)} for ride hailing and ${currency(personal.median)} for private vehicles. The group-level spending difference is ${modeTest.pValue < summary.alpha ? 'statistically significant' : 'not statistically significant'} (${pValue(modeTest.pValue)}).`,
    `Public transport's observed median is ${currency(publicGroup.median)}, but only ${publicGroup.n} respondents used it. Do not generalize this estimate.`,
    `${other.every(t => t.pValue >= summary.alpha) ? 'Distance, travel time, and mobility score show no significant monotonic association with cost.' : 'Some numeric associations warrant closer inspection.'} Age has a ${age.tau < 0 ? 'negative' : 'positive'} association (τ = ${number(age.tau, 3)}, ${pValue(age.pValue)}), but its range is narrow.`,
  ]
  return <div className="insights-grid">{insights.map((insight, i) => <div className="insight-item" key={i}><span className="insight-number">0{i + 1}</span><p>{insight}</p></div>)}</div>
}
export function DataQuality({ summary, activeRecords, rawRecords, cleanedRecords, chart, setChart, before, setBefore }: { summary: AnalysisSummary; activeRecords: TransportationRecord[]; rawRecords: TransportationRecord[]; cleanedRecords: TransportationRecord[]; chart: 'umur' | 'jarak' | 'waktu' | 'biaya' | 'tingkatMobilitas'; setChart: (v: 'umur' | 'jarak' | 'waktu' | 'biaya' | 'tingkatMobilitas') => void; before: boolean; setBefore: (v: boolean) => void }) {
  const quality = summary.quality
  return <><div className="quality-grid">{[['Raw rows', summary.sample.raw], ['Missing values', quality.missingTotal], ['Outliers identified', summary.sample.removed], ['Analysis rows', summary.sample.cleaned]].map(([label, value]) => <div className="quality-tile" key={label}><span>{label}</span><strong>{value}</strong></div>)}</div>
    <div className="grid-two"><Panel title="Outlier inspection" note="IQR boxplot · switch variable and stage"><div className="control-pair"><label>Variable <select value={chart} onChange={e => setChart(e.target.value as typeof chart)}>{(['umur', 'jarak', 'waktu', 'biaya', 'tingkatMobilitas'] as const).map(k => <option key={k} value={k}>{labels[k === 'tingkatMobilitas' ? 'tingkat_mobilitas' : k]}</option>)}</select></label><label>Dataset <select value={before ? 'before' : 'after'} onChange={e => setBefore(e.target.value === 'before')}><option value="before">Before cleaning</option><option value="after">After cleaning</option></select></label></div><OutlierPlot records={before ? rawRecords : cleanedRecords} field={chart} /><p className="chart-insight">1.5 × IQR bounds are applied sequentially to numeric columns in the original order. Removed: {quality.outliers.map(o => `${number(o.value)} ${o.variable === 'jarak' ? 'km' : o.variable}`).join(' and ')}. Whiskers end at the most extreme in-range values; red dots show values outside the displayed variable's IQR bounds.</p></Panel>
      <Panel title="Cleaning audit" note="All transformations documented"><div className="audit"><div><b>Missingness</b><p>{quality.missingTotal} missing or blank cells across {Object.keys(quality.missingByField).length} columns; calculated from source on each preprocessing run.</p></div><div><b>Category normalization</b><p>{quality.normalizedLabels} labels changed: “{quality.normalization.from}” → “{quality.normalization.to}” in vehicle performance. Raw CSV remains untouched.</p></div><div><b>Outlier treatment</b><p>{quality.outliers.map(o => `CSV row ${o.sourceRow}: ${number(o.value)} km`).join('; ')} removed only from the cleaned analytical copy. No record is silently discarded from the raw overview.</p></div><div><b>Current filter</b><p>{activeRecords.length} observations visible in the selected descriptive dataset.</p></div><div><b>Source-data caution</b><p>Very small reported costs (including values below Rp1.000) remain unchanged; their units may need confirmation with the original survey.</p></div></div></Panel></div></>
}
import { OutlierChart as OutlierPlot } from './Charts'
