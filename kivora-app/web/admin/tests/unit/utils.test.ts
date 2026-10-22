import { describe, it, expect } from 'vitest';
import { cn, formatDate, formatTime } from '../../src/lib/utils';

describe('Web Admin Utilities', () => {
  it('cn merges Tailwind CSS classes correctly', () => {
    const result = cn('bg-red-500 text-white', 'bg-blue-500');
    expect(result).toBe('text-white bg-blue-500');
  });

  it('formatDate formats ISO dates to readable string', () => {
    const res = formatDate('2026-04-16T12:00:00Z');
    expect(res).toContain('2026');
  });

  it('formatDate returns dash for null or undefined', () => {
    expect(formatDate(null)).toBe('—');
    expect(formatDate(undefined)).toBe('—');
  });

  it('formatTime returns dash for null or undefined', () => {
    expect(formatTime(null)).toBe('—');
  });
});
