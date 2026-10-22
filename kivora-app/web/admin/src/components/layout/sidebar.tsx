'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Clock,
  Users,
  UserCheck,
  Building2,
  Calendar,
  Layers,
  FileCheck,
  BarChart3,
  Download,
  ShieldCheck,
  Settings,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

const navSections: NavSection[] = [
  {
    title: 'Overview',
    items: [
      { name: 'Dashboard', href: '/', icon: LayoutDashboard },
      { name: 'Live Attendance', href: '/attendance/live', icon: Clock },
    ],
  },
  {
    title: 'Members & Branch',
    items: [
      { name: 'Member Directory', href: '/members', icon: Users },
      { name: 'Join Requests', href: '/members/requests', icon: UserCheck },
      { name: 'Branches', href: '/branches', icon: Building2 },
    ],
  },
  {
    title: 'Operations',
    items: [
      { name: 'Schedules', href: '/schedules', icon: Calendar },
      { name: 'Departments & Groups', href: '/organization/departments', icon: Layers },
      { name: 'Approvals & Requests', href: '/approvals', icon: FileCheck },
    ],
  },
  {
    title: 'Insights & Security',
    items: [
      { name: 'Reports & Analytics', href: '/reports', icon: BarChart3 },
      { name: 'Export Center', href: '/exports', icon: Download },
      { name: 'Audit History', href: '/audit', icon: ShieldCheck },
      { name: 'Settings', href: '/settings', icon: Settings },
    ],
  },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col h-screen fixed left-0 top-0 border-r border-slate-800 z-30">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 gap-3 border-b border-slate-800">
        <div className="w-8 h-8 rounded-lg bg-teal-500 flex items-center justify-center font-bold text-white text-lg tracking-wider">
          K
        </div>
        <div>
          <span className="font-bold text-lg text-white tracking-wide">KIVORA</span>
          <span className="block text-[10px] text-teal-400 font-medium uppercase tracking-widest -mt-1">
            Admin Portal
          </span>
        </div>
      </div>

      {/* Navigation Sections */}
      <nav className="flex-1 overflow-y-auto px-4 py-4 space-y-6">
        {navSections.map((section) => (
          <div key={section.title} className="space-y-1">
            <h4 className="px-3 text-[11px] font-semibold text-slate-400 uppercase tracking-wider">
              {section.title}
            </h4>
            <div className="space-y-0.5 pt-1">
              {section.items.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href;
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                      'flex items-center gap-3 px-3 py-2 text-sm font-medium rounded-lg transition-colors',
                      isActive
                        ? 'bg-teal-600 text-white font-semibold'
                        : 'text-slate-300 hover:bg-slate-800 hover:text-white'
                    )}
                  >
                    <Icon className="w-4 h-4" />
                    <span>{item.name}</span>
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      {/* Footer User Info */}
      <div className="p-4 border-t border-slate-800 flex items-center gap-3">
        <div className="w-9 h-9 rounded-full bg-slate-700 flex items-center justify-center font-semibold text-white text-xs">
          WA
        </div>
        <div className="overflow-hidden">
          <p className="text-xs font-medium text-white truncate">Admin User</p>
          <p className="text-[10px] text-slate-400 truncate">Super Administrator</p>
        </div>
      </div>
    </aside>
  );
}
