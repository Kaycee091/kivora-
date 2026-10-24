'use client';

import React, { useState } from 'react';
import {
  FileCheck,
  Calendar,
  Clock,
  Check,
  X,
  User,
  Building2,
  Filter,
} from 'lucide-react';

interface ApprovalItem {
  id: string;
  type: 'Annual Leave' | 'Sick Leave' | 'Early Departure' | 'Missed Check-Out';
  member: string;
  role: string;
  branch: string;
  dates: string;
  reason: string;
  submittedAt: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

const initialApprovals: ApprovalItem[] = [
  {
    id: 'app-01',
    type: 'Annual Leave',
    member: 'Alex Johnson',
    role: 'Student',
    branch: 'West Campus',
    dates: 'Apr 21 – Apr 25, 2025 (5 days)',
    reason: 'Family event out of state; all prior coursework assignments submitted.',
    submittedAt: 'Today at 08:30 AM',
    status: 'PENDING',
  },
  {
    id: 'app-02',
    type: 'Early Departure',
    member: 'Sophia Clark',
    role: 'Teacher',
    branch: 'West Campus',
    dates: 'Apr 22, 2025 at 02:30 PM',
    reason: 'Scheduled medical appointment at Teaching Hospital.',
    submittedAt: 'Yesterday',
    status: 'PENDING',
  },
  {
    id: 'app-03',
    type: 'Sick Leave',
    member: 'David Taylor',
    role: 'Staff',
    branch: 'East Campus',
    dates: 'Apr 20 – Apr 22, 2025 (3 days)',
    reason: 'Severe malaria treatment; doctor certificate attached.',
    submittedAt: '2 days ago',
    status: 'PENDING',
  },
];

export default function UnifiedApprovalsPage() {
  const [approvals, setApprovals] = useState<ApprovalItem[]>(initialApprovals);
  const [typeFilter, setTypeFilter] = useState('ALL');

  const handleAction = (id: string, newStatus: 'APPROVED' | 'REJECTED') => {
    setApprovals((prev) =>
      prev.map((a) => (a.id === id ? { ...a, status: newStatus } : a))
    );
  };

  const filtered = approvals.filter(
    (a) => typeFilter === 'ALL' || a.type === typeFilter
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Leave & Early Departure Reviews</h1>
            <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
              {approvals.filter((a) => a.status === 'PENDING').length} Pending Decisions
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Institutional approvals hub for absence leaves, early check-outs, and excused departures.
          </p>
        </div>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {['ALL', 'Annual Leave', 'Sick Leave', 'Early Departure'].map((tab) => (
          <button
            key={tab}
            onClick={() => setTypeFilter(tab)}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              typeFilter === tab
                ? 'bg-teal-600 text-white shadow-sm'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            {tab === 'ALL' ? 'All Request Types' : tab}
          </button>
        ))}
      </div>

      {/* Approval Cards */}
      <div className="space-y-4">
        {filtered.map((item) => (
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
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-3 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-xs">
                  {item.member.split(' ').map((n) => n[0]).join('')}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900">{item.member}</span>
                    <span className="text-xs px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 font-medium">
                      {item.role}
                    </span>
                    <span className="text-xs font-semibold px-2.5 py-0.5 rounded-full bg-teal-50 text-teal-700 border border-teal-200">
                      {item.type}
                    </span>
                  </div>
                  <span className="text-xs text-slate-500 mt-0.5 block">{item.branch} • Submitted {item.submittedAt}</span>
                </div>
              </div>

              {/* Status or Buttons */}
              <div className="flex items-center gap-2">
                {item.status === 'PENDING' ? (
                  <>
                    <button
                      onClick={() => handleAction(item.id, 'APPROVED')}
                      className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
                    >
                      <Check className="w-3.5 h-3.5" />
                      Approve Request
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

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-slate-400 block font-medium">Requested Dates / Timeline:</span>
                <span className="font-semibold text-slate-800 mt-0.5 block">{item.dates}</span>
              </div>
              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100">
                <span className="text-slate-400 block font-medium">Justification / Remarks:</span>
                <p className="text-slate-700 mt-0.5">{item.reason}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
