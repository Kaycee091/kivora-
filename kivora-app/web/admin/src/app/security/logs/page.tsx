'use client';

import React, { useState } from 'react';
import {
  ShieldAlert,
  Search,
  Filter,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Fingerprint,
  MapPin,
  Wifi,
} from 'lucide-react';

interface TelemetryLog {
  id: string;
  member: string;
  checkType: 'BIOMETRIC' | 'GPS' | 'NETWORK';
  status: 'PASSED' | 'FAILED' | 'NEEDS_REVIEW';
  detail: string;
  deviceId: string;
  timestamp: string;
}

const mockTelemetryLogs: TelemetryLog[] = [
  {
    id: 'log-01',
    member: 'David Wilson',
    checkType: 'BIOMETRIC',
    status: 'FAILED',
    detail: 'Cryptographic keystore signature verification failed (3 retries exceeded)',
    deviceId: 'SM-A525F-81d2',
    timestamp: 'Today at 08:15 AM',
  },
  {
    id: 'log-02',
    member: 'Emily Davis',
    checkType: 'GPS',
    status: 'NEEDS_REVIEW',
    detail: 'Geofence breach: Reported location 142m from center (allowed radius: 100m)',
    deviceId: 'iPhone14,2-a98e',
    timestamp: 'Today at 08:35 AM',
  },
  {
    id: 'log-03',
    member: 'Sarah Johnson',
    checkType: 'BIOMETRIC',
    status: 'PASSED',
    detail: 'Fingerprint token authenticated with local OS Secure Enclave',
    deviceId: 'SM-G998B-e234',
    timestamp: 'Today at 08:02 AM',
  },
  {
    id: 'log-04',
    member: 'Michael Brown',
    checkType: 'NETWORK',
    status: 'PASSED',
    detail: 'Gateway BSSID (84:d4:7e:92:4a:12) matches authorized access point list',
    deviceId: 'Pixel7-3312',
    timestamp: 'Today at 07:58 AM',
  },
];

export default function SecurityLogsPage() {
  const [filterType, setFilterType] = useState('ALL');

  const filtered = mockTelemetryLogs.filter(
    (l) => filterType === 'ALL' || l.checkType === filterType
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <div className="flex items-center gap-2">
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Security & Verification Logs</h1>
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-rose-50 text-rose-700 border border-rose-200">
            Realtime Telemetry
          </span>
        </div>
        <p className="text-sm text-slate-500 mt-1">
          Low-level telemetry records for biometric challenges, geofence breaches, and access exceptions.
        </p>
      </div>

      {/* Filter Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1">
        {['ALL', 'BIOMETRIC', 'GPS', 'NETWORK'].map((tab) => (
          <button
            key={tab}
            onClick={() => setFilterType(tab)}
            className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              filterType === tab
                ? 'bg-teal-600 text-white shadow-sm'
                : 'bg-white text-slate-600 border border-slate-200 hover:bg-slate-50'
            }`}
          >
            {tab === 'ALL' ? 'All Verification Events' : `${tab} Logs`}
          </button>
        ))}
      </div>

      {/* Telemetry Stream */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Member</th>
                <th className="px-6 py-3.5">Check Subsystem</th>
                <th className="px-6 py-3.5">Verification Outcome</th>
                <th className="px-6 py-3.5">Telemetry Message</th>
                <th className="px-6 py-3.5">Device ID</th>
                <th className="px-6 py-3.5">Timestamp</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filtered.map((log) => (
                <tr key={log.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4 font-semibold text-slate-900">{log.member}</td>
                  <td className="px-6 py-4 text-xs font-mono text-slate-700 flex items-center gap-1.5">
                    {log.checkType === 'BIOMETRIC' && <Fingerprint className="w-4 h-4 text-teal-600" />}
                    {log.checkType === 'GPS' && <MapPin className="w-4 h-4 text-teal-600" />}
                    {log.checkType === 'NETWORK' && <Wifi className="w-4 h-4 text-teal-600" />}
                    <span>{log.checkType}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                        log.status === 'PASSED'
                          ? 'bg-emerald-50 text-emerald-700'
                          : log.status === 'FAILED'
                          ? 'bg-rose-50 text-rose-700'
                          : 'bg-amber-50 text-amber-700'
                      }`}
                    >
                      {log.status === 'PASSED' && <CheckCircle2 className="w-3.5 h-3.5" />}
                      {log.status === 'FAILED' && <XCircle className="w-3.5 h-3.5" />}
                      {log.status === 'NEEDS_REVIEW' && <AlertTriangle className="w-3.5 h-3.5" />}
                      {log.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-xs text-slate-700 max-w-sm">{log.detail}</td>
                  <td className="px-6 py-4 font-mono text-xs text-slate-500">{log.deviceId}</td>
                  <td className="px-6 py-4 text-xs text-slate-500 whitespace-nowrap">{log.timestamp}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
