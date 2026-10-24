'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  Shield,
  UserPlus,
  Trash2,
  Check,
  Building2,
  User,
  ShieldCheck,
} from 'lucide-react';

interface ManagerAssignment {
  id: string;
  name: string;
  email: string;
  scope: 'branch_manager' | 'branch_admin' | 'attendance_supervisor';
  effectiveFrom: string;
}

export default function BranchManagersPage() {
  const params = useParams();
  const id = params?.id as string || 'br-001';

  const [managers, setManagers] = useState<ManagerAssignment[]>([
    {
      id: 'm-01',
      name: 'Sarah Wilson',
      email: 'sarah.wilson@kivora.org',
      scope: 'branch_manager',
      effectiveFrom: '15 Jan 2024',
    },
    {
      id: 'm-02',
      name: 'Michael Brown',
      email: 'michael.brown@kivora.edu.ng',
      scope: 'attendance_supervisor',
      effectiveFrom: '01 Mar 2025',
    },
  ]);

  const [showAddModal, setShowAddModal] = useState(false);
  const [newEmail, setNewEmail] = useState('');
  const [newScope, setNewScope] = useState<'branch_manager' | 'branch_admin' | 'attendance_supervisor'>('branch_admin');

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (newEmail) {
      setManagers([
        ...managers,
        {
          id: `m-${Date.now()}`,
          name: newEmail.split('@')[0],
          email: newEmail,
          scope: newScope,
          effectiveFrom: 'Today',
        },
      ]);
      setNewEmail('');
      setShowAddModal(false);
    }
  };

  const handleRemove = (id: string) => {
    setManagers(managers.filter((m) => m.id !== id));
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href="/branches"
            className="p-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-slate-900 shadow-sm"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Branch Managers & Scopes</h1>
            <p className="text-xs text-slate-500 mt-0.5">Assign authorized administrative leaders for {id}</p>
          </div>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <UserPlus className="w-4 h-4" />
          Assign Manager
        </button>
      </div>

      {/* Managers List */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-4 border-b border-slate-100 bg-slate-50 flex items-center justify-between">
          <span className="text-xs font-bold uppercase text-slate-600 tracking-wider">
            Active Assigned Leaders ({managers.length})
          </span>
        </div>

        <div className="divide-y divide-slate-100">
          {managers.map((mgr) => (
            <div key={mgr.id} className="p-4 flex items-center justify-between hover:bg-slate-50/60 transition-colors">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-xs">
                  {mgr.name.slice(0, 2).toUpperCase()}
                </div>
                <div>
                  <h3 className="font-bold text-slate-900 text-sm">{mgr.name}</h3>
                  <span className="text-xs text-slate-500">{mgr.email}</span>
                </div>
              </div>

              <div className="flex items-center gap-4">
                <div className="text-right">
                  <span className="inline-block px-2.5 py-0.5 rounded-full text-xs font-semibold bg-teal-50 text-teal-700 border border-teal-200 capitalize">
                    {mgr.scope.replace('_', ' ')}
                  </span>
                  <span className="block text-[10px] text-slate-400 mt-0.5">Active since {mgr.effectiveFrom}</span>
                </div>

                <button
                  onClick={() => handleRemove(mgr.id)}
                  className="p-2 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-rose-50 transition-colors"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Add Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <form onSubmit={handleAdd} className="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl border border-slate-200">
            <h3 className="font-bold text-slate-900 text-base">Assign Manager to Branch</h3>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Member Email:</label>
              <input
                type="email"
                required
                placeholder="manager@kivora.org"
                value={newEmail}
                onChange={(e) => setNewEmail(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Delegated Scope:</label>
              <select
                value={newScope}
                onChange={(e) => setNewScope(e.target.value as any)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white focus:outline-none focus:ring-2 focus:ring-teal-500"
              >
                <option value="branch_manager">Full Branch Manager</option>
                <option value="branch_admin">Branch Administrator</option>
                <option value="attendance_supervisor">Attendance Supervisor</option>
              </select>
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
                Confirm Assignment
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
