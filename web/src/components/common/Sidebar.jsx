import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, FileSpreadsheet, ListChecks, Users, LayoutList } from 'lucide-react';

const Sidebar = () => {
  const location = useLocation();

  const menuItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Surveys', path: '/surveys', icon: FileSpreadsheet },
    { name: 'Responses', path: '/responses', icon: ListChecks },
    { name: 'Volunteers', path: '/volunteers', icon: Users },
    { name: 'Tasks', path: '/tasks', icon: LayoutList },
  ];

  return (
    <div className="flex flex-col w-72 bg-white/60 backdrop-blur-3xl border-r border-white shadow-xl pb-6 relative z-10">
      <div className="flex items-center justify-center py-8 border-b border-white/50">
        <span className="text-2xl font-display font-black text-transparent bg-clip-text bg-gradient-to-r from-primary-600 to-indigo-600 truncate drop-shadow-sm px-4">CommunityBridge</span>
      </div>
      <div className="overflow-y-auto overflow-x-hidden flex-grow px-5 mt-8 space-y-3">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path));
          return (
            <Link
              key={item.name}
              to={item.path}
              className={`flex items-center space-x-4 w-full p-3.5 rounded-2xl transition-all duration-300 ${
                isActive
                  ? 'bg-gradient-to-r from-primary-600 to-primary-500 text-white shadow-md border-t border-white/20 hover:-translate-y-0.5'
                  : 'text-slate-500 hover:bg-white hover:text-slate-900 border border-transparent hover:border-slate-100 hover:shadow-sm'
              }`}
            >
              <Icon className="w-5 h-5 flex-shrink-0" />
              <span className="font-bold tracking-wide text-sm">{item.name}</span>
            </Link>
          );
        })}
      </div>
      <div className="px-4 mt-auto">
         <div className="text-xs font-medium text-center text-slate-400">© 2026 NGO Platform</div>
      </div>
    </div>
  );
};

export default Sidebar;
