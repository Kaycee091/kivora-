'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  Shield,
  Save,
  Check,
  User,
  Building2,
  Lock,
} from 'lucide-react';

interface PermissionToggle {
  key: string;
  label: string;
  description: string;
  enabled: boolean;
}

export default function MemberPermissionsPage() {
  const params = useParams();
  const id = params?.id as string || 'usr-001';

  const [saved, setSaved] = useState(false);
  const [role, setRole] = useState('student');

  const [permissions, setPermissions] = useState<PermissionToggle[]>([
    {
      key: 'view_schedule',
      label: 'View Class / Session Schedules',
      description: 'Access assigned classes, session locations, and timetables.',
      enabled: true,
    },
    {
      key: 'mark_attendance',
      label: 'Self-Serve Biometric & GPS Attendance',
      description: 'Allow member to initiate check-in and check-out verification.',
      enabled: true,
    },
    {
      key: 'submit_leave',
      label: 'Submit Leave & Early Departure Requests',
      description: 'Request formal absence or departure before session completion.',
      enabled: true,
    },
    {
      key: 'request_correction',
      label: 'Submit Attendance Correction Requests',
      description: 'Submit missed check-out corrections for administrative approval.',
      enabled: true,
    },
    {
      key: 'request_transfer',
      label: 'Initiate Branch Transfer Requests',
      description: 'Request relocation to another branch within the organization.',
      enabled: true,
    },
    {
      key: 'view_reports',
      label: 'Branch Attendance & Session Reports',
      description: 'Elevated right to view branch-wide aggregated statistics.',
      enabled: false,
    },
    {
      key: 'manage_members',
      label: 'Review Documents & Approve Memberships',
      description: 'Branch administrator privilege to approve join requests.',
      enabled: false,
    },
  ]);

  const togglePermission = (key: string) => {
    setPermissions((prev) =>
      prev.map((p) => (p.key === key ? { ...p, enabled: !p.enabled } : p))
    );
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href="/members"
            className="p-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-slate-900 shadow-sm"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Granular Role Permissions</h1>
            <p className="text-xs text-slate-500 mt-0.5">Configure access grants and capability overrides for member ID: {id}</p>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          {saved ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          {saved ? 'Changes Saved!' : 'Save Permissions'}
        </button>
      </div>

      {/* Profile Overview Card */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-12 h-12 rounded-full bg-teal-100 text-teal-800 font-bold flex items-center justify-center text-base">
            SJ
          </div>
          <div>
            <h2 className="font-bold text-slate-900 text-base">Sarah Johnson</h2>
            <p className="text-xs text-slate-500">sarah.johnson@kivora.edu.ng • Student ID: STU00123</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          <label className="text-xs font-semibold text-slate-600">Assigned Base Role:</label>
          <select
            value={role}
            onChange={(e) => setRole(e.target.value)}
            className="text-xs font-semibold border border-slate-200 rounded-lg px-3 py-2 bg-slate-50 text-slate-800 focus:ring-2 focus:ring-teal-500"
          >
            <option value="student">Student (Member)</option>
            <option value="teacher">Teacher (Supervisor)</option>
            <option value="staff">Administrative Staff</option>
            <option value="branch_manager">Branch Manager</option>
          </select>
        </div>
      </div>

      {/* Permissions Toggle List */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-4">
        <div className="pb-3 border-b border-slate-100">
          <h3 className="font-bold text-slate-900 text-sm">Capability Matrix</h3>
          <p className="text-xs text-slate-500 mt-0.5">Toggle specific system actions available to this account.</p>
        </div>

        <div className="space-y-4">
          {permissions.map((perm) => (
            <div
              key={perm.key}
              className="flex items-center justify-between p-4 rounded-xl border border-slate-100 bg-slate-50/60 hover:bg-slate-50 transition-colors"
            >
              <div className="space-y-0.5 pr-4">
                <span className="font-semibold text-slate-900 text-xs block">{perm.label}</span>
                <span className="text-xs text-slate-500 block">{perm.description}</span>
              </div>

              {/* Custom Toggle Switch */}
              <button
                type="button"
                onClick={() => togglePermission(perm.key)}
                className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors duration-200 ease-in-out ${
                  perm.enabled ? 'bg-teal-600' : 'bg-slate-300'
                }`}
              >
                <div
                  className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ease-in-out ${
                    perm.enabled ? 'translate-x-6' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
