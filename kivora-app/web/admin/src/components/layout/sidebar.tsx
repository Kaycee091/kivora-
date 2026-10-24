'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  LayoutDashboard,
  Clock,
  AlertTriangle,
  FileEdit,
  Users,
  UserCheck,
  UserPlus,
  Building2,
  Calendar,
  Layers,
  Network,
  Briefcase,
  FileCheck,
  ArrowRightLeft,
  Sliders,
  Coffee,
  BarChart3,
  Download,
  ShieldAlert,
  ShieldCheck,
  Settings,
} from 'lucide-react';
import { cn } from '@/lib/utils';

interface NavItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  badge?: string;
}

interface NavSection {
  title: string;
  items: NavItem[];
}

const navSections: NavSection[] = [
  {
    title: 'Attendance & Live Ops',
    items: [
      { name: 'Dashboard', href: '/', icon: LayoutDashboard },
      { name: 'Live Attendance', href: '/attendance/live', icon: Clock, badge: 'Live' },
      { name: 'Exceptions Review', href: '/attendance/exceptions', icon: AlertTriangle, badge: '4' },
      { name: 'Manual Corrections', href: '/attendance/corrections', icon: FileEdit },
    ],
  },
  {
    title: 'Members & Roster',
    items: [
      { name: 'Member Directory', href: '/members', icon: Users },
      { name: 'Join & ID Requests', href: '/members/requests', icon: UserCheck, badge: '3' },
      { name: 'Class Enrollments', href: '/organization/enrollments', icon: UserPlus },
    ],
  },
  {
    title: 'Branches & Boundaries',
    items: [
      { name: 'Branch Overview', href: '/branches', icon: Building2 },
    ],
  },
  {
    title: 'Schedules & Hierarchy',
    items: [
      { name: 'Session Windows', href: '/schedules/windows', icon: Calendar },
      { name: 'Classes & Groups', href: '/organization/groups', icon: Layers },
      { name: 'Departments', href: '/organization/departments', icon: Network },
      { name: 'Responsibilities', href: '/organization/responsibilities', icon: Briefcase },
    ],
  },
  {
    title: 'Approvals & Moves',
    items: [
      { name: 'Leave & Early Reviews', href: '/approvals/requests', icon: FileCheck },
      { name: 'Branch Transfers', href: '/approvals/transfers', icon: ArrowRightLeft },
    ],
  },
  {
    title: 'Policies & Rules',
    items: [
      { name: 'Attendance Rules', href: '/policies/attendance', icon: Sliders },
      { name: 'Breaks & Duration', href: '/policies/breaks', icon: Coffee },
    ],
  },
  {
    title: 'Intelligence & Audit',
    items: [
      { name: 'Reports & Analytics', href: '/reports', icon: BarChart3 },
      { name: 'Export Center', href: '/exports', icon: Download },
      { name: 'Audit Trail', href: '/audit', icon: ShieldCheck },
      { name: 'Security & Telemetry', href: '/security/logs', icon: ShieldAlert },
      { name: 'Settings & Operations', href: '/settings/operations', icon: Settings },
    ],
  },
];

export function Sidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-64 bg-slate-900 text-slate-300 flex flex-col h-screen fixed left-0 top-0 border-r border-slate-800 z-30 select-none">
      {/* Brand Header */}
      <div className="h-16 flex items-center px-6 gap-3 border-b border-slate-800 bg-slate-950/60 backdrop-blur">
        <div className="w-8 h-8 rounded-lg bg-teal-500 flex items-center justify-center font-extrabold text-white text-lg tracking-wider shadow-sm shadow-teal-500/30">
          K
        </div>
        <div>
          <span className="font-bold text-lg text-white tracking-wide">KIVORA</span>
          <span className="block text-[10px] text-teal-400 font-medium uppercase tracking-widest -mt-1">
            Enterprise Admin
          </span>
        </div>
      </div>

      {/* Navigation Sections */}
      <nav className="flex-1 overflow-y-auto px-3 py-4 space-y-6 scrollbar-thin scrollbar-thumb-slate-700">
        {navSections.map((section) => (
          <div key={section.title} className="space-y-1">
            <h4 className="px-3 text-[10px] font-bold text-slate-400 uppercase tracking-widest">
              {section.title}
            </h4>
            <div className="space-y-0.5 pt-1">
              {section.items.map((item) => {
                const Icon = item.icon;
                const isActive = pathname === item.href || (item.href !== '/' && pathname.startsWith(item.href));
                return (
                  <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                      'flex items-center justify-between px-3 py-2 text-xs font-medium rounded-lg transition-all',
                      isActive
                        ? 'bg-teal-600 text-white font-semibold shadow-sm shadow-teal-700/40'
                        : 'text-slate-300 hover:bg-slate-800/80 hover:text-white'
                    )}
                  >
                    <div className="flex items-center gap-2.5 truncate">
                      <Icon className={cn('w-4 h-4 flex-shrink-0', isActive ? 'text-white' : 'text-slate-400')} />
                      <span className="truncate">{item.name}</span>
                    </div>
                    {item.badge && (
                      <span
                        className={cn(
                          'text-[10px] px-1.5 py-0.5 rounded-full font-bold uppercase tracking-wider',
                          item.badge === 'Live'
                            ? 'bg-emerald-500/20 text-emerald-400 animate-pulse'
                            : 'bg-amber-500/20 text-amber-400'
                        )}
                      >
                        {item.badge}
                      </span>
                    )}
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>

      {/* Footer User Info */}
      <div className="p-4 border-t border-slate-800/80 bg-slate-950/40 flex items-center justify-between">
        <div className="flex items-center gap-3 overflow-hidden">
          <div className="w-8 h-8 rounded-full bg-teal-800/80 border border-teal-500/30 flex items-center justify-center font-bold text-teal-200 text-xs flex-shrink-0">
            WA
          </div>
          <div className="overflow-hidden">
            <p className="text-xs font-semibold text-white truncate">Administrator</p>
            <p className="text-[10px] text-teal-400 truncate">System Operator</p>
          </div>
        </div>
      </div>
    </aside>
  );
}
