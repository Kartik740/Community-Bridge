import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, FileSpreadsheet, ListChecks, Users, LayoutList, X } from 'lucide-react';

const Sidebar = ({ isOpen, setIsOpen }) => {
  const location = useLocation();

  const menuItems = [
    { name: 'Dashboard', path: '/', icon: LayoutDashboard },
    { name: 'Surveys', path: '/surveys', icon: FileSpreadsheet },
    { name: 'Responses', path: '/responses', icon: ListChecks },
    { name: 'Volunteers', path: '/volunteers', icon: Users },
    { name: 'Tasks', path: '/tasks', icon: LayoutList },
  ];

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/50 z-40 lg:hidden transition-opacity backdrop-blur-sm"
          onClick={() => setIsOpen(false)}
        />
      )}
      
      <div className={`fixed lg:static inset-y-0 left-0 w-72 bg-white/95 lg:bg-white/60 backdrop-blur-3xl border-r border-white shadow-2xl lg:shadow-xl pb-6 flex flex-col z-50 transform ${isOpen ? 'translate-x-0' : '-translate-x-full'} lg:translate-x-0 transition-transform duration-300 ease-in-out`}>
        <div className="flex items-center justify-between py-6 lg:py-8 border-b border-white/50 px-4 relative">
          <span className="text-2xl font-display font-black text-transparent bg-clip-text bg-gradient-to-r from-primary-600 to-indigo-600 truncate drop-shadow-sm mx-auto">CommunityBridge</span>
          <button 
             className="lg:hidden absolute right-4 p-2 text-slate-500 hover:bg-slate-100 rounded-xl"
             onClick={() => setIsOpen(false)}
             title="Close Menu"
          >
             <X className="w-5 h-5" />
          </button>
        </div>
        <div className="overflow-y-auto overflow-x-hidden flex-grow px-5 mt-8 space-y-3">
        {menuItems.map((item) => {
          const Icon = item.icon;
          const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path));
          return (
            <Link
              key={item.name}
              to={item.path}
              onClick={() => setIsOpen(false)}
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
    </>
  );
};

export default Sidebar;
