import type { Companion } from '../lib/ops.ts';

interface CompanionSelectProps {
  label: string;
  companions: Companion[];
  value: string;
  onChange: (id: string) => void;
}

// Lists every companion, including unverified ones: the database decides
// eligibility and its error is shown to ops as written.
export function CompanionSelect({ label, companions, value, onChange }: CompanionSelectProps) {
  return (
    <label>
      {label}
      <select value={value} onChange={(e) => onChange(e.target.value)}>
        <option value="">Choose a companion</option>
        {companions.map((c) => (
          <option key={c.id} value={c.id}>
            {c.name}{c.verificationStatus === 'verified' && c.active ? '' : ` (${c.active ? c.verificationStatus : 'inactive'})`}
          </option>
        ))}
      </select>
    </label>
  );
}

export function companionName(companions: Companion[], id: string | null): string {
  if (!id) return 'Unassigned';
  return companions.find((c) => c.id === id)?.name ?? 'Unknown companion';
}
