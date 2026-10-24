'use client';

import React, { useState } from 'react';
import {
  UserPlus,
  Users,
  Search,
  Filter,
  Check,
  X,
  Layers,
  ArrowRight,
} from 'lucide-react';

interface EnrollmentMember {
  id: string;
  name: string;
  identifier: string;
  assignedCohort: string;
  enrolledClasses: string[];
}

const mockEnrollments: EnrollmentMember[] = [
  {
    id: 'em-01',
    name: 'Sarah Johnson',
    identifier: 'STU00123',
    assignedCohort: 'Year 2 — Computer Science',
    enrolledClasses: ['CS 201', 'Math 101', 'Practical Lab B'],
  },
  {
    id: 'em-02',
    name: 'James Wilson',
    identifier: 'STU00124',
    assignedCohort: 'Year 1 — General Science',
    enrolledClasses: ['Physics 101', 'Chemistry 101'],
  },
  {
    id: 'em-03',
    name: 'David Wilson',
    identifier: 'STU00125',
    assignedCohort: 'Year 2 — Computer Science',
    enrolledClasses: ['CS 201', 'Programming Fundamentals'],
  },
];

export default function EnrollmentsPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [enrollments, setEnrollments] = useState(mockEnrollments);
  const [selectedClass, setSelectedClass] = useState('ALL');

  const availableClasses = ['CS 201', 'Math 101', 'Physics 101', 'Chemistry 101', 'Practical Lab B'];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Class, Team & Enrollment Assignments</h1>
          <p className="text-sm text-slate-500 mt-1">
            Bulk-enroll members into academic cohorts, practical shifts, and class timetables.
          </p>
        </div>
      </div>

      {/* Filter and Search Bar */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search by student name or identifier..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
          />
        </div>

        <select
          value={selectedClass}
          onChange={(e) => setSelectedClass(e.target.value)}
          className="text-sm border border-slate-200 rounded-lg px-3 py-2 bg-white text-slate-700 focus:ring-2 focus:ring-teal-500"
        >
          <option value="ALL">All Enrolled Courses</option>
          {availableClasses.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </div>

      {/* Roster Table */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="bg-slate-50 text-slate-500 text-xs uppercase font-semibold border-b border-slate-200">
            <tr>
              <th className="px-6 py-3.5">Student / Member</th>
              <th className="px-6 py-3.5">Identifier</th>
              <th className="px-6 py-3.5">Assigned Cohort</th>
              <th className="px-6 py-3.5">Enrolled Sessions & Classes</th>
              <th className="px-6 py-3.5 text-right">Actions</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {enrollments.map((item) => (
              <tr key={item.id} className="hover:bg-slate-50/80 transition-colors">
                <td className="px-6 py-4 font-semibold text-slate-900">{item.name}</td>
                <td className="px-6 py-4 font-mono text-xs text-slate-600">{item.identifier}</td>
                <td className="px-6 py-4 text-xs text-slate-700">{item.assignedCohort}</td>
                <td className="px-6 py-4">
                  <div className="flex flex-wrap gap-1.5">
                    {item.enrolledClasses.map((c) => (
                      <span
                        key={c}
                        className="text-xs px-2 py-0.5 rounded-md bg-teal-50 text-teal-700 font-semibold border border-teal-200"
                      >
                        {c}
                      </span>
                    ))}
                  </div>
                </td>
                <td className="px-6 py-4 text-right">
                  <button className="text-xs font-semibold text-teal-600 hover:text-teal-700 bg-teal-50 px-3 py-1.5 rounded-lg">
                    Modify Roster
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
