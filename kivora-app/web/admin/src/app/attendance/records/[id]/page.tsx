'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useParams } from 'next/navigation';
import {
  ArrowLeft,
  CheckCircle2,
  AlertTriangle,
  Clock,
  MapPin,
  Wifi,
  Fingerprint,
  User,
  ShieldCheck,
  Building2,
  Calendar,
  FileText,
  Check,
  X,
} from 'lucide-react';

export default function AttendanceRecordDetailPage() {
  const params = useParams();
  const id = params?.id as string || 'rec-001';

  const [reviewStatus, setReviewStatus] = useState<'REVIEWED' | 'CONFIRMED' | 'REJECTED' | null>(null);

  const record = {
    id: id,
    member: {
      name: 'Sarah Johnson',
      role: 'Student',
      email: 'sarah.johnson@kivora.edu.ng',
      studentId: 'STU00123',
      branch: 'West Campus',
      avatar: 'SJ',
    },
    session: {
      name: 'Computer Science 201 — Data Structures',
      room: 'Block B - Room 203',
      lecturer: 'Dr. Samuel Adeyemi',
      scheduledStart: '08:00 AM',
      scheduledEnd: '10:00 AM',
      date: 'Monday, 21 April 2025',
    },
    attendance: {
      checkInTime: '08:02:14 UTC',
      checkOutTime: '10:01:45 UTC',
      duration: '1h 59m 31s',
      status: 'Present',
      isLate: false,
      gracePeriodMinutes: 15,
    },
    telemetry: {
      biometric: {
        outcome: 'PASSED',
        type: 'FINGERPRINT (Local OS Keystore)',
        sensorConfidence: 'High (0.98)',
        deviceId: 'SM-G998B-e234a9b',
      },
      gps: {
        outcome: 'PASSED',
        userCoordinates: { lat: 6.524379, lng: 3.379206 },
        branchCoordinates: { lat: 6.524412, lng: 3.379185 },
        distanceMeters: 4.2,
        geofenceRadiusMeters: 100,
        accuracyMeters: 8.5,
      },
      network: {
        outcome: 'PASSED',
        bssid: '84:d4:7e:92:4a:12',
        ssid: 'Kivora-Campus-Secure',
        clientIp: '197.210.45.88',
        gatewayMatch: true,
      },
    },
    audit: [
      { timestamp: '08:02:14 AM', event: 'Biometric cryptographic token signed by device keystore.' },
      { timestamp: '08:02:15 AM', event: 'Geofence validated (4.2m from center). Passed radius 100m.' },
      { timestamp: '08:02:16 AM', event: 'Attendance record created. Status set to Present.' },
    ],
  };

  return (
    <div className="space-y-6">
      {/* Back button and Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <Link
            href="/attendance/live"
            className="p-2 rounded-lg bg-white border border-slate-200 text-slate-600 hover:text-slate-900 shadow-sm"
          >
            <ArrowLeft className="w-5 h-5" />
          </Link>
          <div>
            <div className="flex items-center gap-2">
              <h1 className="text-2xl font-bold text-slate-900 tracking-tight">Record Telemetry & Details</h1>
              <span className="text-xs px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-700 font-mono font-medium">
                {record.id}
              </span>
            </div>
            <p className="text-xs text-slate-500 mt-0.5">Comprehensive audit trail and verification telemetry</p>
          </div>
        </div>

        {/* Action Controls */}
        <div className="flex items-center gap-3">
          {reviewStatus ? (
            <span className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200">
              <Check className="w-4 h-4" /> Action Logged: {reviewStatus}
            </span>
          ) : (
            <>
              <button
                onClick={() => setReviewStatus('CONFIRMED')}
                className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-emerald-600 text-white hover:bg-emerald-700 shadow-sm transition-all"
              >
                <Check className="w-4 h-4" />
                Validate Presence
              </button>
              <button
                onClick={() => setReviewStatus('REJECTED')}
                className="inline-flex items-center gap-1.5 px-3.5 py-2 text-xs font-semibold rounded-lg bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200 transition-all"
              >
                <X className="w-4 h-4" />
                Flag Exception
              </button>
            </>
          )}
        </div>
      </div>

      {/* Grid: Overview Cards */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Member Profile Card */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center gap-3 pb-4 border-b border-slate-100">
            <div className="w-12 h-12 rounded-full bg-teal-600 text-white font-bold flex items-center justify-center text-lg">
              {record.member.avatar}
            </div>
            <div>
              <h2 className="font-bold text-slate-900">{record.member.name}</h2>
              <span className="text-xs font-medium text-teal-600 bg-teal-50 px-2 py-0.5 rounded-full">
                {record.member.role} • {record.member.studentId}
              </span>
            </div>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Email:</span>
              <span className="font-medium text-slate-800">{record.member.email}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Branch:</span>
              <span className="font-medium text-slate-800">{record.member.branch}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Assigned Class:</span>
              <span className="font-medium text-slate-800">Year 2 — Computer Science</span>
            </div>
          </div>
        </div>

        {/* Session Info Card */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center gap-2 pb-4 border-b border-slate-100">
            <Calendar className="w-5 h-5 text-teal-600" />
            <h2 className="font-bold text-slate-900">Session Window</h2>
          </div>

          <div className="space-y-2.5 text-xs">
            <div>
              <span className="text-slate-400 block">Class:</span>
              <span className="font-semibold text-slate-900 text-sm">{record.session.name}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Room / Location:</span>
              <span className="font-medium text-slate-800">{record.session.room}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Instructor:</span>
              <span className="font-medium text-slate-800">{record.session.lecturer}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Window:</span>
              <span className="font-medium text-slate-800">
                {record.session.scheduledStart} – {record.session.scheduledEnd}
              </span>
            </div>
          </div>
        </div>

        {/* Outcome Summary Card */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-4 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <Clock className="w-5 h-5 text-teal-600" />
              <h2 className="font-bold text-slate-900">Recorded Times</h2>
            </div>
            <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700">
              {record.attendance.status}
            </span>
          </div>

          <div className="space-y-2.5 text-xs">
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Check-In Event:</span>
              <span className="font-semibold text-slate-900">{record.attendance.checkInTime}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Check-Out Event:</span>
              <span className="font-semibold text-slate-900">{record.attendance.checkOutTime}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Logged Duration:</span>
              <span className="font-semibold text-emerald-600">{record.attendance.duration}</span>
            </div>
            <div className="flex justify-between text-slate-600">
              <span className="text-slate-400">Grace Period Applied:</span>
              <span className="font-medium text-slate-800">{record.attendance.gracePeriodMinutes} mins</span>
            </div>
          </div>
        </div>
      </div>

      {/* Deep Telemetry Breakdown (Biometric, GPS, Network) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Biometric Telemetry */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <Fingerprint className="w-5 h-5 text-teal-600" />
              <h3 className="font-bold text-slate-900 text-sm">Biometric Assertion</h3>
            </div>
            <span className="text-xs px-2 py-0.5 font-bold rounded-md bg-emerald-50 text-emerald-700">
              {record.telemetry.biometric.outcome}
            </span>
          </div>

          <div className="space-y-2 text-xs text-slate-600">
            <div>
              <span className="text-slate-400 block">Biometric Method:</span>
              <span className="font-medium text-slate-800">{record.telemetry.biometric.type}</span>
            </div>
            <div>
              <span className="text-slate-400 block">Confidence Score:</span>
              <span className="font-medium text-slate-800">{record.telemetry.biometric.sensorConfidence}</span>
            </div>
            <div>
              <span className="text-slate-400 block">Device Identifier:</span>
              <span className="font-mono text-slate-600">{record.telemetry.biometric.deviceId}</span>
            </div>
          </div>
        </div>

        {/* GPS Geofence Telemetry */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <MapPin className="w-5 h-5 text-teal-600" />
              <h3 className="font-bold text-slate-900 text-sm">GPS Geofence Engine</h3>
            </div>
            <span className="text-xs px-2 py-0.5 font-bold rounded-md bg-emerald-50 text-emerald-700">
              {record.telemetry.gps.outcome}
            </span>
          </div>

          <div className="space-y-2 text-xs text-slate-600">
            <div>
              <span className="text-slate-400 block">Calculated Distance:</span>
              <span className="font-bold text-emerald-600">{record.telemetry.gps.distanceMeters} meters from center</span>
            </div>
            <div>
              <span className="text-slate-400 block">Allowed Radius:</span>
              <span className="font-medium text-slate-800">{record.telemetry.gps.geofenceRadiusMeters} meters</span>
            </div>
            <div>
              <span className="text-slate-400 block">Reported GPS Accuracy:</span>
              <span className="font-medium text-slate-800">±{record.telemetry.gps.accuracyMeters} meters</span>
            </div>
          </div>
        </div>

        {/* Network Telemetry */}
        <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <Wifi className="w-5 h-5 text-teal-600" />
              <h3 className="font-bold text-slate-900 text-sm">Network Telemetry</h3>
            </div>
            <span className="text-xs px-2 py-0.5 font-bold rounded-md bg-emerald-50 text-emerald-700">
              {record.telemetry.network.outcome}
            </span>
          </div>

          <div className="space-y-2 text-xs text-slate-600">
            <div>
              <span className="text-slate-400 block">Access Point BSSID:</span>
              <span className="font-mono text-slate-800">{record.telemetry.network.bssid}</span>
            </div>
            <div>
              <span className="text-slate-400 block">SSID:</span>
              <span className="font-medium text-slate-800">{record.telemetry.network.ssid}</span>
            </div>
            <div>
              <span className="text-slate-400 block">Public Client IP:</span>
              <span className="font-mono text-slate-800">{record.telemetry.network.clientIp}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Immutable Audit Log */}
      <div className="bg-white p-6 rounded-2xl border border-slate-200 shadow-sm">
        <div className="flex items-center gap-2 mb-4 pb-2 border-b border-slate-100">
          <ShieldCheck className="w-5 h-5 text-teal-600" />
          <h3 className="font-bold text-slate-900 text-sm">Immutable Verification Event Log</h3>
        </div>

        <div className="space-y-3">
          {record.audit.map((entry, idx) => (
            <div key={idx} className="flex items-start gap-3 text-xs">
              <span className="font-mono text-slate-400 font-medium whitespace-nowrap">{entry.timestamp}</span>
              <div className="w-2 h-2 rounded-full bg-teal-500 mt-1 flex-shrink-0"></div>
              <p className="text-slate-700">{entry.event}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
