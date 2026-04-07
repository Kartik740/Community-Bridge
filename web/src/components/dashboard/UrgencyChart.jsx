import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, Cell } from 'recharts';

const getUrgencyColor = (score) => {
  if (score >= 8) return '#ef4444'; // critical
  if (score >= 6) return '#f97316'; // high
  if (score >= 4) return '#eab308'; // medium
  return '#22c55e'; // low
};

const UrgencyChart = ({ data }) => {
  if (!data || data.length === 0) return null;

  return (
    <div className="h-72 w-full">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          margin={{ top: 20, right: 30, left: 0, bottom: 5 }}
        >
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E5E7EB" />
          <XAxis dataKey="areaName" axisLine={false} tickLine={false} tick={{fill: '#6B7280', fontSize: 12}} />
          <YAxis axisLine={false} tickLine={false} tick={{fill: '#6B7280', fontSize: 12}} />
          <Tooltip 
            cursor={{fill: '#F3F4F6'}}
            contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
          />
          <Bar dataKey="urgencyScore" radius={[4, 4, 0, 0]}>
             {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={getUrgencyColor(entry.urgencyScore)} />
             ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default UrgencyChart;
