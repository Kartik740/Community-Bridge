import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Link, useNavigate } from 'react-router-dom';

const Login = () => {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    try {
      setError('');
      setLoading(true);
      await login(email, password);
      navigate('/');
    } catch (err) {
      setError('Failed to log in: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex h-screen w-full bg-slate-900 overflow-hidden font-sans">
      <div className="hidden lg:flex flex-1 relative items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-t from-slate-900/80 to-transparent z-10 mix-blend-multiply" />
        <img src="/assets/auth_bg.png" alt="Background" className="absolute w-full h-full object-cover animate-fade-in opacity-70" />
        <div className="relative z-20 text-white max-w-lg px-12 animate-fade-in-up">
           <h1 className="text-6xl font-display font-black mb-6 leading-tight tracking-tight text-white">Connect.<br/>Predict.<br/><span className="text-primary-400">Respond.</span></h1>
           <p className="text-xl text-slate-300 font-medium leading-relaxed">The intelligent operating system for modern NGOs to orchestrate field operations and predict urgent community needs via Gemini AI.</p>
        </div>
      </div>
      
      <div className="flex-1 flex flex-col items-center justify-center p-8 bg-slate-50 relative">
         <div className="glass-panel p-10 w-full max-w-md rounded-3xl z-10 shadow-2xl animate-fade-in-up">
           <div className="text-center mb-10">
             <div className="flex items-center justify-center mb-6">
                <span className="text-2xl font-display font-black text-transparent bg-clip-text bg-gradient-to-r from-primary-600 to-indigo-600 drop-shadow-sm">CommunityBridge</span>
             </div>
             <h1 className="text-3xl font-display font-black text-slate-900 tracking-tight">Welcome Back</h1>
             <p className="text-slate-500 mt-2 font-medium">Sign in to your NGO dashboard</p>
           </div>
           {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm mb-6 border border-red-100 font-medium">{error}</div>}
           <form onSubmit={handleSubmit} className="space-y-5">
             <div>
               <label className="block text-sm font-bold text-slate-700 mb-1.5">Email</label>
               <input 
                 type="email" 
                 required 
                 value={email}
                 onChange={(e) => setEmail(e.target.value)}
                 className="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm"
                 placeholder="name@ngo.org"
               />
             </div>
             <div>
               <label className="block text-sm font-bold text-slate-700 mb-1.5">Password</label>
               <input 
                 type="password" 
                 required 
                 value={password}
                 onChange={(e) => setPassword(e.target.value)}
                 className="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm"
                 placeholder="••••••••"
               />
             </div>
             <button 
               type="submit" 
               disabled={loading}
               className="btn-premium w-full py-3.5 mt-4"
             >
               {loading ? 'Signing in...' : 'Sign In'}
             </button>
           </form>
           <div className="mt-8 text-center text-sm text-slate-500 font-medium">
              Need an account? <Link to="/register" className="text-primary-600 font-bold hover:underline ml-1">Register Workspace</Link>
           </div>
         </div>
      </div>
    </div>
  );
};

export default Login;
