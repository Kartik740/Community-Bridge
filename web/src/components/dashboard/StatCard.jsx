import React from 'react';

const StatCard = ({ title, value, subtitle, icon: Icon, colorClass = "text-primary-600", bgClass = "bg-primary-50" }) => {
  const isDanger = colorClass.includes('red') || colorClass.includes('orange');
  const hoverStroke = isDanger ? 'group-hover:border-red-200' : 'group-hover:border-primary-200';
  
  return (
    <div className={`glass-panel p-7 rounded-[2rem] border border-white shadow-[0_8px_30px_rgb(0,0,0,0.04)] hover:shadow-[0_20px_40px_rgb(0,0,0,0.08)] hover:-translate-y-1.5 transition-all duration-300 group overflow-hidden relative bg-white/70 backdrop-blur-xl`}>
      {/* Ambient background glow */}
      <div className={`absolute -right-6 -top-6 w-32 h-32 rounded-full blur-[40px] opacity-40 group-hover:opacity-70 transition-opacity duration-500 ${bgClass}`} />
      
      <div className="flex items-center justify-between relative z-10 mb-2">
        <div className={`p-3.5 rounded-2xl shadow-sm border border-white/80 backdrop-blur-md ${bgClass} transition-transform group-hover:scale-110 duration-500`}>
          <Icon className={`w-7 h-7 ${colorClass}`} />
        </div>
      </div>
      
      <div className="relative z-10 mt-4">
        <h3 className="text-4xl font-display font-black text-slate-900 tracking-tight drop-shadow-sm mb-1">{value}</h3>
        <p className="text-[13px] font-bold text-slate-500 tracking-widest uppercase">{title}</p>
      </div>

      {subtitle && (
        <div className="mt-4 text-sm text-slate-500 font-medium relative z-10">
          {subtitle}
        </div>
      )}
      <div className={`absolute inset-0 bg-gradient-to-br from-white/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity rounded-[2rem] border-2 border-transparent ${hoverStroke} pointer-events-none`} />
    </div>
  );
};

export default StatCard;
