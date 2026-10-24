'use client';

import React, { useState } from 'react';
import {
  Layers,
  Plus,
  Users,
  Building2,
  Trash2,
  BookOpen,
} from 'lucide-react';

interface GroupItem {
  id: string;
  name: string;
  code: string;
  department: string;
  memberCount: number;
  leadInstructor: string;
}

const initialGroups: GroupItem[] = [
  {
    id: 'grp-01',
    name: 'Computer Science 201',
    code: 'CS-201',
    department: 'Computer Science',
    memberCount: 48,
    leadInstructor: 'Dr. Samuel Adeyemi',
  },
  {
    id: 'grp-02',
    name: 'Mathematics 101',
    code: 'MTH-101',
    department: 'Mathematics & Statistics',
    memberCount: 65,
    leadInstructor: 'Prof. Grace Okon',
  },
  {
    id: 'grp-03',
    name: 'Physics 101',
    code: 'PHY-101',
    department: 'Physical Sciences',
    memberCount: 52,
    leadInstructor: 'Dr. Michael Brown',
  },
  {
    id: 'grp-04',
    name: 'Administrative Shift Team A',
    code: 'ADM-SH-A',
    department: 'Central Administration',
    memberCount: 14,
    leadInstructor: 'Sarah Wilson',
  },
];

export default function GroupsManagementPage() {
  const [groups, setGroups] = useState<GroupItem[]>(initialGroups);
  const [showAddModal, setShowAddModal] = useState(false);
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [department, setDepartment] = useState('Computer Science');
  const [leadInstructor, setLeadInstructor] = useState('');

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (name && code) {
      setGroups([
        ...groups,
        {
          id: `grp-${Date.now()}`,
          name,
          code,
          department,
          memberCount: 0,
          leadInstructor: leadInstructor || 'Unassigned',
        },
      ]);
      setShowAddModal(false);
      setName('');
      setCode('');
    }
  };

  const handleRemove = (id: string) => {
    setGroups(groups.filter((g) => g.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Classes, Teams & Group Management</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage academic courses, study cohorts, and departmental teams.
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <Plus className="w-4 h-4" />
          Create New Group
        </button>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {groups.map((group) => (
          <div
            key={group.id}
            className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4 hover:border-slate-300 transition-all flex flex-col justify-between"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-teal-700 bg-teal-50 px-2 py-0.5 rounded border border-teal-200">
                  {group.code}
                </span>
                <span className="text-xs text-slate-500 flex items-center gap-1">
                  <Users className="w-3.5 h-3.5 text-slate-400" />
                  {group.memberCount} members
                </span>
              </div>

              <div>
                <h2 className="font-bold text-slate-900 text-base">{group.name}</h2>
                <span className="text-xs text-slate-500 block mt-0.5">{group.department}</span>
              </div>

              <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-xs">
                <span className="text-slate-400 block font-medium">Lead Instructor / Supervisor:</span>
                <span className="font-semibold text-slate-800 block mt-0.5">{group.leadInstructor}</span>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-end">
              <button
                onClick={() => handleRemove(group.id)}
                className="text-slate-400 hover:text-rose-600 p-1.5 rounded-lg hover:bg-rose-50 transition-colors"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Add Modal */}
      {showAddModal && (
        <div className="fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <form onSubmit={handleAdd} className="bg-white rounded-2xl max-w-md w-full p-6 space-y-4 shadow-xl border border-slate-200">
            <h3 className="font-bold text-slate-900 text-base">Create Class or Group</h3>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Course / Group Title:</label>
              <input
                type="text"
                required
                placeholder="e.g. Advanced Operating Systems"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Course Code:</label>
              <input
                type="text"
                required
                placeholder="e.g. CS-301"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Department:</label>
              <input
                type="text"
                value={department}
                onChange={(e) => setDepartment(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Lead Instructor:</label>
              <input
                type="text"
                placeholder="e.g. Dr. Samuel Adeyemi"
                value={leadInstructor}
                onChange={(e) => setLeadInstructor(e.target.value)}
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
                Create Group
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
