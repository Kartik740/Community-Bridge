import React from 'react';
import { useAuth } from '../../contexts/AuthContext';
import { LogOut, User } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const Navbar = () => {
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
    <header className="bg-white/80 backdrop-blur-xl border-b border-white shadow-sm px-8 py-5 flex items-center justify-between sticky top-0 z-50">
      <h2 className="text-xl font-display font-bold text-slate-800 tracking-tight">
        Workspace
      </h2>
      <div className="flex items-center space-x-6">
        <div className="flex items-center space-x-3 text-slate-700 bg-white px-4 py-2 rounded-xl border border-slate-100 shadow-sm">
          <User className="w-5 h-5 text-primary-500" />
          <span className="text-sm font-bold tracking-wide">{userProfile?.name || 'NGO User'}</span>
        </div>
        <button
          onClick={handleLogout}
          className="p-2.5 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-xl transition-all duration-300"
          title="Logout"
        >
          <LogOut className="w-5 h-5" />
        </button>
      </div>
    </header>
  );
};

export default Navbar;
