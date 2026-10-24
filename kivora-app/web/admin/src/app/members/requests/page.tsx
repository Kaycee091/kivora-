'use client';

import React, { useState } from 'react';
import {
  UserCheck,
  FileText,
  Check,
  X,
  ExternalLink,
  Shield,
  Eye,
  AlertCircle,
  Building2,
} from 'lucide-react';

interface JoinRequest {
  id: string;
  name: string;
  email: string;
  phone: string;
  requestedRole: string;
  branch: string;
  inviteCode: string;
  submittedAt: string;
  documents: {
    name: string;
    type: string;
    verified: boolean;
  }[];
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
}

const initialRequests: JoinRequest[] = [
  {
    id: 'req-001',
    name: 'David Wilson',
    email: 'david.wilson@kivora.org',
    phone: '+234 801 234 5678',
    requestedRole: 'Student',
    branch: 'West Campus',
    inviteCode: 'KIV-9F3D-7A2B',
    submittedAt: 'Today at 09:15 AM',
    documents: [
      { name: 'Profile Photo', type: 'JPG Image', verified: true },
      { name: 'National ID Slip (NIN)', type: 'PDF Document', verified: true },
      { name: 'Admission Offer Letter', type: 'PDF Document', verified: false },
    ],
    status: 'PENDING',
  },
  {
    id: 'req-002',
    name: 'Khadijah Bello',
    email: 'khadijah.bello@kivora.edu.ng',
    phone: '+234 802 987 6543',
    requestedRole: 'Teacher',
    branch: 'East Campus',
    inviteCode: 'KIV-TEA-2025',
    submittedAt: 'Yesterday at 04:30 PM',
    documents: [
      { name: 'Profile Photo', type: 'PNG Image', verified: true },
      { name: 'National Identity Card', type: 'PDF Document', verified: true },
      { name: 'Teaching License Cert', type: 'PDF Document', verified: true },
    ],
    status: 'PENDING',
  },
  {
    id: 'req-003',
    name: 'Chinedu Eze',
    email: 'chinedu.eze@kivora.org',
    phone: '+234 803 111 2233',
    requestedRole: 'Staff',
    branch: 'West Campus',
    inviteCode: 'KIV-ADM-5501',
    submittedAt: '2 days ago',
    documents: [
      { name: 'Profile Photo', type: 'JPG Image', verified: true },
      { name: 'Staff Verification Letter', type: 'PDF Document', verified: false },
    ],
    status: 'PENDING',
  },
];

export default function JoinRequestsPage() {
  const [requests, setRequests] = useState<JoinRequest[]>(initialRequests);
  const [activeDocPreview, setActiveDocPreview] = useState<string | null>(null);

  const handleDecision = (id: string, newStatus: 'APPROVED' | 'REJECTED') => {
    setRequests((prev) =>
      prev.map((r) => (r.id === id ? { ...r, status: newStatus } : r))
    );
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Join Requests & Identity Document Review</h1>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-amber-50 text-amber-700 border border-amber-200">
            {requests.filter((r) => r.status === 'PENDING').length} Awaiting Verification
          </span>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Review incoming branch join requests, inspect uploaded identity documents, and assign verified memberships.
        </p>
      </div>

      {/* Requests List */}
      <div className="space-y-6">
        {requests.map((req) => (
          <div
            key={req.id}
            className={`bg-white p-6 rounded-2xl border shadow-sm space-y-5 transition-all ${
              req.status === 'APPROVED'
                ? 'border-emerald-200 bg-emerald-50/10'
                : req.status === 'REJECTED'
                ? 'border-slate-200 opacity-60'
                : 'border-slate-200'
            }`}
          >
            {/* Top row */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-slate-100">
              <div className="flex items-center gap-3">
                <div className="w-11 h-11 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-sm">
                  {req.name.split(' ').map((n) => n[0]).join('')}
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-bold text-slate-900 text-base">{req.name}</h3>
                    <span className="text-xs px-2.5 py-0.5 rounded-full bg-teal-50 text-teal-700 font-semibold border border-teal-200">
                      Requested: {req.requestedRole}
                    </span>
                  </div>
                  <div className="text-xs text-slate-500 mt-0.5 flex items-center gap-2">
                    <span>{req.email}</span>
                    <span>•</span>
                    <span>{req.phone}</span>
                    <span>•</span>
                    <span className="font-mono text-slate-400">Code: {req.inviteCode}</span>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex items-center gap-2">
                {req.status === 'PENDING' ? (
                  <>
                    <button
                      onClick={() => handleDecision(req.id, 'APPROVED')}
                      className="inline-flex items-center gap-1.5 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
                    >
                      <Check className="w-4 h-4" />
                      Approve Membership
                    </button>
                    <button
                      onClick={() => handleDecision(req.id, 'REJECTED')}
                      className="inline-flex items-center gap-1.5 px-4 py-2 text-xs font-semibold rounded-lg bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200 transition-all"
                    >
                      <X className="w-4 h-4" />
                      Reject
                    </button>
                  </>
                ) : (
                  <span
                    className={`text-xs font-bold px-3 py-1.5 rounded-lg ${
                      req.status === 'APPROVED' ? 'bg-emerald-100 text-emerald-800' : 'bg-rose-100 text-rose-800'
                    }`}
                  >
                    {req.status}
                  </span>
                )}
              </div>
            </div>

            {/* Document attachments review list */}
            <div>
              <span className="text-xs font-bold text-slate-700 uppercase tracking-wider block mb-3">
                Submitted Identity Documents:
              </span>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {req.documents.map((doc, idx) => (
                  <div
                    key={idx}
                    className="p-3 rounded-xl border border-slate-200 bg-slate-50 flex items-center justify-between hover:bg-slate-100/80 transition-colors"
                  >
                    <div className="flex items-center gap-2.5 overflow-hidden">
                      <FileText className="w-4 h-4 text-teal-600 flex-shrink-0" />
                      <div className="truncate">
                        <span className="text-xs font-semibold text-slate-800 block truncate">{doc.name}</span>
                        <span className="text-[10px] text-slate-400">{doc.type}</span>
                      </div>
                    </div>
                    <button
                      onClick={() => setActiveDocPreview(`${req.name} — ${doc.name}`)}
                      className="text-xs font-semibold text-teal-600 hover:text-teal-700 flex items-center gap-1 flex-shrink-0 ml-2"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      Inspect
                    </button>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Document Inspector Modal */}
      {activeDocPreview && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 space-y-4 shadow-xl border border-slate-200">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-slate-900 text-sm">Identity Document Verification</h3>
              <button
                onClick={() => setActiveDocPreview(null)}
                className="text-slate-400 hover:text-slate-600 p-1"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-8 bg-slate-100 rounded-xl text-center space-y-2 border border-dashed border-slate-300">
              <Shield className="w-12 h-12 text-teal-600 mx-auto" />
              <p className="font-semibold text-slate-800 text-sm">{activeDocPreview}</p>
              <p className="text-xs text-slate-500">
                Securely encrypted storage artifact verified against PRD data retention policies.
              </p>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                onClick={() => setActiveDocPreview(null)}
                className="px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700"
              >
                Done Viewing
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
