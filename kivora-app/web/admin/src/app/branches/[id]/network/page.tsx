'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  Wifi,
  Save,
  Check,
  Plus,
  Trash2,
  ShieldCheck,
  AlertCircle,
} from 'lucide-react';

export default function BranchNetworkPage() {
  const params = useParams();
  const id = params?.id as string || 'br-001';

  const [cidrs, setCidrs] = useState<string[]>([
    '197.210.45.0/24',
    '105.112.98.0/24',
  ]);
  const [newCidr, setNewCidr] = useState('');
  const [bssids, setBssids] = useState<string[]>([
    '84:d4:7e:92:4a:12',
    '84:d4:7e:92:4a:13',
  ]);
  const [newBssid, setNewBssid] = useState('');
  const [fallbackPolicy, setFallbackPolicy] = useState('needs_review');
  const [saved, setSaved] = useState(false);

  const handleAddCidr = () => {
    if (newCidr.trim()) {
      setCidrs([...cidrs, newCidr.trim()]);
      setNewCidr('');
    }
  };

  const handleRemoveCidr = (index: number) => {
    setCidrs(cidrs.filter((_, i) => i !== index));
  };

  const handleAddBssid = () => {
    if (newBssid.trim()) {
      setBssids([...bssids, newBssid.trim()]);
      setNewBssid('');
    }
  };

  const handleRemoveBssid = (index: number) => {
    setBssids(bssids.filter((_, i) => i !== index));
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href="/branches"
            className="p-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-slate-900 shadow-sm"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Network Verification Setup</h1>
            <p className="text-xs text-slate-500 mt-0.5">Configure campus Wi-Fi BSSID and IP CIDR validation policies for {id}</p>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          {saved ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          {saved ? 'Policies Saved!' : 'Save Network Config'}
        </button>
      </div>

      {/* Allowed CIDR Blocks */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div>
            <h2 className="font-bold text-slate-900 text-sm">Trusted Public IP CIDR Blocks</h2>
            <p className="text-xs text-slate-500">Match incoming HTTP check-in requests against branch gateway addresses.</p>
          </div>
        </div>

        <div className="flex gap-2">
          <input
            type="text"
            placeholder="e.g. 197.210.45.0/24"
            value={newCidr}
            onChange={(e) => setNewCidr(e.target.value)}
            className="flex-1 text-xs font-mono p-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
          />
          <button
            type="button"
            onClick={handleAddCidr}
            className="px-3.5 py-2 text-xs font-semibold rounded-xl bg-teal-50 text-teal-700 hover:bg-teal-100 border border-teal-200 flex items-center gap-1"
          >
            <Plus className="w-3.5 h-3.5" /> Add CIDR
          </button>
        </div>

        <div className="space-y-2 pt-2">
          {cidrs.map((cidr, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100 text-xs font-mono text-slate-800"
            >
              <span>{cidr}</span>
              <button
                onClick={() => handleRemoveCidr(idx)}
                className="text-slate-400 hover:text-rose-600 p-1"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Authorized BSSID MACs */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
        <div className="flex items-center justify-between pb-3 border-b border-slate-100">
          <div>
            <h2 className="font-bold text-slate-900 text-sm">Authorized Wi-Fi BSSID Hardware MACs</h2>
            <p className="text-xs text-slate-500">Verified campus access point hardware identifiers reported by mobile OS.</p>
          </div>
        </div>

        <div className="flex gap-2">
          <input
            type="text"
            placeholder="e.g. 84:d4:7e:92:4a:12"
            value={newBssid}
            onChange={(e) => setNewBssid(e.target.value)}
            className="flex-1 text-xs font-mono p-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
          />
          <button
            type="button"
            onClick={handleAddBssid}
            className="px-3.5 py-2 text-xs font-semibold rounded-xl bg-teal-50 text-teal-700 hover:bg-teal-100 border border-teal-200 flex items-center gap-1"
          >
            <Plus className="w-3.5 h-3.5" /> Add BSSID
          </button>
        </div>

        <div className="space-y-2 pt-2">
          {bssids.map((bssid, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between p-3 rounded-xl bg-slate-50 border border-slate-100 text-xs font-mono text-slate-800"
            >
              <span>{bssid}</span>
              <button
                onClick={() => handleRemoveBssid(idx)}
                className="text-slate-400 hover:text-rose-600 p-1"
              >
                <Trash2 className="w-4 h-4" />
              </button>
            </div>
          ))}
        </div>
      </div>

      {/* Fallback Behavior Policy */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-3">
        <h2 className="font-bold text-slate-900 text-sm">Network Verification Fallback Mode</h2>
        <p className="text-xs text-slate-500">
          In compliance with PRD Section 4.3 (Handling CGNAT & Dynamic Carrier Cellular IP limits):
        </p>

        <select
          value={fallbackPolicy}
          onChange={(e) => setFallbackPolicy(e.target.value)}
          className="w-full text-xs font-medium border border-slate-200 rounded-xl p-3 bg-slate-50 text-slate-800 focus:ring-2 focus:ring-teal-500"
        >
          <option value="needs_review">
            Allow Check-In with Flag &quot;NEEDS_REVIEW&quot; if Biometric & GPS Pass
          </option>
          <option value="strict_reject">Strict Mode: Reject Check-In if Network Check Fails</option>
          <option value="advisory_only">Advisory Only: Log Network Outcome without Blocking Presence</option>
        </select>
      </div>
    </div>
  );
}
