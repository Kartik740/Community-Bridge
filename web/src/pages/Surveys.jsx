import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs } from 'firebase/firestore';
import { db } from '../services/firebase';
import { Link } from 'react-router-dom';
import { Plus, CheckCircle, FileText } from 'lucide-react';
import LoadingSpinner from '../components/common/LoadingSpinner';

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

  if (loading) return <LoadingSpinner message="Loading surveys..." />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center mb-6">
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
            <div key={survey.id} className="glass p-6 rounded-2xl hover:border-primary-300 transition-colors cursor-pointer block">
              <div className="flex justify-between items-start mb-4">
                 <div className="bg-primary-50 text-primary-700 font-mono px-3 py-1 rounded-lg font-bold tracking-wider">
                   {survey.surveyCode}
                 </div>
                 {survey.isActive && <CheckCircle className="w-5 h-5 text-green-500" />}
              </div>
              <h3 className="font-bold text-lg text-gray-900 mb-2">{survey.title}</h3>
              <p className="text-sm text-gray-500 mb-4 line-clamp-2">{survey.description}</p>
              <div className="pt-4 border-t flex justify-between text-sm text-gray-500 font-medium">
                 <span>{survey.fields?.length || 0} fields</span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

export default Surveys;
