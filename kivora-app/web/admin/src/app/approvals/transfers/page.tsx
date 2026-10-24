'use client';

import React, { useState } from 'react';
import {
  ArrowRightLeft,
  Building2,
  Check,
  X,
  Clock,
  User,
  ArrowRight,
} from 'lucide-react';

interface TransferRecord {
  id: string;
  member: string;
  identifier: string;
  role: string;
  sourceBranch: string;
  targetBranch: string;
  reason: string;
  submittedDate: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

const initialTransfers: TransferRecord[] = [
  {
    id: 'tr-01',
    member: 'Alex Johnson',
    identifier: 'STU00123',
    role: 'Student',
    sourceBranch: 'West Campus',
    targetBranch: 'East Campus',
    reason: 'Family residential relocation to Enugu State; academic transcript verified.',
    submittedDate: 'Today',
    status: 'PENDING',
  },
  {
    id: 'tr-02',
    member: 'Grace Okon',
    identifier: 'TEA0045',
    role: 'Teacher',
    sourceBranch: 'West Campus',
    targetBranch: 'North Campus',
    reason: 'Inter-departmental faculty transfer approved by Dean.',
    submittedDate: 'Yesterday',
    status: 'PENDING',
  },
  {
    id: 'tr-03',
    member: 'James Wilson',
    identifier: 'STU00124',
    role: 'Student',
    sourceBranch: 'East Campus',
    targetBranch: 'West Campus',
    reason: 'Academic lab specialization transfer.',
    submittedDate: 'Apr 10, 2025',
    status: 'APPROVED',
  },
];

export default function TransferReviewsPage() {
  const [transfers, setTransfers] = useState<TransferRecord[]>(initialTransfers);

  const handleDecision = (id: string, newStatus: 'APPROVED' | 'REJECTED') => {
    setTransfers((prev) =>
      prev.map((t) => (t.id === id ? { ...t, status: newStatus } : t))
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Inter-Branch Transfer Oversight</h1>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
            {transfers.filter((t) => t.status === 'PENDING').length} Open Transfer Petitions
          </span>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Review, approve, and execute seamless member relocations between organizational branches.
        </p>
      </div>

      {/* Transfer Cards */}
      <div className="space-y-4">
        {transfers.map((item) => (
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
                <div className="w-10 h-10 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-xs">
                  {item.member.split(' ').map((n) => n[0]).join('')}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900">{item.member}</span>
                    <span className="text-xs px-2 py-0.5 rounded bg-slate-100 text-slate-700 font-medium">
                      {item.role} • {item.identifier}
                    </span>
                  </div>
                  <span className="text-xs text-slate-400 mt-0.5 block">Submitted {item.submittedDate}</span>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center gap-2">
                {item.status === 'PENDING' ? (
                  <>
                    <button
                      onClick={() => handleDecision(item.id, 'APPROVED')}
                      className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
                    >
                      <Check className="w-3.5 h-3.5" />
                      Approve Relocation
                    </button>
                    <button
                      onClick={() => handleDecision(item.id, 'REJECTED')}
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

            {/* Path visualization */}
            <div className="flex items-center gap-3 p-4 rounded-xl bg-slate-50 border border-slate-100 text-xs">
              <div className="flex items-center gap-2 font-semibold text-slate-800">
                <Building2 className="w-4 h-4 text-slate-400" />
                <span>{item.sourceBranch}</span>
              </div>
              <ArrowRight className="w-4 h-4 text-teal-600" />
              <div className="flex items-center gap-2 font-bold text-teal-700">
                <Building2 className="w-4 h-4 text-teal-600" />
                <span>{item.targetBranch}</span>
              </div>
            </div>

            <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-xs">
              <span className="text-slate-400 block font-medium">Relocation Justification:</span>
              <p className="text-slate-700 mt-1">{item.reason}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
