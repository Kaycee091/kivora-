'use client';

import React, { useState } from 'react';
import {
  FileEdit,
  Clock,
  CheckCircle2,
  XCircle,
  Check,
  X,
  AlertCircle,
  FileText,
  User,
} from 'lucide-react';

interface CorrectionRequest {
  id: string;
  member: string;
  role: string;
  session: string;
  branch: string;
  requestedCheckIn: string;
  requestedCheckOut: string;
  originalCheckIn: string;
  reason: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

const initialCorrections: CorrectionRequest[] = [
  {
    id: 'cor-201',
    member: 'Alex Johnson',
    role: 'Student',
    session: 'Computer Science 201',
    branch: 'West Campus',
    requestedCheckIn: '08:00 AM',
    requestedCheckOut: '10:05 AM',
    originalCheckIn: '08:02 AM (Missed Check-Out)',
    reason: 'Device battery died during session end; departed with instructor permission.',
    status: 'PENDING',
  },
  {
    id: 'cor-202',
    member: 'Grace Okon',
    role: 'Teacher',
    session: 'Mathematics 101',
    branch: 'West Campus',
    requestedCheckIn: '07:55 AM',
    requestedCheckOut: '11:00 AM',
    originalCheckIn: 'None (Forgot phone in vehicle)',
    reason: 'Conducted lecture on schedule; attendance verified by department head.',
    status: 'PENDING',
  },
  {
    id: 'cor-203',
    member: 'Samuel Adeyemi',
    role: 'Staff',
    session: 'Campus Facilities',
    branch: 'East Campus',
    requestedCheckIn: '07:30 AM',
    requestedCheckOut: '04:00 PM',
    originalCheckIn: '07:30 AM (Check-out missed due to network maintenance)',
    reason: 'Network router maintenance during end of shift.',
    status: 'PENDING',
  },
];

export default function ManualCorrectionsPage() {
  const [corrections, setCorrections] = useState<CorrectionRequest[]>(initialCorrections);

  const handleAction = (id: string, newStatus: 'APPROVED' | 'REJECTED') => {
    setCorrections((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status: newStatus } : c))
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Manual Corrections & Missed Check-Outs</h1>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
            {corrections.filter((c) => c.status === 'PENDING').length} Open Requests
          </span>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Review and audit retroactive attendance corrections submitted by members and staff.
        </p>
      </div>

      {/* Requests List */}
      <div className="space-y-4">
        {corrections.map((item) => (
          <div
            key={item.id}
            className={`bg-white p-6 rounded-2xl border shadow-sm space-y-4 transition-all ${
              item.status === 'APPROVED'
                ? 'border-emerald-200 bg-emerald-50/10'
                : item.status === 'REJECTED'
                ? 'border-slate-200 opacity-60'
                : 'border-slate-200'
            }`}
          >
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-sm">
                  {item.member.split(' ').map((n) => n[0]).join('')}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900">{item.member}</span>
                    <span className="text-xs px-2 py-0.5 rounded bg-slate-100 text-slate-700 font-medium">
                      {item.role}
                    </span>
                  </div>
                  <span className="text-xs text-slate-500">{item.session} • {item.branch}</span>
                </div>
              </div>

              {/* Status Badge or Action Buttons */}
              <div className="flex items-center gap-2">
                {item.status === 'PENDING' ? (
                  <>
                    <button
                      onClick={() => handleAction(item.id, 'APPROVED')}
                      className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
                    >
                      <Check className="w-3.5 h-3.5" />
                      Approve Correction
                    </button>
                    <button
                      onClick={() => handleAction(item.id, 'REJECTED')}
                      className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200 transition-all"
                    >
                      <X className="w-3.5 h-3.5" />
                      Reject
                    </button>
                  </>
                ) : (
                  <span
                    className={`text-xs font-bold px-3 py-1.5 rounded-lg ${
                      item.status === 'APPROVED' ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {item.status}
                  </span>
                )}
              </div>
            </div>

            {/* Timestamps Comparison */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-xs">
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-slate-400 block font-medium">Original Recorded State:</span>
                <span className="font-semibold text-slate-700 mt-0.5 block">{item.originalCheckIn}</span>
              </div>
              <div className="bg-teal-50/60 p-3 rounded-xl border border-teal-100">
                <span className="text-teal-700 block font-medium">Proposed Check-In Time:</span>
                <span className="font-semibold text-teal-900 mt-0.5 block">{item.requestedCheckIn}</span>
              </div>
              <div className="bg-teal-50/60 p-3 rounded-xl border border-teal-100">
                <span className="text-teal-700 block font-medium">Proposed Check-Out Time:</span>
                <span className="font-semibold text-teal-900 mt-0.5 block">{item.requestedCheckOut}</span>
              </div>
            </div>

            {/* Reason */}
            <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-xs">
              <span className="text-slate-400 block font-medium">Submitted Justification:</span>
              <p className="text-slate-700 mt-1">{item.reason}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
