'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  Users,
  Search,
  Filter,
  Download,
  UserPlus,
  Shield,
  ShieldAlert,
  MoreVertical,
  CheckCircle2,
  AlertCircle,
  Building2,
} from 'lucide-react';

interface MemberRecord {
  id: string;
  name: string;
  email: string;
  identifierCode: string;
  role: 'student' | 'teacher' | 'staff' | 'branch_manager';
  branch: string;
  classOrDept: string;
  accountStatus: 'active' | 'suspended' | 'pending_verification';
  joinedDate: string;
}

const mockMembers: MemberRecord[] = [
  {
    id: 'usr-001',
    name: 'Sarah Johnson',
    email: 'sarah.johnson@kivora.edu.ng',
    identifierCode: 'STU00123',
    role: 'student',
    branch: 'West Campus',
    classOrDept: 'CS 201',
    accountStatus: 'active',
    joinedDate: 'Apr 12, 2025',
  },
  {
    id: 'usr-002',
    name: 'Michael Brown',
    email: 'michael.brown@kivora.edu.ng',
    identifierCode: 'TEA0045',
    role: 'teacher',
    branch: 'West Campus',
    classOrDept: 'Mathematics',
    accountStatus: 'active',
    joinedDate: 'Jan 15, 2024',
  },
  {
    id: 'usr-003',
    name: 'Emily Davis',
    email: 'emily.davis@kivora.org',
    identifierCode: 'STF0012',
    role: 'staff',
    branch: 'West Campus',
    classOrDept: 'Registry',
    accountStatus: 'active',
    joinedDate: 'Mar 01, 2025',
  },
  {
    id: 'usr-004',
    name: 'James Wilson',
    email: 'james.wilson@kivora.edu.ng',
    identifierCode: 'STU00124',
    role: 'student',
    branch: 'East Campus',
    classOrDept: 'Physics 101',
    accountStatus: 'suspended',
    joinedDate: 'Feb 10, 2025',
  },
  {
    id: 'usr-005',
    name: 'Olivia Martinez',
    email: 'olivia.m@kivora.edu.ng',
    identifierCode: 'TEA0046',
    role: 'teacher',
    branch: 'West Campus',
    classOrDept: 'Computer Science',
    accountStatus: 'active',
    joinedDate: 'Aug 20, 2024',
  },
  {
    id: 'usr-006',
    name: 'Daniel Taylor',
    email: 'daniel.t@kivora.org',
    identifierCode: 'MGR001',
    role: 'branch_manager',
    branch: 'North Campus',
    classOrDept: 'Administration',
    accountStatus: 'active',
    joinedDate: 'Nov 05, 2023',
  },
];

export default function MemberDirectoryPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('ALL');
  const [statusFilter, setStatusFilter] = useState('ALL');
  const [branchFilter, setBranchFilter] = useState('ALL');

  const filteredMembers = mockMembers.filter((m) => {
    const matchesSearch =
      m.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.identifierCode.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRole = roleFilter === 'ALL' || m.role === roleFilter;
    const matchesStatus = statusFilter === 'ALL' || m.accountStatus === statusFilter;
    const matchesBranch = branchFilter === 'ALL' || m.branch === branchFilter;
    return matchesSearch && matchesRole && matchesStatus && matchesBranch;
  });

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Member Directory</h1>
          <p className="text-sm text-slate-500 mt-1">
            Browse, manage, and assign role permissions for members across all campus branches.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Link
            href="/exports"
            className="inline-flex items-center gap-2 px-3.5 py-2 text-sm font-semibold rounded-lg bg-white border border-slate-200 text-slate-700 hover:bg-slate-50 shadow-sm transition-all"
          >
            <Download className="w-4 h-4 text-slate-500" />
            Export Directory
          </Link>
          <Link
            href="/members/requests"
            className="inline-flex items-center gap-2 px-3.5 py-2 text-sm font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
          >
            <UserPlus className="w-4 h-4" />
            Review Requests
          </Link>
        </div>
      </div>

      {/* Search & Filter Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by name, ID or email..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
          />
        </div>

        <div className="flex flex-wrap items-center gap-3 w-full md:w-auto">
          <select
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
            className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Roles</option>
            <option value="student">Student</option>
            <option value="teacher">Teacher</option>
            <option value="staff">Staff</option>
            <option value="branch_manager">Branch Manager</option>
          </select>

          <select
            value={branchFilter}
            onChange={(e) => setBranchFilter(e.target.value)}
            className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Branches</option>
            <option value="West Campus">West Campus</option>
            <option value="East Campus">East Campus</option>
            <option value="North Campus">North Campus</option>
          </select>

          <select
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
          >
            <option value="ALL">All Account Statuses</option>
            <option value="active">Active</option>
            <option value="suspended">Suspended</option>
            <option value="pending_verification">Pending Verification</option>
          </select>
        </div>
      </div>

      {/* Directory Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
              <tr>
                <th className="px-6 py-3.5">Member Name</th>
                <th className="px-6 py-3.5">Identifier / Code</th>
                <th className="px-6 py-3.5">Assigned Role</th>
                <th className="px-6 py-3.5">Branch</th>
                <th className="px-6 py-3.5">Department / Cohort</th>
                <th className="px-6 py-3.5">Account Status</th>
                <th className="px-6 py-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {filteredMembers.map((member) => (
                <tr key={member.id} className="hover:bg-slate-50/80 transition-colors">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 rounded-full bg-teal-50 text-teal-700 font-bold flex items-center justify-center text-xs border border-teal-200">
                        {member.name.split(' ').map((n) => n[0]).join('')}
                      </div>
                      <div>
                        <span className="font-semibold text-slate-900 block">{member.name}</span>
                        <span className="text-xs text-slate-400 block">{member.email}</span>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-mono text-xs text-slate-700">{member.identifierCode}</td>
                  <td className="px-6 py-4">
                    <span className="capitalize text-xs font-semibold px-2.5 py-1 rounded-md bg-slate-100 text-slate-700">
                      {member.role.replace('_', ' ')}
                    </span>
                  </td>
                  <td className="px-6 py-4 text-xs text-slate-600">{member.branch}</td>
                  <td className="px-6 py-4 text-xs text-slate-600">{member.classOrDept}</td>
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold ${
                        member.accountStatus === 'active'
                          ? 'bg-emerald-50 text-emerald-700'
                          : member.accountStatus === 'suspended'
                          ? 'bg-rose-50 text-rose-700'
                          : 'bg-amber-50 text-amber-700'
                      }`}
                    >
                      {member.accountStatus === 'active' ? (
                        <CheckCircle2 className="w-3.5 h-3.5" />
                      ) : (
                        <AlertCircle className="w-3.5 h-3.5" />
                      )}
                      <span className="capitalize">{member.accountStatus.replace('_', ' ')}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 text-right">
                    <div className="flex items-center justify-end gap-2">
                      <Link
                        href={`/members/${member.id}/permissions`}
                        title="Manage Permissions"
                        className="p-1.5 rounded-lg text-slate-600 hover:text-teal-600 hover:bg-teal-50 transition-colors"
                      >
                        <Shield className="w-4 h-4" />
                      </Link>
                      <Link
                        href={`/members/${member.id}/status`}
                        title="Account Status Lifecycle"
                        className="p-1.5 rounded-lg text-slate-600 hover:text-rose-600 hover:bg-rose-50 transition-colors"
                      >
                        <ShieldAlert className="w-4 h-4" />
                      </Link>
                    </div>
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
