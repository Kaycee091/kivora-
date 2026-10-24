'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  Clock,
  Search,
  Filter,
  RefreshCw,
  Eye,
  CheckCircle2,
  AlertTriangle,
  XCircle,
  MapPin,
  Wifi,
  Fingerprint,
} from 'lucide-react';

interface AttendanceFeedItem {
  id: string;
  member: string;
  avatar: string;
  role: 'Student' | 'Teacher' | 'Staff';
  session: string;
  branch: string;
  checkInTime: string;
  status: 'Present' | 'Late' | 'Needs Review' | 'Failed';
  verification: {
    biometric: 'PASSED' | 'FAILED' | 'UNAVAILABLE';
    gps: 'PASSED' | 'FAILED' | 'NEEDS_REVIEW';
    network: 'PASSED' | 'FAILED' | 'UNAVAILABLE';
  };
}

const mockFeed: AttendanceFeedItem[] = [
  {
    id: 'rec-001',
    member: 'Sarah Johnson',
    avatar: 'SJ',
    role: 'Student',
    session: 'Computer Science 201',
    branch: 'West Campus',
    checkInTime: '08:02 AM',
    status: 'Present',
    verification: { biometric: 'PASSED', gps: 'PASSED', network: 'PASSED' },
  },
  {
    id: 'rec-002',
    member: 'Michael Brown',
    avatar: 'MB',
    role: 'Teacher',
    session: 'Mathematics 101',
    branch: 'West Campus',
    checkInTime: '07:58 AM',
    status: 'Present',
    verification: { biometric: 'PASSED', gps: 'PASSED', network: 'PASSED' },
  },
  {
    id: 'rec-003',
    member: 'Emily Davis',
    avatar: 'ED',
    role: 'Staff',
    session: 'Administration Office',
    branch: 'West Campus',
    checkInTime: '08:35 AM',
    status: 'Needs Review',
    verification: { biometric: 'PASSED', gps: 'NEEDS_REVIEW', network: 'FAILED' },
  },
  {
    id: 'rec-004',
    member: 'James Wilson',
    avatar: 'JW',
    role: 'Student',
    session: 'Physics 101',
    branch: 'East Campus',
    checkInTime: '08:42 AM',
    status: 'Late',
    verification: { biometric: 'PASSED', gps: 'PASSED', network: 'PASSED' },
  },
  {
    id: 'rec-005',
    member: 'Olivia Martinez',
    avatar: 'OM',
    role: 'Teacher',
    session: 'Programming Fundamentals',
    branch: 'West Campus',
    checkInTime: '07:50 AM',
    status: 'Present',
    verification: { biometric: 'PASSED', gps: 'PASSED', network: 'PASSED' },
  },
  {
    id: 'rec-006',
    member: 'David Wilson',
    avatar: 'DW',
    role: 'Student',
    session: 'Practical Lab B',
    branch: 'West Campus',
    checkInTime: '08:15 AM',
    status: 'Failed',
    verification: { biometric: 'FAILED', gps: 'PASSED', network: 'FAILED' },
  },
];

export default function LiveAttendancePage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [roleFilter, setRoleFilter] = useState<string>('ALL');
  const [isRefreshing, setIsRefreshing] = useState(false);

  const filteredItems = mockFeed.filter((item) => {
    const matchesSearch =
      item.member.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.session.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.branch.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'ALL' || item.status === statusFilter;
    const matchesRole = roleFilter === 'ALL' || item.role === roleFilter;
    return matchesSearch && matchesStatus && matchesRole;
  });

  const handleRefresh = () => {
    setIsRefreshing(true);
    setTimeout(() => setIsRefreshing(false), 600);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Live Attendance Monitor</h1>
            <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
              Live Stream Active
            </span>
          </div>
          <p className="text-sm text-slate-500 mt-1">
            Real-time feed of member check-in verification events across all branches.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={handleRefresh}
            className="inline-flex items-center gap-2 px-3.5 py-2 text-sm font-semibold rounded-lg bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 shadow-sm transition-all"
          >
            <RefreshCw className={`w-4 h-4 ${isRefreshing ? 'animate-spin text-teal-600' : ''}`} />
            Refresh Feed
          </button>
        </div>
      </div>

      {/* KPI Highlights */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Today&apos;s Active Check-ins</span>
          <p className="text-2xl font-bold text-slate-900 mt-1">1,428</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">On-Time Presence</span>
          <p className="text-2xl font-bold text-emerald-600 mt-1">94.2%</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Flagged Exceptions</span>
          <p className="text-2xl font-bold text-amber-600 mt-1">4</p>
        </div>
        <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Failed Attempts</span>
          <p className="text-2xl font-bold text-rose-600 mt-1">1</p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by member name, session or branch..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full md:w-auto">
          <div className="flex items-center gap-2">
            <Filter className="w-4 h-4 text-slate-400" />
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
            >
              <option value="ALL">All Statuses</option>
              <option value="Present">Present</option>
              <option value="Late">Late</option>
              <option value="Needs Review">Needs Review</option>
              <option value="Failed">Failed</option>
            </select>
          </div>

          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Roles</option>
            <option value="Student">Students</option>
            <option value="Teacher">Teachers</option>
            <option value="Staff">Staff</option>
          </select>
        </div>
      </div>

      {/* Live Stream Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Member</th>
                <th className="px-6 py-3.5">Role</th>
                <th className="px-6 py-3.5">Session / Class</th>
                <th className="px-6 py-3.5">Branch</th>
                <th className="px-6 py-3.5">Timestamp</th>
                <th className="px-6 py-3.5">Verification Signals</th>
                <th className="px-6 py-3.5">Attendance Status</th>
                <th className="px-6 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredItems.map((item) => (
                <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-xs">
                        {item.avatar}
                      </div>
                      <span className="font-semibold text-slate-900">{item.member}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-slate-600 text-xs font-medium">{item.role}</td>
                  <td className="px-6 py-4 text-slate-800 font-medium">{item.session}</td>
                  <td className="px-6 py-4 text-slate-600 text-xs">{item.branch}</td>
                  <td className="px-6 py-4 text-slate-600 text-xs flex items-center gap-1.5">
                    <Clock className="w-3.5 h-3.5 text-slate-400" />
                    {item.checkInTime}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <span
                        title={`Biometric: ${item.verification.biometric}`}
                        className={`p-1 rounded ${
                          item.verification.biometric === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-600'
                            : item.verification.biometric === 'FAILED'
                            ? 'bg-rose-50 text-rose-600'
                            : 'bg-slate-100 text-slate-400'
                        }`}
                      >
                        <Fingerprint className="w-4 h-4" />
                      </span>
                      <span
                        title={`GPS Geofence: ${item.verification.gps}`}
                        className={`p-1 rounded ${
                          item.verification.gps === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-600'
                            : item.verification.gps === 'NEEDS_REVIEW'
                            ? 'bg-amber-50 text-amber-600'
                            : 'bg-rose-50 text-rose-600'
                        }`}
                      >
                        <MapPin className="w-4 h-4" />
                      </span>
                      <span
                        title={`Network: ${item.verification.network}`}
                        className={`p-1 rounded ${
                          item.verification.network === 'PASSED'
                            ? 'bg-emerald-50 text-emerald-600'
                            : 'bg-slate-100 text-slate-400'
                        }`}
                      >
                        <Wifi className="w-4 h-4" />
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-xs font-semibold ${
                        item.status === 'Present'
                          ? 'bg-emerald-50 text-emerald-700'
                          : item.status === 'Late'
                          ? 'bg-amber-50 text-amber-700'
                          : item.status === 'Needs Review'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-rose-50 text-rose-700'
                      }`}
                    >
                      {item.status === 'Present' && <CheckCircle2 className="w-3.5 h-3.5" />}
                      {item.status === 'Needs Review' && <AlertTriangle className="w-3.5 h-3.5" />}
                      {item.status === 'Failed' && <XCircle className="w-3.5 h-3.5" />}
                      {item.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <Link
                      href={`/attendance/records/${item.id}`}
                      className="inline-flex items-center gap-1 px-3 py-1.5 text-xs font-semibold rounded-lg text-teal-600 bg-teal-50 hover:bg-teal-100 transition-colors"
                    >
                      <Eye className="w-3.5 h-3.5" />
                      Inspect
                    </Link>
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
