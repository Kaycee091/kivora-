// Haversine formula to calculate distance between coordinates in meters
export function calculateHaversineDistanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const R = 6371e3; // Earth radius in meters
  const phi1 = (lat1 * Math.PI) / 180;
  const phi2 = (lat2 * Math.PI) / 180;
  const deltaPhi = ((lat2 - lat1) * Math.PI) / 180;
  const deltaLambda = ((lon2 - lon1) * Math.PI) / 180;

  const a =
    Math.sin(deltaPhi / 2) * Math.sin(deltaPhi / 2) +
    Math.cos(phi1) * Math.cos(phi2) * Math.sin(deltaLambda / 2) * Math.sin(deltaLambda / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return R * c;
}

export type VerificationState = 'passed' | 'failed' | 'unavailable' | 'needs_review';

export interface VerificationEvidence {
  biometricVerified?: boolean;
  latitude?: number;
  longitude?: number;
  accuracyMeters?: number;
  networkBssid?: string;
  clientIp?: string;
}

export interface VerificationEvaluation {
  overallStatus: VerificationState;
  biometricResult: VerificationState;
  gpsResult: VerificationState;
  networkResult: VerificationState;
  details: Record<string, unknown>;
}

export function evaluateVerificationEvidence(
  evidence: VerificationEvidence,
  branchLat?: number,
  branchLon?: number,
  geofenceRadius = 100
): VerificationEvaluation {
  // 1. Biometric evaluation
  let biometricResult: VerificationState = 'unavailable';
  if (evidence.biometricVerified === true) {
    biometricResult = 'passed';
  } else if (evidence.biometricVerified === false) {
    biometricResult = 'failed';
  }

  // 2. GPS evaluation
  let gpsResult: VerificationState = 'unavailable';
  let distance = -1;
  if (
    evidence.latitude !== undefined &&
    evidence.longitude !== undefined &&
    branchLat !== undefined &&
    branchLon !== undefined
  ) {
    distance = calculateHaversineDistanceMeters(
      evidence.latitude,
      evidence.longitude,
      branchLat,
      branchLon
    );
    if (distance <= geofenceRadius) {
      gpsResult = 'passed';
    } else if (evidence.accuracyMeters && evidence.accuracyMeters > 50) {
      // Inaccurate reading inside urban canyon/indoor
      gpsResult = 'needs_review';
    } else {
      gpsResult = 'failed';
    }
  }

  // 3. Network evaluation
  const networkResult: VerificationState = 'unavailable'; // default unless network verification is enabled

  // 4. Overall status calculation
  let overallStatus: VerificationState = 'passed';
  if (biometricResult === 'failed' || gpsResult === 'failed') {
    overallStatus = 'failed';
  } else if (biometricResult === 'needs_review' || gpsResult === 'needs_review') {
    overallStatus = 'needs_review';
  } else if (biometricResult === 'passed' && (gpsResult === 'passed' || gpsResult === 'unavailable')) {
    overallStatus = 'passed';
  } else {
    overallStatus = 'needs_review';
  }

  return {
    overallStatus,
    biometricResult,
    gpsResult,
    networkResult,
    details: {
      distanceMeters: Math.round(distance),
      geofenceRadius,
    },
  };
}
