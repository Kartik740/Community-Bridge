import React from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { LogOut, User, Menu } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const Navbar = ({ toggleSidebar }) => {
  const { userProfile, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = async () => {
    try {
      await logout();
      navigate('/login');
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <header className="bg-white/80 backdrop-blur-xl border-b border-white shadow-sm px-4 sm:px-8 py-4 sm:py-5 flex items-center justify-between sticky top-0 z-30">
      <div className="flex items-center">
        <button 
           className="mr-3 sm:mr-4 p-2 text-slate-500 hover:bg-slate-100 rounded-xl lg:hidden transition-colors"
           onClick={toggleSidebar}
           title="Toggle Menu"
        >
          <Menu className="w-5 h-5 sm:w-6 sm:h-6" />
        </button>
        <h2 className="text-xl font-display font-bold text-slate-800 tracking-tight hidden sm:block">
          Workspace
        </h2>
        <img src="/logo.jpeg" alt="CommunityBridge Logo" className="w-8 h-8 rounded-lg sm:hidden shadow-sm object-cover" />
      </div>
      <div className="flex items-center space-x-3 sm:space-x-6">
        <div className="flex items-center space-x-2 sm:space-x-3 text-slate-700 bg-white px-3 sm:px-4 py-1.5 sm:py-2 rounded-xl border border-slate-100 shadow-sm">
          <User className="w-4 h-4 sm:w-5 sm:h-5 text-primary-500" />
          <span className="text-xs sm:text-sm font-bold tracking-wide truncate max-w-[100px] sm:max-w-none">{userProfile?.name || 'NGO User'}</span>
        </div>
        <button
          onClick={handleLogout}
          className="p-2 sm:p-2.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all duration-300"
          title="Logout"
        >
          <LogOut className="w-4 h-4 sm:w-5 sm:h-5" />
        </button>
      </div>
    </header>
  );
};

export default Navbar;
