'use client';

import React, { useState } from 'react';
import {
  ShieldCheck,
  Search,
  Filter,
  User,
  Clock,
  Layers,
  Building2,
} from 'lucide-react';

interface AuditEvent {
  id: string;
  actor: string;
  actorEmail: string;
  action: string;
  targetEntity: string;
  branch: string;
  timestamp: string;
  ipAddress: string;
  type: 'MEMBERSHIP' | 'SETTINGS' | 'SECURITY' | 'ATTENDANCE';
}

const mockAuditTrail: AuditEvent[] = [
  {
    id: 'aud-01',
    actor: 'Alex Johnson',
    actorEmail: 'alex.j@kivora.org',
    action: 'Branch attendance policies updated (Grace period: 15 mins)',
    targetEntity: 'attendance_policies:West-Campus',
    branch: 'West Campus',
    timestamp: '21 Apr 2025, 09:12 AM',
    ipAddress: '197.210.45.88',
    type: 'SETTINGS',
  },
  {
    id: 'aud-02',
    actor: 'Sarah Wilson',
    actorEmail: 'sarah.w@kivora.org',
    action: 'Member join petition approved (Sarah Johnson)',
    targetEntity: 'profiles:usr-001',
    branch: 'West Campus',
    timestamp: '21 Apr 2025, 08:30 AM',
    ipAddress: '197.210.45.12',
    type: 'MEMBERSHIP',
  },
  {
    id: 'aud-03',
    actor: 'Admin Operator',
    actorEmail: 'admin@kivora.org',
    action: 'Account suspended for disciplinary investigation (James Wilson)',
    targetEntity: 'profiles:usr-004',
    branch: 'East Campus',
    timestamp: '20 Apr 2025, 05:40 PM',
    ipAddress: '105.112.98.4',
    type: 'SECURITY',
  },
  {
    id: 'aud-04',
    actor: 'Sarah Wilson',
    actorEmail: 'sarah.w@kivora.org',
    action: 'New 7-day invitation code generated (KIV-9F3D-7A2B)',
    targetEntity: 'branch_invite_codes:West-Campus',
    branch: 'West Campus',
    timestamp: '20 Apr 2025, 11:15 AM',
    ipAddress: '197.210.45.12',
    type: 'MEMBERSHIP',
  },
  {
    id: 'aud-05',
    actor: 'Michael Brown',
    actorEmail: 'michael.b@kivora.edu.ng',
    action: 'Manual attendance correction approved (Emily Davis)',
    targetEntity: 'attendance_corrections:cor-201',
    branch: 'West Campus',
    timestamp: '19 Apr 2025, 02:00 PM',
    ipAddress: '197.210.45.90',
    type: 'ATTENDANCE',
  },
];

export default function AuditHistoryPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState('ALL');

  const filtered = mockAuditTrail.filter((a) => {
    const matchesSearch =
      a.actor.toLowerCase().includes(searchTerm.toLowerCase()) ||
      a.action.toLowerCase().includes(searchTerm.toLowerCase()) ||
      a.targetEntity.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesType = typeFilter === 'ALL' || a.type === typeFilter;
    return matchesSearch && matchesType;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Immutable System Audit Trail</h1>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-teal-50 text-teal-700 border border-teal-200">
            Append-Only
          </span>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Chronological record of privileged administrative actions, configuration changes, and security events.
        </p>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search audit trail by actor, action, or entity..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
          />
        </div>

        <div className="flex items-center gap-2">
          <Filter className="w-4 h-4 text-slate-400" />
          <select
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Event Types</option>
            <option value="MEMBERSHIP">Membership & Access</option>
            <option value="SETTINGS">Settings & Policies</option>
            <option value="SECURITY">Security & Status</option>
            <option value="ATTENDANCE">Attendance Operations</option>
          </select>
        </div>
      </div>

      {/* Audit Log Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Actor</th>
                <th className="px-6 py-3.5">Action Executed</th>
                <th className="px-6 py-3.5">Target Entity</th>
                <th className="px-6 py-3.5">Branch</th>
                <th className="px-6 py-3.5">Timestamp</th>
                <th className="px-6 py-3.5">Client IP</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((item) => (
                <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4">
                    <span className="font-semibold text-slate-900 block">{item.actor}</span>
                    <span className="text-[11px] text-slate-400 block">{item.actorEmail}</span>
                  </td>
                  <td className="px-6 py-4 text-xs font-medium text-slate-800">{item.action}</td>
                  <td className="px-6 py-4 font-mono text-[11px] text-teal-700">{item.targetEntity}</td>
                  <td className="px-6 py-4 text-xs text-slate-600">{item.branch}</td>
                  <td className="px-6 py-4 text-xs text-slate-600 whitespace-nowrap">{item.timestamp}</td>
                  <td className="px-6 py-4 font-mono text-xs text-slate-500">{item.ipAddress}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
