'use client';

import React, { useState } from 'react';
import {
  Calendar,
  Clock,
  Plus,
  Trash2,
  Edit,
  Building2,
  Users,
  CheckCircle2,
} from 'lucide-react';

interface SessionWindow {
  id: string;
  title: string;
  branch: string;
  type: 'Class' | 'Shift' | 'Lab';
  startTime: string;
  endTime: string;
  earlyCheckInBuffer: number; // minutes before start allowed
  lateGracePeriod: number; // minutes after start
  assignedGroup: string;
  room: string;
}

const initialWindows: SessionWindow[] = [
  {
    id: 'win-01',
    title: 'Morning Class Cohort A',
    branch: 'West Campus',
    type: 'Class',
    startTime: '08:00 AM',
    endTime: '10:00 AM',
    earlyCheckInBuffer: 15,
    lateGracePeriod: 10,
    assignedGroup: 'CS 201 — Computer Science',
    room: 'Block B - Room 203',
  },
  {
    id: 'win-02',
    title: 'Midday Practical Science Lab',
    branch: 'West Campus',
    type: 'Lab',
    startTime: '10:30 AM',
    endTime: '12:30 PM',
    earlyCheckInBuffer: 20,
    lateGracePeriod: 15,
    assignedGroup: 'Physics 101 Cohort',
    room: 'Science Lab 4',
  },
  {
    id: 'win-03',
    title: 'Administrative Operations Shift',
    branch: 'East Campus',
    type: 'Shift',
    startTime: '08:00 AM',
    endTime: '04:00 PM',
    earlyCheckInBuffer: 30,
    lateGracePeriod: 15,
    assignedGroup: 'Registry & Operations Staff',
    room: 'Central Admin Office',
  },
];

export default function SessionWindowsPage() {
  const [windows, setWindows] = useState<SessionWindow[]>(initialWindows);
  const [showAddModal, setShowAddModal] = useState(false);

  const [title, setTitle] = useState('');
  const [type, setType] = useState<'Class' | 'Shift' | 'Lab'>('Class');
  const [startTime, setStartTime] = useState('08:00 AM');
  const [endTime, setEndTime] = useState('10:00 AM');
  const [room, setRoom] = useState('');
  const [assignedGroup, setAssignedGroup] = useState('');

  const handleAdd = (e: React.FormEvent) => {
    e.preventDefault();
    if (title && room) {
      setWindows([
        ...windows,
        {
          id: `win-${Date.now()}`,
          title,
          branch: 'West Campus',
          type,
          startTime,
          endTime,
          earlyCheckInBuffer: 15,
          lateGracePeriod: 10,
          assignedGroup: assignedGroup || 'General Group',
          room,
        },
      ]);
      setShowAddModal(false);
      setTitle('');
      setRoom('');
    }
  };

  const handleRemove = (id: string) => {
    setWindows(windows.filter((w) => w.id !== id));
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Schedule & Session Windows</h1>
          <p className="text-sm text-slate-500 mt-1">
            Configure permitted arrival windows, early check-in buffers, and assigned room locations.
          </p>
        </div>

        <button
          onClick={() => setShowAddModal(true)}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          <Plus className="w-4 h-4" />
          Create Session Window
        </button>
      </div>

      {/* Grid of Session Windows */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {windows.map((win) => (
          <div
            key={win.id}
            className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4 hover:border-slate-300 transition-all flex flex-col justify-between"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-[10px] font-bold px-2 py-0.5 rounded uppercase tracking-wider bg-teal-50 text-teal-700 border border-teal-200">
                  {win.type}
                </span>
                <span className="text-xs text-slate-400 font-medium">{win.branch}</span>
              </div>

              <h2 className="font-bold text-slate-900 text-base">{win.title}</h2>

              <div className="space-y-1.5 text-xs text-slate-600">
                <div className="flex items-center gap-2">
                  <Clock className="w-3.5 h-3.5 text-teal-600" />
                  <span className="font-semibold text-slate-800">
                    {win.startTime} – {win.endTime}
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <Building2 className="w-3.5 h-3.5 text-slate-400" />
                  <span>{win.room}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users className="w-3.5 h-3.5 text-slate-400" />
                  <span className="truncate">{win.assignedGroup}</span>
                </div>
              </div>

              <div className="p-3 bg-slate-50 rounded-xl border border-slate-100 grid grid-cols-2 gap-2 text-center text-xs">
                <div>
                  <span className="text-[10px] text-slate-400 block font-medium">Early Buffer</span>
                  <span className="font-bold text-slate-700">{win.earlyCheckInBuffer} mins</span>
                </div>
                <div>
                  <span className="text-[10px] text-slate-400 block font-medium">Late Grace</span>
                  <span className="font-bold text-slate-700">{win.lateGracePeriod} mins</span>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-100 flex items-center justify-end">
              <button
                onClick={() => handleRemove(win.id)}
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
            <h3 className="font-bold text-slate-900 text-base">New Schedule Session Window</h3>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Session Title:</label>
              <input
                type="text"
                required
                placeholder="e.g. Morning Class Cohort B"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">Start Time:</label>
                <input
                  type="text"
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full text-xs p-3 rounded-xl border border-slate-200"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold text-slate-700">End Time:</label>
                <input
                  type="text"
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  className="w-full text-xs p-3 rounded-xl border border-slate-200"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Room / Location:</label>
              <input
                type="text"
                required
                placeholder="e.g. Block C - Room 102"
                value={room}
                onChange={(e) => setRoom(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Assigned Cohort / Class:</label>
              <input
                type="text"
                placeholder="e.g. CS 201 — Computer Science"
                value={assignedGroup}
                onChange={(e) => setAssignedGroup(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
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
                Create Window
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
}
