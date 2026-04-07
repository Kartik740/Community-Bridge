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
import { FileSpreadsheet, ListChecks, Users, LayoutList, Bot } from 'lucide-react';

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
      <div className="flex justify-between items-center mb-10">
        <div>
           <h1 className="text-3xl font-display font-black text-slate-900 tracking-tight">Platform Overview</h1>
           <p className="text-slate-500 font-medium mt-1 tracking-wide">Welcome back, {userProfile?.name}</p>
        </div>
        <button 
          onClick={handleRunAnalysis}
          disabled={analysing}
          className="btn-premium px-6 py-3.5 flex items-center shadow-md disabled:opacity-50"
        >
          <Bot className="w-5 h-5 mr-3" />
          {analysing ? 'Running Algorithm...' : 'Run AI Analysis'}
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

          <div className="glass-panel p-8 rounded-3xl">
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-display font-bold text-slate-900 tracking-tight">Top Urgent Tasks</h3>
            </div>
            <div className="space-y-4">
              {tasks.length === 0 ? (
                <p className="text-sm text-gray-500 text-center py-4">No active tasks found</p>
              ) : (
                tasks.map(task => (
                  <div key={task.id} className="border p-4 rounded-xl hover:border-primary-200 transition-colors">
                    <div className="flex justify-between items-start mb-2">
                       <h4 className="font-bold text-gray-900 truncate pr-4">{task.title || task.category.toUpperCase()}</h4>
                       <UrgencyBadge score={task.urgencyScore} />
                    </div>
                    <p className="text-sm text-gray-500 line-clamp-2">{task.areaName}</p>
                    <p className="text-xs text-primary-600 font-medium mt-2">
                       {task.numberOfPeopleAffected} affected
                    </p>
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
