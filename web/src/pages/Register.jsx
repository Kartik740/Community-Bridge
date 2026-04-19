import React, { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { Link, useNavigate } from 'react-router-dom';

const Register = () => {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    orgName: '',
    email: '',
    location: '',
    password: '',
    confirmPassword: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  async function handleSubmit(e) {
    e.preventDefault();
    if(formData.password !== formData.confirmPassword){
        return setError('Passwords do not match');
    }
    try {
      setError('');
      setLoading(true);
      await register(formData.email, formData.password, formData.orgName, formData.location);
      navigate('/');
    } catch (err) {
      setError('Failed to register: ' + err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="flex h-screen w-full bg-slate-900 overflow-hidden font-sans">
      <div className="hidden lg:flex flex-1 relative items-center justify-center overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-b from-slate-900/80 to-transparent z-10 mix-blend-multiply" />
        <img src="/assets/auth_bg.png" alt="Background" className="absolute w-full h-full object-cover animate-fade-in opacity-70" />
        <div className="relative z-20 text-white max-w-lg px-12 animate-fade-in-up">
           <h1 className="text-6xl font-display font-black mb-6 leading-tight tracking-tight text-white">Scale Your <br/><span className="text-primary-400">Impact.</span></h1>
           <p className="text-xl text-slate-300 font-medium leading-relaxed">Join the centralized platform that routes intelligent tasks to your volunteers seamlessly.</p>
        </div>
      </div>
      
      <div className="flex-1 flex flex-col items-center justify-center p-8 bg-slate-50 relative overflow-y-auto">
         <div className="glass-panel p-10 w-full max-w-md rounded-3xl z-10 shadow-2xl animate-fade-in-up my-auto">
           <div className="text-center mb-8">
             <h1 className="text-3xl font-display font-black text-slate-900 tracking-tight">Create Workspace</h1>
             <p className="text-slate-500 mt-2 font-medium">Setup your NGO command center</p>
           </div>
           {error && <div className="bg-red-50 text-red-600 p-3 rounded-xl text-sm mb-6 border border-red-100 font-medium">{error}</div>}
           <form onSubmit={handleSubmit} className="space-y-4">
             <div>
               <label className="block text-sm font-bold text-slate-700 mb-1.5">Organization Name</label>
               <input type="text" name="orgName" required value={formData.orgName} onChange={handleChange} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm" placeholder="Helping Hands NGO" />
             </div>
             <div>
               <label className="block text-sm font-bold text-slate-700 mb-1.5">Headquarters Location</label>
               <input type="text" name="location" required value={formData.location} onChange={handleChange} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm" placeholder="Bhopal, MP" />
             </div>
             <div>
               <label className="block text-sm font-bold text-slate-700 mb-1.5">Email (Admin)</label>
               <input type="email" name="email" required value={formData.email} onChange={handleChange} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm" placeholder="admin@ngo.org" />
             </div>
             <div className="grid grid-cols-2 gap-4">
               <div>
                 <label className="block text-sm font-bold text-slate-700 mb-1.5">Password</label>
                 <input type="password" name="password" required value={formData.password} onChange={handleChange} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm" placeholder="••••••••" />
               </div>
               <div>
                 <label className="block text-sm font-bold text-slate-700 mb-1.5">Confirm</label>
                 <input type="password" name="confirmPassword" required value={formData.confirmPassword} onChange={handleChange} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:ring-4 focus:ring-primary-500/20 focus:border-primary-500 transition-all outline-none font-medium text-slate-800 shadow-sm" placeholder="••••••••" />
               </div>
             </div>
             <button type="submit" disabled={loading} className="btn-premium w-full py-3.5 mt-6">
               {loading ? 'Creating...' : 'Register Workspace'}
             </button>
           </form>
           <div className="mt-8 text-center text-sm text-slate-500 font-medium">
              Already registered? <Link to="/login" className="text-primary-600 font-bold hover:underline ml-1">Sign In</Link>
           </div>
         </div>
      </div>
    </div>
  );
};

export default Register;
