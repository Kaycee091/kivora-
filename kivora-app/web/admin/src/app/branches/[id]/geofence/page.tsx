'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  MapPin,
  Save,
  Check,
  Compass,
  AlertCircle,
  Sliders,
} from 'lucide-react';

export default function BranchGeofencePage() {
  const params = useParams();
  const id = params?.id as string || 'br-001';

  const [lat, setLat] = useState('6.524412');
  const [lng, setLng] = useState('3.379185');
  const [radius, setRadius] = useState(100);
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
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
            <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Geofence Boundary Configuration</h1>
            <p className="text-xs text-slate-500 mt-0.5">Define physical GPS verification coordinates and radius for {id}</p>
          </div>
        </div>

        <button
          onClick={handleSave}
          className="inline-flex items-center gap-2 px-4 py-2 text-xs font-semibold rounded-lg bg-teal-600 text-white hover:bg-teal-700 shadow-sm transition-all"
        >
          {saved ? <Check className="w-4 h-4" /> : <Save className="w-4 h-4" />}
          {saved ? 'Geofence Updated!' : 'Save Boundary'}
        </button>
      </div>

      {/* Geofence Form & Map Simulator */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-6">
        {/* Interactive Map Visual Simulator */}
        <div className="h-64 rounded-xl bg-slate-900 relative overflow-hidden flex items-center justify-center border border-slate-800">
          <div className="absolute inset-0 opacity-20 bg-[radial-gradient(#14b8a6_1px,transparent_1px)] [background-size:16px_16px]"></div>

          {/* Simulated Geofence Ring */}
          <div
            style={{
              width: `${Math.min(240, Math.max(80, radius * 1.4))}px`,
              height: `${Math.min(240, Math.max(80, radius * 1.4))}px`,
            }}
            className="rounded-full border-2 border-teal-500 bg-teal-500/10 flex items-center justify-center transition-all duration-300 relative"
          >
            <div className="w-4 h-4 rounded-full bg-teal-400 animate-ping absolute"></div>
            <div className="w-3 h-3 rounded-full bg-teal-500 shadow-lg"></div>
            <span className="absolute -bottom-6 text-[10px] font-mono text-teal-300 font-bold bg-slate-950/80 px-2 py-0.5 rounded-full border border-teal-500/30">
              Radius: {radius}m
            </span>
          </div>

          <div className="absolute top-3 left-3 bg-slate-950/80 px-3 py-1 rounded-lg border border-slate-700 text-[10px] font-mono text-slate-300 flex items-center gap-1.5">
            <Compass className="w-3.5 h-3.5 text-teal-400" />
            Lat: {lat}, Lng: {lng}
          </div>
        </div>

        <form onSubmit={handleSave} className="space-y-5">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 uppercase tracking-wider block">
                Center Latitude (WGS 84):
              </label>
              <input
                type="text"
                value={lat}
                onChange={(e) => setLat(e.target.value)}
                className="w-full text-xs font-mono p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 uppercase tracking-wider block">
                Center Longitude (WGS 84):
              </label>
              <input
                type="text"
                value={lng}
                onChange={(e) => setLng(e.target.value)}
                className="w-full text-xs font-mono p-3 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-teal-500"
              />
            </div>
          </div>

          <div className="space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-bold text-slate-700 uppercase tracking-wider">
                Geofence Radius (Meters):
              </label>
              <span className="font-mono text-xs font-bold text-teal-600 bg-teal-50 px-2.5 py-1 rounded-md">
                {radius} meters
              </span>
            </div>
            <input
              type="range"
              min="20"
              max="500"
              step="10"
              value={radius}
              onChange={(e) => setRadius(Number(e.target.value))}
              className="w-full accent-teal-600"
            />
            <p className="text-[11px] text-slate-500">
              Check-ins with GPS distance within this radius pass automatically. Points beyond this threshold trigger an exception review.
            </p>
          </div>
        </form>
      </div>
    </div>
  );
}
