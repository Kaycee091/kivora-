'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import {
  ArrowLeft,
  ShieldAlert,
  ShieldCheck,
  AlertTriangle,
  Lock,
  RotateCcw,
  Clock,
  CheckCircle2,
} from 'lucide-react';

export default function AccountStatusPage() {
  const params = useParams();
  const router = useRouter();
  const id = params?.id as string || 'usr-001';

  const [status, setStatus] = useState<'active' | 'suspended' | 'archived'>('active');
  const [reason, setReason] = useState('');
  const [revokeSessions, setRevokeSessions] = useState(true);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    setTimeout(() => {
      router.push('/members');
    }, 1500);
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Link
          href="/members"
          className="p-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-slate-900 shadow-sm"
        >
          <ArrowLeft className="w-5 h-5" />
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Account Status & Lifecycle Control</h1>
          <p className="text-xs text-slate-500 mt-0.5">Manage administrative lock, suspension, and reactivation for {id}</p>
        </div>
      </div>

      {submitted ? (
        <div className="bg-white p-8 rounded-2xl border border-emerald-200 shadow-sm text-center space-y-3">
          <CheckCircle2 className="w-12 h-12 text-emerald-600 mx-auto" />
          <h2 className="text-lg font-bold text-slate-900">Account Status Updated Successfully</h2>
          <p className="text-xs text-slate-500">
            Audit log record created and active authorization tokens purged. Redirecting to directory...
          </p>
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
          {/* Member Card */}
          <div className="p-4 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between">
            <div>
              <span className="font-bold text-slate-900 text-sm block">Sarah Johnson</span>
              <span className="text-xs text-slate-500">sarah.johnson@kivora.edu.ng • Student ID: STU00123</span>
            </div>
            <span className="text-xs font-bold px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700">
              Current: Active
            </span>
          </div>

          {/* Status Choice */}
          <div className="space-y-3">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-700 block">
              Target Account State:
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <button
                type="button"
                onClick={() => setStatus('active')}
                className={`p-4 rounded-xl border text-left transition-all ${
                  status === 'active'
                    ? 'border-emerald-500 bg-emerald-50/50 ring-2 ring-emerald-500/20'
                    : 'border-slate-200 hover:border-slate-300'
                }`}
              >
                <ShieldCheck className="w-5 h-5 text-emerald-600 mb-1" />
                <span className="font-bold text-xs text-slate-900 block">Active & Verified</span>
                <span className="text-[11px] text-slate-500">Normal check-in allowed</span>
              </button>

              <button
                type="button"
                onClick={() => setStatus('suspended')}
                className={`p-4 rounded-xl border text-left transition-all ${
                  status === 'suspended'
                    ? 'border-rose-500 bg-rose-50/50 ring-2 ring-rose-500/20'
                    : 'border-slate-200 hover:border-slate-300'
                }`}
              >
                <ShieldAlert className="w-5 h-5 text-rose-600 mb-1" />
                <span className="font-bold text-xs text-slate-900 block">Suspended</span>
                <span className="text-[11px] text-slate-500">Block all mobile check-ins</span>
              </button>

              <button
                type="button"
                onClick={() => setStatus('archived')}
                className={`p-4 rounded-xl border text-left transition-all ${
                  status === 'archived'
                    ? 'border-slate-700 bg-slate-50 ring-2 ring-slate-400/20'
                    : 'border-slate-200 hover:border-slate-300'
                }`}
              >
                <Lock className="w-5 h-5 text-slate-700 mb-1" />
                <span className="font-bold text-xs text-slate-900 block">Archived / Inactive</span>
                <span className="text-[11px] text-slate-500">Graduated or departed</span>
              </button>
            </div>
          </div>

          {/* Reason Input */}
          <div className="space-y-2">
            <label className="text-xs font-bold uppercase tracking-wider text-slate-700 block">
              Administrative Justification (Mandatory for Audit Trail):
            </label>
            <textarea
              required
              rows={3}
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder="State the official rationale for this status transition..."
              className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
            />
          </div>

          {/* Session Invalidation Toggle */}
          <div className="flex items-center justify-between p-4 rounded-xl bg-slate-50 border border-slate-200">
            <div className="space-y-0.5">
              <span className="text-xs font-bold text-slate-900 block">Revoke Active Mobile Refresh Tokens</span>
              <span className="text-[11px] text-slate-500 block">
                Forces immediate logout across all installed Android and iOS devices.
              </span>
            </div>
            <input
              type="checkbox"
              checked={revokeSessions}
              onChange={(e) => setRevokeSessions(e.target.checked)}
              className="w-4 h-4 text-teal-600 rounded focus:ring-teal-500"
            />
          </div>

          {/* Submit Button */}
          <div className="flex justify-end gap-3 pt-2">
            <Link
              href="/members"
              className="px-4 py-2 text-xs font-semibold rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200"
            >
              Cancel
            </Link>
            <button
              type="submit"
              className="px-5 py-2 text-xs font-bold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
            >
              Apply Status Transition
            </button>
          </div>
        </form>
      )}
    </div>
  );
}
