import React from 'react';

const StatCard = ({ title, value, subtitle, icon: Icon, colorClass = "text-primary-600", bgClass = "bg-primary-50" }) => {
  const isDanger = colorClass.includes('red') || colorClass.includes('orange');
  const hoverStroke = isDanger ? 'group-hover:border-red-200' : 'group-hover:border-primary-200';
  
  return (
    <div className={`glass-panel p-6 rounded-2xl border border-slate-100 shadow-sm hover:-translate-y-1 transition-all duration-300 group overflow-hidden relative`}>
      <div className="flex items-center justify-between relative z-10">
        <div>
          <p className="text-sm font-bold text-slate-500 mb-1 tracking-wide uppercase">{title}</p>
          <h3 className="text-4xl font-display font-black text-slate-900 tracking-tight drop-shadow-sm">{value}</h3>
        </div>
        <div className={`p-4 rounded-2xl shadow-inner border border-white/50 backdrop-blur-md ${bgClass} transition-transform group-hover:scale-110 duration-300`}>
          <Icon className={`w-8 h-8 ${colorClass} drop-shadow-sm`} />
        </div>
      </div>
      {subtitle && (
        <div className="mt-4 text-sm text-slate-500 font-medium relative z-10">
          {subtitle}
        </div>
      )}
      <div className={`absolute inset-0 bg-gradient-to-br from-white/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity rounded-2xl rounded-2xl border border-transparent ${hoverStroke} -z-0`} />
    </div>
  );
};

export default StatCard;
