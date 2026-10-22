import test from 'node:test';
import assert from 'node:assert';

// Pure JS implementation of Haversine for unit testing
function calculateHaversineDistanceMeters(lat1, lon1, lat2, lon2) {
  const R = 6371e3;
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

function evaluateEvidence(evidence, branchLat, branchLon, geofenceRadius = 100) {
  let biometricResult = 'unavailable';
  if (evidence.biometricVerified === true) biometricResult = 'passed';
  if (evidence.biometricVerified === false) biometricResult = 'failed';

  let gpsResult = 'unavailable';
  let distance = -1;
  if (evidence.latitude !== undefined && evidence.longitude !== undefined) {
    distance = calculateHaversineDistanceMeters(evidence.latitude, evidence.longitude, branchLat, branchLon);
    if (distance <= geofenceRadius) {
      gpsResult = 'passed';
    } else if (evidence.accuracyMeters && evidence.accuracyMeters > 50) {
      gpsResult = 'needs_review';
    } else {
      gpsResult = 'failed';
    }
  }

  let overallStatus = 'passed';
  if (biometricResult === 'failed' || gpsResult === 'failed') {
    overallStatus = 'failed';
  } else if (biometricResult === 'needs_review' || gpsResult === 'needs_review') {
    overallStatus = 'needs_review';
  } else if (biometricResult === 'passed' && (gpsResult === 'passed' || gpsResult === 'unavailable')) {
    overallStatus = 'passed';
  } else {
    overallStatus = 'needs_review';
  }

  return { overallStatus, biometricResult, gpsResult, distance };
}

test('Haversine distance calculates accurate zero distance for identical coordinates', () => {
  const dist = calculateHaversineDistanceMeters(6.5244, 3.3792, 6.5244, 3.3792);
  assert.strictEqual(Math.round(dist), 0);
});

test('Verification evaluation marks PASSED when biometric passes and device is inside geofence', () => {
  const result = evaluateEvidence(
    { biometricVerified: true, latitude: 6.5244, longitude: 3.3792, accuracyMeters: 5 },
    6.5244,
    3.3792,
    100
  );
  assert.strictEqual(result.overallStatus, 'passed');
  assert.strictEqual(result.biometricResult, 'passed');
  assert.strictEqual(result.gpsResult, 'passed');
});

test('Verification evaluation marks FAILED when device coordinates are outside geofence boundary', () => {
  // Coords approximately 1km away
  const result = evaluateEvidence(
    { biometricVerified: true, latitude: 6.5334, longitude: 3.3792, accuracyMeters: 10 },
    6.5244,
    3.3792,
    100
  );
  assert.strictEqual(result.overallStatus, 'failed');
  assert.strictEqual(result.gpsResult, 'failed');
});

test('Verification evaluation marks NEEDS_REVIEW when GPS accuracy is poor (>50m)', () => {
  const result = evaluateEvidence(
    { biometricVerified: true, latitude: 6.5260, longitude: 3.3792, accuracyMeters: 80 },
    6.5244,
    3.3792,
    100
  );
  assert.strictEqual(result.overallStatus, 'needs_review');
  assert.strictEqual(result.gpsResult, 'needs_review');
});
