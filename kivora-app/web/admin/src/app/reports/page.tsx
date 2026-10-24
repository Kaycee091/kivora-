'use client';

import React, { useState } from 'react';
import {
  BarChart3,
  Calendar,
  Filter,
  Download,
  TrendingUp,
  CheckCircle2,
  Clock,
  AlertTriangle,
  Building2,
} from 'lucide-react';
import Link from 'next/link';

export default function ReportsAnalyticsPage() {
  const [dateRange, setDateRange] = useState('Apr 1 - Apr 30, 2025');
  const [branchFilter, setBranchFilter] = useState('ALL');

  const roleAttendance = [
    { role: 'Students', total: 1140, attended: 1072, rate: '94.0%' },
    { role: 'Teachers', total: 64, attended: 62, rate: '96.8%' },
    { role: 'Administrative Staff', total: 38, attended: 35, rate: '92.1%' },
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Institutional Reports & Analytics</h1>
          <p className="text-sm text-slate-500 mt-1">
            Aggregated attendance trends, role segment compliance, and verification rate analytics.
          </p>
        </div>

        <Link
          href="/exports"
          className="inline-flex items-center gap-2 px-3.5 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <Download className="w-4 h-4" />
          Export Report Data
        </Link>
      </div>

      {/* Filter Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col sm:flex-row gap-4 items-center justify-between">
        <div className="flex items-center gap-2 text-xs text-slate-600">
          <Calendar className="w-4 h-4 text-teal-600" />
          <span className="font-semibold">Period:</span>
          <span className="font-mono text-slate-800 bg-slate-100 px-2.5 py-1 rounded-md">{dateRange}</span>
        </div>

        <div className="flex items-center gap-3">
          <Building2 className="w-4 h-4 text-slate-400" />
          <select
            value={branchFilter}
            onChange={(e) => setBranchFilter(e.target.value)}
            className="text-xs border border-slate-200 rounded-lg px-3 py-1.5 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Branches</option>
            <option value="West Campus">West Campus</option>
            <option value="East Campus">East Campus</option>
            <option value="North Campus">North Campus</option>
          </select>
        </div>
      </div>

      {/* Key Metric Gauges */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Average Attendance Rate</span>
          <div className="flex items-baseline gap-2 mt-2">
            <span className="text-3xl font-extrabold text-slate-900">94.2%</span>
            <span className="text-xs font-semibold text-emerald-600 flex items-center gap-0.5">
              <TrendingUp className="w-3.5 h-3.5" /> +1.8%
            </span>
          </div>
          <span className="text-[11px] text-slate-400 mt-1 block">vs preceding 30-day baseline</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Total Scheduled Sessions</span>
          <div className="flex items-baseline gap-2 mt-2">
            <span className="text-3xl font-extrabold text-slate-900">482</span>
          </div>
          <span className="text-[11px] text-slate-400 mt-1 block">Across all academic cohorts</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Late Arrivals Recorded</span>
          <div className="flex items-baseline gap-2 mt-2">
            <span className="text-3xl font-extrabold text-amber-600">38</span>
          </div>
          <span className="text-[11px] text-slate-400 mt-1 block">2.6% of all recorded events</span>
        </div>

        <div className="bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
          <span className="text-xs text-slate-500 font-medium">Approved Leave Days</span>
          <div className="flex items-baseline gap-2 mt-2">
            <span className="text-3xl font-extrabold text-blue-600">45</span>
          </div>
          <span className="text-[11px] text-slate-400 mt-1 block">Authorized excused absences</span>
        </div>
      </div>

      {/* Breakdown by Role */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-5">
        <h2 className="font-bold text-slate-900 text-sm">Attendance Rate by Organizational Role</h2>

        <div className="space-y-4">
          {roleAttendance.map((item) => (
            <div key={item.role} className="space-y-1.5">
              <div className="flex justify-between text-xs">
                <span className="font-bold text-slate-800">{item.role}</span>
                <span className="text-slate-500">
                  <strong className="text-slate-900">{item.rate}</strong> ({item.attended} of {item.total})
                </span>
              </div>
              <div className="w-full h-3 rounded-full bg-slate-100 overflow-hidden">
                <div
                  style={{ width: item.rate }}
                  className="h-full rounded-full bg-teal-500 transition-all duration-500"
                ></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
