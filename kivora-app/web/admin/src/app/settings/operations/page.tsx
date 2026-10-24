'use client';

import React, { useState } from 'react';
import {
  Settings,
  Bell,
  Send,
  Plus,
  Shield,
  Save,
  Check,
  Building2,
} from 'lucide-react';

interface Announcement {
  id: string;
  title: string;
  content: string;
  targetRole: string;
  sentDate: string;
}

export default function OperationsSettingsPage() {
  const [announcements, setAnnouncements] = useState<Announcement[]>([
    {
      id: 'ann-01',
      title: 'Mid-Term Examination Attendance Protocol',
      content: 'All candidates must execute biometric verification at least 15 minutes prior to session start.',
      targetRole: 'Students & Teachers',
      sentDate: '18 Apr 2025',
    },
    {
      id: 'ann-02',
      title: 'Campus Wi-Fi Maintenance Window',
      content: 'Network verification will switch to cellular fallback between 02:00 AM and 05:00 AM.',
      targetRole: 'All Members',
      sentDate: '14 Apr 2025',
    },
  ]);

  const [annTitle, setAnnTitle] = useState('');
  const [annContent, setAnnContent] = useState('');
  const [annRole, setAnnRole] = useState('All Members');
  const [broadcastSent, setBroadcastSent] = useState(false);

  const handleBroadcast = (e: React.FormEvent) => {
    e.preventDefault();
    if (annTitle && annContent) {
      setAnnouncements([
        {
          id: `ann-${Date.now()}`,
          title: annTitle,
          content: annContent,
          targetRole: annRole,
          sentDate: 'Just now',
        },
        ...announcements,
      ]);
      setAnnTitle('');
      setAnnContent('');
      setBroadcastSent(true);
      setTimeout(() => setBroadcastSent(false), 2500);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Operations, Roles & Announcements</h1>
        <p className="text-sm text-slate-500 mt-1">
          Manage system-wide broadcast alerts, custom role configurations, and operational defaults.
        </p>
      </div>

      {/* Broadcast Announcement Form */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
        <div className="flex items-center gap-2 pb-3 border-b border-slate-100">
          <Bell className="w-5 h-5 text-teal-600" />
          <h2 className="font-bold text-slate-900 text-sm">Broadcast System Announcement</h2>
        </div>

        <form onSubmit={handleBroadcast} className="space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="sm:col-span-2 space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Announcement Headline:</label>
              <input
                type="text"
                required
                placeholder="e.g. Schedule Update for Friday Classes"
                value={annTitle}
                onChange={(e) => setAnnTitle(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-slate-700">Recipient Audience:</label>
              <select
                value={annRole}
                onChange={(e) => setAnnRole(e.target.value)}
                className="w-full text-xs p-3 rounded-xl border border-slate-200 bg-white"
              >
                <option value="All Members">All Members</option>
                <option value="Students Only">Students Only</option>
                <option value="Teachers Only">Teachers Only</option>
                <option value="Staff Only">Staff Only</option>
              </select>
            </div>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-slate-700">Message Body:</label>
            <textarea
              required
              rows={3}
              placeholder="Enter announcement text to be broadcast to mobile inboxes..."
              value={annContent}
              onChange={(e) => setAnnContent(e.target.value)}
              className="w-full text-xs p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
            />
          </div>

          <div className="flex items-center justify-between pt-2">
            {broadcastSent && (
              <span className="text-xs text-emerald-700 font-bold flex items-center gap-1.5">
                <Check className="w-4 h-4" /> Announcement published to inboxes!
              </span>
            )}
            <div className="ml-auto">
              <button
                type="submit"
                className="inline-flex items-center gap-2 px-5 py-2.5 text-xs font-bold rounded-xl bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
              >
                <Send className="w-4 h-4" />
                Publish Announcement
              </button>
            </div>
          </div>
        </form>
      </div>

      {/* Published Announcements Feed */}
      <div className="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
        <div className="p-4 bg-slate-50 border-b border-slate-100 flex items-center justify-between">
          <span className="text-xs font-bold uppercase text-slate-600 tracking-wider">
            Broadcast History ({announcements.length})
          </span>
        </div>

        <div className="divide-y divide-slate-100">
          {announcements.map((ann) => (
            <div key={ann.id} className="p-5 space-y-2 hover:bg-slate-50/60 transition-colors">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <h3 className="font-bold text-slate-900 text-sm">{ann.title}</h3>
                  <span className="text-[10px] font-bold px-2 py-0.5 rounded bg-teal-50 text-teal-700 border border-teal-200">
                    {ann.targetRole}
                  </span>
                </div>
                <span className="text-xs text-slate-400 font-mono">{ann.sentDate}</span>
              </div>
              <p className="text-xs text-slate-600">{ann.content}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
