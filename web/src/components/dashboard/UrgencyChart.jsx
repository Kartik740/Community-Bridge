import React from 'react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid, Cell } from 'recharts';

const getUrgencyGradient = (score) => {
  if (score >= 8) return 'url(#colorCritical)';
  if (score >= 6) return 'url(#colorHigh)';
  if (score >= 4) return 'url(#colorMedium)';
  return 'url(#colorLow)';
};

const UrgencyChart = ({ data }) => {
  if (!data || data.length === 0) return null;

  return (
    <div className="h-72 w-full mt-2">
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          margin={{ top: 10, right: 10, left: -20, bottom: 0 }}
        >
          <defs>
            <linearGradient id="colorCritical" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#f43f5e" stopOpacity={1}/>
              <stop offset="100%" stopColor="#be123c" stopOpacity={0.9}/>
            </linearGradient>
            <linearGradient id="colorHigh" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#fb923c" stopOpacity={1}/>
              <stop offset="100%" stopColor="#c2410c" stopOpacity={0.9}/>
            </linearGradient>
            <linearGradient id="colorMedium" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#fde047" stopOpacity={1}/>
              <stop offset="100%" stopColor="#a16207" stopOpacity={0.9}/>
            </linearGradient>
            <linearGradient id="colorLow" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#34d399" stopOpacity={1}/>
              <stop offset="100%" stopColor="#047857" stopOpacity={0.9}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
          <XAxis 
            dataKey="areaName" 
            axisLine={false} 
            tickLine={false} 
            tick={{fill: '#94a3b8', fontSize: 13, fontWeight: 500}} 
            dy={10}
          />
          <YAxis 
            axisLine={false} 
            tickLine={false} 
            tick={{fill: '#94a3b8', fontSize: 13, fontWeight: 500}} 
          />
          <Tooltip 
            cursor={{fill: '#f8fafc'}}
            contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 40px -10px rgba(0,0,0,0.12)', padding: '12px 20px', fontWeight: 600, color: '#1e293b' }}
            itemStyle={{ color: '#334155', fontWeight: 'bold' }}
            cursorStyle={{ opacity: 0.5 }}
          />
          <Bar dataKey="urgencyScore" barSize={36} radius={[6, 6, 0, 0]}>
             {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={getUrgencyGradient(entry.urgencyScore)} />
             ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </div>
  );
};

export default UrgencyChart;
