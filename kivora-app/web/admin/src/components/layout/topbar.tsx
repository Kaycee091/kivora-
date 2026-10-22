'use client';

import React from 'react';
import { Bell, Search, Globe, ChevronDown } from 'lucide-react';

export function Topbar() {
  return (
    <header className="h-16 bg-white border-b border-slate-200 fixed top-0 right-0 left-64 z-20 flex items-center justify-between px-8">
      {/* Branch Context Selector */}
      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 px-3 py-1.5 bg-slate-100 rounded-lg border border-slate-200 text-sm font-medium text-slate-700 cursor-pointer hover:bg-slate-200 transition-colors">
          <Globe className="w-4 h-4 text-teal-600" />
          <span>West Campus (Primary)</span>
          <ChevronDown className="w-3.5 h-3.5 text-slate-400" />
        </div>
        <span className="text-xs text-slate-400">All attendance & member actions scoped to this branch</span>
      </div>

      {/* Global Search & Notifications */}
      <div className="flex items-center gap-4">
        <div className="relative w-64">
          <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            placeholder="Search members, IDs, sessions..."
            className="w-full pl-9 pr-4 py-1.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-teal-500 focus:bg-white"
          />
        </div>

        <button
          type="button"
          aria-label="View notifications"
          className="relative p-2 text-slate-500 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition-colors"
        >
          <Bell className="w-5 h-5" />
          <span className="absolute top-1.5 right-1.5 w-2 h-2 bg-teal-500 rounded-full" />
        </button>
      </div>
    </header>
  );
}
