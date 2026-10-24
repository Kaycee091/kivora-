'use client';

import React, { useState } from 'react';
import {
  Download,
  FileSpreadsheet,
  FileText,
  Clock,
  ShieldCheck,
  CheckCircle2,
  Calendar,
  Building2,
} from 'lucide-react';

interface ExportLog {
  id: string;
  name: string;
  format: 'CSV' | 'PDF' | 'XLSX';
  generatedBy: string;
  timestamp: string;
  size: string;
  sha256: string;
}

const mockExportLogs: ExportLog[] = [
  {
    id: 'exp-01',
    name: 'West_Campus_April_Attendance_Summary.csv',
    format: 'CSV',
    generatedBy: 'Admin User',
    timestamp: '21 Apr 2025, 08:45 AM',
    size: '1.2 MB',
    sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  },
  {
    id: 'exp-02',
    name: 'Audit_History_Security_Logs_Q1.xlsx',
    format: 'XLSX',
    generatedBy: 'Sarah Wilson',
    timestamp: '15 Apr 2025, 04:12 PM',
    size: '3.4 MB',
    sha256: 'c29013c87f465c490a6e3427357876a4dfc8df59a60e0a514d7a85eb80336048',
  },
  {
    id: 'exp-03',
    name: 'Verified_Roster_ID_Documents_Index.pdf',
    format: 'PDF',
    generatedBy: 'Admin User',
    timestamp: '01 Apr 2025, 11:20 AM',
    size: '850 KB',
    sha256: '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
  },
];

export default function ExportCenterPage() {
  const [dataset, setDataset] = useState('attendance');
  const [format, setFormat] = useState('CSV');
  const [branch, setBranch] = useState('West Campus');
  const [isExporting, setIsExporting] = useState(false);
  const [exportComplete, setExportComplete] = useState(false);

  const handleExport = (e: React.FormEvent) => {
    e.preventDefault();
    setIsExporting(true);
    setTimeout(() => {
      setIsExporting(false);
      setExportComplete(true);
      setTimeout(() => setExportComplete(false), 3000);
    }, 1200);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Compliance Export Center</h1>
        <p className="text-sm text-slate-500 mt-1">
          Generate secure, cryptographically hashed compliance archives and audit exports.
        </p>
      </div>

      {/* Export Generator Card */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-5">
        <h2 className="font-bold text-slate-900 text-sm">Generate New Export Dataset</h2>

        <form onSubmit={handleExport} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Target Dataset:</label>
              <select
                value={dataset}
                onChange={(e) => setDataset(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white"
              >
                <option value="attendance">Complete Attendance Log & Telemetry</option>
                <option value="members">Verified Member Directory & Roles</option>
                <option value="audit">System Audit Trail & Admin Actions</option>
                <option value="exceptions">Verification Exceptions & Waivers</option>
              </select>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Scope Branch:</label>
              <select
                value={branch}
                onChange={(e) => setBranch(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white"
              >
                <option value="All Branches">All Organization Branches</option>
                <option value="West Campus">West Campus</option>
                <option value="East Campus">East Campus</option>
                <option value="North Campus">North Campus</option>
              </select>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Export Format:</label>
              <select
                value={format}
                onChange={(e) => setFormat(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white"
              >
                <option value="CSV">Comma-Separated Values (.CSV)</option>
                <option value="XLSX">Microsoft Excel (.XLSX)</option>
                <option value="PDF">Formal Compliance Document (.PDF)</option>
              </select>
            </div>
          </div>

          <div className="flex justify-end pt-2">
            <button
              type="submit"
              disabled={isExporting}
              className="inline-flex items-center gap-2 px-5 py-2.5 text-xs font-bold rounded-xl bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all disabled:opacity-50"
            >
              <Download className={`w-4 h-4 ${isExporting ? 'animate-bounce' : ''}`} />
              {isExporting ? 'Generating Signed Archive...' : 'Generate & Download Export'}
            </button>
          </div>
        </form>

        {exportComplete && (
          <div className="p-3.5 bg-emerald-50 border border-emerald-200 rounded-xl flex items-center gap-2 text-xs text-emerald-800 font-medium">
            <CheckCircle2 className="w-4 h-4 text-emerald-600 flex-shrink-0" />
            <span>Export generated successfully and logged to the administrative audit trail.</span>
          </div>
        )}
      </div>

      {/* Historical Exports Audit Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-4 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
          <span className="text-xs font-bold uppercase text-slate-600 tracking-wider">
            Export History & Cryptographic Hashes
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Filename</th>
                <th className="px-6 py-3.5">Format</th>
                <th className="px-6 py-3.5">Generated By</th>
                <th className="px-6 py-3.5">Timestamp</th>
                <th className="px-6 py-3.5">File Size</th>
                <th className="px-6 py-3.5">SHA-256 Digest</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {mockExportLogs.map((log) => (
                <tr key={log.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4 font-semibold text-slate-900 flex items-center gap-2">
                    <FileSpreadsheet className="w-4 h-4 text-teal-600 flex-shrink-0" />
                    <span>{log.name}</span>
                  </td>
                  <td className="px-6 py-4 font-mono text-xs text-slate-700">{log.format}</td>
                  <td className="px-6 py-4 text-xs text-slate-600">{log.generatedBy}</td>
                  <td className="px-6 py-4 text-xs text-slate-600">{log.timestamp}</td>
                  <td className="px-6 py-4 text-xs text-slate-600">{log.size}</td>
                  <td className="px-6 py-4 font-mono text-[10px] text-slate-400 truncate max-w-xs" title={log.sha256}>
                    {log.sha256.slice(0, 16)}...
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
