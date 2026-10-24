'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Eye,
  Filter,
  Check,
  X,
  Search,
  MapPin,
  Fingerprint,
  Wifi,
} from 'lucide-react';

interface ExceptionItem {
  id: string;
  member: string;
  role: string;
  session: string;
  branch: string;
  timestamp: string;
  flagReason: string;
  failingComponent: 'GPS' | 'BIOMETRIC' | 'NETWORK' | 'DUAL';
  status: 'PENDING' | 'APPROVED' | 'DISMISSED';
}

const initialExceptions: ExceptionItem[] = [
  {
    id: 'exc-101',
    member: 'Emily Davis',
    role: 'Staff',
    session: 'Administration Office',
    branch: 'West Campus',
    timestamp: '08:35 AM',
    flagReason: 'GPS reported distance (142m) exceeds 100m geofence radius by 42m',
    failingComponent: 'GPS',
    status: 'PENDING',
  },
  {
    id: 'exc-102',
    member: 'David Wilson',
    role: 'Student',
    session: 'Practical Lab B',
    branch: 'West Campus',
    timestamp: '08:15 AM',
    flagReason: 'Biometric cryptographic signature mismatch; fallback PIN used without admin waiver',
    failingComponent: 'BIOMETRIC',
    status: 'PENDING',
  },
  {
    id: 'exc-103',
    member: 'Tunde Bakare',
    role: 'Student',
    session: 'Physics 101',
    branch: 'East Campus',
    timestamp: '09:02 AM',
    flagReason: 'Cellular network IP detected outside verified campus CIDR range',
    failingComponent: 'NETWORK',
    status: 'PENDING',
  },
  {
    id: 'exc-104',
    member: 'Amina Yusuf',
    role: 'Teacher',
    session: 'Chemistry Lab',
    branch: 'North Campus',
    timestamp: '07:45 AM',
    flagReason: 'Device clock drift detected (> 5 minutes difference from server time)',
    failingComponent: 'DUAL',
    status: 'PENDING',
  },
];

export default function ExceptionsReviewPage() {
  const [exceptions, setExceptions] = useState<ExceptionItem[]>(initialExceptions);
  const [filterType, setFilterType] = useState<string>('ALL');

  const handleResolve = (id: string, newStatus: 'APPROVED' | 'DISMISSED') => {
    setExceptions((prev) =>
      prev.map((item) => (item.id === id ? { ...item, status: newStatus } : item))
    );
  };

  const filtered = exceptions.filter((item) => {
    if (filterType === 'ALL') return true;
    if (filterType === 'PENDING') return item.status === 'PENDING';
    return item.failingComponent === filterType;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Exceptions & Verification Review</h1>
            <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
              {exceptions.filter((e) => e.status === 'PENDING').length} Pending Review
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Resolve suspicious, flagged, or boundary-violating check-in events.
          </p>
        </div>
      </div>

      {/* Filter Chips */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {['ALL', 'PENDING', 'GPS', 'BIOMETRIC', 'NETWORK'].map((chip) => (
          <button
            key={chip}
            onClick={() => setFilterType(chip)}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filterType === chip
                ? 'bg-teal-600 text-white shadow-sm'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            {chip === 'ALL' ? 'All Exceptions' : chip === 'PENDING' ? 'Pending Only' : `${chip} Violations`}
          </button>
        ))}
      </div>

      {/* Exceptions Grid / List */}
      <div className="space-y-4">
        {filtered.map((item) => (
          <div
            key={item.id}
            className={`bg-white p-5 rounded-2xl border shadow-sm transition-all flex flex-col md:flex-row md:items-center justify-between gap-4 ${
              item.status === 'APPROVED'
                ? 'border-emerald-200 bg-emerald-50/20'
                : item.status === 'DISMISSED'
                ? 'border-slate-200 opacity-60'
                : 'border-amber-200'
            }`}
          >
            <div className="space-y-2">
              <div className="flex items-center gap-3">
                <span className="font-bold text-slate-900 text-base">{item.member}</span>
                <span className="text-xs px-2 py-0.5 rounded-md bg-slate-100 text-slate-600 font-medium">
                  {item.role}
                </span>
                <span className="text-xs text-slate-500">• {item.session} ({item.branch})</span>
                <span className="text-xs font-mono text-slate-400">@ {item.timestamp}</span>
              </div>

              <div className="flex items-start gap-2 text-xs">
                <AlertTriangle className="w-4 h-4 text-amber-500 flex-shrink-0 mt-0.5" />
                <p className="text-slate-700 font-medium">{item.flagReason}</p>
              </div>
            </div>

            {/* Actions */}
            <div className="flex items-center gap-2 flex-shrink-0">
              <Link
                href={`/attendance/records/${item.id}`}
                className="inline-flex items-center gap-1 px-3 py-2 text-xs font-semibold rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200 transition-colors"
              >
                <Eye className="w-3.5 h-3.5" />
                Telemetry
              </Link>

              {item.status === 'PENDING' ? (
                <>
                  <button
                    onClick={() => handleResolve(item.id, 'APPROVED')}
                    className="inline-flex items-center gap-1 px-3 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
                  >
                    <Check className="w-3.5 h-3.5" />
                    Approve Exception
                  </button>
                  <button
                    onClick={() => handleResolve(item.id, 'DISMISSED')}
                    className="inline-flex items-center gap-1 px-3 py-2 text-xs font-semibold rounded-lg bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200 transition-all"
                  >
                    <X className="w-3.5 h-3.5" />
                    Invalidate
                  </button>
                </>
              ) : (
                <span
                  className={`text-xs font-bold px-3 py-1.5 rounded-lg ${
                    item.status === 'APPROVED'
                      ? 'bg-emerald-100 text-emerald-800'
                      : 'bg-rose-100 text-rose-800'
                  }`}
                >
                  {item.status}
                </span>
              )}
            </div>
          </div>
        ))}

        {filtered.length === 0 && (
          <div className="bg-white p-12 text-center rounded-2xl border border-slate-200">
            <CheckCircle2 className="w-10 h-10 text-emerald-500 mx-auto mb-2" />
            <p className="text-sm font-semibold text-slate-800">No matching verification exceptions found</p>
            <p className="text-xs text-slate-500 mt-1">All telemetry events are currently in compliant states.</p>
          </div>
        )}
      </div>
    </div>
  );
}
