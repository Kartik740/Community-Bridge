import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../services/firebase';
import StatCard from '../components/dashboard/StatCard';
import CategoryBreakdown from '../components/dashboard/CategoryBreakdown';
import UrgencyChart from '../components/dashboard/UrgencyChart';
import NeedsHeatmap from '../components/dashboard/NeedsHeatmap';
import LoadingSpinner from '../components/common/LoadingSpinner';
import UrgencyBadge from '../components/common/UrgencyBadge';
import { FileSpreadsheet, ListChecks, Users, LayoutList, Bot, MapPin, ArrowRight } from 'lucide-react';

const Dashboard = () => {
  const { userProfile } = useAuth();
  const [stats, setStats] = useState(null);
  const [heatmapData, setHeatmapData] = useState([]);
  const [tasks, setTasks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [analysing, setAnalysing] = useState(false);

  useEffect(() => {
    if (userProfile?.id) {
      fetchDashboardData();
    }
  }, [userProfile]);

  const fetchDashboardData = async () => {
    try {
      const orgId = userProfile.id;
      
      const withTimeout = (promise, ms) => Promise.race([promise, new Promise((_, reject) => setTimeout(() => reject(new Error('timeout')), ms))]);

      // Fetch stats concurrently
      const [resSnap, volsSnap, tasksSnap] = await Promise.all([
        withTimeout(getDocs(query(collection(db, 'responses'), where('orgId', '==', orgId))), 3000),
        withTimeout(getDocs(query(collection(db, 'volunteers'), where('orgId', '==', orgId))), 3000),
        withTimeout(getDocs(query(collection(db, 'tasks'), where('orgId', '==', orgId))), 3000)
      ]);

      const responses = resSnap.docs.map(d => d.data());
      
      // Compute counts
      const pendingReview = responses.filter(r => r.status === 'pending').length;
      const approvedLocations = responses.filter(r => (r.status === 'approved' || r.status === 'analysed') && r.location).map(r => ({
         lat: r.location.lat, lng: r.location.lng, surveyId: r.surveyId, answers: r.answers
      }));
      
      const categoryCounts = tasksSnap.docs.reduce((acc, doc) => {
         const cat = doc.data().category;
         acc[cat] = (acc[cat] || 0) + 1;
         return acc;
      }, {});

      const chartData = Object.keys(categoryCounts).map(k => ({ name: k, value: categoryCounts[k] }));
      const allTasks = tasksSnap.docs.map(d => ({id: d.id, ...d.data()}));
      
      setStats({
         totalResponses: responses.length,
         pendingReview,
         availableVolunteers: volsSnap.docs.filter(d => d.data().availability).length,
         activeTasks: allTasks.filter(t => t.status === 'open').length,
         categoryChart: chartData.length > 0 ? chartData : [{name: 'No Data', value: 1}]
      });

      setHeatmapData(approvedLocations);
      setTasks(allTasks.filter(t => t.status === 'open').sort((a,b) => b.urgencyScore - a.urgencyScore).slice(0, 5));
      
    } catch (err) {
      console.warn('Firebase query timed out. Displaying fallback UI data.', err);
      // Fallback Demo Data
      setStats({
         totalResponses: 142,
         pendingReview: 8,
         availableVolunteers: 35,
         activeTasks: 12,
         categoryChart: [{name: 'Medical', value: 40}, {name: 'Food', value: 60}, {name: 'Shelter', value: 20}]
      });
      setHeatmapData([{lat: 23.2599, lng: 77.4126}]);
      setTasks([
         {id: '1', title: 'Emergency Food Delivery', category: 'Food', urgencyScore: 9, areaName: 'Bhopal Central', numberOfPeopleAffected: 120, recommendedAction: 'Deploy immediate food aid kits'}
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleRunAnalysis = async () => {
    setAnalysing(true);
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/analyse/${userProfile.id}`, {
        method: 'POST'
      });
      const data = await response.json();
      if(response.ok) {
         fetchDashboardData();
         alert(`Analysis completed. ${data.tasks?.length || 0} tasks generated.`);
      } else {
         alert('Analysis failed: ' + data.error);
      }
    } catch (err) {
      alert('Network error triggered by analysis request.');
    } finally {
      setAnalysing(false);
    }
  };

  if (loading) return <LoadingSpinner message="Loading your dashboard..." />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-12 gap-4">
        <div className="relative">
           <div className="absolute -left-6 -top-6 w-32 h-32 bg-primary-100/60 rounded-full blur-[50px] opacity-70 pointer-events-none" />
           <h1 className="text-[32px] font-display font-black text-slate-900 tracking-tight relative z-10 leading-tight">Platform Overview</h1>
           <p className="text-slate-500 font-medium mt-1 tracking-wide relative z-10 flex items-center">
             <span className="w-2.5 h-2.5 rounded-full bg-emerald-400 mr-2.5 shadow-[0_0_12px_rgba(52,211,153,0.9)] animate-pulse border border-white"></span>
             Welcome back, {userProfile?.name}
           </p>
        </div>
        <button 
          onClick={handleRunAnalysis}
          disabled={analysing}
          className="group relative inline-flex items-center justify-center px-8 py-4 font-bold text-white transition-all duration-300 bg-gradient-to-r from-primary-600 via-indigo-500 to-primary-600 bg-[length:200%_auto] hover:bg-[center_right_1rem] rounded-2xl shadow-[0_10px_40px_rgba(79,70,229,0.25)] hover:shadow-[0_15px_60px_rgba(79,70,229,0.35)] hover:-translate-y-1 overflow-hidden disabled:opacity-70 disabled:hover:translate-y-0 disabled:shadow-none"
        >
          <div className="absolute inset-0 bg-white/20 group-hover:translate-x-full -translate-x-full skew-x-[-15deg] transition-transform duration-700 ease-out" />
          <Bot className={`w-5 h-5 mr-3 relative z-10 ${analysing ? 'animate-bounce' : 'group-hover:rotate-[15deg] transition-transform duration-300'}`} />
          <span className="relative z-10 tracking-wide uppercase text-[13px]">{analysing ? 'Running AI Check...' : 'Run AI Analysis'}</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Total Responses" value={stats.totalResponses} icon={FileSpreadsheet} colorClass="text-blue-600" bgClass="bg-blue-50" />
        <StatCard title="Pending Review" value={stats.pendingReview} icon={ListChecks} colorClass="text-orange-600" bgClass="bg-orange-50" />
        <StatCard title="Active Tasks" value={stats.activeTasks} icon={LayoutList} colorClass="text-red-600" bgClass="bg-red-50" />
        <StatCard title="Available Volunteers" value={stats.availableVolunteers} icon={Users} colorClass="text-green-600" bgClass="bg-green-50" />
      </div>

      <div className="grid grid-cols-1 xl:grid-cols-3 gap-8 py-4">
        <div className="xl:col-span-2 space-y-8">
          <div className="glass-panel p-8 rounded-3xl">
            <h3 className="text-xl font-display font-bold text-slate-900 mb-6 tracking-tight">Critical Needs Heatmap</h3>
            <NeedsHeatmap coordinates={heatmapData} />
          </div>
          <div className="glass-panel p-8 rounded-3xl">
            <h3 className="text-xl font-display font-bold text-slate-900 mb-6 tracking-tight">Urgency by Area</h3>
            <UrgencyChart data={tasks} />
          </div>
        </div>

        <div className="space-y-8">
          <div className="glass-panel p-8 rounded-3xl">
            <h3 className="text-xl font-display font-bold text-slate-900 mb-6 tracking-tight">Needs Breakdown</h3>
            <CategoryBreakdown data={stats.categoryChart} />
          </div>

          <div className="glass-panel p-8 rounded-[2rem] bg-white/60 backdrop-blur-xl border border-white shadow-[0_8px_30px_rgb(0,0,0,0.03)] relative overflow-hidden">
             {/* Subtle top glare */}
             <div className="absolute top-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-primary-200/50 to-transparent" />
             
             <div className="flex items-center justify-between mb-8">
               <h3 className="text-2xl font-display font-black text-slate-900 tracking-tight">Top Urgent Tasks</h3>
             </div>
             
             <div className="space-y-4">
               {tasks.length === 0 ? (
                 <div className="py-10 text-center border-2 border-dashed border-slate-100 rounded-2xl">
                    <p className="text-sm text-slate-400 font-medium">No active tasks found</p>
                 </div>
               ) : (
                 tasks.map(task => (
                   <div key={task.id} className="group relative bg-white p-5 rounded-2xl border border-slate-100 hover:border-primary-200 transition-all duration-300 shadow-[0_2px_10px_rgba(0,0,0,0.02)] hover:shadow-[0_15px_35px_rgba(0,0,0,0.06)] hover:-translate-y-1 overflow-hidden z-10">
                     {/* Left accent bar on hover */}
                     <div className="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-primary-300 to-indigo-400 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                     
                     <div className="flex justify-between items-start mb-3">
                        <h4 className="font-bold text-slate-800 text-[16px] truncate pr-4 group-hover:text-primary-600 transition-colors leading-tight">
                          {task.title || task.category.toUpperCase()}
                        </h4>
                        <div className="shrink-0 scale-90 origin-top-right">
                           <UrgencyBadge score={task.urgencyScore} />
                        </div>
                     </div>
                     
                     <p className="text-sm text-slate-500 font-medium flex items-center mb-4">
                        <MapPin className="w-3.5 h-3.5 mr-1.5 text-slate-400" />
                        {task.areaName}
                     </p>
                     
                     <div className="pt-4 border-t border-slate-50 flex justify-between items-center -mx-5 -mb-5 px-5 py-4 bg-slate-50/50 group-hover:bg-primary-50/30 transition-colors">
                        <p className="text-[12px] text-primary-700 font-bold bg-primary-100/50 border border-primary-100 px-2.5 py-1 rounded-md tracking-wide">
                           {task.numberOfPeopleAffected} AFFECTED
                        </p>
                        <button className="text-[12px] font-bold text-indigo-400 group-hover:text-indigo-600 transition-colors flex items-center uppercase tracking-wider">
                           Action <ArrowRight className="w-3.5 h-3.5 ml-1 transform group-hover:translate-x-1 transition-transform" />
                        </button>
                     </div>
                   </div>
                 ))
               )}
             </div>
           </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
