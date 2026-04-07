import React from 'react';

const getUrgencyConfig = (score) => {
  if (score >= 8) return { label: 'CRITICAL', className: 'bg-urgency-critical/10 text-urgency-critical border-urgency-critical/20' };
  if (score >= 6) return { label: 'HIGH', className: 'bg-urgency-high/10 text-urgency-high border-urgency-high/20' };
  if (score >= 4) return { label: 'MEDIUM', className: 'bg-urgency-medium/10 text-urgency-medium border-urgency-medium/20' };
  return { label: 'LOW', className: 'bg-urgency-low/10 text-urgency-low border-urgency-low/20' };
};

const UrgencyBadge = ({ score }) => {
  const config = getUrgencyConfig(score);
  return (
    <div className={`px-2.5 py-1 text-xs font-bold rounded-md border inline-flex items-center space-x-1 ${config.className}`}>
      <span className="w-1.5 h-1.5 rounded-full bg-current"></span>
      <span>{config.label} ({score})</span>
    </div>
  );
};

export default UrgencyBadge;
