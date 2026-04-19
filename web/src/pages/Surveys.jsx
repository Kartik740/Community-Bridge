import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../services/firebase';
import { Link } from 'react-router-dom';
import { Plus, CheckCircle, FileText, Trash2 } from 'lucide-react';
import LoadingSpinner from '../components/common/LoadingSpinner';
import toast, { Toaster } from 'react-hot-toast';

const Surveys = () => {
  const { userProfile } = useAuth();
  const [surveys, setSurveys] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchSurveys = async () => {
      try {
        const q = query(collection(db, 'surveys'), where('orgId', '==', userProfile.id));
        const snap = await getDocs(q);
        setSurveys(snap.docs.map(doc => ({ id: doc.id, ...doc.data() })));
      } catch (err) {
        console.error(err);
      } finally {
        setLoading(false);
      }
    };
    if (userProfile?.id) fetchSurveys();
  }, [userProfile]);

  const handleDelete = async (e, survey) => {
    e.preventDefault();
    e.stopPropagation();
    if (!window.confirm(`Are you sure you want to completely delete "${survey.title}"? This will permanently erase the survey, ALL of its responses, and associated tasks. This action cannot be undone.`)) return;
    
    try {
      const response = await fetch(`${import.meta.env.VITE_BACKEND_URL}/api/surveys/delete`, {
         method: 'POST',
         headers: { 'Content-Type': 'application/json' },
         body: JSON.stringify({ surveyId: survey.id, orgId: userProfile.id })
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error);

      setSurveys(surveys.filter(s => s.id !== survey.id));
      toast.success('Survey successfully deleted.');
    } catch (err) {
      console.error(err);
      toast.error('Failed to delete survey.');
    }
  };

  if (loading) return <LoadingSpinner message="Loading surveys..." />;

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
        <div>
           <h1 className="text-2xl font-black text-gray-900">Surveys</h1>
           <p className="text-gray-500">Manage your data collection forms</p>
        </div>
        <Link 
          to="/surveys/build"
          className="bg-primary-600 hover:bg-primary-700 text-white px-5 py-2.5 rounded-xl font-bold flex items-center shadow-sm transition-all"
        >
          <Plus className="w-5 h-5 mr-2" />
          Create New Survey
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {surveys.length === 0 ? (
           <div className="col-span-full">
             <div className="text-center py-12 glass rounded-2xl">
                <FileText className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                <h3 className="text-lg font-bold">No Surveys Found</h3>
                <p className="text-gray-500 max-w-sm mx-auto mt-2">Start collecting data from volunteers by creating your first survey.</p>
             </div>
           </div>
        ) : (
          surveys.map(survey => (
            <div key={survey.id} className="bg-white rounded-3xl p-6 border border-gray-100/80 shadow-[0_4px_20px_-4px_rgba(0,0,0,0.05)] hover:shadow-[0_12px_36px_-6px_rgba(0,0,0,0.1)] hover:-translate-y-1 transition-all duration-300 cursor-pointer flex flex-col group relative overflow-hidden backdrop-blur-xl">
               {/* Top accent line */}
              <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-primary-400 to-indigo-500 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              
              <div className="flex justify-between items-start mb-5">
                 <div className="bg-primary-50/50 group-hover:bg-primary-50 text-primary-700 font-mono px-3.5 py-1.5 rounded-xl text-[11px] font-bold tracking-widest uppercase shadow-sm border border-primary-100/50 transition-colors">
                   {survey.surveyCode}
                 </div>
                 <div className="flex space-x-2">
                   {survey.isActive && (
                     <div className="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-500 border border-emerald-100 shadow-sm">
                        <CheckCircle className="w-4 h-4" />
                     </div>
                   )}
                   <button 
                     onClick={(e) => handleDelete(e, survey)}
                     className="w-8 h-8 rounded-full bg-red-50 flex items-center justify-center text-red-500 border border-red-100 shadow-sm hover:bg-red-500 hover:text-white transition-colors"
                     title="Delete Survey"
                   >
                     <Trash2 className="w-4 h-4" />
                   </button>
                 </div>
              </div>
              
              <h3 className="font-bold text-xl text-gray-900 mb-3 group-hover:text-primary-600 transition-colors leading-tight">{survey.title}</h3>
              <p className="text-sm text-gray-500 mb-6 line-clamp-2 leading-relaxed flex-grow">{survey.description}</p>
              
              <div className="mt-auto pt-4 border-t border-gray-100/80 flex justify-between items-center text-sm font-medium">
                 <div className="flex items-center text-gray-500">
                    <FileText className="w-4 h-4 mr-2 text-gray-400 group-hover:text-primary-500 transition-colors" />
                    <span>{survey.fields?.length || 0} Fields Configured</span>
                 </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Surveys;
