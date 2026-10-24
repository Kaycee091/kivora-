'use client';

import React, { useState } from 'react';
import {
  Briefcase,
  Users,
  Plus,
  Trash2,
  ShieldCheck,
  Check,
} from 'lucide-react';

interface DutyAssignment {
  id: string;
  roleTitle: string;
  assignee: string;
  email: string;
  scope: string;
  status: 'ACTIVE' | 'ON_CALL';
}

const initialDuties: DutyAssignment[] = [
  {
    id: 'dt-01',
    roleTitle: 'Primary Biometric Verification Auditor',
    assignee: 'Sarah Wilson',
    email: 'sarah.wilson@kivora.org',
    scope: 'West Campus — All Blocks',
    status: 'ACTIVE',
  },
  {
    id: 'dt-02',
    roleTitle: 'Practical Lab B Safety & Attendance Supervisor',
    assignee: 'Dr. Samuel Adeyemi',
    email: 'samuel.a@kivora.edu.ng',
    scope: 'West Campus — Lab 4 & 5',
    status: 'ACTIVE',
  },
  {
    id: 'dt-03',
    roleTitle: 'Evening Shift Duty Manager',
    assignee: 'Michael Brown',
    email: 'michael.brown@kivora.edu.ng',
    scope: 'East Campus — Campus Wide',
    status: 'ON_CALL',
  },
];

export default function ResponsibilitiesPage() {
  const [duties, setDuties] = useState<DutyAssignment[]>(initialDuties);
  const [showAddModal, setShowAddModal] = useState(false);
  const [title, setTitle] = useState('');
  const [assignee, setAssignee] = useState('');
  const [scope, setScope] = useState('');

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (title && assignee) {
      setDuties([
        ...duties,
        {
          id: `dt-${Date.now()}`,
          roleTitle: title,
          assignee,
          email: `${assignee.toLowerCase().replace(' ', '.')}@kivora.org`,
          scope: scope || 'Campus Wide',
          status: 'ACTIVE',
        },
      ]);
      setShowAddModal(false);
      setTitle('');
      setAssignee('');
    }
  };

  const handleRemove = (id: string) => {
    setDuties(duties.filter((d) => d.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Assignments & Responsibilities</h1>
          <p className="text-sm text-slate-500 mt-1">
            Delegate operational duties, proctor roles, and attendance verification leadership.
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <Plus className="w-4 h-4" />
          Assign Duty
        </button>
      </div>

      {/* Duties List */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Assigned Responsibility</th>
                <th className="px-6 py-3.5">Appointed Member</th>
                <th className="px-6 py-3.5">Operational Scope</th>
                <th className="px-6 py-3.5">Status</th>
                <th className="px-6 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {duties.map((duty) => (
                <tr key={duty.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4 font-semibold text-slate-900 flex items-center gap-2.5">
                    <Briefcase className="w-4 h-4 text-teal-600 flex-shrink-0" />
                    <span>{duty.roleTitle}</span>
                  </td>
                  <td className="px-6 py-4">
                    <span className="font-medium text-slate-800 block">{duty.assignee}</span>
                    <span className="text-xs text-slate-400 block">{duty.email}</span>
                  </td>
                  <td className="px-6 py-4 text-xs text-slate-600">{duty.scope}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-block px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                        duty.status === 'ACTIVE'
                          ? 'bg-emerald-50 text-emerald-700'
                          : 'bg-blue-50 text-blue-700'
                      }`}
                    >
                      {duty.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <button
                      onClick={() => handleRemove(duty.id)}
                      className="text-slate-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <form onSubmit={handleAdd} className="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl border border-slate-200">
            <h3 className="font-bold text-slate-900 text-base">Appoint Operational Duty</h3>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Duty / Responsibility Name:</label>
              <input
                type="text"
                required
                placeholder="e.g. Weekend Attendance Proctor"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Appointed Member Name:</label>
              <input
                type="text"
                required
                placeholder="e.g. Sarah Wilson"
                value={assignee}
                onChange={(e) => setAssignee(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Operational Scope:</label>
              <input
                type="text"
                placeholder="e.g. West Campus — Main Library"
                value={scope}
                onChange={(e) => setScope(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => setShowAddModal(false)}
                className="px-4 py-2 text-xs font-semibold rounded-lg bg-slate-100 text-slate-700 hover:bg-slate-200"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-4 py-2 text-xs font-bold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm"
              >
                Save Duty
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
