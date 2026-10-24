'use client';

import React, { useState } from 'react';
import {
  Sliders,
  Clock,
  AlertTriangle,
  Save,
  Check,
  Shield,
  Calendar,
} from 'lucide-react';

export default function AttendanceRulesPage() {
  const [gracePeriod, setGracePeriod] = useState(15);
  const [lateThreshold, setLateThreshold] = useState(30);
  const [halfDayMinutes, setHalfDayMinutes] = useState(180);
  const [consecutiveAbsenceAlert, setConsecutiveAbsenceAlert] = useState(3);
  const [autoAbsentMinutes, setAutoAbsentMinutes] = useState(60);
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Attendance Verification Policies & Rules</h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure system-wide grace periods, late thresholds, and automatic absence evaluation.
          </p>
        </div>

        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          {saved ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          {saved ? 'Rules Updated!' : 'Save Rules'}
        </button>
      </div>

      {/* Rules Config Form */}
      <form onSubmit={handleSave} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
        {/* Grace Period */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Check-In Grace Window (Minutes)</span>
            <span className="text-[11px] text-slate-500 block">
              Check-ins recorded within this buffer after scheduled session start are logged as Present.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="0"
              max="60"
              value={gracePeriod}
              onChange={(e) => setGracePeriod(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>

        {/* Late Threshold */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Late Arrival Threshold (Minutes)</span>
            <span className="text-[11px] text-slate-500 block">
              Arrivals beyond the grace period but before this limit are marked as Late.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="15"
              max="120"
              value={lateThreshold}
              onChange={(e) => setLateThreshold(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>

        {/* Auto Absence */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Automatic Absent Trigger (Minutes)</span>
            <span className="text-[11px] text-slate-500 block">
              Members with no check-in after this duration from start are automatically designated Absent.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="30"
              max="240"
              value={autoAbsentMinutes}
              onChange={(e) => setAutoAbsentMinutes(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>

        {/* Half Day Cutoff */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Half-Day Minimum Presence Duration</span>
            <span className="text-[11px] text-slate-500 block">
              Required cumulative logged minutes to qualify for half-day attendance credit.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="60"
              max="360"
              value={halfDayMinutes}
              onChange={(e) => setHalfDayMinutes(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>

        {/* Consecutive Absence Alert */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Consecutive Unexcused Absence Alert</span>
            <span className="text-[11px] text-slate-500 block">
              Trigger automated warning to supervisor when unexcused absences reach this count.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="1"
              max="10"
              value={consecutiveAbsenceAlert}
              onChange={(e) => setConsecutiveAbsenceAlert(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">days</span>
          </div>
        </div>
      </form>
    </div>
  );
}
