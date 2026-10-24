'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import {
  Building2,
  MapPin,
  Wifi,
  Users,
  Shield,
  Plus,
  Search,
  ExternalLink,
  CheckCircle2,
} from 'lucide-react';

interface BranchItem {
  id: string;
  name: string;
  code: string;
  type: string;
  address: string;
  activeMembers: number;
  geofenceRadius: number;
  trustedNetworksCount: number;
  manager: string;
  status: 'ACTIVE' | 'INACTIVE';
}

const mockBranches: BranchItem[] = [
  {
    id: 'br-001',
    name: 'West Campus',
    code: 'WEST-01',
    type: 'Higher Education Campus',
    address: '12 Education Road, Lagos, Nigeria',
    activeMembers: 1042,
    geofenceRadius: 100,
    trustedNetworksCount: 3,
    manager: 'Sarah Wilson',
    status: 'ACTIVE',
  },
  {
    id: 'br-002',
    name: 'East Campus',
    code: 'EAST-02',
    type: 'Science & Technology Branch',
    address: '45 Innovation Way, Enugu, Nigeria',
    activeMembers: 412,
    geofenceRadius: 150,
    trustedNetworksCount: 2,
    manager: 'Michael Brown',
    status: 'ACTIVE',
  },
  {
    id: 'br-003',
    name: 'North Campus',
    code: 'NORTH-03',
    type: 'Administrative Hub',
    address: '88 Commercial Crescent, Kano, Nigeria',
    activeMembers: 198,
    geofenceRadius: 80,
    trustedNetworksCount: 1,
    manager: 'Daniel Taylor',
    status: 'ACTIVE',
  },
  {
    id: 'br-004',
    name: 'South Campus',
    code: 'SOUTH-04',
    type: 'Vocational Training Facility',
    address: '14 River View Avenue, Port Harcourt, Nigeria',
    activeMembers: 320,
    geofenceRadius: 120,
    trustedNetworksCount: 2,
    manager: 'Grace Okon',
    status: 'ACTIVE',
  },
];

export default function BranchesPage() {
  const [searchTerm, setSearchTerm] = useState('');

  const filtered = mockBranches.filter(
    (b) =>
      b.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      b.code.toLowerCase().includes(searchTerm.toLowerCase()) ||
      b.address.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Branch Infrastructure & Overview</h1>
          <p className="text-sm text-slate-500 mt-1">
            Manage multi-tenant campus branches, physical boundaries, and network verifiers.
          </p>
        </div>
      </div>

      {/* Search & Actions */}
      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm flex flex-col md:flex-row gap-4 justify-between items-center">
        <div className="relative w-full md:w-96">
          <Search className="w-4 h-4 text-slate-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
          <input
            type="text"
            placeholder="Search branches by name, code or city..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="w-full pl-10 pr-4 py-2 text-sm rounded-lg border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent"
          />
        </div>
      </div>

      {/* Branches Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {filtered.map((branch) => (
          <div
            key={branch.id}
            className="bg-white rounded-2xl border border-slate-200 shadow-sm p-6 space-y-5 hover:border-slate-300 transition-all flex flex-col justify-between"
          >
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-teal-50 border border-teal-200 text-teal-700 flex items-center justify-center font-bold">
                    <Building2 className="w-5 h-5" />
                  </div>
                  <div>
                    <h2 className="font-bold text-slate-900 text-base">{branch.name}</h2>
                    <span className="text-xs text-slate-400 font-mono">{branch.code} • {branch.type}</span>
                  </div>
                </div>
                <span className="text-xs px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 font-bold border border-emerald-200">
                  {branch.status}
                </span>
              </div>

              <p className="text-xs text-slate-500 flex items-center gap-1.5">
                <MapPin className="w-3.5 h-3.5 text-slate-400 flex-shrink-0" />
                {branch.address}
              </p>

              {/* Metrics */}
              <div className="grid grid-cols-3 gap-2 pt-2">
                <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-center">
                  <span className="text-[10px] text-slate-400 font-semibold uppercase block">Members</span>
                  <span className="font-bold text-slate-900 text-sm">{branch.activeMembers}</span>
                </div>
                <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-center">
                  <span className="text-[10px] text-slate-400 font-semibold uppercase block">Geofence</span>
                  <span className="font-bold text-slate-900 text-sm">{branch.geofenceRadius}m</span>
                </div>
                <div className="bg-slate-50 p-3 rounded-xl border border-slate-100 text-center">
                  <span className="text-[10px] text-slate-400 font-semibold uppercase block">Networks</span>
                  <span className="font-bold text-slate-900 text-sm">{branch.trustedNetworksCount} CIDRs</span>
                </div>
              </div>
            </div>

            {/* Quick Management Links */}
            <div className="pt-4 border-t border-slate-100 flex flex-wrap items-center justify-between gap-2">
              <span className="text-xs text-slate-500">
                Lead Admin: <strong className="text-slate-700">{branch.manager}</strong>
              </span>

              <div className="flex items-center gap-2">
                <Link
                  href={`/branches/${branch.id}/geofence`}
                  className="px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 hover:bg-slate-200 transition-colors flex items-center gap-1"
                >
                  <MapPin className="w-3.5 h-3.5 text-teal-600" />
                  Geofence
                </Link>
                <Link
                  href={`/branches/${branch.id}/network`}
                  className="px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 hover:bg-slate-200 transition-colors flex items-center gap-1"
                >
                  <Wifi className="w-3.5 h-3.5 text-teal-600" />
                  Network
                </Link>
                <Link
                  href={`/branches/${branch.id}/managers`}
                  className="px-2.5 py-1.5 rounded-lg text-xs font-semibold bg-slate-100 text-slate-700 hover:bg-slate-200 transition-colors flex items-center gap-1"
                >
                  <Shield className="w-3.5 h-3.5 text-teal-600" />
                  Managers
                </Link>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
