'use client';

import React, { useState } from 'react';
import {
  Coffee,
  Clock,
  Save,
  Check,
  AlertCircle,
  Sliders,
} from 'lucide-react';

export default function BreaksPolicyPage() {
  const [mandatoryBreakMins, setMandatoryBreakMins] = useState(45);
  const [shiftThresholdHours, setShiftThresholdHours] = useState(4);
  const [autoDeduct, setAutoDeduct] = useState(true);
  const [maxBreakMins, setMaxBreakMins] = useState(60);
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
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Breaks & Shift Duration Policies</h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure approved intermission durations, auto-deductions, and shift rest thresholds.
          </p>
        </div>

        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          {saved ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          {saved ? 'Rules Updated!' : 'Save Break Rules'}
        </button>
      </div>

      {/* Rules Config Form */}
      <form onSubmit={handleSave} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
        {/* Mandatory Break Duration */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Mandatory Rest Break Duration</span>
            <span className="text-[11px] text-slate-500 block">
              Default allotted meal or intermission time for long shifts.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="15"
              max="120"
              value={mandatoryBreakMins}
              onChange={(e) => setMandatoryBreakMins(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>

        {/* Shift Length Trigger */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Shift Length Trigger for Break</span>
            <span className="text-[11px] text-slate-500 block">
              Continuous session duration that mandates a break allowance.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="2"
              max="12"
              value={shiftThresholdHours}
              onChange={(e) => setShiftThresholdHours(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">hours</span>
          </div>
        </div>

        {/* Automatic Deduction Switch */}
        <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Automatic Break Deduction</span>
            <span className="text-[11px] text-slate-500 block">
              Automatically deduct break minutes from total logged duration for eligible shifts.
            </span>
          </div>
          <input
            type="checkbox"
            checked={autoDeduct}
            onChange={(e) => setAutoDeduct(e.target.checked)}
            className="w-4 h-4 text-teal-600 rounded focus:ring-teal-500"
          />
        </div>

        {/* Max Break Allowed */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 p-4 rounded-xl bg-slate-50 border border-slate-100">
          <div className="space-y-0.5 max-w-md">
            <span className="font-bold text-xs text-slate-900 block">Maximum Permitted Break Overstay</span>
            <span className="text-[11px] text-slate-500 block">
              Flag early departure or attendance exception if break duration exceeds this limit.
            </span>
          </div>
          <div className="flex items-center gap-2">
            <input
              type="number"
              min="30"
              max="180"
              value={maxBreakMins}
              onChange={(e) => setMaxBreakMins(Number(e.target.value))}
              className="w-20 text-xs font-bold text-center p-2 rounded-lg border border-slate-200 focus:ring-2 focus:ring-teal-500"
            />
            <span className="text-xs text-slate-500 font-medium">mins</span>
          </div>
        </div>
      </form>
    </div>
  );
}
