import React, { useEffect, useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { collection, query, where, getDocs, doc, updateDoc } from 'firebase/firestore';
import { db } from '../services/firebase';
import LoadingSpinner from '../components/common/LoadingSpinner';
import { MapPin, Phone, Mail, Award, CheckCircle, XCircle } from 'lucide-react';

const Volunteers = () => {
  const { userProfile } = useAuth();
  const [volunteers, setVolunteers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchVolunteers();
  }, [userProfile]);

  const fetchVolunteers = async () => {
    if (!userProfile?.id) return;
    try {
      const q = query(collection(db, 'volunteers'), where('orgId', '==', userProfile.id));
      const snap = await getDocs(q);
      setVolunteers(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const toggleAvailability = async (id, currentStatus) => {
    try {
      await updateDoc(doc(db, 'volunteers', id), { availability: !currentStatus });
      setVolunteers(volunteers.map(v => v.id === id ? { ...v, availability: !currentStatus } : v));
    } catch (err) {
      alert("Failed to update status");
    }
  };

  if (loading) return <LoadingSpinner message="Loading volunteers directory..." />;

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center mb-6">
        <div>
           <h1 className="text-2xl font-black text-gray-900">Volunteers</h1>
           <p className="text-gray-500">Manage your deployed field workers</p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
         {volunteers.map(vol => (
            <div key={vol.id} className="glass p-6 rounded-2xl transition-all border-t-4 border-t-primary-500">
               <div className="flex justify-between items-start mb-4">
                  <h3 className="text-xl font-bold text-gray-900">{vol.name}</h3>
                  <button 
                    onClick={() => toggleAvailability(vol.id, vol.availability)}
                    title="Toggle Availability"
                    className={`flex items-center text-xs font-bold px-2 py-1 rounded-full border ${
                       vol.availability ? 'bg-green-50 text-green-700 border-green-200' : 'bg-red-50 text-red-700 border-red-200'
                    }`}
                  >
                     {vol.availability ? <CheckCircle className="w-3 h-3 mr-1" /> : <XCircle className="w-3 h-3 mr-1" />}
                     {vol.availability ? 'Available' : 'Busy'}
                  </button>
               </div>
               
               <div className="space-y-3 mb-6 flex-grow text-sm">
                  <div className="flex items-center text-gray-600">
                     <Mail className="w-4 h-4 mr-3 text-gray-400" />
                     {vol.email}
                  </div>
                  <div className="flex items-center text-gray-600">
                     <Phone className="w-4 h-4 mr-3 text-gray-400" />
                     {vol.phone}
                  </div>
                  <div className="flex items-center text-gray-600">
                     <MapPin className="w-4 h-4 mr-3 text-gray-400" />
                     Last Ping: {vol.location?.lat.toFixed(4)}, {vol.location?.lng.toFixed(4)}
                  </div>
               </div>
               
               <div className="mt-auto border-t pt-4">
                  <p className="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2 flex items-center">
                     <Award className="w-4 h-4 mr-1" />
                     Registered Skills
                  </p>
                  <div className="flex flex-wrap gap-2">
                     {vol.skills?.map(skill => (
                        <span key={skill} className="bg-primary-50 text-primary-600 text-xs font-semibold px-2.5 py-1 rounded-md border border-primary-100 capitalize">
                           {skill}
                        </span>
                     ))}
                  </div>
               </div>
            </div>
         ))}
      </div>
    </div>
  );
};

export default Volunteers;
