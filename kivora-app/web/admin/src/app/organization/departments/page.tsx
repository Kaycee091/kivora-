'use client';

import React, { useState } from 'react';
import {
  Network,
  Plus,
  Users,
  Building2,
  Trash2,
  Briefcase,
} from 'lucide-react';

interface DepartmentItem {
  id: string;
  name: string;
  code: string;
  headOfDepartment: string;
  staffCount: number;
  branch: string;
}

const initialDepartments: DepartmentItem[] = [
  {
    id: 'dept-01',
    name: 'Computer Science & Software Engineering',
    code: 'CS-DEPT',
    headOfDepartment: 'Dr. Samuel Adeyemi',
    staffCount: 18,
    branch: 'West Campus',
  },
  {
    id: 'dept-02',
    name: 'Mathematics & Statistics',
    code: 'MTH-DEPT',
    headOfDepartment: 'Prof. Grace Okon',
    staffCount: 12,
    branch: 'West Campus',
  },
  {
    id: 'dept-03',
    name: 'Physical Sciences & Physics',
    code: 'PHY-DEPT',
    headOfDepartment: 'Dr. Michael Brown',
    staffCount: 14,
    branch: 'East Campus',
  },
  {
    id: 'dept-04',
    name: 'Central Administration & Registry',
    code: 'REG-DEPT',
    headOfDepartment: 'Sarah Wilson',
    staffCount: 22,
    branch: 'West Campus',
  },
];

export default function DepartmentsPage() {
  const [departments, setDepartments] = useState<DepartmentItem[]>(initialDepartments);
  const [showAddModal, setShowAddModal] = useState(false);
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [head, setHead] = useState('');
  const [branch, setBranch] = useState('West Campus');

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (name && code) {
      setDepartments([
        ...departments,
        {
          id: `dept-${Date.now()}`,
          name,
          code,
          headOfDepartment: head || 'To be nominated',
          staffCount: 1,
          branch,
        },
      ]);
      setShowAddModal(false);
      setName('');
      setCode('');
      setHead('');
    }
  };

  const handleRemove = (id: string) => {
    setDepartments(departments.filter((d) => d.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Department Management</h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure institutional organizational hierarchy, departments, and heads of units.
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <Plus className="w-4 h-4" />
          Add Department
        </button>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {departments.map((dept) => (
          <div
            key={dept.id}
            className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4 hover:border-slate-300 transition-all flex flex-col justify-between"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="font-mono text-xs font-bold text-teal-700 bg-teal-50 px-2.5 py-1 rounded border border-teal-200">
                  {dept.code}
                </span>
                <span className="text-xs text-slate-500 font-medium">{dept.branch}</span>
              </div>

              <h2 className="font-bold text-slate-900 text-base">{dept.name}</h2>

              <div className="bg-slate-50 p-3.5 rounded-xl border border-slate-100 flex items-center justify-between text-xs">
                <div>
                  <span className="text-slate-400 block font-medium">Head of Department:</span>
                  <span className="font-semibold text-slate-800 mt-0.5 block">{dept.headOfDepartment}</span>
                </div>
                <div className="text-right">
                  <span className="text-slate-400 block font-medium">Staff Members:</span>
                  <span className="font-bold text-teal-600 mt-0.5 block">{dept.staffCount}</span>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-end">
              <button
                onClick={() => handleRemove(dept.id)}
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
            <h3 className="font-bold text-slate-900 text-base">New Institutional Department</h3>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Department Name:</label>
              <input
                type="text"
                required
                placeholder="e.g. Biological & Life Sciences"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Department Code:</label>
              <input
                type="text"
                required
                placeholder="e.g. BIO-DEPT"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Head of Unit:</label>
              <input
                type="text"
                placeholder="e.g. Dr. Jane Doe"
                value={head}
                onChange={(e) => setHead(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Primary Branch:</label>
              <select
                value={branch}
                onChange={(e) => setBranch(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white"
              >
                <option value="West Campus">West Campus</option>
                <option value="East Campus">East Campus</option>
                <option value="North Campus">North Campus</option>
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
                Save Department
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
