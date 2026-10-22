import React from 'react';
import {
  Users,
  CheckCircle2,
  Clock,
  AlertTriangle,
  ArrowUpRight,
  ShieldCheck,
  TrendingUp,
} from 'lucide-react';

export default function AdminDashboardPage() {
  const stats = [
    { label: 'Active Members', value: '1,428', change: '+12% this month', icon: Users, color: 'text-teal-600 bg-teal-50' },
    { label: 'Today Attendance Rate', value: '94.2%', change: '+2.1% vs avg', icon: CheckCircle2, color: 'text-emerald-600 bg-emerald-50' },
    { label: 'Sessions Scheduled', value: '38', change: '4 in progress now', icon: Clock, color: 'text-blue-600 bg-blue-50' },
    { label: 'Pending Reviews', value: '7', change: '3 join, 4 exceptions', icon: AlertTriangle, color: 'text-amber-600 bg-amber-50' },
  ];

  const recentAttendance = [
    { id: '1', name: 'Sarah Johnson', role: 'Student', class: 'CS 201', time: '08:02 AM', status: 'Present', verification: 'Passed (Biometric + GPS)' },
    { id: '2', name: 'Michael Brown', role: 'Teacher', class: 'Math 101', time: '07:58 AM', status: 'Present', verification: 'Passed (Biometric)' },
    { id: '3', name: 'Emily Davis', role: 'Staff', class: 'Main Office', time: '08:35 AM', status: 'Late', verification: 'Needs Review (Low GPS accuracy)' },
    { id: '4', name: 'James Wilson', role: 'Student', class: 'Physics 101', time: '—', status: 'Absent', verification: 'Failed' },
  ];

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Administrative Overview</h1>
        <p className="text-sm text-slate-500 mt-1">
          Branch operational overview, live attendance health, and verification queue.
        </p>
      </div>

      {/* KPI Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((s) => {
          const Icon = s.icon;
          return (
            <div key={s.label} className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-between">
              <div className="flex items-center justify-between">
                <span className="text-xs font-semibold uppercase tracking-wider text-slate-500">{s.label}</span>
                <div className={`p-2.5 rounded-xl ${s.color}`}>
                  <Icon className="w-5 h-5" />
                </div>
              </div>
              <div className="mt-4">
                <div className="text-3xl font-extrabold text-slate-900">{s.value}</div>
                <div className="text-xs font-medium text-slate-500 mt-1 flex items-center gap-1">
                  <TrendingUp className="w-3.5 h-3.5 text-teal-600" />
                  <span>{s.change}</span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Live Activity & Exception Split */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Recent Attendance Feed */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div className="p-6 border-b border-slate-100 flex items-center justify-between">
            <div>
              <h2 className="text-base font-semibold text-slate-900">Live Attendance Activity</h2>
              <p className="text-xs text-slate-500">Real-time check-in stream for today&apos;s active sessions</p>
            </div>
            <a href="/attendance/live" className="text-xs font-semibold text-teal-600 hover:text-teal-700 flex items-center gap-1">
              View all <ArrowUpRight className="w-4 h-4" />
            </a>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-sm">
              <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-medium border-b border-slate-200">
                <tr>
                  <th className="px-6 py-3">Member</th>
                  <th className="px-6 py-3">Session</th>
                  <th className="px-6 py-3">Time</th>
                  <th className="px-6 py-3">Status</th>
                  <th className="px-6 py-3">Verification</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {recentAttendance.map((row) => (
                  <tr key={row.id} className="hover:bg-slate-50 transition-colors">
                    <td className="px-6 py-4 font-medium text-slate-900">{row.name}</td>
                    <td className="px-6 py-4 text-slate-600">{row.class}</td>
                    <td className="px-6 py-4 text-slate-600">{row.time}</td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        row.status === 'Present' ? 'bg-emerald-50 text-emerald-700' :
                        row.status === 'Late' ? 'bg-amber-50 text-amber-700' : 'bg-red-50 text-red-700'
                      }`}>
                        {row.status}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-xs text-slate-500">{row.verification}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* System Trust & Security Status */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3">
              <div className="p-2.5 bg-teal-50 rounded-xl text-teal-600">
                <ShieldCheck className="w-6 h-6" />
              </div>
              <div>
                <h3 className="font-semibold text-slate-900">Security & Integrity</h3>
                <p className="text-xs text-slate-500">Row Level Security & Audit Active</p>
              </div>
            </div>

            <div className="mt-6 space-y-4 text-sm">
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200">
                <span className="block text-xs font-semibold text-slate-700">Geofence Compliance</span>
                <span className="text-xs text-slate-500">West Campus boundary set to 150m radius. 98.4% within boundary.</span>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200">
                <span className="block text-xs font-semibold text-slate-700">Biometric OS Signal</span>
                <span className="text-xs text-slate-500">Hardware token validation enabled. No raw templates stored.</span>
              </div>
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-200">
                <span className="block text-xs font-semibold text-slate-700">Audit Trail Immutable</span>
                <span className="text-xs text-slate-500">Zero deleted audit entries in last 90 days.</span>
              </div>
            </div>
          </div>

          <div className="mt-6 pt-4 border-t border-slate-100 flex items-center justify-between text-xs text-slate-400">
            <span>Server Time (UTC): Verified</span>
            <span className="font-mono text-slate-600">{new Date().toISOString().substring(11, 19)}</span>
          </div>
        </div>
      </div>
    </div>
  );
}
